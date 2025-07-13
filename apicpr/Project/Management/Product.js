const express = require('express');
const core = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Database = require('../Server');

const app = express();
app.use(express.json());
app.use(core());

const connection = new Database();
const db = connection.getConnection();

// --- Multer Storage Configuration ---
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // [FIX] แก้ไข path ให้ชี้ไปยังโฟลเดอร์ 'uploads' ที่ root directory
    const dir = path.join(__dirname, '..', 'uploads');
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    cb(null, 'product-' + Date.now() + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

async function writeActivityLog(logData) {
    const { EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails } = logData;
    if (!EmployeeID || !EmployeeName) {
        console.log("Log skipped: Missing EmployeeID or EmployeeName.");
        return;
    }
    const logSQL = "INSERT INTO tbactivity_log (EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails) VALUES (?, ?, ?, ?, ?, ?)";
    
    // เปลี่ยนมาใช้ db.query แบบ callback ปกติเพื่อให้เข้ากับโปรเจกต์
    db.query(logSQL, [EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails], (err, result) => {
        if (err) {
            console.log("Error writing activity log:", err);
        } else {
            // console.log("Activity logged successfully:", TargetRecordID);
        }
    });
}
//do query for sell
function queryAsync(sql, params) {
    return new Promise((resolve, reject) => {
        db.query(sql, params, (err, result) => {
            if (err) reject(err);
            else resolve(result);
        });
    });
}

// --- GET Endpoints ---
app.get("/product", function(req, res) {
    // SELECT p.* จะดึง Bpage มาด้วยอัตโนมัติ ไม่ต้องแก้ไข
    const sql = `SELECT p.*, c.CategoryName, u.UnitName, a.name as AuthorName FROM tbproduct p LEFT JOIN tbunit u ON p.UnitID = u.UnitID LEFT JOIN tbcategory c ON p.CategoryID = c.CategoryID LEFT JOIN tbauthor a ON p.authorsID = a.authorID ORDER BY p.ProductID`;
    db.query(sql, (err, result) => {
        if (err) return res.status(400).send({ "msg": "Data not found" });
        return res.status(200).send(result);
    });
});
app.get("/product/:pid", (req, res) => {
    const pid = req.params.pid;
    const searchTerm = `%${pid}%`;
    const sql = `SELECT p.*, c.CategoryName, u.UnitName, a.name as AuthorName FROM tbproduct p LEFT JOIN tbunit u ON p.UnitID = u.UnitID LEFT JOIN tbcategory c ON p.CategoryID = c.CategoryID LEFT JOIN tbauthor a ON p.authorsID = a.authorID WHERE p.ProductID LIKE ? OR p.ProductName LIKE ? OR u.UnitName LIKE ? OR c.CategoryName LIKE ? OR a.name LIKE ?`;
    db.query(sql, [searchTerm, searchTerm, searchTerm, searchTerm, searchTerm], (err, result) => {
        if (err) return res.status(400).send({ "msg": "Database query error" });
        return res.status(200).send(result);
    });
});

// --- POST (Create) Endpoint ---
app.post("/product", upload.single('image'), (req, res) => {
  // [EDIT] เพิ่ม Bpage เข้ามา
  const { ProductID, ProductName, Bpage, Quantity, ImportPrice, SellPrice, UnitID, CategoryID, authorsID, Balance, Level, EmployeeID, EmployeeName } = req.body;
  
  let imagePath = req.file ? `/uploads/${req.file.filename}` : null;
  
  const chsql = "SELECT * FROM tbproduct WHERE ProductID = ? OR ProductName = ?";
  db.query(chsql, [ProductID, ProductName], (err, chresult) => {
    if (err) return res.status(500).send({ "msg": "Database error" });
    if (chresult.length > 0) return res.status(409).send({ "msg": "Product already exists" });

    // [EDIT] เพิ่ม Bpage ในคำสั่ง SQL
    const sql = "INSERT INTO tbproduct (ProductID, ProductName, Bpage, Quantity, ImportPrice, SellPrice, UnitID, CategoryID, authorsID, Balance, Level, ProductImageURL) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";
    const val = [ProductID, ProductName, Bpage, Quantity, ImportPrice, SellPrice, UnitID, CategoryID, authorsID, Balance, Level, imagePath];
    
    db.query(sql, val, (err, result) => {
      if (err) return res.status(400).send({ "msg": "Insert failed" });
      const logDetails = `ເພີ່ມປຶ້ມໃໝ່: '${ProductName}' (ID: ${ProductID})`;
      writeActivityLog({ EmployeeID, EmployeeName, ActionType: 'CREATE', TargetTable: 'tbproduct', TargetRecordID: ProductID, ChangeDetails: logDetails });
      return res.status(200).send({ "msg": "Data is saved" });
    });
  });
});

// --- PUT (Update) Endpoint ---
app.put("/product/:pid", upload.single('image'), (req, res) => {
  const pid = req.params.pid;
  // [EDIT] เพิ่ม Bpage เข้ามา
  const { NewProductID, ProductName, NewProductName, Bpage, Quantity, ImportPrice, SellPrice, UnitID, CategoryID, authorsID, Balance, Level, EmployeeID, EmployeeName } = req.body;

  db.query("SELECT * FROM tbproduct WHERE ProductID = ?", [pid], (findErr, findResult) => {
    if (findErr || findResult.length === 0) return res.status(404).send({ msg: "Product not found" });
    
    const oldProduct = findResult[0];
    let newImagePath = oldProduct.ProductImageURL;
    let imageChanged = false;

    if (req.file) {
      imageChanged = true;
      newImagePath = `/uploads/${req.file.filename}`;
      if (oldProduct.ProductImageURL) {
        const oldFilename = path.basename(oldProduct.ProductImageURL);
        const oldFilePath = path.join(__dirname, '..', 'uploads', oldFilename);
        if (fs.existsSync(oldFilePath)) fs.unlink(oldFilePath, (err) => { if (err) console.error(err); });
      }
    }

    const finalProductID = NewProductID || pid;
    const finalProductName = NewProductName || ProductName;

    const chsql = "SELECT * FROM tbproduct WHERE (ProductID = ? OR ProductName = ?) AND ProductID != ?";
    db.query(chsql, [finalProductID, finalProductName, pid], (err, chresult) => {
      if (err || (chresult && chresult.length > 0)) return res.status(409).send({ msg: "Product ID or Name already exists" });

      // [EDIT] เพิ่ม Bpage ในคำสั่ง SQL
      const sql = "UPDATE tbproduct SET ProductID = ?, ProductName = ?, Bpage = ?, Quantity = ?, ImportPrice = ?, SellPrice = ?, UnitID = ?, CategoryID = ?, authorsID = ?, Balance = ?, Level = ?, ProductImageURL = ? WHERE ProductID = ?";
      const val = [finalProductID, finalProductName, Bpage, Quantity, ImportPrice, SellPrice, UnitID, CategoryID, authorsID, Balance, Level, newImagePath, pid];
      
      db.query(sql, val, (err, result) => {
        if (err || result.affectedRows === 0) return res.status(400).send({ msg: "Update failed" });

        const changes = [];
        if (finalProductID !== oldProduct.ProductID) changes.push(`ProductID: '${oldProduct.ProductID}' -> '${finalProductID}'`);
        if (finalProductName !== oldProduct.ProductName) changes.push(`ProductName: '${oldProduct.ProductName}' -> '${finalProductName}'`);
        // 
        if (parseInt(Bpage) !== oldProduct.Bpage) changes.push(`ໜ້າເຈ້ຍ: ${oldProduct.Bpage} -> ${Bpage}`);
        if (parseInt(authorsID) !== oldProduct.authorsID) changes.push(`ຜູ້ແຕ່ງ: ${oldProduct.authorsID} -> ${authorsID}`);
        if (parseInt(Quantity) !== oldProduct.Quantity) changes.push(`ຈຳນວນ: ${oldProduct.Quantity} -> ${Quantity}`);
        if (parseInt(ImportPrice) !== oldProduct.ImportPrice) changes.push(`ລາຄານຳເຂົ້າ: ${oldProduct.ImportPrice} -> ${ImportPrice}`);
        if (parseInt(SellPrice) !== oldProduct.SellPrice) changes.push(`ລາຄາຂາຍ: ${oldProduct.SellPrice} -> ${SellPrice}`);
        if (parseInt(Balance) !== oldProduct.Balance) changes.push(`ຍອດລວມຈຳນວນ: ${oldProduct.Balance} -> ${Balance}`);
        if (parseInt(Level) !== oldProduct.Level) changes.push(`ຈຳນວນຂັ້ນຕໍ່າ: ${oldProduct.Level} -> ${Level}`);
        if (UnitID !== oldProduct.UnitID) changes.push(`ຫົວໜ່ວຍ: '${oldProduct.UnitID}' -> '${UnitID}'`);
        if (CategoryID !== oldProduct.CategoryID) changes.push(`ໝວດໝູ່: '${oldProduct.CategoryID}' -> '${CategoryID}'`);
        if (imageChanged) changes.push(`ປ່ຽນຮູບພາບເປັນ: ${req.file.filename}`);
        
        if (changes.length > 0) {
          const changeDetails = `ແກ້ໄຂຂໍ້ມູນປຶ້ມ '${oldProduct.ProductName}':\n- ${changes.join('\n- ')}`;
          writeActivityLog({ EmployeeID, EmployeeName, ActionType: 'UPDATE', TargetTable: 'tbproduct', TargetRecordID: pid, ChangeDetails: changeDetails });
        }

        return res.status(200).send({ msg: "Data is edited" });
      });
    });
  });
});

// --- DELETE Endpoint with Image Deletion ---
app.delete("/product/:pid", (req, res) => {
  const pid = req.params.pid;
  const { EmployeeID, EmployeeName } = req.body;
  
  db.query("SELECT ProductName, ProductImageURL FROM tbproduct WHERE ProductID = ?", [pid], (findErr, findResult) => {
    if (findErr || findResult.length === 0) return res.status(404).send({ "msg": "Product not found" });
    
    const productToDelete = findResult[0];
    const sql = "DELETE FROM tbproduct WHERE ProductID = ?";
    db.query(sql, [pid], (err, result) => {
      if (err) return res.status(400).send({ "msg": "Delete failed, it might be in use." });
      if (result.affectedRows === 0) return res.status(404).send({ "msg": "Product not found" });

      if (productToDelete.ProductImageURL) {
        const filename = path.basename(productToDelete.ProductImageURL);
        const filePath = path.join(__dirname, '..', 'uploads', filename);
        if (fs.existsSync(filePath)) fs.unlink(filePath, (err) => { if (err) console.error("Error deleting file:", err); });
      }

      // 
      const logDetails = `ລົບປຶ້ມ: '${productToDelete.ProductName}' (ID: ${pid})`;
      writeActivityLog({ EmployeeID, EmployeeName, ActionType: 'DELETE', TargetTable: 'tbproduct', TargetRecordID: pid, ChangeDetails: logDetails });

      return res.status(200).send({ "msg": "Data has been deleted" });
    });
  });
});

// --- Sell Endpoint ---
app.post("/product/sell", async (req, res) => {
    try {
        const { SaleDetails, Date, Time, Subtotal, GrandTotal, Money, Change, PaymentMethod, EmployeeID, EmployeeName, MemberID } = req.body;
        if (!SaleDetails || SaleDetails.length === 0) {
            return res.status(400).send({ msg: "Sale details are missing." });
        }

        await queryAsync("START TRANSACTION");
        
        try {
            for (const item of SaleDetails) {
                const productRows = await queryAsync("SELECT Quantity, ProductName FROM tbproduct WHERE ProductID = ?", [item.ProductID]);
                if (productRows.length === 0) throw new Error(`Product ${item.ProductID} not found`);
                if (productRows[0].Quantity < item.SellQty) throw new Error(`Not enough stock for ${productRows[0].ProductName}`);
                await queryAsync("UPDATE tbproduct SET Quantity = Quantity - ? WHERE ProductID = ?", [item.SellQty, item.ProductID]);
            }

            const sellsql = "INSERT INTO tbsell (Date, Time, SubTotal, GrandTotal, Money, ChangeTotal, PaymentMethod, EmployeeID, MemberID) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            const sellResult = await queryAsync(sellsql, [Date, Time, Subtotal, GrandTotal, Money, Change, PaymentMethod, EmployeeID, MemberID]);
            const sellID = sellResult.insertId;

            const sellDsql = "INSERT INTO tbselldetail (SellID, ProductID, Price, Quantity, Total) VALUES ?";
            const sellDetailsValues = SaleDetails.map(item => [sellID, item.ProductID, item.Price, item.SellQty, item.Total]);
            await queryAsync(sellDsql, [sellDetailsValues]);

            await queryAsync("COMMIT");

            writeActivityLog({
                EmployeeID, EmployeeName, ActionType: 'CREATE', TargetTable: 'tbsell',
                TargetRecordID: sellID, ChangeDetails: `ສ້າງລາຍການຂາຍ #${sellID} ລວມ ${SaleDetails.length} ລາຍການ`
            });

            const transactionDataForBill = { ...req.body, SellID: sellID };
            return res.status(200).send({ msg: "Sale complete", transactionData: transactionDataForBill });

        } catch (err) {
            await queryAsync("ROLLBACK");
            console.log(err);
            return res.status(500).send({ "msg": err.message || "Transaction failed" });
        }
    } catch (err) {
        console.log(err);
        return res.status(500).send({ "msg": "Path to database not found" });
    }
});

module.exports = app;