const express = require('express');
const core = require('cors');
const Database = require('../Server');

const app = express();
app.use(express.json());
app.use(core());

const connection = new Database();
const db = connection.getConnection();

// --- API Endpoints ---

// 1. Get All Sales History with Employee Details
app.get('/sales', (req, res) => {
    try {
        const sql = `
            SELECT 
                s.SellID,
                s.Date,
                s.Time,
                s.SubTotal,
                s.GrandTotal,
                s.Money,
                s.ChangeTotal,
                s.PaymentMethod,
                s.EmployeeID,
                s.MemberID,
                CONCAT(u.UserFname, ' ', u.UserLname) AS EmployeeName,
                r.RoleName AS EmployeeRole
            FROM tbsell s
            LEFT JOIN tbuser u ON s.EmployeeID = u.UID
            LEFT JOIN tbrole r ON u.Position = r.RID
            ORDER BY s.Date DESC, s.Time DESC
        `;
        db.query(sql, (err, result) => {
            if (err) {
                console.error('Error fetching sales history:', err);
                return res.status(500).json({ msg: 'Failed to retrieve sales history.', error: err.message });
            }
            return res.status(200).json(result);
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: 'Path to database not found' });
    }
});

// 2. Get Specific Sale Details with Employee Information
app.get('/sales/:sellId', (req, res) => {
    try {
        const { sellId } = req.params;
        const sqlSale = `
            SELECT 
                s.*,
                CONCAT(u.UserFname, ' ', u.UserLname) AS EmployeeName,
                r.RoleName AS EmployeeRole,
                u.Phone AS EmployeePhone,
                u.Email AS EmployeeEmail
            FROM tbsell s
            LEFT JOIN tbuser u ON s.EmployeeID = u.UID
            LEFT JOIN tbrole r ON u.Position = r.RID
            WHERE s.SellID = ?
        `;
        db.query(sqlSale, [sellId], (err, sale) => {
            if (err) {
                console.error(`Error fetching sale details for SellID ${sellId}:`, err);
                return res.status(500).json({ msg: 'Failed to retrieve sale details.', error: err.message });
            }
            if (sale.length === 0) {
                return res.status(404).json({ msg: `Sale with ID ${sellId} not found.` });
            }
            const sqlDetails = `
                SELECT 
                    sd.SellDetailID, 
                    sd.ProductID, 
                    p.ProductName, 
                    sd.Price, 
                    sd.Quantity, 
                    sd.Total,
                    c.CategoryName,
                    u.UnitName
                FROM tbselldetail sd 
                JOIN tbproduct p ON sd.ProductID = p.ProductID 
                LEFT JOIN tbcategory c ON p.CategoryID = c.CategoryID
                LEFT JOIN tbunit u ON p.UnitID = u.UnitID
                WHERE sd.SellID = ?
            `;
            db.query(sqlDetails, [sellId], (err2, details) => {
                if (err2) {
                    console.error(`Error fetching sale details for SellID ${sellId}:`, err2);
                    return res.status(500).json({ msg: 'Failed to retrieve sale details.', error: err2.message });
                }
                const responseData = {
                    ...sale[0],
                    details: details
                };
                return res.status(200).json(responseData);
            });
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: 'Path to database not found' });
    }
});

