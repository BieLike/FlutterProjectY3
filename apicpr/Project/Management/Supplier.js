const express = require('express');
const core = require('cors');
const Database = require('../Server');

const app = express();
app.use(express.json());
app.use(core());

const connection = new Database();
const db = connection.getConnection();

// Helper function to write to activity log
async function writeActivityLog(logData) {
    const { EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails } = logData;
    if (!EmployeeID || !EmployeeName) return;
    const logSQL = "INSERT INTO tbactivity_log (EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails) VALUES (?, ?, ?, ?, ?, ?)";
    db.query(logSQL, [EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails], (err) => {
        if (err) console.log("Error logging activity:", err);
    });
}

// GET all suppliers
app.get("/supplier", (req, res) => {
    const sql = "SELECT * FROM tbsupplier ORDER BY SupplierID DESC";
    db.query(sql, (err, result) => {
        if (err) return res.status(500).json({ msg: "Error querying database" });
        return res.status(200).json(result);
    });
});

// GET supplier by search term
app.get("/supplier/:search", (req, res) => {
    const searchTerm = `%${req.params.search}%`;
    const sql = "SELECT * FROM tbsupplier WHERE SupplierID LIKE ? OR SupplierName LIKE ? OR Phone LIKE ? OR Email LIKE ?";
    db.query(sql, [searchTerm, searchTerm, searchTerm, searchTerm], (err, result) => {
        if (err) return res.status(500).json({ msg: "Error querying database" });
        return res.status(200).json(result);
    });
});

// POST - Create new supplier
app.post("/supplier", (req, res) => {
    const { SupplierName, ContactPerson, Phone, Email, Address, Status, EmployeeID, EmployeeName } = req.body;
    const sql = "INSERT INTO tbsupplier (SupplierName, ContactPerson, Phone, Email, Address, Status) VALUES (?, ?, ?, ?, ?, ?)";
    const values = [SupplierName, ContactPerson, Phone, Email, Address, Status || 'Active'];

    db.query(sql, values, (err, result) => {
        if (err) return res.status(400).json({ msg: "Failed to create supplier. Please check your data." });
        const newId = result.insertId;
        writeActivityLog({
            EmployeeID, EmployeeName, ActionType: 'CREATE', TargetTable: 'tbsupplier',
            TargetRecordID: newId, ChangeDetails: `ເພີ່ມຜູ້ສະໜອງໃໝ່: '${SupplierName}' (ID: ${newId})`
        });
        return res.status(201).json({ msg: "Supplier created successfully", newId });
    });
});

// [EDIT] แก้ไข PUT Endpoint ทั้งหมดเพื่อรองรับ Detailed Logging
app.put("/supplier/:id", (req, res) => {
    const supplierId = req.params.id;
    const { SupplierName, ContactPerson, Phone, Email, Address, Status, EmployeeID, EmployeeName } = req.body;

    // 1. ดึงข้อมูลเก่าก่อน
    db.query("SELECT * FROM tbsupplier WHERE SupplierID = ?", [supplierId], (findErr, findRes) => {
        if (findErr) return res.status(500).json({ msg: "Database error while finding supplier." });
        if (findRes.length === 0) return res.status(404).json({ msg: "Supplier not found." });
        
        const oldSupplier = findRes[0];

        // 2. เตรียมข้อมูลใหม่
        const newValues = {
            SupplierName: SupplierName || oldSupplier.SupplierName,
            ContactPerson: ContactPerson || oldSupplier.ContactPerson,
            Phone: Phone || oldSupplier.Phone,
            Email: Email || oldSupplier.Email,
            Address: Address || oldSupplier.Address,
            Status: Status || oldSupplier.Status
        };

        const sql = `UPDATE tbsupplier SET SupplierName = ?, ContactPerson = ?, Phone = ?, Email = ?, Address = ?, Status = ? WHERE SupplierID = ?`;
        const values = [newValues.SupplierName, newValues.ContactPerson, newValues.Phone, newValues.Email, newValues.Address, newValues.Status, supplierId];

        // 3. อัปเดตข้อมูล
        db.query(sql, values, (updateErr, result) => {
            if (updateErr) return res.status(400).json({ msg: "Failed to update supplier." });
            if (result.affectedRows === 0) return res.status(404).json({ msg: "Supplier not found." });

            // 4. เปรียบเทียบและสร้าง Log
            const changes = [];
            if (newValues.SupplierName !== oldSupplier.SupplierName) changes.push(`ຊື່: '${oldSupplier.SupplierName}' -> '${newValues.SupplierName}'`);
            if (newValues.ContactPerson !== oldSupplier.ContactPerson) changes.push(`ຜູ້ຕິດຕໍ່: '${oldSupplier.ContactPerson}' -> '${newValues.ContactPerson}'`);
            if (newValues.Phone !== oldSupplier.Phone) changes.push(`ເບີໂທ: '${oldSupplier.Phone}' -> '${newValues.Phone}'`);
            if (newValues.Email !== oldSupplier.Email) changes.push(`Email: '${oldSupplier.Email}' -> '${newValues.Email}'`);
            if (newValues.Address !== oldSupplier.Address) changes.push(`ທີ່ຢູ່: '${oldSupplier.Address}' -> '${newValues.Address}'`);
            if (newValues.Status !== oldSupplier.Status) changes.push(`ສະຖານະ: '${oldSupplier.Status}' -> '${newValues.Status}'`);

            if (changes.length > 0) {
                const changeDetails = `ແກ້ໄຂຂໍ້ມູນຜູ້ສະໜອງ '${oldSupplier.SupplierName}':\n- ${changes.join('\n- ')}`;
                writeActivityLog({
                    EmployeeID, EmployeeName, ActionType: 'UPDATE', TargetTable: 'tbsupplier',
                    TargetRecordID: supplierId, ChangeDetails: changeDetails
                });
            }

            return res.status(200).json({ msg: "Supplier updated successfully" });
        });
    });
});


// DELETE - Delete supplier
app.delete("/supplier/:id", (req, res) => {
    const supplierId = req.params.id;
    const { EmployeeID, EmployeeName } = req.body;

    db.query("SELECT SupplierName FROM tbsupplier WHERE SupplierID = ?", [supplierId], (findErr, findRes) => {
        if (findErr || findRes.length === 0) {
            return res.status(404).json({ msg: "Supplier not found to delete." });
        }
        const supplierNameToDelete = findRes[0].SupplierName;

        const sql = "DELETE FROM tbsupplier WHERE SupplierID = ?";
        db.query(sql, [supplierId], (err, result) => {
            if (err) {
                 if (err.code === 'ER_ROW_IS_REFERENCED_2') {
                    return res.status(409).json({ message: 'Cannot delete: Supplier is still in use by other records.' });
                 }
                 return res.status(400).json({ msg: "Failed to delete supplier." });
            }
            if (result.affectedRows === 0) {
                return res.status(404).json({ msg: "Supplier not found." });
            }

            writeActivityLog({
                EmployeeID, EmployeeName, ActionType: 'DELETE', TargetTable: 'tbsupplier',
                TargetRecordID: supplierId, ChangeDetails: `ລົບຜູ້ສະໜອງ: '${supplierNameToDelete}' (ID: ${supplierId})`
            });

            return res.status(200).json({ msg: "Supplier has been deleted." });
        });
    });
});

module.exports = app;