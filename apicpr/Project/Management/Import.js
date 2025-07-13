const express = require('express');
const core = require('cors');
const Database = require('../Server');

const app = express();
app.use(express.json());
app.use(core());

const connection = new Database();
const db = connection.getConnection();

// --- Helper Functions ---
function queryAsync(sql, params) {
    return new Promise((resolve, reject) => {
        db.query(sql, params, (err, result) => {
            if (err) reject(err);
            else resolve(result);
        });
    });
}

async function writeActivityLog(logData) {
    const { EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails } = logData;
    if (!EmployeeID || !EmployeeName) {
        console.log("Skipping log due to missing employee data.");
        return;
    }
    const logSQL = "INSERT INTO tbactivity_log (EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails) VALUES (?, ?, ?, ?, ?, ?)";
    try {
        await queryAsync(logSQL, [EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails]);
    } catch (logErr) {
        console.log("Error logging activity:", logErr);
    }
}

// --- GET Endpoints ---
app.get("/import", async (req, res) => {
    try {
        const sql = `SELECT i.* FROM tbimport i ORDER BY i.ImportDate DESC, i.ImportID DESC`;
        const result = await queryAsync(sql);
        return res.status(200).json(result);
    } catch (err) {
        return res.status(500).json({ msg: "Database connection error" });
    }
});

app.get("/import/:id", async (req, res) => {
    try {
        const importID = req.params.id;
        const headerSql = `SELECT * FROM tbimport WHERE ImportID = ?`;
        const header = await queryAsync(headerSql, [importID]);

        if (header.length === 0) return res.status(404).json({ msg: "Import record not found" });

        const detailSql = `SELECT id.*, p.ProductName FROM tbimportdetail id JOIN tbproduct p ON id.ProductID = p.ProductID WHERE id.ImportID = ?`;
        const details = await queryAsync(detailSql, [importID]);

        return res.status(200).json({ header: header[0], details: details });
    } catch (err) {
        return res.status(500).json({ msg: "Database connection error" });
    }
});

// --- POST (Create) Endpoint ---
app.post("/import", async (req, res) => {
    await queryAsync("START TRANSACTION");
    try {
        const { ImportDate, ImportTime, SupplierName, InvoiceNumber, Notes, CreatedBy, items, EmployeeID, EmployeeName } = req.body;
        
        let totalItems = 0;
        let totalCost = 0;
        for (const item of items) {
            totalItems += parseInt(item.ImportQuantity);
            totalCost += parseFloat(item.ImportPrice) * parseInt(item.ImportQuantity);
        }

        const importSql = `INSERT INTO tbimport (ImportDate, ImportTime, TotalItems, TotalCost, SupplierName, InvoiceNumber, Notes, Status, CreatedBy) VALUES (?, ?, ?, ?, ?, ?, ?, 'Pending', ?)`;
        const importResult = await queryAsync(importSql, [ImportDate, ImportTime, totalItems, totalCost, SupplierName, InvoiceNumber, Notes, CreatedBy]);
        const importID = importResult.insertId;

        for (const item of items) {
            const [productResult] = await queryAsync("SELECT Quantity FROM tbproduct WHERE ProductID = ?", [item.ProductID]);
            if (!productResult) throw new Error(`Product with ID ${item.ProductID} not found.`);
            
            const itemTotalCost = parseFloat(item.ImportPrice) * parseInt(item.ImportQuantity);
            const detailSql = `INSERT INTO tbimportdetail (ImportID, ProductID, ImportQuantity, ImportPrice, TotalCost, PreviousQuantity) VALUES (?, ?, ?, ?, ?, ?)`;
            await queryAsync(detailSql, [importID, item.ProductID, item.ImportQuantity, item.ImportPrice, itemTotalCost, productResult.Quantity]);
        }
        
        await queryAsync("COMMIT");

        await writeActivityLog({ EmployeeID, EmployeeName, ActionType: 'CREATE', TargetTable: 'tbimport', TargetRecordID: importID, ChangeDetails: `ສ້າງໃບນຳເຂົ້າ #${importID} ຈາກ '${SupplierName}'` });
        return res.status(201).json({ msg: "Import created successfully", importID: importID });
    } catch (err) {
        await queryAsync("ROLLBACK");
        return res.status(500).json({ msg: err.message || "Database transaction failed" });
    }
});