// 3. Update Product Quantity Only in Sale Detail
app.put('/sales/detail/:sellDetailId', (req, res) => {
    try {
        const { sellDetailId } = req.params;
        const { newQuantity } = req.body;
        
        // Validate input
        if (!newQuantity || isNaN(newQuantity) || parseInt(newQuantity) <= 0) {
            return res.status(400).json({ msg: 'Invalid input. newQuantity must be a positive number.' });
        }
        
        const finalQuantity = parseInt(newQuantity);
        
        // Get current detail information
        const sqlDetail = `
            SELECT 
                sd.ProductID, 
                sd.Quantity, 
                sd.Price, 
                p.Quantity AS ProductStock 
            FROM tbselldetail sd 
            JOIN tbproduct p ON sd.ProductID = p.ProductID 
            WHERE sd.SellDetailID = ?
        `;
        
        db.query(sqlDetail, [sellDetailId], (err, currentDetail) => {
            if (err) {
                console.error(`Error updating sale detail ${sellDetailId}:`, err);
                return res.status(500).json({ msg: 'Failed to update sale detail.', error: err.message });
            }
            if (currentDetail.length === 0) {
                return res.status(404).json({ msg: `Sale detail with ID ${sellDetailId} not found.` });
            }
            
            const oldQuantity = currentDetail[0].Quantity;
            const price = parseFloat(currentDetail[0].Price);
            const productID = currentDetail[0].ProductID;
            const currentStock = currentDetail[0].ProductStock;
            
            // Calculate quantity difference
            const quantityDifference = finalQuantity - oldQuantity;
            
            // Check if we have enough stock for increase
            if (quantityDifference > 0 && currentStock < quantityDifference) {
                return res.status(409).json({ 
                    msg: `Insufficient stock for product ${productID}. Available: ${currentStock}, Needed: ${quantityDifference}.` 
                });
            }
            
            const newTotal = price * finalQuantity;
            
            // Update sale detail
            const sqlUpdateDetail = 'UPDATE tbselldetail SET Quantity = ?, Total = ? WHERE SellDetailID = ?';
            db.query(sqlUpdateDetail, [finalQuantity, newTotal, sellDetailId], (err2) => {
                if (err2) {
                    console.error(`Error updating sale detail ${sellDetailId}:`, err2);
                    return res.status(500).json({ msg: 'Failed to update sale detail.', error: err2.message });
                }
                
                // Update product stock (subtract the difference)
                const sqlUpdateStock = 'UPDATE tbproduct SET Quantity = Quantity - ? WHERE ProductID = ?';
                db.query(sqlUpdateStock, [quantityDifference, productID], (err3) => {
                    if (err3) {
                        console.error(`Error updating product stock for ${productID}:`, err3);
                        return res.status(500).json({ msg: 'Failed to update product stock.', error: err3.message });
                    }
                    
                    // Get parent sale ID and recalculate totals
                    const sqlParentSell = 'SELECT SellID FROM tbselldetail WHERE SellDetailID = ?';
                    db.query(sqlParentSell, [sellDetailId], (err4, parentSell) => {
                        if (err4 || parentSell.length === 0) {
                            return res.status(500).json({ msg: 'Failed to update parent sale.' });
                        }
                        
                        const sellID = parentSell[0].SellID;
                        const sqlRecalc = 'SELECT SUM(Total) AS newSubTotal FROM tbselldetail WHERE SellID = ?';
                        db.query(sqlRecalc, [sellID], (err5, recalculatedTotals) => {
                            const newSubTotal = recalculatedTotals && recalculatedTotals[0] && recalculatedTotals[0].newSubTotal ? recalculatedTotals[0].newSubTotal : 0;
                            
                            const sqlUpdateSell = 'UPDATE tbsell SET SubTotal = ?, GrandTotal = ? WHERE SellID = ?';
                            db.query(sqlUpdateSell, [newSubTotal, newSubTotal, sellID], (err6) => {
                                if (err6) {
                                    return res.status(500).json({ msg: 'Failed to update parent sale.' });
                                }
                                return res.status(200).json({ 
                                    msg: 'Sale detail updated successfully. Stock adjusted.',
                                    oldQuantity: oldQuantity,
                                    newQuantity: finalQuantity,
                                    stockChange: -quantityDifference
                                });
                            });
                        });
                    });
                });
            });
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: 'Path to database not found' });
    }
});

// 4. Delete Product from Sale Detail (with stock restoration)
app.delete('/sales/detail/:sellDetailId', (req, res) => {
    try {
        const { sellDetailId } = req.params;
        const sqlDetail = `
            SELECT 
                sd.SellID, 
                sd.ProductID, 
                sd.Quantity, 
                sd.Total 
            FROM tbselldetail sd 
            WHERE sd.SellDetailID = ?
        `;
        
        db.query(sqlDetail, [sellDetailId], (err, detailToDelete) => {
            if (err) {
                console.error(`Error deleting sale detail ${sellDetailId}:`, err);
                return res.status(500).json({ msg: 'Failed to delete product from sale detail.', error: err.message });
            }
            if (detailToDelete.length === 0) {
                return res.status(404).json({ msg: `Sale detail with ID ${sellDetailId} not found.` });
            }
            
            const { SellID, ProductID, Quantity: deletedQuantity } = detailToDelete[0];
            
            // Delete the sale detail
            const sqlDelete = 'DELETE FROM tbselldetail WHERE SellDetailID = ?';
            db.query(sqlDelete, [sellDetailId], (err2) => {
                if (err2) {
                    return res.status(500).json({ msg: 'Failed to delete product from sale detail.', error: err2.message });
                }
                
                // Restore stock to tbproduct
                const sqlRevertStock = 'UPDATE tbproduct SET Quantity = Quantity + ? WHERE ProductID = ?';
                db.query(sqlRevertStock, [deletedQuantity, ProductID], (err3) => {
                    if (err3) {
                        return res.status(500).json({ msg: 'Failed to revert stock.', error: err3.message });
                    }
                    
                    // Recalculate parent sale totals
                    const sqlRecalc = 'SELECT SUM(Total) AS newSubTotal FROM tbselldetail WHERE SellID = ?';
                    db.query(sqlRecalc, [SellID], (err4, remainingDetails) => {
                        const newSubTotal = remainingDetails && remainingDetails[0] && remainingDetails[0].newSubTotal ? remainingDetails[0].newSubTotal : 0;
                        
                        const sqlUpdateSell = 'UPDATE tbsell SET SubTotal = ?, GrandTotal = ? WHERE SellID = ?';
                        db.query(sqlUpdateSell, [newSubTotal, newSubTotal, SellID], (err5) => {
                            if (err5) {
                                return res.status(500).json({ msg: 'Failed to update parent sale.' });
                            }
                            return res.status(200).json({ 
                                msg: 'Product removed from sale and stock restored successfully.',
                                restoredQuantity: deletedQuantity,
                                productID: ProductID
                            });
                        });
                    });
                });
            });
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: 'Path to database not found' });
    }
});

