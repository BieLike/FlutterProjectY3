const express = require('express')
const cors = require('cors')
const Database = require('../Server')

const app = express()
app.use(express.json())
app.use(cors())

const connection = new Database()
const db = connection.getConnection()

// 🔎 GET All Authors
app.get("/author", (req, res) => {
    try {
        const sql = "SELECT * FROM tbauthor"
        db.query(sql, (err, result, field) => {
            if (err) {
                console.log(err)
                return res.status(404).send({ "msg": "Data not found in database" })
            }
            console.log(field) // Log field information as in the provided unit code
            return res.status(200).send(result)
        })
    } catch (err) {
        console.log(err)
        // Changed error message to match the unit code's style
        return res.status(500).send({ "msg": "Path to database not found" })
    }
})

// 🔎 GET Author by ID or Name
app.get("/author/:search", (req, res) => {
    try {
        const search = req.params.search
        // Using parameterized query for safety and LIKE syntax
        const sql = "SELECT * FROM tbauthor WHERE authorID LIKE ? OR name LIKE ?"
        const searchParam = `%${search}%` // Add wildcards for LIKE search
        db.query(sql, [searchParam, searchParam], (err, result) => {
            if (err) {
                console.log(err)
                return res.status(404).send({ "msg": "Data not found in database" })
            }
            return res.status(200).send(result)
        })
    } catch (err) {
        console.log(err)
        // Changed error message to match the unit code's style
        return res.status(500).send({ "msg": "Path to database not found" })
    }
})

// ➕ POST Insert New Author
app.post("/author", (req, res) => {
    try {
        const { authorID, name } = req.body
        const val = [authorID, name]
        // Check for existing authorID or name
        const checkSQL = "SELECT * FROM tbauthor WHERE authorID = ? OR name = ?"

        db.query(checkSQL, [authorID, name], (err, checkResult) => {
            if (err) {
                console.log(err)
                // Keeping status 401 as in the provided unit code for checking error
                return res.status(401).send({ "msg": "Insert checking error" })
            }
            if (checkResult.length > 0) {
                // Keeping status 300 as in the provided unit code for conflict
                return res.status(300).send({ "msg": "This author already Existed" })
            } else {
                const insertSQL = "INSERT INTO tbauthor VALUES(?,?)"
                db.query(insertSQL, val, (err, result) => {
                    if (err) {
                        console.log(err)
                        // Keeping status 400 as in the provided unit code for insert failure
                        return res.status(400).send({ "msg": "Please check again" })
                    }
                    // Keeping success message as in the provided unit code
                    return res.status(200).send({ "msg": "Data is saved" })
                })
            }
        })
    } catch (err) {
        console.log(err)
        // Changed error message to match the unit code's style
        return res.status(500).send({ "msg": "Path to database not found" })
    }
})

// ✏️ PUT Update Author
app.put("/author/:id", (req, res) => {
    try {
        const id = req.params.id; // Original authorID from URL parameter
        let { NewAuthorID, name, NewName } = req.body; // 'name' is the existing name, 'NewName' is the potential new name

        // Default fallback if fields are empty or not provided
        // If NewAuthorID is not provided, use the original ID from params
        NewAuthorID = NewAuthorID || id;
        // If NewName is not provided, use the existing 'name' from the body (if available), or keep it undefined if neither is present.
        // It's safer to get the current name from the DB if NewName is not provided, but for simplicity, matching the pattern.
        // A more robust solution would fetch the current name from DB if NewName is null/undefined.
        NewName = NewName || name; 

        // Check if the new authorID or name already exists for *other* authors
        const checkSQL = "SELECT * FROM tbauthor WHERE (authorID = ? OR name = ?) AND authorID != ?";
        db.query(checkSQL, [NewAuthorID, NewName, id], (err, checkResult) => {
            if (err) {
                console.log(err);
                // Keeping status 500 as in the provided unit code for checking error
                return res.status(500).send({ msg: "Edit checking error" });
            }

            if (checkResult.length > 0) {
                // Keeping status 409 as in the provided unit code for conflict
                return res.status(409).send({ msg: "Author ID or name already exists" });
            }

            // Perform the update
            const updateSQL = "UPDATE tbauthor SET authorID = ?, name = ? WHERE authorID = ?";
            db.query(updateSQL, [NewAuthorID, NewName, id], (err, result) => {
                if (err) {
                    console.log(err);
                    // Keeping status 400 as in the provided unit code for update failure
                    return res.status(400).send({ msg: "Update failed" });
                }
                // Keeping success message as in the provided unit code
                return res.status(200).send({ msg: "Author updated successfully" });
            });
        });
    } catch (err) {
        console.log(err);
        // Changed error message to match the unit code's style
        return res.status(500).send({ msg: "Path to database not found" });
    }
});

// ❌ DELETE Author
app.delete("/author/:id", (req, res) => {
    try {
        const id = req.params.id // Original authorID from URL parameter
        const sql = "DELETE FROM tbauthor WHERE authorID = ?"
        const val = [id]
        db.query(sql, val, (err, result) => {
            if (err) {
                // Corrected variable name from 'error' to 'err'
                if (err.code === 'ER_ROW_IS_REFERENCED_2') {
                    // Keeping status 409 and message as in the provided unit code
                    return res.status(409).json({
                        message: 'Cannot delete author: It is still in use'
                    });
                }
                console.log(err)
                // Keeping status 400 as in the provided unit code for delete failure
                return res.status(400).send({ "msg": "Please check again" })
            }
            // Keeping success message as in the provided unit code
            return res.status(200).send({ "msg": "Data has been deleted" })
        })

    } catch (err) {
        console.log(err)
        // Changed error message to match the unit code's style
        return res.status(500).send({ "msg": "Path to database not found" })
    }
})

module.exports = app
