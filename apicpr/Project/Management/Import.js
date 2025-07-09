const express = require('express')
const cors = require('cors')
const Database = require('../Server')
const os = require('os')

const app = express()
app.use(express.json())
app.use(cors())

const connection = new Database()
const db = connection.getConnection()

// Helper function to promisify database queries
function queryAsync(sql, params) {
    return new Promise((resolve, reject) => {
        db.query(sql, params, (err, result) => {
            if (err) reject(err);
            else resolve(result);
        });
    });
}

// Helper function to validate required fields
function validateRequired(fields, data) {
    const missing = [];
    for (const field of fields) {
        if (!data[field] || data[field] === '') {
            missing.push(field);
        }
    }
    return missing;
}

// Helper function to validate numeric fields
function validateNumeric(value, fieldName, min = null, max = null) {
    const num = parseFloat(value);
    if (isNaN(num)) {
        return `${fieldName} must be a valid number`;
    }
    if (min !== null && num < min) {
        return `${fieldName} must be at least ${min}`;
    }
    if (max !== null && num > max) {
        return `${fieldName} must not exceed ${max}`;
    }
    return null;
}

// Update import status with selective item confirmation
app.put("/import/:id/update-status", async (req, res) => {
    try {
        const importID = req.params.id;
        const { status, checkedItems, reason } = req.body;
        const clientInfo = req.clientInfo || { hostname: 'Unknown Computer', serverHostname: os.hostname() };
        const checkQuery = 'SELECT Status FROM tbimport WHERE ImportID = ?';
        const existingImport = await queryAsync(checkQuery, [importID]);
        
        if (existingImport.length === 0) {
            return res.status(404).json({ msg: 'Import not found' });
        }
        
        if (existingImport[0].Status === 'Completed') {
            return res.status(400).json({ 
                msg: 'Import is already completed and cannot be confirmed again',
                alreadyCompleted: true 
            });
        }
        
        // Validate required fields
        if (!status) {
            return res.status(400).json({ 
                msg: "Status is required",
                clientInfo 
            });
        }
        
        // Check if import exists and current status
        const checkSql = "SELECT Status FROM tbimport WHERE ImportID = ?";
        const existing = await queryAsync(checkSql, [importID]);
        
        if (existing.length === 0) {
            return res.status(404).json({ 
                msg: "Import record not found",
                clientInfo 
            });
        }
        
        const currentStatus = existing[0].Status;
        
        // Validate status transition
        if (currentStatus === 'Completed' && status !== 'Completed') {
            return res.status(400).json({ 
                msg: "Cannot change status of completed import",
                clientInfo 
            });
        }
        
        // Start transaction
        await queryAsync("START TRANSACTION");
        
        try {
            if (status === 'Completed' && checkedItems && checkedItems.length > 0) {
                // Update only checked items and their product quantities
                for (const item of checkedItems) {
                    const { ImportDetailID, ReceivedQuantity } = item;
                    
                    // Validate received quantity
                    const qtyError = validateNumeric(ReceivedQuantity, 'ReceivedQuantity', 1);
                    if (qtyError) {
                        await queryAsync("ROLLBACK");
                        return res.status(400).json({ msg: qtyError, clientInfo });
                    }
                    
                    // Get import detail info
                    const detailSql = `SELECT id.*, p.ProductName 
                                      FROM tbimportdetail id 
                                      JOIN tbproduct p ON id.ProductID = p.ProductID 
                                      WHERE id.ImportDetailID = ? AND id.ImportID = ?`;
                    const detailResult = await queryAsync(detailSql, [ImportDetailID, importID]);
                    
                    if (detailResult.length === 0) {
                        await queryAsync("ROLLBACK");
                        return res.status(404).json({ 
                            msg: `Import detail ${ImportDetailID} not found`,
                            clientInfo 
                        });
                    }
                    
                    const detail = detailResult[0];
                    const actualQuantity = parseInt(ReceivedQuantity);
                    
                    // Update product quantity and balance
                    const updateProductSql = `UPDATE tbproduct 
                                             SET Quantity = Quantity + ?, 
                                                 Balance = Balance + ? 
                                             WHERE ProductID = ?`;
                    await queryAsync(updateProductSql, [
                        actualQuantity, 
                        actualQuantity, 
                        detail.ProductID
                    ]);
                    
                    // Update import detail with actual received quantity
                    const updateDetailSql = `UPDATE tbimportdetail 
                                            SET ImportQuantity = ?,
                                                NewQuantity = PreviousQuantity + ?,
                                                TotalCost = ? * ImportPrice
                                            WHERE ImportDetailID = ?`;
                    await queryAsync(updateDetailSql, [
                        actualQuantity,
                        actualQuantity,
                        actualQuantity,
                        ImportDetailID
                    ]);
                }
                
                // Recalculate import totals
                const recalcSql = `UPDATE tbimport 
                                  SET TotalItems = (SELECT SUM(ImportQuantity) FROM tbimportdetail WHERE ImportID = ?),
                                      TotalCost = (SELECT SUM(TotalCost) FROM tbimportdetail WHERE ImportID = ?)
                                  WHERE ImportID = ?`;
                await queryAsync(recalcSql, [importID, importID, importID]);
            }
            
            // Update import status
            let updateSql = "UPDATE tbimport SET Status = ? WHERE ImportID = ?";
            let updateParams = [status, importID];
            
            if (status === 'Cancelled' && reason) {
                updateSql = "UPDATE tbimport SET Status = ?, Notes = CONCAT(COALESCE(Notes, ''), ' [CANCELLED: ', ?, ']') WHERE ImportID = ?";
                updateParams = [status, reason, importID];
            }
            
            await queryAsync(updateSql, updateParams);
            
            await queryAsync("COMMIT");
            
            return res.status(200).json({ 
                msg: `Import ${status.toLowerCase()} successfully`,
                updatedItems: checkedItems ? checkedItems.length : 0,
                clientInfo 
            });
            
        } catch (updateError) {
            await queryAsync("ROLLBACK");
            throw updateError;
        }
        
    } catch (err) {
        console.error(err);
        // Make sure to rollback if transaction was started
        try {
            await queryAsync("ROLLBACK");
        } catch (rollbackErr) {
            console.error("Rollback failed:", rollbackErr);
        }
        return res.status(500).json({ msg: "Database transaction failed: " + err.message });
    }
});

