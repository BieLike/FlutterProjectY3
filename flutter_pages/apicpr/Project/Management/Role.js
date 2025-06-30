const express = require('express')
const core = require('cors')
const Database = require('../Server')

const app = express()
app.use(express.json())
app.use(core())

const connection = new Database()
const db = connection.getConnection()

// GET all roles
app.get("/role", function(req, res){
    try{
        const sql = "SELECT * FROM tbrole ORDER BY RID"
        db.query(sql,(err, result, field)=>{
            if(err){
                console.log(err)
                return res.status(404).send({"msg":"Data not found in database"})
            }
            console.log(field)
            return res.status(200).send(result)
        })
    }catch(err){
        console.log(err)
        return res.status(500).send({"msg":"Path to database not found"})
    }
})

// GET role by ID or Name (search functionality)
app.get("/role/:rid", (req, res)=>{
    try{
        const rid = req.params.rid
        // Search by RID or RoleName - handles both numeric ID and text search
        const sql = "SELECT * FROM tbrole WHERE RID LIKE '%"+rid+"%' OR RoleName LIKE '%"+rid+"%'"
        db.query(sql,(err, result)=>{
            if(err){
                console.log(err)
                return res.status(404).send({"msg":"Data not found in database"})
            }
            return res.status(200).send(result)
        })
    }catch(err){
        console.log(err)
        return res.status(500).send({"msg":"Path to database not found"})
    }
})

// POST - Create new role
app.post("/role", (req,res) =>{
    try{
        const {RID, RoleName, BaseSalary} = req.body
        
        // Input validation - check if required fields are provided
        if(!RID || !RoleName || BaseSalary === undefined || BaseSalary === null){
            return res.status(400).send({"msg":"All fields (RID, RoleName, BaseSalary) are required"})
        }
        
        // Validate RID is numeric (int(5) means max 5 digits)
        if(isNaN(RID) || RID.toString().length > 5 || RID < 1){
            return res.status(400).send({"msg":"RID must be a valid number (1-5 digits)"})
        }
        
        // Validate RoleName length (varchar(20))
        if(RoleName.length > 20 || RoleName.trim() === ""){
            return res.status(400).send({"msg":"RoleName must be 1-20 characters long"})
        }
        
        // Validate BaseSalary is numeric and positive (int(8) means max 8 digits)
        if(isNaN(BaseSalary) || BaseSalary < 0 || BaseSalary.toString().length > 8){
            return res.status(400).send({"msg":"BaseSalary must be a valid positive number (max 8 digits)"})
        }
        
        const sql = "INSERT INTO tbrole VALUES(?,?,?)"
        const val = [RID, RoleName.trim(), BaseSalary]
        
        // Check if RID or RoleName already exists
        const chsql = "SELECT * FROM tbrole WHERE RID = ? OR RoleName = ?"
        db.query(chsql,[RID, RoleName.trim()],(err, chresult)=>{
            if(err){
                console.log(err)
                return res.status(401).send({"msg":"Insert checking error"})
            }
            if (chresult.length > 0){
                return res.status(300).send({"msg":"This role ID or name already exists"})
            }
            else{    
                db.query(sql,val,(err,result) =>{
                    if(err){
                        console.log(err)
                        return res.status(400).send({"msg":"Please check again - Insert failed"})
                    }
                    return res.status(200).send({"msg":"Role data is saved successfully"})
                })
            }
        })

    }catch(err){
        console.log(err)
        return res.status(500).send({"msg":"Path to database not found"})
    }
})

// PUT - Update existing role
app.put("/role/:rid", (req, res) => {
    try {
        const rid = req.params.rid;
        let { NewRID, RoleName, NewRoleName, BaseSalary, NewBaseSalary } = req.body;
        
        // Input validation for URL parameter
        if(isNaN(rid)){
            return res.status(400).send({"msg":"Invalid Role ID in URL"})
        }
        
        // Default fallback if fields are empty - keep original values
        NewRID = NewRID || rid;
        NewRoleName = NewRoleName || RoleName;
        NewBaseSalary = (NewBaseSalary !== undefined && NewBaseSalary !== null) ? NewBaseSalary : BaseSalary;
        
        // Validate new values
        if(isNaN(NewRID) || NewRID.toString().length > 5 || NewRID < 1){
            return res.status(400).send({"msg":"New RID must be a valid number (1-5 digits)"})
        }
        
        if(!NewRoleName || NewRoleName.length > 20 || NewRoleName.trim() === ""){
            return res.status(400).send({"msg":"New RoleName must be 1-20 characters long"})
        }
        
        if(isNaN(NewBaseSalary) || NewBaseSalary < 0 || NewBaseSalary.toString().length > 8){
            return res.status(400).send({"msg":"New BaseSalary must be a valid positive number (max 8 digits)"})
        }
        
        // Check if new RID or RoleName already exists (excluding current record)
        const checkSQL = "SELECT * FROM tbrole WHERE (RID = ? OR RoleName = ?) AND RID != ?";
        db.query(checkSQL, [NewRID, NewRoleName.trim(), rid], (err, checkResult) => {
            if (err) {
                console.log(err);
                return res.status(500).send({ msg: "Edit checking error" });
            }
            
            if (checkResult.length > 0) {
                return res.status(409).send({ msg: "Role ID or Name already exists" });
            }
            
            // Update the role
            const updateSQL = "UPDATE tbrole SET RID = ?, RoleName = ?, BaseSalary = ? WHERE RID = ?";
            db.query(updateSQL, [NewRID, NewRoleName.trim(), NewBaseSalary, rid], (err, result) => {
                if (err) {
                    console.log(err);
                    return res.status(400).send({ msg: "Update failed" });
                }
                
                // Check if any rows were affected (role exists)
                if(result.affectedRows === 0){
                    return res.status(404).send({ msg: "Role not found" });
                }
                
                return res.status(200).send({ msg: "Role updated successfully" });
            });
        });
    } catch (err) {
        console.log(err);
        return res.status(500).send({ msg: "Server error" });
    }
});

// DELETE role by ID
app.delete("/role/:rid",(req,res) =>{
    try{
        const rid = req.params.rid
        
        // Validate RID parameter
        if(isNaN(rid)){
            return res.status(400).send({"msg":"Invalid Role ID"})
        }
        
        const sql = "DELETE FROM tbrole WHERE RID = ?"
        const val = [rid]
        
        db.query(sql, val, (err,result)=>{
            if(err){
                // Handle foreign key constraint error (if role is referenced by other tables)
                if (err.code === 'ER_ROW_IS_REFERENCED_2') {
                    return res.status(409).json({ 
                        message: 'Cannot delete role: It is still in use by other records' 
                    });
                }
                console.log(err)
                return res.status(400).send({"msg":"Delete operation failed"})
            }
            
            // Check if any rows were affected (role exists)
            if(result.affectedRows === 0){
                return res.status(404).send({"msg":"Role not found"})
            }
            
            return res.status(200).send({"msg":"Role has been deleted successfully"})
        })

    }catch(err){
        console.log(err)
        return res.status(500).send({"msg":"Path to database not found"})
    }
})

module.exports = app