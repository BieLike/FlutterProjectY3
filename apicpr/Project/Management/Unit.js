const express = require('express')
const core = require('cors')
const Database = require('../Server')

const app = express()
app.use(express.json())
app.use(core())

const connection = new Database()
const db = connection.getConnection()

app.get("/unit", function(req, res){
    try{
        const sql = "select * from tbunit"
        db.query(sql,(err, result, field)=>{
            if(err){
                console.log(err)
                return res.status(404).send({"msg":"Data not found in database",})
            }
            console.log(field)
            return res.status(200).send(result)
        })
    }catch(err){
        console.log(err)
        return res.status(500).send({"msg":"Path to database not found"})
    }
})

app.get("/unit/:uid", (req, res)=>{
    try{
        const uid = req.params.uid
        const sql = "select * from tbunit where UnitID like '%"+uid+"%' or UnitName like '%"+uid+"%'"
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

app.post("/unit", (req,res) =>{
    try{
        const sql = "insert into tbunit value(?,?)"
        const {UnitID, UnitName} = req.body
        const val = [UnitID, UnitName]
        const chsql = "select * from tbunit where UnitID = ? or UnitName like ?"
        db.query(chsql,[UnitID, UnitName],(err, chresult)=>{
            if(err){
                console.log(err)
                return res.status(401).send({"msg":"Insert checking error"})
            }
            if (chresult.length > 0){
                return res.status(300).send({"msg":"This unit already Existed"})
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

// app.put("/unit/:uid", (req,res)=>{
//     try{
//         const uid = req.params.uid
//         const sql = "update tbunit set UnitID = ?, UnitName = ? where UnitID = ?"
//         const {NewUnitID, UnitName, NewUnitName} = req.body
//         const val = [NewUnitID, NewUnitName, uid]
//         const chsql = "select * from tbunit where UnitID = ? or UnitName like ?"
//         db.query(chsql,[NewUnitID, NewUnitName],(err, chresult)=>{
//             if(err){
//                 console.log(err)
//                 return res.status(401).send({"msg":"Edit checking error"})
//             }if (chresult.length > 0){
//                 if (chresult[0].UnitID == uid || chresult[0].UnitName == UnitName){
//                     NewUnitID = uid
//                     NewUnitName = UnitName
//                     const val = [NewUnitID, NewUnitName, uid]
//                     db.query(sql,val, (err,result) =>{
//                         if(err){
//                             console.log(err)
//                             return res.status(400).send({"msg":"Please check again"})
//                         } 
//                         return res.status(200).send({"msg":"Data is edited"})
//                     })  
//                 }
//                 return res.status(300).send({"msg":"This Unit ID or Name already Existed"})
//             }
//             else if ((NewUnitID == "" || NewUnitID == uid) && (NewUnitName == UnitName || NewUnitName == "")){
//                 NewUnitID = uid
//                 NewUnitName = UnitName
//                 const val = [NewUnitID, NewUnitName, uid]
//                 db.query(sql,val, (err,result) =>{
//                     if(err){
//                         console.log(err)
//                         return res.status(400).send({"msg":"Please check again"})
//                     } 
//                     return res.status(200).send({"msg":"Data is edited"})
//                 })
//             }
//             else if ((NewUnitID == "" || NewUnitName == "") && (NewUnitID != uid || NewUnitName != UnitName)){
//                 if(NewUnitID == ""){
//                     NewUnitID = uid
//                 }else{
//                 NewUnitName = UnitName
//                 }
//                 const val = [NewUnitID, NewUnitName, uid]
//                 db.query(sql,val, (err,result) =>{
//                     if(err){
//                         console.log(err)
//                         return res.status(400).send({"msg":"Please check again"})
//                     } 
//                     return res.status(200).send({"msg":"Data is edited"})
//                 })
//             }
//             else{  
//                 db.query(sql,val, (err,result) =>{
//                     if(err){
//                         console.log(err)
//                         return res.status(400).send({"msg":"Please check again"})
//                     } 
//                     return res.status(200).send({"msg":"Data is edited"})
//                 })
//              }
//         })
        
//     }catch(err){
//         console.log(err)
//         return res.status(500).send({"msg":"Path to database not found"})
//     }
// })

app.put("/unit/:uid", (req, res) => {
    try {
      const uid = req.params.uid;
      let { NewUnitID, UnitName, NewUnitName } = req.body;
  
      // Default fallback if fields are empty
      NewUnitID = NewUnitID || uid;
      NewUnitName = NewUnitName || UnitName;
  
      const checkSQL = "SELECT * FROM tbunit WHERE (UnitID = ? OR UnitName = ?) AND UnitID != ?";
      db.query(checkSQL, [NewUnitID, NewUnitName, uid], (err, checkResult) => {
        if (err) {
          console.log(err);
          return res.status(500).send({ msg: "Edit checking error" });
        }
  
        if (checkResult.length > 0) {
          return res.status(409).send({ msg: "Unit ID or Name already exists" });
        }
  
        const updateSQL = "UPDATE tbunit SET UnitID = ?, UnitName = ? WHERE UnitID = ?";
        db.query(updateSQL, [NewUnitID, NewUnitName, uid], (err, result) => {
          if (err) {
            console.log(err);
            return res.status(400).send({ msg: "Update failed" });
          }
          return res.status(200).send({ msg: "Unit updated successfully" });
        });
      });
    } catch (err) {
      console.log(err);
      return res.status(500).send({ msg: "Server error" });
    }
  });
  


app.delete("/unit/:uid",(req,res) =>{
    try{
        const uid = req.params.uid
        const sql = "delete from tbunit where UnitID = ?"
        const val = [uid]
        db.query(sql, val, (err,result)=>{
            if(err){
                if (error.code === 'ER_ROW_IS_REFERENCED_2') {
                    return res.status(409).json({ 
                      message: 'Cannot delete unit: It is still in use' 
                    });
                }
                console.log(err)
                return res.status(400).send({"msg":"Please check again"})
            }
            return res.status(200).send({"msg":"Data has been deleted"})
        })

    }catch(err){
            console.log(err)
            return res.status(500).send({"msg":"Path to database not found"})
    }
})



module.exports = app