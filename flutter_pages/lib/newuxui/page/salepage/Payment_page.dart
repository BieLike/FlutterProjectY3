import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/page/salepage/Billpage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  final List cartItems;
  final double totalAmount;
  final Function onPaymentComplete;

  const PaymentPage({
    Key? key,
    required this.cartItems,
    required this.totalAmount,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final String baseUrl = basePath().bpath();
  bool isLoading = false;
  TextEditingController cashReceivedController = TextEditingController();

  int? _employeeId;
  String? _employeeName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = json.decode(userDataString);
      setState(() {
        _employeeId = userData['UID'];
        _employeeName = userData['UserFname'];
      });
    }
  }

  Future<void> processPayment() async {
    if (cashReceivedController.text.isEmpty) {
      showErrorMessage("Please input cash amount");
      return;
    }
    double cashReceived = double.tryParse(cashReceivedController.text) ?? 0;
    if (cashReceived < widget.totalAmount) {
      showErrorMessage("Not enough money");
      return;
    }
    setState(() {
      isLoading = true;
    });

    try {
      final DateTime now = DateTime.now();
      final String dateStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final String timeStr =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      final List<Map<String, dynamic>> saleDetails = widget.cartItems
          .map((item) => {
                "ProductID": item['ProductID'],
                "ProductName": item['ProductName'],
                "SellQty": item['quantity'],
                "Price": item['SellPrice'],
                "Total": (double.parse(item['SellPrice'].toString()) *
                        item['quantity'])
                    .toString(),
              })
          .toList();

      final Map<String, dynamic> saleData = {
        "Subtotal": widget.totalAmount.toString(),
        "GrandTotal": widget.totalAmount.toString(),
        "Money": cashReceived.toString(),
        "Change": (cashReceived - widget.totalAmount).toString(),
        "Date": dateStr,
        "Time": timeStr,
        "PaymentMethod": "CASH",
        "Employee": _employeeId,
        "EmployeeName": _employeeName,
        "Member": "M001",
        "SaleDetails": saleDetails,
      };

      final response = await http.post(
        Uri.parse("$baseUrl/main/product/sell"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(saleData),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final transactionData = responseBody['transactionData'];
        goToBillPage(transactionData);
      } else {
        showErrorMessage(
            "Failed to process transaction: ${response.statusCode} - ${response.body}");
        print("API response: ${response.body}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorMessage("Error: $e");
    }
  }

  void goToBillPage(Map<String, dynamic> transactionData) {
    widget.onPaymentComplete();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => BillPage(transactionData: transactionData),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: Color(0xFFE45C58),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  color: Color(0xFFE45C58).withOpacity(0.1),
                  child: Column(
                    children: [
                      Text('${widget.totalAmount.toStringAsFixed(0)}k',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE45C58))),
                      Text('Total Amount',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700])),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(5)),
                          child: Icon(Icons.inventory_2_outlined,
                              size: 20, color: Colors.amber.shade800),
                        ),
                        title: Text(item['ProductName'] ?? "Product",
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle:
                            Text('${item['SellPrice']}k × ${item['quantity']}'),
                        trailing: Text(
                            '${(double.parse(item['SellPrice'].toString()) * item['quantity']).toStringAsFixed(0)}k',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, -3))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pay ${widget.totalAmount.toStringAsFixed(0)}k',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      TextField(
                        controller: cashReceivedController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(),
                          hintText: "Input money received",
                          suffixText: "k",
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  padding: EdgeInsets.symmetric(vertical: 12)),
                              child: Text('Back',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: processPayment,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFE45C58),
                                  padding: EdgeInsets.symmetric(vertical: 12)),
                              child: Text('Confirm',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
