const express = require('express');
const core = require('cors');
const Database = require('../Server');

const app = express();
app.use(express.json());
app.use(core());

const connection = new Database();
const db = connection.getConnection();

// Helper function to promisify database queries
function queryAsync(sql, params) {
    return new Promise((resolve, reject) => {
        db.query(sql, params, (err, result) => {
            if (err) reject(err);
            else resolve(result);
        });
    });
}

// Helper function to write to activity log
async function writeActivityLog(logData) {
    const { EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails } = logData;
    if (!EmployeeID || !EmployeeName) return; 
    const logSQL = "INSERT INTO tbactivity_log (EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails) VALUES (?, ?, ?, ?, ?, ?)";
    try {
        await queryAsync(logSQL, [EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails]);
    } catch (logErr) {
        console.log("Error logging activity:", logErr);
    }
}

// 1. Get All Sales History with Employee Details
app.get('/sales', async (req, res) => {
    try {
        const sql = `
            SELECT s.SellID, s.Date, s.Time, s.GrandTotal, CONCAT(u.UserFname, ' ', u.UserLname) AS EmployeeName
            FROM tbsell s
            LEFT JOIN tbuser u ON s.EmployeeID = u.UID
            ORDER BY s.Date DESC, s.Time DESC
        `;
        const result = await queryAsync(sql);
        res.status(200).json(result);
    } catch (err) {
        res.status(500).json({ msg: 'Failed to retrieve sales history.' });
    }
});

// 2. Get Specific Sale Details with all related info
app.get('/sales/:sellId', async (req, res) => {
    try {
        const { sellId } = req.params;
        const sqlSale = `
            SELECT s.*, CONCAT(u.UserFname, ' ', u.UserLname) AS EmployeeName, r.RoleName AS EmployeeRole,
                   u.Phone AS EmployeePhone, u.Email AS EmployeeEmail
            FROM tbsell s
            LEFT JOIN tbuser u ON s.EmployeeID = u.UID
            LEFT JOIN tbrole r ON u.Position = r.RID
            WHERE s.SellID = ?
        `;
        const sale = await queryAsync(sqlSale, [sellId]);
        if (sale.length === 0) return res.status(404).json({ msg: `Sale with ID ${sellId} not found.` });

        const sqlDetails = `
            SELECT sd.SellDetailID, sd.ProductID, p.ProductName, sd.Price, sd.Quantity, sd.Total,
                   c.CategoryName, u.UnitName
            FROM tbselldetail sd 
            JOIN tbproduct p ON sd.ProductID = p.ProductID 
            LEFT JOIN tbcategory c ON p.CategoryID = c.CategoryID
            LEFT JOIN tbunit u ON p.UnitID = u.UnitID
            WHERE sd.SellID = ?
        `;
        let details = await queryAsync(sqlDetails, [sellId]);
        // Ensure all fields are the correct type for Flutter
        details = details.map(d => ({
            SellDetailID: Number(d.SellDetailID),
            ProductID: d.ProductID.toString(),
            ProductName: d.ProductName ? d.ProductName.toString() : 'N/A',
            Price: Number(d.Price),
            Quantity: Number(d.Quantity),
            Total: Number(d.Total),
            CategoryName: d.CategoryName ? d.CategoryName.toString() : 'N/A',
            UnitName: d.UnitName ? d.UnitName.toString() : 'N/A',
        }));
        // Also ensure sale[0] fields are correct type
        const s = sale[0];
        const responseData = {
            SellID: Number(s.SellID),
            Date: s.Date,
            Time: s.Time,
            GrandTotal: Number(s.GrandTotal),
            EmployeeName: s.EmployeeName ? s.EmployeeName.toString() : null,
            EmployeeRole: s.EmployeeRole ? s.EmployeeRole.toString() : null,
            EmployeePhone: s.EmployeePhone ? s.EmployeePhone.toString() : null,
            EmployeeEmail: s.EmployeeEmail ? s.EmployeeEmail.toString() : null,
            SubTotal: s.SubTotal !== undefined ? Number(s.SubTotal) : Number(s.GrandTotal),
            Money: s.Money !== undefined ? Number(s.Money) : 0,
            ChangeTotal: s.ChangeTotal !== undefined ? Number(s.ChangeTotal) : 0,
            PaymentMethod: s.PaymentMethod ? s.PaymentMethod.toString() : '',
            details: details
        };
        res.status(200).json(responseData);
    } catch (err) {
        res.status(500).json({ msg: 'Failed to retrieve sale details.' });
    }
});

