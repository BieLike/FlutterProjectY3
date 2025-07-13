const express = require('express');
const core = require('cors');
const Database = require('../Server');

const app = express();
app.use(express.json());
app.use(core());

const connection = new Database();
const db = connection.getConnection();

// --- Helper function to write to activity log ---
async function writeActivityLog(logData) {
    const { EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails } = logData;
    const logSQL = "INSERT INTO tbactivity_log (EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails) VALUES (?, ?, ?, ?, ?, ?)";
    try {
        db.query(logSQL, [EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails], (err) => {
            if (err) console.log("Error logging activity:", err);
        });
    } catch (logErr) {
        console.log("Error in writeActivityLog:", logErr);
    }
}

// --- GET Endpoints (No changes needed) ---
app.get("/unit", function(req, res) {
    try {
        const sql = "select * from tbunit";
        db.query(sql, (err, result, field) => {
            if (err) return res.status(404).send({ "msg": "Data not found in database" });
            return res.status(200).send(result);
        });
    } catch (err) {
        console.log(err);
        return res.status(500).send({ "msg": "Path to database not found" });
    }
});

app.get("/unit/:uid", (req, res) => {
    try {
        const uid = req.params.uid;
        const sql = "select * from tbunit where UnitID LIKE ? or UnitName LIKE ?";
        const searchTerm = `%${uid}%`;
        db.query(sql, [searchTerm, searchTerm], (err, result) => {
            if (err) return res.status(404).send({ "msg": "Data not found in database" });
            return res.status(200).send(result);
        });
    } catch (err) {
        console.log(err);
        return res.status(500).send({ "msg": "Path to database not found" });
    }
});

// --- POST (Create) Endpoint ---
app.post("/unit", (req, res) => {
    try {
        // 1. รับข้อมูลพนักงาน
        const { UnitID, UnitName, EmployeeID, EmployeeName } = req.body;
        const val = [UnitID, UnitName];
        const chsql = "select * from tbunit where UnitID = ? or UnitName = ?";

        db.query(chsql, [UnitID, UnitName], (err, chresult) => {
            if (err) return res.status(401).send({ "msg": "Insert checking error" });
            if (chresult.length > 0) return res.status(300).send({ "msg": "This unit already existed" });

            const sql = "insert into tbunit (UnitID, UnitName) value(?,?)";
            db.query(sql, val, (err, result) => {
                if (err) return res.status(400).send({ "msg": "Please check again" });

                // 2. บันทึก Log
                writeActivityLog({
                    EmployeeID,
                    EmployeeName,
                    ActionType: 'CREATE',
                    TargetTable: 'tbunit',
                    TargetRecordID: UnitID,
                    ChangeDetails: `ເພີ່ມຫົວໜ່ວຍໃໝ່: '${UnitName}' (ID: ${UnitID})`
                });

                return res.status(200).send({ "msg": "Data is saved" });
            });
        });
    } catch (err) {
        console.log(err);
        return res.status(500).send({ "msg": "Path to database not found" });
    }
});


// --- PUT (Update) Endpoint ---
app.put("/unit/:uid", (req, res) => {
    try {
        const uid = req.params.uid;
        // 1. รับข้อมูลพนักงาน
        const { NewUnitID, UnitName, NewUnitName, EmployeeID, EmployeeName } = req.body;

        const finalUnitID = NewUnitID || uid;
        const finalUnitName = NewUnitName || UnitName;

        const checkSQL = "SELECT * FROM tbunit WHERE (UnitID = ? OR UnitName = ?) AND UnitID != ?";
        db.query(checkSQL, [finalUnitID, finalUnitName, uid], (err, checkResult) => {
            if (err) return res.status(500).send({ msg: "Edit checking error" });
            if (checkResult.length > 0) return res.status(409).send({ msg: "Unit ID or Name already exists" });

            const updateSQL = "UPDATE tbunit SET UnitID = ?, UnitName = ? WHERE UnitID = ?";
            db.query(updateSQL, [finalUnitID, finalUnitName, uid], (err, result) => {
                if (err) return res.status(400).send({ msg: "Update failed" });
                if (result.affectedRows === 0) return res.status(404).send({ msg: "Unit not found" });

                // 2. บันทึก Log
                const changeDetails = `ແກ້ໄຂຫົວໜ່ວຍ ID: ${uid}. ID ໃໝ່: ${finalUnitID}, ຊື່ໃໝ່: '${finalUnitName}'`;
                writeActivityLog({
                    EmployeeID,
                    EmployeeName,
                    ActionType: 'UPDATE',
                    TargetTable: 'tbunit',
                    TargetRecordID: uid,
                    ChangeDetails: changeDetails
                });

                return res.status(200).send({ msg: "Unit updated successfully" });
            });
        });
    } catch (err) {
        console.log(err);
        return res.status(500).send({ msg: "Server error" });
    }
});


// --- DELETE Endpoint ---
app.delete("/unit/:uid", (req, res) => {
    try {
        const uid = req.params.uid;
        // 1. รับข้อมูลพนักงาน
        const { EmployeeID, EmployeeName } = req.body;

        db.query("SELECT UnitName FROM tbunit WHERE UnitID = ?", [uid], (findErr, findResult) => {
            if (findErr || findResult.length === 0) {
                return res.status(404).send({ "msg": "Unit not found" });
            }
            const unitNameToDelete = findResult[0].UnitName;

            const sql = "delete from tbunit where UnitID = ?";
            db.query(sql, [uid], (err, result) => {
                if (err) {
                    if (err.code === 'ER_ROW_IS_REFERENCED_2') {
                        return res.status(409).json({ message: 'Cannot delete unit: It is still in use' });
                    }
                    return res.status(400).send({ "msg": "Delete failed, please check again" });
                }
                if (result.affectedRows === 0) return res.status(404).send({ "msg": "Unit not found" });

                // 2. บันทึก Log
                writeActivityLog({
                    EmployeeID,
                    EmployeeName,
                    ActionType: 'DELETE',
                    TargetTable: 'tbunit',
                    TargetRecordID: uid,
                    ChangeDetails: `ລົບຫົວໜ່ວຍ: '${unitNameToDelete}' (ID: ${uid})`
                });

                return res.status(200).send({ "msg": "Data has been deleted" });
            });
        });
    } catch (err) {
        console.log(err);
        return res.status(500).send({ "msg": "Path to database not found" });
    }
});

module.exports = app;
