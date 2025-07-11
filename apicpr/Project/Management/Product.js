const express = require('express')
const core = require('cors')
const Database = require('../Server')
const os = require('os')

const app = express()
app.use(express.json())
app.use(core())

const connection = new Database()
const db = connection.getConnection()

function queryAsync(sql, params) {
    return new Promise((resolve, reject) => {
      db.query(sql, params, (err, result) => {
        if (err) reject(err);
        else resolve(result);
      });
    });
  }

app.get("/product", function(req, res){
    try{
        const sql = "select *, c.CategoryName, u.UnitName from tbproduct p join tbunit u on p.UnitID = u.UnitID join tbcategory c on p.CategoryID = c.CategoryID"
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

app.get("/product/:pid", (req, res)=>{
    try{
        const pid = req.params.pid
        const sql = "select *, c.CategoryName, u.UnitName from tbproduct p join tbunit u on p.UnitID = u.UnitID join tbcategory c on p.CategoryID = c.CategoryID where ProductID like '%"+pid+"%' or ProductName like '%"+pid+"%' or Quantity like '%"+pid+"%' or ImportPrice like '%"+pid+"%' or SellPrice like '%"+pid+"%' or UnitName like '%"+pid+"%' or CategoryName like '%"+pid+"%' or u.UnitID like '%"+pid+"%' or c.CategoryID like '%"+pid+"%' or Balance like '%"+pid+"%' or Level like '%"+pid+"%' "
        db.query(sql,(err, result)=>{
            if(err){
                console.log(err)
                return res.status(400).send({"msg":"Data not found in database"})
            }
            if (result == ""){
                return res.status(300).send({"msg":"Not found the product"})

            }
            return res.status(200).send(result)
        })
    }catch(err){
        console.log(err)
        return res.status(500).send({"msg":"Path to database not found"})
    }
})

app.post("/product", (req,res) =>{
    try{
        const sql = "insert into tbproduct value(?,?,?,?,?,?,?,?,?,?)"
        const {ProductID, ProductName, Quantity, ImportPrice, SellPrice, UnitID, CategoryID, Authors, Balance, Level} = req.body
        const val = [ProductID, ProductName, Quantity, ImportPrice, SellPrice, UnitID, CategoryID, Authors, Balance, Level]
        const chsql = "select * from tbproduct where ProductID = ? or ProductName like ? "
const clientInfo = req.clientInfo || { hostname: 'Unknown Computer', serverHostname: os.hostname()};//ດຶງຂໍ້ມູນເຄື່ອງ
        db.query(chsql,[ProductID, ProductName],(err, chresult)=>{
            if(err){
                console.log(err)
                return res.status(401).send({
                    "msg":"Insert checking error",  "clientInfo": clientInfo//ເພີ່ມຂໍ້ມູນເຄື່ອງໃນການແຈ້ງກັບ
                    })
                
            }
            if (chresult.length > 0){
                return res.status(300).send({
                    "msg":"This Product already Existed", "clientInfo": clientInfo//ເພີ່ມຂໍ້ມູນເຄື່ອງໃນການແຈ້ງກັບ
                    })
            }
            else{    
            db.query(sql,val,(err,result) =>{
                if(err){
                    console.log(err)
                    return res.status(400).send({
                        "msg":"Please check again", "clientInfo": clientInfo//ເພີ່ມຂໍ້ມູນເຄື່ອງໃນການແຈ້ງກັບ
                        })
                }
                return res.status(200).send({
                    "msg":"Data is saved", "clientInfo": clientInfo//ເພີ່ມຂໍ້ມູນເຄື່ອງໃນການແຈ້ງກັບ
                    })
             })
            }
        })
    }catch(err){
        console.log(err)
        return res.status(500).send({
            "msg":"Path to database not found"
            })
    }
})


// })

app.put("/product/:pid", (req, res) => {
    try {
        const pid = req.params.pid;
        let {
            NewProductID, ProductName, NewProductName,
            Quantity, ImportPrice, SellPrice,
            UnitID, CategoryID, Authors, Balance, Level
        } = req.body;

        const chsql = "SELECT * FROM tbproduct WHERE ProductID = ? OR ProductName = ?";
        const sql = "UPDATE tbproduct SET ProductID = ?, ProductName = ?, Quantity = ?, ImportPrice = ?, SellPrice = ?, UnitID = ?, CategoryID = ?, authorsID = ?, Balance = ?, Level = ? WHERE ProductID = ?";

        const clientInfo = req.clientInfo || { hostname: 'Unknown Computer', serverHostname: os.hostname() };

        db.query(chsql, [NewProductID, NewProductName], (err, chresult) => {
            if (err) {
                console.log(err);
                return res.status(401).send({ msg: "Edit checking error", clientInfo });
            }

            if (chresult.length > 0) {
                const existing = chresult[0];
                if (existing.ProductID !== pid && existing.ProductName !== ProductName) {
                    return res.status(300).send({ msg: "This Product ID or Name already exists", clientInfo });
                }
            }

            // Use existing if blank
            if (!NewProductID) NewProductID = pid;
            if (!NewProductName) NewProductName = ProductName;

            const val = [NewProductID, NewProductName, Quantity, ImportPrice, SellPrice, UnitID, CategoryID, Authors, Balance, Level, pid];

            db.query(sql, val, (err, result) => {
                if (err) {
                    console.log(err);
                    return res.status(400).send({ msg: "Please check again", clientInfo });
                }
                return res.status(200).send({ msg: "Data is edited", clientInfo });
            });
        });
    } catch (err) {
        console.log(err);
        return res.status(500).send({ msg: "Path to database not found" });
    }
});


app.post("/product/sell", async (req, res) => {
    try {
        const items = req.body.SaleDetails; // ດຶງ items ຈາກ SaleDetails
        const { Date, Time, Subtotal, GrandTotal, Money, Change, PaymentMethod, Employee, Member } = req.body; // ດຶງຂໍ້ມູນຈາກ Body ໂດຍກົງ
        
        const sql = "update tbproduct set Quantity = Quantity - ? where ProductID = ?";
        const sellDsql = "insert into tbselldetail (SellID, ProductID, Price, Quantity, Total) value(?, ?, ?, ?, ?)";
        const sellsql = "insert into tbsell (Date, Time, SubTotal, GrandTotal, Money, ChangeTotal, PaymentMethod, EmployeeID, MemberID) value(?, ?, ?, ?, ?, ?, ?, ?, ?)";
        const clientInfo = req.clientInfo || { hostname: 'Unknown Computer', serverHostname: os.hostname() };

        // ກວດສອບສະຕັອກສິນຄ້າ
        for (const item of items) {
            const { ProductID, SellQty } = item;
            console.log("Checking product:", ProductID);
            const productRows = await queryAsync("select Quantity from tbproduct where ProductID = ?", [ProductID]);
            console.log("Query result:", productRows);
            if (productRows.length === 0) { 
                return res.status(404).send({ msg: "Product " + ProductID + " not found", clientInfo });
            }
            if (productRows[0].Quantity < SellQty) {
                return res.status(400).send({ msg: "Not enough stock for sale", clientInfo });
            }
        }
        
        // ບັນທຶກຂໍ້ມູນ
        const sellResult = await queryAsync(
            sellsql, [Date, Time, Subtotal, GrandTotal, Money, Change, PaymentMethod, Employee, Member]
        );
        const sellID = sellResult.insertId;

        for (const item of items) {
            const { ProductID, SellQty, Price, Total } = item;
            await queryAsync(
                sellDsql, [sellID, ProductID, Price, SellQty, Total]
            );
            await queryAsync(
                sql, [SellQty, ProductID]
            );
        }

       
        // ສ້າງ Object ຂໍ້ມູນສົ່ງໄປໜ້າ BillPage
        const transactionDataForBill = {
            ...req.body, // ເອົາຂໍ້ມູນທັງໝົດທີ່ສົ່ງມາ
            SellID: sellID // ເພີ່ມ SellID ທີ່ສ້າງເຂົ້າໄປ
        };
        
        return res.status(200).send({ 
            msg: "Sale complete",
            transactionData: transactionDataForBill, // ສົ່ງຂໍ້ມູນກັບໄປ
            clientInfo 
        });

    } catch (err) {
        console.log(err);
        return res.status(500).send({
            "msg": "Path to database not found"
        });
    }
});


app.delete("/product/:pid",(req,res) =>{
    try{
        const pid = req.params.pid
        const sql = "delete from tbproduct where ProductID = ?"
        const val =[pid]
        const clientInfo = req.clientInfo || { hostname: 'Unknown Computer', serverHostname: os.hostname()};//ດຶງຂໍ້ມູນເຄື່ອງ
        db.query(sql, val, (err,result)=>{
            if(err){
                console.log(err)
                return res.status.send({
                    "msg":"Please check again", "clientInfo": clientInfo//ເພີ່ມຂໍ້ມູນເຄື່ອງໃນການແຈ້ງກັບ
                    })
            }
            return res.status(200).send({
                "msg":"Data has been deleted", "clientInfo": clientInfo//ເພີ່ມຂໍ້ມູນເຄື່ອງໃນການແຈ້ງກັບ
                })
        })

    }catch(err){
        if (error.code === 'ER_ROW_IS_REFERENCED_2') {
        return res.status(409).json({ 
          message: 'Cannot delete category: It is still used by products' 
        });
    }
    else {
        console.log(err)
        return res.status(500).send({
            "msg":"Path to database not found"
            })
    }
    }
})




module.exports = app