// ===================== IMPORT MANAGEMENT =====================

// Get all imports with supplier details
app.get("/import", async (req, res) => {
    try {
        const sql = `SELECT i.*, s.ContactPerson, s.Phone, s.Email 
                    FROM tbimport i 
                    LEFT JOIN tbsupplier s ON i.SupplierName = s.SupplierName 
                    ORDER BY i.CreatedDate DESC`;
        const result = await queryAsync(sql);
        return res.status(200).json(result);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: "Database connection error" });
    }
});

// Get import by ID with details
app.get("/import/:id", async (req, res) => {
    try {
        const importID = req.params.id;
        
        // Get import header
        const headerSql = `SELECT i.*, s.ContactPerson, s.Phone, s.Email 
                          FROM tbimport i 
                          LEFT JOIN tbsupplier s ON i.SupplierName = s.SupplierName 
                          WHERE i.ImportID = ?`;
        const header = await queryAsync(headerSql, [importID]);
        
        if (header.length === 0) {
            return res.status(404).json({ msg: "Import record not found" });
        }
        
        // Get import details
        const detailSql = `SELECT id.*, p.ProductName 
                          FROM tbimportdetail id 
                          JOIN tbproduct p ON id.ProductID = p.ProductID 
                          WHERE id.ImportID = ?`;
        const details = await queryAsync(detailSql, [importID]);
        
        return res.status(200).json({
            header: header[0],
            details: details
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: "Database connection error" });
    }
});

