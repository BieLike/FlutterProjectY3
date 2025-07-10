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

// ===================== SUPPLIER MANAGEMENT =====================

// Get all suppliers
app.get("/supplier", async (req, res) => {
    try {
        const sql = "SELECT * FROM tbsupplier ORDER BY SupplierName";
        const result = await queryAsync(sql);
        return res.status(200).json(result);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: "Database connection error" });
    }
});

app.get("/supplier/active", async (req, res) => {
    try {
        const sql = "SELECT * FROM tbsupplier where status like 'Active' ORDER BY SupplierName";
        const result = await queryAsync(sql);
        return res.status(200).json(result);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: "Database connection error" });
    }
});

// Get supplier by ID
app.get("/supplier/:id", async (req, res) => {
    try {
        const supplierID = req.params.id;
        const sql = "SELECT * FROM tbsupplier WHERE SupplierID = ?";
        const result = await queryAsync(sql, [supplierID]);
        
        if (result.length === 0) {
            return res.status(404).json({ msg: "Supplier not found" });
        }
        
        return res.status(200).json(result[0]);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: "Database connection error" });
    }
});

// Create new supplier
app.post("/supplier", async (req, res) => {
    try {
        const { SupplierName, ContactPerson, Phone, Email, Address, Status } = req.body;
        const clientInfo = req.clientInfo || { hostname: 'Unknown Computer', serverHostname: os.hostname() };
        
        // Validate required fields
        const requiredFields = ['SupplierName', 'ContactPerson', 'Phone'];
        const missingFields = validateRequired(requiredFields, req.body);
        
        if (missingFields.length > 0) {
            return res.status(400).json({ 
                msg: `Missing required fields: ${missingFields.join(', ')}`,
                clientInfo 
            });
        }
        
        // Validate email format if provided
        if (Email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(Email)) {
            return res.status(400).json({ 
                msg: "Invalid email format",
                clientInfo 
            });
        }
        
        // Check for duplicate supplier name
        const checkSql = "SELECT SupplierID FROM tbsupplier WHERE SupplierName = ?";
        const existing = await queryAsync(checkSql, [SupplierName]);
        
        if (existing.length > 0) {
            return res.status(409).json({ 
                msg: "Supplier with this name already exists",
                clientInfo 
            });
        }
        
        const sql = `INSERT INTO tbsupplier 
                    (SupplierName, ContactPerson, Phone, Email, Address, Status, CreatedDate) 
                    VALUES (?, ?, ?, ?, ?, ?, NOW())`;
        const values = [SupplierName, ContactPerson, Phone, Email || null, Address || null, Status || 'Active'];
        
        await queryAsync(sql, values);
        return res.status(201).json({ 
            msg: "Supplier created successfully",
            clientInfo 
        });
        
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: "Database connection error" });
    }
});

// Update supplier
app.put("/supplier/:id", async (req, res) => {
    try {
        const supplierID = req.params.id;
        const { SupplierName, ContactPerson, Phone, Email, Address, Status } = req.body;
        const clientInfo = req.clientInfo || { hostname: 'Unknown Computer', serverHostname: os.hostname() };
        
        // Check if supplier exists
        const checkSql = "SELECT SupplierID FROM tbsupplier WHERE SupplierID = ?";
        const existing = await queryAsync(checkSql, [supplierID]);
        
        if (existing.length === 0) {
            return res.status(404).json({ 
                msg: "Supplier not found",
                clientInfo 
            });
        }
        
        // Validate email format if provided
        if (Email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(Email)) {
            return res.status(400).json({ 
                msg: "Invalid email format",
                clientInfo 
            });
        }
        
        // Check for duplicate name (excluding current supplier)
        if (SupplierName) {
            const duplicateCheck = "SELECT SupplierID FROM tbsupplier WHERE SupplierName = ? AND SupplierID != ?";
            const duplicate = await queryAsync(duplicateCheck, [SupplierName, supplierID]);
            
            if (duplicate.length > 0) {
                return res.status(409).json({ 
                    msg: "Another supplier with this name already exists",
                    clientInfo 
                });
            }
        }
        
        const sql = `UPDATE tbsupplier SET 
                    SupplierName = COALESCE(?, SupplierName),
                    ContactPerson = COALESCE(?, ContactPerson),
                    Phone = COALESCE(?, Phone),
                    Email = ?,
                    Address = ?,
                    Status = COALESCE(?, Status)
                    WHERE SupplierID = ?`;
        const values = [SupplierName, ContactPerson, Phone, Email, Address, Status, supplierID];
        
        await queryAsync(sql, values);
        return res.status(200).json({ 
            msg: "Supplier updated successfully",
            clientInfo 
        });
        
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: "Database connection error" });
    }
});

// Delete supplier
app.delete("/supplier/:id", async (req, res) => {
    try {
        const supplierID = req.params.id;
        const clientInfo = req.clientInfo || { hostname: 'Unknown Computer', serverHostname: os.hostname() };
        
        // Check if supplier exists
        const checkSql = "SELECT SupplierID FROM tbsupplier WHERE SupplierID = ?";
        const existing = await queryAsync(checkSql, [supplierID]);
        
        if (existing.length === 0) {
            return res.status(404).json({ 
                msg: "Supplier not found",
                clientInfo 
            });
        }
        
        // Check if supplier is used in imports
        const usageCheck = "SELECT ImportID FROM tbimport WHERE SupplierName = (SELECT SupplierName FROM tbsupplier WHERE SupplierID = ?) LIMIT 1";
        const inUse = await queryAsync(usageCheck, [supplierID]);
        
        if (inUse.length > 0) {
            return res.status(409).json({ 
                msg: "Cannot delete supplier: It has associated import records",
                clientInfo 
            });
        }
        
        const sql = "DELETE FROM tbsupplier WHERE SupplierID = ?";
        await queryAsync(sql, [supplierID]);
        
        return res.status(200).json({ 
            msg: "Supplier deleted successfully",
            clientInfo 
        });
        
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: "Database connection error" });
    }
});

module.exports = app;