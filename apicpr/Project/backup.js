const express = require("express");
const multer = require("multer");
const { exec } = require("child_process");
const path = require("path");
const fs = require("fs");
const app = express();

const upload = multer({ dest: "uploads/" });

app.get('/backup', (req, res) => {
    const date = new Date().toISOString().slice(0, 10);
    const filePath = `E:/Flutter_project/backup/Manually/backup-manual-${date}.sql`;
  
    // Add password if needed: -p'yourpassword'
    const command = `mysqldump -u root dbcpr --ignore-table=dbcpr.tbsell --ignore-table=dbcpr.tbimport --ignore-table=dbcpr.tbselldetail --ignore-table=dbcpr.tbimportdetail > "${filePath}"`;
    
    exec(command, (err) => {
        if (err) {
            console.error('Backup error:', err);
            return res.status(500).send('Backup failed');
        }
        
        // Check if file was created and send it
        if (fs.existsSync(filePath)) {
            res.setHeader('Content-Type', 'application/sql');
            res.setHeader('Content-Disposition', `attachment; filename="backup-${date}.sql"`);
            
            // Send the actual file content
            fs.readFile(filePath, (readErr, data) => {
                if (readErr) {
                    console.error('File read error:', readErr);
                    return res.status(500).send('Failed to read backup file');
                }
                res.send(data);
            });
        } else {
            res.status(500).send('Backup file not created');
        }
    });
});

app.post("/restore", upload.single("sqlfile"), (req, res) => {
    if (!req.file) {
        return res.status(400).send({ msg: "No file uploaded" });
    }
    
    const filePath = req.file.path; // multer already provides the full path
    // Add password if needed: -p'yourpassword'
    const command = `mysql -u root dbcpr < "${filePath}"`;

    exec(command, (error, stdout, stderr) => {
        // Clean up uploaded file
        fs.unlink(filePath, (unlinkErr) => {
            if (unlinkErr) console.error('File cleanup error:', unlinkErr);
        });
        
        if (error) {
            console.error('Restore error:', error);
            return res.status(500).send({ msg: "Restore failed", error: stderr });
        }
        res.status(200).send({ msg: "Database restored successfully" });
    });
});

module.exports = app;