// --- PUT (Update Status) Endpoint ---
app.put("/import/:id/update-status", async (req, res) => {
    await queryAsync("START TRANSACTION");
    try {
        const importID = req.params.id;
        const { status, checkedItems, reason, EmployeeID, EmployeeName } = req.body;

        if (!status || !EmployeeID || !EmployeeName) return res.status(400).json({ msg: "Status, EmployeeID, and EmployeeName are required." });
        
        const [existing] = await queryAsync("SELECT Status FROM tbimport WHERE ImportID = ?", [importID]);
        if (!existing) return res.status(404).json({ msg: "Import record not found" });
        if (existing.Status !== 'Pending') return res.status(400).json({ msg: `Import is already ${existing.Status} and cannot be changed.` });

        if (status === 'Completed') {
            let itemsToProcess = [];
            // If specific items are sent, use them. Otherwise, fetch all items for this import.
            if (checkedItems && checkedItems.length > 0) {
                itemsToProcess = checkedItems;
            } else {
                const allDetails = await queryAsync("SELECT ImportDetailID, ImportQuantity as ReceivedQuantity FROM tbimportdetail WHERE ImportID = ?", [importID]);
                itemsToProcess = allDetails;
            }

            for (const item of itemsToProcess) {
                const { ImportDetailID, ReceivedQuantity } = item;
                const [detail] = await queryAsync("SELECT ProductID FROM tbimportdetail WHERE ImportDetailID = ? AND ImportID = ?", [ImportDetailID, importID]);
                if (!detail) throw new Error(`Import detail ${ImportDetailID} not found`);
                
                await queryAsync("UPDATE tbproduct SET Quantity = Quantity + ? WHERE ProductID = ?", [ReceivedQuantity, detail.ProductID]);
            }
        }

        let updateSql = "UPDATE tbimport SET Status = ? WHERE ImportID = ?";
        let updateParams = [status, importID];
        if (status === 'Cancelled' && reason) {
            updateSql = "UPDATE tbimport SET Status = ?, Notes = CONCAT(COALESCE(Notes, ''), ' [CANCELLED: ', ?, ']') WHERE ImportID = ?";
            updateParams = [status, reason, importID];
        }
        await queryAsync(updateSql, updateParams);
        
        await queryAsync("COMMIT");
        
        let logDetails = `ອັບເດດສະຖານະໃບນຳເຂົ້າ #${importID} ເປັນ '${status}'`;
        if (reason) logDetails += `\nເຫດຜົນ: ${reason}`;
        
        await writeActivityLog({ EmployeeID, EmployeeName, ActionType: 'UPDATE', TargetTable: 'tbimport', TargetRecordID: importID, ChangeDetails: logDetails });
        return res.status(200).json({ msg: `Import status updated to ${status} successfully.` });
    
    } catch (err) {
        await queryAsync("ROLLBACK");
        return res.status(500).json({ msg: err.message || "Database transaction failed." });
    }
});


// --- DELETE Endpoint ---
app.delete("/import/:id", async (req, res) => {
    await queryAsync("START TRANSACTION");
    try {
        const importID = req.params.id;
        const { EmployeeID, EmployeeName } = req.body;

        const [existing] = await queryAsync("SELECT Status FROM tbimport WHERE ImportID = ?", [importID]);
        if (!existing) return res.status(404).json({ msg: "Import record not found" });
        if (existing.Status === 'Completed') return res.status(400).json({ msg: "Cannot delete completed imports" });
        
        await queryAsync("DELETE FROM tbimportdetail WHERE ImportID = ?", [importID]);
        await queryAsync("DELETE FROM tbimport WHERE ImportID = ?", [importID]);
        
        await queryAsync("COMMIT");
        
        await writeActivityLog({ EmployeeID, EmployeeName, ActionType: 'DELETE', TargetTable: 'tbimport', TargetRecordID: importID, ChangeDetails: `ລົບໃບນຳເຂົ້າ #${importID}` });
        return res.status(200).json({ msg: "Import deleted successfully" });
    } catch (err) {
        await queryAsync("ROLLBACK");
        return res.status(500).json({ msg: "Database connection error" });
    }
});

module.exports = app;