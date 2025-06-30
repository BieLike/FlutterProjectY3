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
                return res.status(400).send({"msg":"Data not found in database"})
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
                return res.status(400).send({"msg":"Data not found in database"})
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

app.put("/category/:cid", (req,res)=>{
    try{
        const cid = req.params.cid
        const sql = "update tbcategory set CategoryID = ?, CategoryName = ? where CategoryID = ?"
        const {NewCategoryID, NewCategoryName, CategoryName} = req.body
        const val = [NewCategoryID, NewCategoryName, cid]
        const chsql = "select * from tbcategory where CategoryID = ? or CategoryName like ?"
        db.query(chsql,[NewCategoryID, NewCategoryName],(err, chresult)=>{
            if(err){
                console.log(err)
                return res.status(401).send({"msg":"Edit checking error"})
            }
            if (chresult.length > 0){
                if (chresult[0].CategoryID == cid || chresult[0].CategoryName == CategoryName){
                    NewCategoryID = cid
                    NewCategoryName = CategoryName
                    const val = [NewCategoryID, NewCategoryName, cid]
                    db.query(sql,val, (err,result) =>{
                        if(err){
                            console.log(err)
                            return res.status(400).send({"msg":"Please check again"})
                        } 
                        return res.status(205).send({"msg":"Data is edited"})
                    })
                }
                return res.status(300).send({"msg":"This Category ID or Name already Existed"})
            }
            else if ((NewCategoryID == "" || NewCategoryID == cid) && (NewCategoryName == CategoryName || NewCategoryName == "")){
                NewCategoryID = cid
                NewCategoryName = CategoryName
                const val = [NewCategoryID, NewCategoryName, cid]
                db.query(sql,val, (err,result) =>{
                    if(err){
                        console.log(err)
                        return res.status(400).send({"msg":"Please check again"})
                    } 
                    return res.status(200).send({"msg":"Data is edited"})
                })
            }
            else if ((NewCategoryID == "" || NewCategoryName == "") && (NewCategoryID != cid || NewCategoryName != CategoryName)){
                if(NewCategoryID == ""){
                    NewCategoryID = cid
                }
                else{
                NewCategoryName = CategoryName
                }
                const val = [NewCategoryID, NewCategoryName, cid]
                db.query(sql,val, (err,result) =>{
                    if(err){
                        console.log(err)
                        return res.status(400).send({"msg":"Please check again"})
                    } 
                    return res.status(200).send({"msg":"Data is edited"})
                })
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
        db.query(sql,val, (err,result) =>{
            if(err){
                console.log(err)
                return res.status(400).send({"msg":"Please check again"})
            }
            return res.status(200).send({"msg":"Data is edited"})
        })

    }catch(err){
        console.log(err)
        return res.status(500).send({"msg":"Path to database not found"})
    }
})


app.delete("/category/:cid",(req,res) =>{
    try{
        const cid = req.params.cid
        const sql = "delete from tbCategory where CategoryID = ?"
        const val = [cid]
        db.query(sql, val, (err,result)=>{
            if(err){
                if (error.code === 'ER_ROW_IS_REFERENCED_2') {
                    return res.status(409).json({ 
                      message: 'Cannot delete category: It is still in use' 
                    });
                }
                console.log(err)
                return res.status.send({"msg":"Please check again"})
            }
            return res.status(200).send({"msg":"Data has been deleted"})
        })

    }catch(err){
            console.log(err)
            return res.status(500).send({"msg":"Path to database not found"})
    }
})



module.exports = app