// 3. Update Product Quantity in Sale Detail (Return Items)
app.put('/sales/detail/:sellDetailId', async (req, res) => {
    const { sellDetailId } = req.params;
    const { newQuantity, EmployeeID, EmployeeName } = req.body;
    
    if (!newQuantity || isNaN(newQuantity) || parseInt(newQuantity) < 0) {
        return res.status(400).json({ msg: 'Invalid quantity.' });
    }
    
    await queryAsync("START TRANSACTION");
    try {
        // ดึงข้อมูลรายการขายและข้อมูลการขายหลัก
        const sqlDetail = `
            SELECT sd.ProductID, sd.Quantity, sd.Price, p.ProductName, sd.SellID, p.Quantity as ProductStock,
                   s.Money, s.ChangeTotal, s.SubTotal, s.GrandTotal
            FROM tbselldetail sd 
            JOIN tbproduct p ON sd.ProductID = p.ProductID 
            JOIN tbsell s ON sd.SellID = s.SellID
            WHERE sd.SellDetailID = ?`;
        const [currentDetail] = await queryAsync(sqlDetail, [sellDetailId]);
        if (!currentDetail) throw new Error(`Sale detail with ID ${sellDetailId} not found.`);

        const { 
            ProductID, Quantity: oldQuantity, Price, ProductName, SellID,
            Money, ChangeTotal, SubTotal, GrandTotal 
        } = currentDetail;
        
        const finalQuantity = parseInt(newQuantity);
        if (finalQuantity >= oldQuantity) {
            throw new Error('New quantity must be less than current quantity');
        }

        // คำนวณจำนวนสินค้าที่คืนและเงินที่ต้องคืน
        const returnedQuantity = oldQuantity - finalQuantity;
        const refundAmount = returnedQuantity * Price;
        
        // คำนวณยอดรวมใหม่
        const newTotal = Price * finalQuantity;
        const newSubTotal = SubTotal - refundAmount;
        const newGrandTotal = GrandTotal - refundAmount;
        const newChangeTotal = ChangeTotal + refundAmount;  // เพิ่มเงินทอนตามจำนวนเงินที่ต้องคืน

        // อัพเดทฐานข้อมูล
        await queryAsync('UPDATE tbselldetail SET Quantity = ?, Total = ? WHERE SellDetailID = ?', 
            [finalQuantity, newTotal, sellDetailId]);
        
        await queryAsync('UPDATE tbproduct SET Quantity = Quantity + ? WHERE ProductID = ?', 
            [returnedQuantity, ProductID]);
        
        await queryAsync(`
            UPDATE tbsell 
            SET SubTotal = ?, GrandTotal = ?, ChangeTotal = ? 
            WHERE SellID = ?`, 
            [newSubTotal, newGrandTotal, newChangeTotal, SellID]);
        
        await queryAsync("COMMIT");

        writeActivityLog({ 
            EmployeeID, 
            EmployeeName, 
            ActionType: 'RETURN', 
            TargetTable: 'tbsell', 
            TargetRecordID: SellID, 
            ChangeDetails: `ຮັບຄືນສິນຄ້າໃນບິນ #${SellID}: ສິນຄ້າ '${ProductName}' ຈຳນວນ ${returnedQuantity} ລາຍການ, ເງິນທີ່ຕ້ອງຄືນ ${refundAmount} ກີບ`
        });
        
        res.status(200).json({ 
            msg: 'Items returned successfully',
            returnedQuantity,
            refundAmount,
            newChangeTotal
        });
    } catch (err) {
        await queryAsync("ROLLBACK");
        res.status(500).json({ msg: err.message || 'Failed to update sale detail.' });
    }
});