// Create new import
app.post("/import", async (req, res) => {
    try {
        const { 
            ImportDate, ImportTime, SupplierName, SupplierContact, 
            InvoiceNumber, Notes, CreatedBy, items 
        } = req.body;
        const clientInfo = req.clientInfo || { hostname: 'Unknown Computer', serverHostname: os.hostname() };
        
        // Validate required fields
        const requiredFields = ['ImportDate', 'ImportTime', 'SupplierName', 'CreatedBy', 'items'];
        const missingFields = validateRequired(requiredFields, req.body);
        
        if (missingFields.length > 0) {
            return res.status(400).json({ 
                msg: `Missing required fields: ${missingFields.join(', ')}`,
                clientInfo 
            });
        }
        
        // Validate items array
        if (!Array.isArray(items) || items.length === 0) {
            return res.status(400).json({ 
                msg: "Items array is required and must not be empty",
                clientInfo 
            });
        }
        
        // Validate each item
        let totalItems = 0;
        let totalCost = 0;
        
        for (let i = 0; i < items.length; i++) {
            const item = items[i];
            const requiredItemFields = ['ProductID', 'ImportQuantity', 'ImportPrice'];
            const missingItemFields = validateRequired(requiredItemFields, item);
            
            if (missingItemFields.length > 0) {
                return res.status(400).json({ 
                    msg: `Item ${i + 1}: Missing required fields: ${missingItemFields.join(', ')}`,
                    clientInfo 
                });
            }
            
            // Validate numeric fields
            const qtyError = validateNumeric(item.ImportQuantity, `Item ${i + 1} ImportQuantity`, 1);
            if (qtyError) {
                return res.status(400).json({ msg: qtyError, clientInfo });
            }
            
            const priceError = validateNumeric(item.ImportPrice, `Item ${i + 1} ImportPrice`, 0);
            if (priceError) {
                return res.status(400).json({ msg: priceError, clientInfo });
            }
            
            // Check if product exists and get current quantity
            const productCheck = "SELECT Quantity FROM tbproduct WHERE ProductID = ?";
            const productResult = await queryAsync(productCheck, [item.ProductID]);
            
            if (productResult.length === 0) {
                return res.status(404).json({ 
                    msg: `Product ${item.ProductID} not found`,
                    clientInfo 
                });
            }
            
            item.PreviousQuantity = productResult[0].Quantity;
            item.NewQuantity = item.PreviousQuantity + parseInt(item.ImportQuantity);
            item.TotalCost = parseFloat(item.ImportQuantity) * parseFloat(item.ImportPrice);
            
            totalItems += parseInt(item.ImportQuantity);
            totalCost += item.TotalCost;
        }
        
        // Start transaction
        await queryAsync("START TRANSACTION");
        
        try {
            // Insert import header
            const importSql = `INSERT INTO tbimport 
                              (ImportDate, ImportTime, TotalItems, TotalCost, SupplierName, 
                               SupplierContact, InvoiceNumber, Notes, Status, CreatedBy, CreatedDate) 
                              VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Pending', ?, NOW())`;
            const importValues = [ImportDate, ImportTime, totalItems, totalCost, SupplierName, 
                                SupplierContact, InvoiceNumber, Notes, CreatedBy];
            
            const importResult = await queryAsync(importSql, importValues);
            const importID = importResult.insertId;
            
            // Insert import details
            const detailSql = `INSERT INTO tbimportdetail 
                              (ImportID, ProductID, ImportQuantity, ImportPrice, TotalCost, 
                               PreviousQuantity, NewQuantity, BatchNumber) 
                              VALUES (?, ?, ?, ?, ?, ?, ?, ?)`;
            
            for (const item of items) {
                const detailValues = [
                    importID, item.ProductID, item.ImportQuantity, item.ImportPrice,
                    item.TotalCost, item.PreviousQuantity, item.NewQuantity, item.BatchNumber || null
                ];
                await queryAsync(detailSql, detailValues);
            }
            
            await queryAsync("COMMIT");
            
            return res.status(201).json({ 
                msg: "Import created successfully",
                importID: importID,
                clientInfo 
            });
            
        } catch (detailError) {
            await queryAsync("ROLLBACK");
            throw detailError;
        }
        
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: "Database connection error" });
    }
});

// Confirm/Complete import (updates product quantities)
app.put("/import/:id/confirm", async (req, res) => {
    try {
        const importID = req.params.id;
        const clientInfo = req.clientInfo || { hostname: 'Unknown Computer', serverHostname: os.hostname() };
        
        // Check if import exists and is pending
        const checkSql = "SELECT Status FROM tbimport WHERE ImportID = ?";
        const existing = await queryAsync(checkSql, [importID]);
        
        if (existing.length === 0) {
            return res.status(404).json({ 
                msg: "Import record not found",
                clientInfo 
            });
        }
        
        if (existing[0].Status !== 'Pending') {
            return res.status(400).json({ 
                msg: `Cannot confirm import. Current status: ${existing[0].Status}`,
                clientInfo 
            });
        }
        
        // Get import details
        const detailsSql = "SELECT * FROM tbimportdetail WHERE ImportID = ?";
        const details = await queryAsync(detailsSql, [importID]);
        
        // Start transaction
        await queryAsync("START TRANSACTION");
        
        try {
            // Update product quantities and balance
            for (const detail of details) {
                const updateProductSql = `UPDATE tbproduct 
                                         SET Quantity = Quantity + ?, 
                                             Balance = Balance + ? 
                                         WHERE ProductID = ?`;
                await queryAsync(updateProductSql, [
                    detail.ImportQuantity, 
                    detail.ImportQuantity, 
                    detail.ProductID
                ]);
            }
            
            // Update import status
            const updateImportSql = "UPDATE tbimport SET Status = 'Completed' WHERE ImportID = ?";
            await queryAsync(updateImportSql, [importID]);
            
            await queryAsync("COMMIT");
            
            return res.status(200).json({ 
                msg: "Import confirmed and inventory updated successfully",
                clientInfo 
            });
            
        } catch (confirmError) {
            await queryAsync("ROLLBACK");
            throw confirmError;
        }
        
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: "Database connection error" });
    }
});

