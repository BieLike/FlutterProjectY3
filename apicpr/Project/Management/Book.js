const express = require('express')
const core = require('cors')
const Database = require('../Server')

const app = express()
app.use(express.json())
app.use(core())

const connection = new Database()
const db = connection.getConnection()

app.get("/book",function(req,res){
    try{
        const sql = "select * from tbbooks"
        db.query(sql,(err,result,fields)=>{ 
            if(err){
                console.log(err)
                return res.status(400).send()
            }
            console.log(fields)
            return res.status(200).send(result)
        })
    }catch(err){
        console.log(err)
        return res.status(500).send()
    }
})

app.get("/book/:bid",(req,res)=>{
    try {
        const bid = req.params.bid
        const sql= "select * from tbbooks where BID like '%"+bid+"%' or Bname like '%"+bid+"%' or Bprice like '"+bid+"' or Bpage like '"+bid+"' ";
        //const val=[bid]
        db.query(sql,(err,result)=>{
            if(err){
                console.log(err)
                return res.status(400).send()
            }
            return res.status(200).send(result)
        })

    } catch (err) {
        console.log(err)
        return res.status(500).send()
    }
})

app.post("/book",(req, res)=>{
    try {
        const sql="insert into tbbooks value(?,?,?,?)"
        const {bid,bname,bpage,bprice} = req.body
        const val=[bid,bname,bpage,bprice]
        db.query(sql,val,(err,result)=>{
            if(err){
                console.log(err)
                return res.status(400).send()
            }
            return res.status(200).send({"msg":"Data is saved"})
        })
    } catch (err) {
        console.log(err)
        return res.status(500).send(err)
    }
})


app.delete("/book/:bid",(req, res)=>{
    try {
        const bid = req.body.bid
        const val = [bid]
        const sql = "delete from tbbooks where BID = ?"
        db.query(sql,val,(err,result)=>{
            if(err){
                console.log(err)
                return res.status(400).send()
            }
            return res.status(200).send({"msg":"Data has been deleted"})
        })
        
    } catch (err) {
        console.log(err)
        return res.status(500).send(err)
    }
})

app.put("/book/:bid",(req,res)=>{
    try {
        const bid = req.params.bid
    const sql = "Update tbbooks set Bname = ?, Bprice = ?, Bpage = ? where BID = ?"
    const {bname, bprice, bpage} = req.body
    const val = [bname, bprice, bpage, bid]
    db.query(sql,val,(err, result)=>{
        if(err){
            console.log(err)
            return res.status(400).send()
        }
        return res.status(200).send({"msg": "Data has been updated"})
    })
    } catch (error) {
        console.log(err)
        return res.status(500).send({err})
    }
    
})


module.exports = app