// 4. Delete Product from Sale Detail
app.delete('/sales/detail/:sellDetailId', async (req, res) => {
    const { sellDetailId } = req.params;
    const { EmployeeID, EmployeeName } = req.body;

    await queryAsync("START TRANSACTION");
    try {
        const sqlDetail = `SELECT sd.SellID, sd.ProductID, sd.Quantity, p.ProductName FROM tbselldetail sd JOIN tbproduct p ON sd.ProductID = p.ProductID WHERE sd.SellDetailID = ?`;
        const [detail] = await queryAsync(sqlDetail, [sellDetailId]);
        if (!detail) throw new Error('Sale detail not found.');

        const { SellID, ProductID, Quantity, ProductName, Price } = detail;
        
        // Get current sale info before deletion
        const [currentSale] = await queryAsync("SELECT Money, SubTotal, GrandTotal FROM tbsell WHERE SellID = ?", [SellID]);
        
        // Calculate refund amount
        const refundAmount = Quantity * Price;
        const newSubTotal = parseFloat(currentSale.SubTotal) - refundAmount;
        const newGrandTotal = parseFloat(currentSale.GrandTotal) - refundAmount;
        const newChangeTotal = parseFloat(currentSale.Money) - newGrandTotal;  // คำนวณเงินทอนใหม่

        // Update database
        await queryAsync("DELETE FROM tbselldetail WHERE SellDetailID = ?", [sellDetailId]);
        await queryAsync("UPDATE tbproduct SET Quantity = Quantity + ? WHERE ProductID = ?", [Quantity, ProductID]);
        await queryAsync('UPDATE tbsell SET SubTotal = ?, GrandTotal = ?, ChangeTotal = ? WHERE SellID = ?', 
            [newSubTotal, newGrandTotal, newChangeTotal, SellID]);

        await queryAsync("COMMIT");

        writeActivityLog({ EmployeeID, EmployeeName, ActionType: 'UPDATE', TargetTable: 'tbsell', TargetRecordID: SellID, ChangeDetails: `ລົບສິນຄ້າ '${ProductName}' ອອກຈາກບິນ #${SellID}` });
        res.status(200).json({ msg: 'Product removed from sale and stock restored.' });
    } catch (err) {
        await queryAsync("ROLLBACK");
        res.status(500).json({ msg: err.message || 'Failed to delete product from sale.' });
    }
});


// 5. Delete Entire Sale Record
app.delete('/sales/:sellId', async (req, res) => {
    const { sellId } = req.params;
    const { EmployeeID, EmployeeName } = req.body;

    if (!EmployeeID || !EmployeeName) return res.status(400).json({ msg: "Employee information is required for logging." });
    
    await queryAsync("START TRANSACTION");
    try {
        const details = await queryAsync("SELECT ProductID, Quantity FROM tbselldetail WHERE SellID = ?", [sellId]);
        
        for (const detail of details) {
            await queryAsync("UPDATE tbproduct SET Quantity = Quantity + ? WHERE ProductID = ?", [detail.Quantity, detail.ProductID]);
        }

        await queryAsync("DELETE FROM tbselldetail WHERE SellID = ?", [sellId]);
        const deleteSaleResult = await queryAsync("DELETE FROM tbsell WHERE SellID = ?", [sellId]);

        if (deleteSaleResult.affectedRows === 0) throw new Error(`Sale with ID ${sellId} not found.`);

        await queryAsync("COMMIT");

        writeActivityLog({ EmployeeID, EmployeeName, ActionType: 'DELETE', TargetTable: 'tbsell', TargetRecordID: sellId, ChangeDetails: `ລົບການຂາຍທັງໝົດຂອງບິນ #${sellId}` });
        res.status(200).json({ msg: 'Sale record deleted and stock restored.' });
    } catch (err) {
        await queryAsync("ROLLBACK");
        res.status(500).json({ msg: err.message || 'Failed to delete sale.' });
    }
});

module.exports = app;