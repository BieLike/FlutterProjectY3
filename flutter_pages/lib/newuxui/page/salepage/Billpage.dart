import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/page/salepage/Salepage.dart';
import 'package:intl/intl.dart';

class BillPage extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  const BillPage({Key? key, required this.transactionData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0");
    final List saleDetails = transactionData['SaleDetails'] ?? [];
    final String employeeName = transactionData['EmployeeName'] ?? 'N/A';
    final String date = transactionData['Date'] ?? 'N/A';
    final String time = transactionData['Time'] ?? 'N/A';
    final double grandTotal =
        double.tryParse(transactionData['GrandTotal'] ?? '0') ?? 0;
    final double money = double.tryParse(transactionData['Money'] ?? '0') ?? 0;
    final double change =
        double.tryParse(transactionData['Change'] ?? '0') ?? 0;

    return Scaffold(
      appBar: AppBar(
          title: Text(
            "ໃບບິນ",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color(0xFFE45C58),
          automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Icon(Icons.check_circle, color: Colors.green, size: 60),
          SizedBox(height: 16),
          Text("ຂາຍສຳເລັດແລ້ວ",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("ວັນທີ: $date ເວລາ: $time"),
          Text("ພະນັກງານ: $employeeName"),
          Divider(height: 30, thickness: 1),
          Expanded(
              child: ListView.builder(
            itemCount: saleDetails.length,
            itemBuilder: (context, index) {
              final item = saleDetails[index];
              return ListTile(
                title: Text(item['ProductName'] ?? 'Product'),
                subtitle: Text(
                    "${formatter.format(item['Price'])} LAK x ${item['SellQty']}"),
                trailing: Text(
                    "${formatter.format(double.tryParse(item['Total'].toString()) ?? 0)} LAK"),
              );
            },
          )),
          Divider(height: 30, thickness: 1),
          _buildSummaryRow("ຍອດລວມ:", "${formatter.format(grandTotal)} LAK"),
          SizedBox(height: 8),
          _buildSummaryRow("ເງິນສົດ:", "${formatter.format(money)} LAK"),
          SizedBox(height: 8),
          _buildSummaryRow("ເງິນທອນ:", "${formatter.format(change)} LAK",
              isBold: true, color: Color(0xFFE45C58)),
          SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.point_of_sale),
              label: Text("ເຮັດການຂາຍໃໝ່"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE45C58),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16)),
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => SalePage()),
                  (Route<dynamic> route) => false),
            ),
          ),
        ]),
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
