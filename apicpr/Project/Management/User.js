const express = require('express');
const core = require('cors');
const Database = require('../Server');

const app = express();
app.use(express.json());
app.use(core());

const connection = new Database();
const db = connection.getConnection();

// [ADD] เพิ่ม Helper function สำหรับบันทึก Log
async function writeActivityLog(logData) {
    const { EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails } = logData;
    if (!EmployeeID || !EmployeeName) return;
    const logSQL = "INSERT INTO tbactivity_log (EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails) VALUES (?, ?, ?, ?, ?, ?)";
    db.query(logSQL, [EmployeeID, EmployeeName, ActionType, TargetTable, TargetRecordID, ChangeDetails], (err) => {
        if (err) console.log("Error logging activity:", err);
    });
}

// --- Endpoint สำหรับดึงข้อมูล User ทั้งหมด (เหมือนเดิม) ---
app.get("/user", function(req, res){
    try{
        const sql = "SELECT u.*, r.RoleName FROM tbuser u JOIN tbrole r ON u.position = r.RID";
        db.query(sql,(err, result, field)=>{
            if(err) return res.status(400).send({"msg":"Data not found in database"});
            return res.status(200).send(result);
        });
    }catch(err){
        console.log(err);
        return res.status(500).send({"msg":"Path to database not found"});
    }
});


// [EDIT] ปรับปรุง API สำหรับ Login ใหม่ทั้งหมด
app.post("/user/login", function(req, res){
    try{
        const { Phone, UserPassword } = req.body;
        if (!Phone || !UserPassword) {
            return res.status(400).send({ success: false, msg: "Phone and Password are required." });
        }

        const sql = "SELECT u.*, r.RoleName FROM tbuser u JOIN tbrole r ON u.position = r.RID WHERE u.Phone = ? AND u.UserPassword = ?";
        const values = [Phone, UserPassword];

        db.query(sql, values, (err, result) => {
            if(err){
                console.log(err);
                return res.status(500).send({ success: false, msg: "Database query error." });
            }
            
            if(result.length > 0){
                const user = result[0];
                // บันทึก Log การ Login สำเร็จ
                writeActivityLog({
                    EmployeeID: user.UID,
                    EmployeeName: user.UserFname,
                    ActionType: 'LOGIN',
                    TargetTable: 'tbuser',
                    TargetRecordID: user.UID,
                    ChangeDetails: `ຜູ້ໃຊ້ '${user.UserFname}' ໄດ້ເຂົ້າສູ່ລະບົບ.`
                });
                
                // ส่งข้อมูลผู้ใช้ทั้งหมดกลับไป
                return res.status(200).send({ success: true, user: user });
            }
            else {
                return res.status(401).send({ success: false, msg: "ເບີໂທ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ" });
            }
        });
    }catch(err){
        console.log(err);
        return res.status(500).send({"msg":"Internal server error"});
    }
});

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