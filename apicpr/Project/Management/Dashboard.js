const express = require('express');
const core = require('cors');
const Database = require('../Server');

const app = express();
app.use(express.json());
app.use(core());

const connection = new Database();
const db = connection.getConnection();

function queryAsync(sql, params) {
    return new Promise((resolve, reject) => {
        db.query(sql, params, (err, result) => {
            if (err) reject(err);
            else resolve(result);
        });
    });
}

// --- API Endpoint to get dashboard statistics [EDITED] ---
app.get('/dashboard/stats', async (req, res) => {
    try {
        const { startDate, endDate } = req.query;
        let dateFilterClause = '';
        let params = [];

        if (startDate && endDate) {
            dateFilterClause = 'WHERE Date BETWEEN ? AND ?';
            params = [startDate, endDate];
        } else if (startDate) {
            dateFilterClause = 'WHERE Date = ?';
            params = [startDate];
        } else {
            dateFilterClause = 'WHERE Date = CURDATE()';
        }

        // 
        const salesSql = `
            SELECT 
                SUM(GrandTotal) as sales, 
                SUM(IF(PaymentMethod = 'CASH', GrandTotal, 0)) as salesCash,
                SUM(IF(PaymentMethod = 'TRANSFER', GrandTotal, 0)) as salesTransfer,
                COUNT(SellID) as transactions 
            FROM tbsell 
            ${dateFilterClause}
        `;
        const pendingImportsSql = "SELECT COUNT(*) as pendingImports FROM tbimport WHERE Status = 'Pending'";

        // 
        const [
            salesResult,
            pendingImportsResult
        ] = await Promise.all([
            queryAsync(salesSql, params),
            queryAsync(pendingImportsSql)
        ]);
        
        //
        const stats = {
            sales: salesResult[0]?.sales || 0,
            salesCash: salesResult[0]?.salesCash || 0,
            salesTransfer: salesResult[0]?.salesTransfer || 0,
            transactions: salesResult[0]?.transactions || 0,
            pendingImports: pendingImportsResult[0].pendingImports || 0,
        };

        res.status(200).json(stats);

    } catch (err) {
        console.error("Dashboard stats error:", err);
        res.status(500).json({ msg: "Failed to retrieve dashboard statistics." });
    }
});

// --- Endpoint for Top 5 Best-Selling Products (No changes) ---
app.get('/dashboard/top-products', async (req, res) => {
    try {
        const { startDate, endDate } = req.query;
        let dateFilterClause = '';
        let params = [];

        if (startDate && endDate) {
            dateFilterClause = 'WHERE s.Date BETWEEN ? AND ?';
            params = [startDate, endDate];
        } else if (startDate) {
            dateFilterClause = 'WHERE s.Date = ?';
            params = [startDate];
        } else {
            dateFilterClause = 'WHERE s.Date = CURDATE()';
        }

        const topProductsSql = `
            SELECT p.ProductName, SUM(sd.Quantity) as total_quantity_sold
            FROM tbselldetail sd
            JOIN tbproduct p ON sd.ProductID = p.ProductID
            JOIN tbsell s ON sd.SellID = s.SellID
            ${dateFilterClause}
            GROUP BY p.ProductID, p.ProductName
            ORDER BY total_quantity_sold DESC
            LIMIT 5;
        `;
        
        const result = await queryAsync(topProductsSql, params);
        res.status(200).json(result);

    } catch (err) {
        res.status(500).json({ msg: "Failed to retrieve top products." });
    }
});

// --- Endpoint for Low Stock Products (No changes) ---
app.get('/dashboard/low-stock-products', async (req, res) => {
    try {
        const lowStockSql = `
            SELECT ProductName, Quantity, Level 
            FROM tbproduct 
            WHERE Quantity <= Level
            ORDER BY Quantity ASC
            LIMIT 10;
        `;
        const result = await queryAsync(lowStockSql);
        res.status(200).json(result);
    } catch (err) {
        console.error("Error fetching low stock products:", err);
        res.status(500).json({ msg: "Failed to retrieve low stock products." });
    }
});


module.exports = app;