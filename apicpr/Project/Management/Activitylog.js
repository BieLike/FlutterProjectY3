const express = require('express');
const core = require('cors');
const Database = require('../Server');

const app = express();
app.use(express.json());
app.use(core());

const connection = new Database();
const db = connection.getConnection();

// API Endpoint สำหรับดึง Log
app.get('/logs', (req, res) => {
    try {
        const { startDate, endDate } = req.query;

        let sql = 'SELECT * FROM tbactivity_log';
        let params = [];
        let whereClause = '';

        if (startDate && endDate) {
            // Filter by date range (for month or week)
            whereClause = 'WHERE DATE(LogTimestamp) BETWEEN ? AND ?';
            params = [startDate, endDate];
        } else if (startDate) {
            // Filter by a single day
            whereClause = 'WHERE DATE(LogTimestamp) = ?';
            params = [startDate];
        }

        sql += ` ${whereClause}`;
        sql += ' ORDER BY LogTimestamp DESC';

        // ถ้าไม่ได้กำหนดช่วงเวลา ให้แสดงแค่ 200 รายการล่าสุด
        if (!startDate) {
            sql += ' LIMIT 200';
        }

        db.query(sql, params, (err, result) => {
            if (err) {
                console.error("Error fetching logs:", err);
                return res.status(500).json({ msg: 'Failed to retrieve logs.' });
            }
            return res.status(200).json(result);
        });
    } catch (err) {
        return res.status(500).json({ msg: 'Server error' });
    }
});

module.exports = app;