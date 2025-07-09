const express = require('express')
const core = require('cors')
const Database = require('../Server')

const app = express()
app.use(express.json())
app.use(core())

const connection = new Database()
const db = connection.getConnection()

app.get("/category", function(req, res){
    try{
        const sql = "select * from tbcategory"
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

app.get("/category/:cid", (req, res)=>{
    try{
        const cid = req.params.cid
        const sql = "select * from tbcategory where CategoryID like '%"+cid+"%' or CategoryName like '%"+cid+"%'"
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

app.post("/category", (req,res) =>{
    try{
        const sql = "insert into tbcategory value(?,?)"
        const {CategoryID, CategoryName} = req.body
        const val = [CategoryID, CategoryName]
        const chsql = "select * from tbcategory where CategoryID = ? or CategoryName like ?"
        db.query(chsql,[CategoryID, CategoryName],(err, chresult)=>{
            if(err){
                console.log(err)
                return res.status(401).send({"msg":"Insert checking error"})
            }
            if (chresult.length > 0){
                return res.status(300).send({"msg":"This category already Existed"})
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

app.put("/category/:cid", (req, res) => {
    try {
      const cid = req.params.cid;
      let { NewCategoryID, CategoryName, NewCategoryName } = req.body;
  
      // Default fallback if fields are empty
      NewCategoryID = NewCategoryID || cid;
      NewCategoryName = NewCategoryName || CategoryName;
  
      const checkSQL = "SELECT * FROM tbcategory WHERE (CategoryID = ? OR CategoryName = ?) AND CategoryID != ?";
      db.query(checkSQL, [NewCategoryID, NewCategoryName, cid], (err, checkResult) => {
        if (err) {
          console.log(err);
          return res.status(500).send({ msg: "Edit checking error" });
        }
  
        if (checkResult.length > 0) {
          return res.status(409).send({ msg: "Category ID or Name already exists" });
        }
  
        const updateSQL = "UPDATE tbcategory SET CategoryID = ?, CategoryName = ? WHERE CategoryID = ?";
        db.query(updateSQL, [NewCategoryID, NewCategoryName, cid], (err, result) => {
          if (err) {
            console.log(err);
            return res.status(400).send({ msg: "Update failed" });
          }
          return res.status(200).send({ msg: "Category updated successfully" });
        });
      });
    } catch (err) {
      console.log(err);
      return res.status(500).send({ msg: "Server error" });
    }
  });

app.delete("/category/:cid",(req,res) =>{
    try{
        const cid = req.params.cid
        const sql = "delete from tbcategory where CategoryID = ?"
        const val = [cid]
        db.query(sql, val, (err,result)=>{
            if(err){
                if (err.code === 'ER_ROW_IS_REFERENCED_2') {
                    return res.status(409).json({ 
                      message: 'Cannot delete category: It is still in use' 
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