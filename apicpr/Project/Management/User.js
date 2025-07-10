const express = require('express')
const core = require('cors')
const Database = require('../Server')

const app = express()
app.use(express.json())
app.use(core())

const connection = new Database()
const db = connection.getConnection()

app.get("/user", function(req, res){
    try{
        const sql = "select *, r.RoleName from tbuser u join tbrole r on u.position = r.RID"
        db.query(sql,(err, result, field)=>{
            if(err){
                console.log(err)
                return res.status(400).send({"msg":"Data not found in database",})
            }
            console.log(field)
            return res.status(200).send(result)
        })
    }catch(err){
        console.log(err)
        return res.status(500).send({"msg":"Path to database not found"})
    }
})

app.post("/user/login", function(req, res){
    try{
        const sql = "select *, r.RoleName from tbuser u join tbrole r on u.position = r.RID where Phone = ? and UserPassword = ?"
        const {Phone, UserPassword} = req.body
        const val =  [Phone, UserPassword]
        db.query(sql,val,(err, result, field)=>{
            if(err){
                console.log(err) 
                return res.status(400).send({"msg":"Data not found in database"})
            }
            if(result != ""){
            console.log(field)
            return res.status(200).send({
                "RoleName": result[0].RoleName,
                "UserFname": result[0].UserFname, success:true})
            }
            else{
                return res.status(401).send({
                    "success": false,
                    "msg": "Invalid credentials"
                })
            }
        })
    }catch(err){
        console.log(err)
        return res.status(500).send({"msg":"Path to database not found"})
    }
})

app.get("/user/:usrid", (req, res)=>{
    try{
        const usrid = req.params.usrid
        const sql = "select *, r.RoleName from tbuser u join tbrole r on u.position = r.RID where UID like '%"+usrid+"%' or UserFname like '%"+usrid+"%' or UserLname like '%"+usrid+"%' or DateOfBirth like '%"+usrid+"%' or Gender like '%"+usrid+"%' or Phone like '%"+usrid+"%' or Email like '%"+usrid+"%' or RoleName like '%"+usrid+"%' "
        db.query(sql,(err, result)=>{
            if(err){
                console.log(err)
                return res.status(400).send({"msg":"Data not found in database"})
            }
            return res.status(200).send(result)
        })
    }catch(err){
        console.log(err)
        return res.status(500).send({"msg":"Path to database not found"})
    }
})

app.post("/user", (req,res) =>{
    try{
        const sql = "insert into tbuser value(NULL,?,?,?,?,?,?,?,?)"
        const {UserFname, UserLname, DateOfBirth, Gender, Phone, Email, Position, UserPassword} = req.body
        const val = [UserFname, UserLname, DateOfBirth, Gender, Phone, Email, Position, UserPassword]
        const chsql = "select * from tbuser where Phone = ? or Email like ? or UserPassword like ?"
        db.query(chsql,[Phone, Email, UserPassword],(err, chresult)=>{
            if(err){
                console.log(err)
                return res.status(400).send({"msg":"Insert checking error"})
            }
            if (chresult.length > 0){
                return res.status(300).send({"msg":"This phone/email/Password already Existed"})
            }
            else{    
            db.query(sql,val,(err,result) =>{
                if(err){
                    console.log(err)
                    return res.status(400).send({"msg":"Please check again"})
                }
                return res.status(200).send({"msg":"Data is saved"})
        })
            }
        })

    }catch(err){
        console.log(err)
        return res.status(500).send({"msg":"Path to database not found"})
    }
})

app.put("/user/:usrid", (req,res)=>{
    try{
        const usrid = req.params.usrid
        const sql = "update tbuser set UserFname = ?, UserLname = ?, DateOfBirth = ?, Gender = ?, Phone = ?, Email = ?, Position = ?, UserPassword = ? where UID = ? "
        const {UserFname, UserLname, DateOfBirth, Gender, Phone, Email, Position, UserPassword} = req.body
        const val = [UserFname, UserLname, DateOfBirth, Gender, Phone, Email, Position, UserPassword, usrid]
        
        // Check for duplicates excluding current user
        const chsql = "select * from tbuser where (Phone = ? or Email = ?) and UID != ?"
        db.query(chsql,[Phone, Email, usrid],(err, chresult)=>{
            if(err){
                console.log(err)
                return res.status(400).send({"msg":"Edit checking error"})
            }
            if (chresult.length > 0){
                return res.status(300).send({"msg":"This phone/email already exists"})
            }
            else{  
                db.query(sql,val, (err,result) =>{
                    if(err){
                        console.log(err)
                        return res.status(400).send({"msg":"Please check again"})
                    } 
                    return res.status(200).send({"msg":"Data is edited"})
                })
             }
        })
        
    }catch(err){
        console.log(err)
        return res.status(500).send({"msg":"Path to database not found"})
    }
})


app.delete("/user/:usrid",(req,res) =>{
    try{
        const usrid = req.params.usrid
        const sql = "delete from tbuser where UID = ?"
        const val = [usrid]
        db.query(sql, val, (err,result)=>{
            if(err){
                console.log(err)
                return res.status.send({"msg":"Please check again"})
            }
            return res.status(200).send({"msg":"Data has been deleted"})
        })

    }catch(err){
        if (error.code === 'ER_ROW_IS_REFERENCED_2') {
            return res.status(409).json({ 
              message: 'Cannot delete : It is still in use' 
            });
        }
        else {
            console.log(err)
            return res.status(500).send({"msg":"Path to database not found"})
        }
    }
})



module.exports = app