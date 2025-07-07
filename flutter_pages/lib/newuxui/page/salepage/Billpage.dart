// Billpage.dart (Refactored)

import 'package:flutter/material.dart';
import 'package:flutter_application_1/newuxui/page/salepage/Salepage.dart';
// import 'package:flutter_lect2/newuxui/page/salepage/Salepage.dart';

class BillPage extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  const BillPage({Key? key, required this.transactionData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List saleDetails = transactionData['SaleDetails'] ?? [];
    final String employeeName = transactionData['EmployeeName'] ?? 'N/A';
    final String date = transactionData['Date'] ?? 'N/A';
    final String time = transactionData['Time'] ?? 'N/A';
    final String grandTotal = transactionData['GrandTotal'] ?? '0';
    final String money = transactionData['Money'] ?? '0';
    final String change = transactionData['Change'] ?? '0';

    return Scaffold(
      appBar: AppBar(
        title: Text("ໃບບິນ "),
        backgroundColor: Color(0xFFE45C58),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 16),
            Text(
              "ຂາຍສຳເລັດແລ້ວ (Transaction Complete)",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("ວັນທີ: $date ເວລາ: $time"),
            Text("ພະນັກງານ: $employeeName"),
            Divider(height: 30, thickness: 1),

            // ລາຍການສິນຄ້າ
            Expanded(
              child: ListView.builder(
                itemCount: saleDetails.length,
                itemBuilder: (context, index) {
                  final item = saleDetails[index];

                  return ListTile(
                    title: Text(item['ProductName'] ?? 'Product'),
                    subtitle: Text("${item['Price']} LAK x ${item['SellQty']}"),
                    trailing: Text("${item['Total']} LAK"),
                  );
                },
              ),
            ),

            Divider(height: 30, thickness: 1),

            // ສະລຸບຍອດ
            _buildSummaryRow("ຍອດລວມ:", "$grandTotal LAK"),
            SizedBox(height: 8),
            _buildSummaryRow("ເງິນສົດ:", "$money LAK"),
            SizedBox(height: 8),
            _buildSummaryRow("ເງິນທອນ:", "$change LAK",
                isBold: true, color: Color(0xFFE45C58)),
            SizedBox(height: 30),

            // ປຸ່ມກັບໄປຫນ້າຂາຍໃໝ່
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.point_of_sale),
                label: Text("ເຮັດການຂາຍໃໝ່"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE45C58),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // ກັບໄປທີ່ໜ້າ SalePage ແລະລ້າງໜ້າກ່ອນຫນ້າທັງໝົດ
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => SalePage()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color)),
      ],
    );
  }
}