// 5. Delete Entire Sale Record (with stock restoration)
app.delete('/sales/:sellId', (req, res) => {
    try {
        const { sellId } = req.params;
        
        // First, get all products in this sale to restore stock
        const sqlGetDetails = `
            SELECT 
                sd.ProductID, 
                sd.Quantity 
            FROM tbselldetail sd 
            WHERE sd.SellID = ?
        `;
        
        db.query(sqlGetDetails, [sellId], (err, saleDetails) => {
            if (err) {
                console.error(`Error fetching sale details for deletion:`, err);
                return res.status(500).json({ msg: 'Failed to delete sale record.', error: err.message });
            }
            
            // Check if sale exists
            if (saleDetails.length === 0) {
                return res.status(404).json({ msg: `Sale with ID ${sellId} not found.` });
            }
            
            // Delete all sale details first (foreign key constraint)
            const sqlDeleteDetails = 'DELETE FROM tbselldetail WHERE SellID = ?';
            db.query(sqlDeleteDetails, [sellId], (err2) => {
                if (err2) {
                    return res.status(500).json({ msg: 'Failed to delete sale details.', error: err2.message });
                }
                
                // Delete the main sale record
                const sqlDeleteSale = 'DELETE FROM tbsell WHERE SellID = ?';
                db.query(sqlDeleteSale, [sellId], (err3) => {
                    if (err3) {
                        return res.status(500).json({ msg: 'Failed to delete sale record.', error: err3.message });
                    }
                    
                    // Restore stock for all products in this sale
                    let stockRestorePromises = saleDetails.map(detail => {
                        return new Promise((resolve, reject) => {
                            const sqlRestoreStock = 'UPDATE tbproduct SET Quantity = Quantity + ? WHERE ProductID = ?';
                            db.query(sqlRestoreStock, [detail.Quantity, detail.ProductID], (err4) => {
                                if (err4) {
                                    reject(err4);
                                } else {
                                    resolve({ productID: detail.ProductID, restoredQuantity: detail.Quantity });
                                }
                            });
                        });
                    });
                    
                    // Wait for all stock restoration to complete
                    Promise.all(stockRestorePromises)
                        .then(restoredItems => {
                            return res.status(200).json({ 
                                msg: 'Sale record deleted successfully and stock restored.',
                                sellId: sellId,
                                restoredItems: restoredItems
                            });
                        })
                        .catch(stockErr => {
                            console.error('Error restoring stock:', stockErr);
                            return res.status(500).json({ 
                                msg: 'Sale deleted but failed to restore some stock items.',
                                error: stockErr.message 
                            });
                        });
                });
            });
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: 'Path to database not found' });
    }
});

// 6. Get Sales Summary with Employee Performance
app.get('/sales/summary/employee', (req, res) => {
    try {
        const sql = `
            SELECT 
                u.UID AS EmployeeID,
                CONCAT(u.UserFname, ' ', u.UserLname) AS EmployeeName,
                r.RoleName,
                COUNT(s.SellID) AS TotalSales,
                SUM(s.GrandTotal) AS TotalRevenue,
                AVG(s.GrandTotal) AS AverageTicketSize,
                MIN(s.Date) AS FirstSaleDate,
                MAX(s.Date) AS LastSaleDate
            FROM tbuser u
            LEFT JOIN tbrole r ON u.Position = r.RID
            LEFT JOIN tbsell s ON u.UID = s.EmployeeID
            GROUP BY u.UID, u.UserFname, u.UserLname, r.RoleName
            ORDER BY TotalRevenue DESC
        `;
        
        db.query(sql, (err, result) => {
            if (err) {
                console.error('Error fetching employee sales summary:', err);
                return res.status(500).json({ msg: 'Failed to retrieve employee sales summary.', error: err.message });
            }
            return res.status(200).json(result);
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: 'Path to database not found' });
    }
});

module.exports = app;