// Cancel import
app.put("/import/:id/cancel", async (req, res) => {
    try {
        const importID = req.params.id;
        const { reason } = req.body;
        const clientInfo = req.clientInfo || { hostname: 'Unknown Computer', serverHostname: os.hostname() };
        
        // Check if import exists and is pending
        const checkSql = "SELECT Status FROM tbimport WHERE ImportID = ?";
        const existing = await queryAsync(checkSql, [importID]);
        
        if (existing.length === 0) {
            return res.status(404).json({ 
                msg: "Import record not found",
                clientInfo 
            });
        }
        
        if (existing[0].Status !== 'Pending') {
            return res.status(400).json({ 
                msg: `Cannot cancel import. Current status: ${existing[0].Status}`,
                clientInfo 
            });
        }
        
        const sql = "UPDATE tbimport SET Status = 'Cancelled', Notes = CONCAT(COALESCE(Notes, ''), ' [CANCELLED: ', ?, ']') WHERE ImportID = ?";
        await queryAsync(sql, [reason || 'No reason provided', importID]);
        
        return res.status(200).json({ 
            msg: "Import cancelled successfully",
            clientInfo 
        });
        
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: "Database connection error" });
    }
});

// Delete import (only if cancelled or pending)
app.delete("/import/:id", async (req, res) => {
    try {
        const importID = req.params.id;
        const clientInfo = req.clientInfo || { hostname: 'Unknown Computer', serverHostname: os.hostname() };
        
        // Check import status
        const checkSql = "SELECT Status FROM tbimport WHERE ImportID = ?";
        const existing = await queryAsync(checkSql, [importID]);
        
        if (existing.length === 0) {
            return res.status(404).json({ 
                msg: "Import record not found",
                clientInfo 
            });
        }
        
        if (existing[0].Status === 'Completed') {
            return res.status(400).json({ 
                msg: "Cannot delete completed imports",
                clientInfo 
            });
        }
        
        // Start transaction
        await queryAsync("START TRANSACTION");
        
        try {
            // Delete import details first
            await queryAsync("DELETE FROM tbimportdetail WHERE ImportID = ?", [importID]);
            
            // Delete import header
            await queryAsync("DELETE FROM tbimport WHERE ImportID = ?", [importID]);
            
            await queryAsync("COMMIT");
            
            return res.status(200).json({ 
                msg: "Import deleted successfully",
                clientInfo 
            });
            
        } catch (deleteError) {
            await queryAsync("ROLLBACK");
            throw deleteError;
        }
        
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: "Database connection error" });
    }
});

// Get import statistics
app.get("/import/stats", async (req, res) => {
    try {
        const { startDate, endDate } = req.query;
        
        let dateFilter = "";
        let params = [];
        
        if (startDate && endDate) {
            dateFilter = "WHERE ImportDate BETWEEN ? AND ?";
            params = [startDate, endDate];
        }
        
        const statsSql = `SELECT 
                            COUNT(*) as TotalImports,
                            SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) as CompletedImports,
                            SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) as PendingImports,
                            SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) as CancelledImports,
                            SUM(CASE WHEN Status = 'Completed' THEN TotalCost ELSE 0 END) as TotalCost,
                            SUM(CASE WHEN Status = 'Completed' THEN TotalItems ELSE 0 END) as TotalItems
                         FROM tbimport ${dateFilter}`;
        
        const stats = await queryAsync(statsSql, params);
        return res.status(200).json(stats[0]);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: "Database connection error" });
    }
});

module.exports = app;