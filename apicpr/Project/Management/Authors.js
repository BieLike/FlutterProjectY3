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
    // This function remains the same
    const { EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails } = logData;
    const logSQL = "INSERT INTO tbactivity_log (EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails) VALUES (?, ?, ?, ?, ?, ?)";
    try {
        // Using a promise-wrapper for consistency, though fire-and-forget is also fine here
        await new Promise((resolve, reject) => {
            db.query(logSQL, [EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails], (err, result) => {
                if (err) reject(err);
                resolve(result);
            });
        });
    } catch (logErr) {
        console.log("Error logging activity:", logErr);
    }
}


// --- 🔎 GET ALL Authors (FIXED) ---
app.get("/author", (req, res) => {
    try {
        const sql = "SELECT * FROM tbauthor ORDER BY name ASC";
        db.query(sql, (err, result) => {
            if (err) {
                console.error("Error fetching authors:", err);
                return res.status(500).json({ msg: "Failed to retrieve authors." });
            }
            return res.status(200).json(result);
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: "Server error occurred." });
    }
});

// --- 🔎 GET Author by ID or Name (Search - FIXED) ---
app.get("/author/:search", (req, res) => {
    try {
        const searchTerm = `%${req.params.search}%`;
        const sql = "SELECT * FROM tbauthor WHERE authorID LIKE ? OR name LIKE ?";
        db.query(sql, [searchTerm, searchTerm], (err, result) => {
            if (err) {
                console.error("Error searching authors:", err);
                return res.status(500).json({ msg: "Failed to search for authors." });
            }
            if (result.length === 0) {
                return res.status(404).json({ msg: "No authors found matching the search term." });
            }
            return res.status(200).json(result);
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ msg: "Server error occurred." });
    }
});


// --- ➕ POST Insert New Author ---
app.post("/author", (req, res) => {
    try {
        const { authorID, name, EmployeeID, EmployeeName } = req.body;
        
        const val = [authorID, name];
        const checkSQL = "SELECT * FROM tbauthor WHERE authorID = ? OR name = ?";

        db.query(checkSQL, [authorID, name], (err, checkResult) => {
            if (err) return res.status(401).send({ "msg": "Insert checking error" });
            if (checkResult.length > 0) return res.status(300).send({ "msg": "This author already Existed" });
            
            const insertSQL = "INSERT INTO tbauthor (authorID, name) VALUES(?,?)";
            db.query(insertSQL, val, (err, result) => {
                if (err) return res.status(400).send({ "msg": "Please check again" });

                // 2. บันทึก Log
                writeActivityLog({
                    EmployeeID,
                    EmployeeName,
                    ActionType: 'CREATE',
                    TargetTable: 'tbauthor',
                    TargetRecordID: authorID,
                    ChangeDetails: `ສ້າງຜູ້ຂຽນໃໝ່: '${name}' (ID: ${authorID})`
                });

                return res.status(200).send({ "msg": "Data is saved" });
            });
        });
    } catch (err) {
        console.log(err);
        return res.status(500).send({ "msg": "Path to database not found" });
    }
});


// --- ✏️ PUT Update Author ---
app.put("/author/:id", (req, res) => {
    try {
        const id = req.params.id;
        
        let { NewAuthorID, name, NewName, EmployeeID, EmployeeName } = req.body;

        NewAuthorID = NewAuthorID || id;
        NewName = NewName || name; 

        const checkSQL = "SELECT * FROM tbauthor WHERE (authorID = ? OR name = ?) AND authorID != ?";
        db.query(checkSQL, [NewAuthorID, NewName, id], (err, checkResult) => {
            if (err) return res.status(500).send({ msg: "Edit checking error" });
            if (checkResult.length > 0) return res.status(409).send({ msg: "Author ID or name already exists" });

            const updateSQL = "UPDATE tbauthor SET authorID = ?, name = ? WHERE authorID = ?";
            db.query(updateSQL, [NewAuthorID, NewName, id], (err, result) => {
                if (err) return res.status(400).send({ msg: "Update failed" });

                if (result.affectedRows === 0) {
                    return res.status(404).send({ msg: "Author not found" });
                }

                // 2. ບັນທຶກ Log
                const changeDetails = `ແກ້ໄຂຜູ້ຂຽນ ID: ${id}. ID ໃໝ່: ${NewAuthorID}, ຊື່ໃໝ່: '${NewName}'`;
                writeActivityLog({
                    EmployeeID,
                    EmployeeName,
                    ActionType: 'UPDATE',
                    TargetTable: 'tbauthor',
                    TargetRecordID: id,
                    ChangeDetails: changeDetails
                });

                return res.status(200).send({ msg: "Author updated successfully" });
            });
        });
    } catch (err) {
        console.log(err);
        return res.status(500).send({ "msg": "Path to database not found" });
    }
});


// --- ❌ DELETE Author ---
app.delete("/author/:id", (req, res) => {
    try {
        const id = req.params.id;
        
        const { EmployeeID, EmployeeName } = req.body;

        
        db.query("SELECT name FROM tbauthor WHERE authorID = ?", [id], (findErr, findResult) => {
            if (findErr || findResult.length === 0) {
                return res.status(404).send({ "msg": "Author not found" });
            }
            const authorNameToDelete = findResult[0].name;

            const sql = "DELETE FROM tbauthor WHERE authorID = ?";
            db.query(sql, [id], (err, result) => {
                if (err) {
                    if (err.code === 'ER_ROW_IS_REFERENCED_2') {
                        return res.status(409).json({ message: 'Cannot delete author: It is still in use by other records (e.g., products)' });
                    }
                    return res.status(400).send({ "msg": "Please check again" });
                }

                if (result.affectedRows === 0) {
                    return res.status(404).send({ msg: "Author not found" });
                }
                
                // 2. บันทึก Log
                writeActivityLog({
                    EmployeeID,
                    EmployeeName,
                    ActionType: 'DELETE',
                    TargetTable: 'tbauthor',
                    TargetRecordID: id,
                    ChangeDetails: `ລົບຜູ້ຂຽນ: '${authorNameToDelete}' (ID: ${id})`
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