import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/page/salepage/Billpage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  final List cartItems;
  final double totalAmount;
  final Function onPaymentComplete;

  const PaymentPage(
      {Key? key,
      required this.cartItems,
      required this.totalAmount,
      required this.onPaymentComplete})
      : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final String baseUrl = basePath().bpath();
  bool isLoading = false;
  TextEditingController cashReceivedController = TextEditingController();

  final formatter = NumberFormat("#,##0");
  String _selectedPaymentMethod = 'CASH';
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
    if (cashReceivedController.text.isEmpty &&
        _selectedPaymentMethod == 'CASH') {
      showErrorMessage("Please input received amount");
      return;
    }
    double cashReceived =
        double.tryParse(cashReceivedController.text.replaceAll(',', '')) ?? 0;
    if (cashReceived < widget.totalAmount && _selectedPaymentMethod == 'CASH') {
      showErrorMessage("Not enough money");
      return;
    }

    setState(() => isLoading = true);

    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final timeStr = DateFormat('HH:mm:ss').format(now);

      final saleDetails = widget.cartItems
          .map((item) => {
                "ProductID": item['ProductID'],
                "SellQty": item['quantity'],
                "Price": item['SellPrice'],
                "Total": (double.parse(item['SellPrice'].toString()) *
                        item['quantity'])
                    .toString(),
              })
          .toList();

      final saleData = {
        "Subtotal": widget.totalAmount.toString(),
        "GrandTotal": widget.totalAmount.toString(),
        "Money": _selectedPaymentMethod == 'CASH'
            ? cashReceived.toString()
            : widget.totalAmount.toString(),
        "Change": _selectedPaymentMethod == 'CASH'
            ? (cashReceived - widget.totalAmount).toString()
            : '0',
        "Date": dateStr,
        "Time": timeStr,
        "PaymentMethod": _selectedPaymentMethod,
        "EmployeeID": _employeeId,
        "EmployeeName": _employeeName,
        "MemberID": 1,
        "SaleDetails": saleDetails,
      };

      final response = await http.post(
        Uri.parse("$baseUrl/main/product/sell"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(saleData),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        goToBillPage(responseBody['transactionData']);
      } else {
        showErrorMessage(
            "Failed to process transaction: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      showErrorMessage("Error: $e");
    }
  }

  void goToBillPage(Map<String, dynamic> transactionData) {
    widget.onPaymentComplete();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) => BillPage(transactionData: transactionData)),
      (Route<dynamic> route) => false,
    );
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'ຊຳລະເງິນ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color(0xFFE45C58),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(children: [
                _buildTotalAmount(),
                _buildItemList(),
                _buildPaymentSection(),
              ]),
            ),
    );
  }

  Widget _buildTotalAmount() => Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        color: Color(0xFFE45C58).withOpacity(0.1),
        child: Column(children: [
          Text('${formatter.format(widget.totalAmount)} LAK',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE45C58))),
          Text('Total Amount',
              style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ]),
      );

  Widget _buildItemList() => ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.cartItems.length,
        itemBuilder: (context, index) {
          final item = widget.cartItems[index];
          final imageUrl = item['ProductImageURL'] != null
              ? baseUrl + item['ProductImageURL']
              : null;

          return ListTile(
            leading: Container(
              width: 50,
              height: 50,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8)),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          Icon(Icons.image_not_supported),
                    )
                  : Icon(Icons.inventory_2_outlined,
                      color: Colors.grey.shade400),
            ),
            title: Text(item['ProductName'] ?? "Product",
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
                '${formatter.format(item['SellPrice'])} LAK × ${item['quantity']}'),
            trailing: Text(
                '${formatter.format(double.parse(item['SellPrice'].toString()) * item['quantity'])} LAK',
                style: TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      );

  Widget _buildPaymentSection() => Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, -3))
        ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pay ${formatter.format(widget.totalAmount)} LAK',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(children: [
              _paymentMethodChip('CASH', Icons.money),
              SizedBox(width: 10),
              _paymentMethodChip('TRANSFER', Icons.qr_code_scanner),
            ]),
            SizedBox(height: 16),
            if (_selectedPaymentMethod == 'CASH')
              TextField(
                controller: cashReceivedController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(),
                    hintText: "Input money received",
                    suffixText: "LAK"),
              ),
            SizedBox(height: 24),
            Row(children: [
              Expanded(
                  child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          padding: EdgeInsets.symmetric(vertical: 12)),
                      child: Text('Back',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)))),
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
                              fontWeight: FontWeight.bold)))),
            ]),
          ],
        ),
      );

  Widget _paymentMethodChip(String method, IconData icon) => Expanded(
        child: OutlinedButton.icon(
          onPressed: () => setState(() => _selectedPaymentMethod = method),
          icon: Icon(icon),
          label: Text(method),
          style: OutlinedButton.styleFrom(
            backgroundColor: _selectedPaymentMethod == method
                ? Color(0xFFE45C58).withOpacity(0.1)
                : Colors.white,
            foregroundColor: Color(0xFFE45C58),
            side: BorderSide(
                color: _selectedPaymentMethod == method
                    ? Color(0xFFE45C58)
                    : Colors.grey.shade300),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
}
