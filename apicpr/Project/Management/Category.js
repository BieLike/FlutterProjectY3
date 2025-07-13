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
        // Use a promise-based query to avoid callback hell, or just fire and forget
        db.query(logSQL, [EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails], (err) => {
            if (err) console.log("Error logging activity:", err);
        });
    } catch (logErr) {
        console.log("Error in writeActivityLog:", logErr);
    }
}


// --- GET Endpoints (No changes needed) ---
app.get("/category", function(req, res) {
    try {
        const sql = "select * from tbcategory";
        db.query(sql, (err, result, field) => {
            if (err) {
                console.log(err);
                return res.status(400).send({ "msg": "Data not found in database" });
            }
            return res.status(200).send(result);
        });
    } catch (err) {
        console.log(err);
        return res.status(500).send({ "msg": "Path to database not found" });
    }
});

app.get("/category/:cid", (req, res) => {
    try {
        const cid = req.params.cid;
        const sql = "select * from tbcategory where CategoryID LIKE ? OR CategoryName LIKE ?";
        const searchTerm = `%${cid}%`;
        db.query(sql, [searchTerm, searchTerm], (err, result) => {
            if (err) {
                console.log(err);
                return res.status(400).send({ "msg": "Data not found in database" });
            }
            return res.status(200).send(result);
        });
    } catch (err) {
        console.log(err);
        return res.status(500).send({ "msg": "Path to database not found" });
    }
});


// --- POST (Create) Endpoint ---
app.post("/category", (req, res) => {
    try {
        // 1. รับข้อมูลพนักงาน
        const { CategoryID, CategoryName, EmployeeID, EmployeeName } = req.body;
        const val = [CategoryID, CategoryName];
        const chsql = "select * from tbcategory where CategoryID = ? or CategoryName = ?";

        db.query(chsql, [CategoryID, CategoryName], (err, chresult) => {
            if (err) return res.status(401).send({ "msg": "Insert checking error" });
            if (chresult.length > 0) return res.status(300).send({ "msg": "This category already existed" });

            const sql = "insert into tbcategory (CategoryID, CategoryName) value(?,?)";
            db.query(sql, val, (err, result) => {
                if (err) return res.status(400).send({ "msg": "Please check again" });

                // 2. บันทึก Log
                writeActivityLog({
                    EmployeeID,
                    EmployeeName,
                    ActionType: 'CREATE',
                    TargetTable: 'tbcategory',
                    TargetRecordID: CategoryID,
                    ChangeDetails: `ສ້າງໝວດໝູ່ໃໝ່: '${CategoryName}' (ID: ${CategoryID})`
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
app.put("/category/:cid", (req, res) => {
    try {
        const cid = req.params.cid;
        // 1. รับข้อมูลพนักงาน
        const { NewCategoryID, NewCategoryName, CategoryName, EmployeeID, EmployeeName } = req.body;
        
        // Use new values if provided, otherwise use original values
        const finalCategoryID = NewCategoryID || cid;
        const finalCategoryName = NewCategoryName || CategoryName;

        const chsql = "SELECT * FROM tbcategory WHERE (CategoryID = ? OR CategoryName = ?) AND CategoryID != ?";
        db.query(chsql, [finalCategoryID, finalCategoryName, cid], (err, chresult) => {
            if (err) return res.status(401).send({ "msg": "Edit checking error" });
            if (chresult.length > 0) return res.status(300).send({ "msg": "This Category ID or Name already exists" });

            const sql = "UPDATE tbcategory SET CategoryID = ?, CategoryName = ? WHERE CategoryID = ?";
            const val = [finalCategoryID, finalCategoryName, cid];
            db.query(sql, val, (err, result) => {
                if (err) return res.status(400).send({ "msg": "Please check again" });
                if (result.affectedRows === 0) return res.status(404).send({ "msg": "Category not found" });

                // 2. บันทึก Log
                const changeDetails = `ແກ້ໄຂໝວດໝູ່ ID: ${cid}. ID ໃໝ່: ${finalCategoryID}, ຊື່ໃໝ່: '${finalCategoryName}'`;
                writeActivityLog({
                    EmployeeID,
                    EmployeeName,
                    ActionType: 'UPDATE',
                    TargetTable: 'tbcategory',
                    TargetRecordID: cid,
                    ChangeDetails: changeDetails
                });

                return res.status(200).send({ "msg": "Data is edited" });
            });
        });
    } catch (err) {
        console.log(err);
        return res.status(500).send({ "msg": "Path to database not found" });
    }
});


// --- DELETE Endpoint ---
app.delete("/category/:cid", (req, res) => {
    try {
        const cid = req.params.cid;
        // 1. รับข้อมูลพนักงาน
        const { EmployeeID, EmployeeName } = req.body;

        // Find the category name before deleting for logging purposes
        db.query("SELECT CategoryName FROM tbcategory WHERE CategoryID = ?", [cid], (findErr, findResult) => {
            if (findErr || findResult.length === 0) {
                return res.status(404).send({ "msg": "Category not found" });
            }
            const categoryNameToDelete = findResult[0].CategoryName;

            const sql = "DELETE FROM tbcategory WHERE CategoryID = ?";
            db.query(sql, [cid], (err, result) => {
                if (err) {
                    if (err.code === 'ER_ROW_IS_REFERENCED_2') {
                        return res.status(409).json({ message: 'Cannot delete category: It is still in use' });
                    }
                    return res.status(400).send({ "msg": "Delete failed, please check again" });
                }
                if (result.affectedRows === 0) return res.status(404).send({ "msg": "Category not found" });

                // 2. บันทึก Log
                writeActivityLog({
                    EmployeeID,
                    EmployeeName,
                    ActionType: 'DELETE',
                    TargetTable: 'tbcategory',
                    TargetRecordID: cid,
                    ChangeDetails: `ລົບໝວດໝູ່: '${categoryNameToDelete}' (ID: ${cid})`
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
