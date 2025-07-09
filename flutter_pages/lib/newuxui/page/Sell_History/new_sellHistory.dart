// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Make sure to add intl to your pubspec.yaml
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';

class Sale {
  final int sellId;
  final DateTime date;
  final String time;
  final double subTotal;
  final double grandTotal;
  final double money;
  final double changeTotal;
  final String paymentMethod;
  final int employeeId;
  final String? memberId;
  final String? employeeName;
  final String? employeeRole;

  Sale({
    required this.sellId,
    required this.date,
    required this.time,
    required this.subTotal,
    required this.grandTotal,
    required this.money,
    required this.changeTotal,
    required this.paymentMethod,
    required this.employeeId,
    this.memberId,
    required this.employeeName,
    required this.employeeRole,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      sellId: int.parse(json['SellID'].toString()),
      date: DateTime.parse(json['Date']),
      time: json['Time'],
      subTotal: double.parse(json['SubTotal'].toString()),
      grandTotal: double.parse(json['GrandTotal'].toString()),
      money: double.parse(json['Money'].toString()),
      changeTotal: double.parse(json['ChangeTotal'].toString()),
      paymentMethod: json['PaymentMethod'],
      employeeId: int.parse(json['EmployeeID'].toString()),
      memberId: json['MemberID']?.toString(),
      employeeName: json['EmployeeName']?.toString(),
      employeeRole: json['EmployeeRole']?.toString(),
    );
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

// models/sale_detail.dart
class SaleDetail {
  final int sellDetailId;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double total;
  final String? categoryName;
  final String? unitName;

  SaleDetail({
    required this.sellDetailId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
    this.categoryName,
    this.unitName,
  });

  factory SaleDetail.fromJson(Map<String, dynamic> json) {
    return SaleDetail(
      sellDetailId: int.parse(json['SellDetailID'].toString()),
      productId: json['ProductID'].toString(),
      productName: json['ProductName'],
      price: double.parse(json['Price'].toString()),
      quantity: int.parse(json['Quantity'].toString()),
      total: double.parse(json['Total'].toString()),
      categoryName: json['CategoryName'],
      unitName: json['UnitName'],
    );
  }
}

// models/full_sale_details.dart
class FullSaleDetails extends Sale {
  final String? employeePhone;
  final String? employeeEmail;
  final List<SaleDetail> details;

  FullSaleDetails({
    required super.sellId,
    required super.date,
    required super.time,
    required super.subTotal,
    required super.grandTotal,
    required super.money,
    required super.changeTotal,
    required super.paymentMethod,
    required super.employeeId,
    super.memberId,
    required super.employeeName,
    required super.employeeRole,
    required this.employeePhone,
    required this.employeeEmail,
    required this.details,
  });

  factory FullSaleDetails.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List;
    List<SaleDetail> parsedDetails =
        detailsList.map((i) => SaleDetail.fromJson(i)).toList();

    return FullSaleDetails(
      sellId: int.parse(json['SellID'].toString()),
      date: DateTime.parse(json['Date']),
      time: json['Time'],
      subTotal: double.parse(json['SubTotal'].toString()),
      grandTotal: double.parse(json['GrandTotal'].toString()),
      money: double.parse(json['Money'].toString()),
      changeTotal: double.parse(json['ChangeTotal'].toString()),
      paymentMethod: json['PaymentMethod'],
      employeeId: int.parse(json['EmployeeID'].toString()),
      memberId: json['MemberID']?.toString(),
      employeeName: json['EmployeeName']?.toString(),
      employeeRole: json['EmployeeRole']?.toString(),
      employeePhone: json['EmployeePhone']?.toString(),
      employeeEmail: json['EmployeeEmail']?.toString(),
      details: parsedDetails,
    );
  }
}

// services/api_service.dart
class ApiService {
  // IMPORTANT: Replace with your actual API server URL
  // If running locally, use your machine's IP address (e.g., 'http://192.168.1.X:3000')
  // or 'http://localhost:3000' if running on a simulator/emulator with port forwarding.
  final String baseUrl = '${basePath().bpath()}/main';

  Future<List<Sale>> getSalesHistory() async {
    final response = await http.get(Uri.parse('$baseUrl/sales'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((sale) => Sale.fromJson(sale)).toList();
    } else {
      throw Exception('Failed to load sales history: ${response.statusCode}');
    }
  }

  Future<FullSaleDetails> getSaleDetails(int sellId) async {
    final response = await http.get(Uri.parse('$baseUrl/sales/$sellId'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return FullSaleDetails.fromJson(jsonResponse);
    } else {
      throw Exception(
        'Failed to load sale details for ID $sellId: ${response.statusCode}',
      );
    }
  }

  // Method to update product quantity in sale detail
  Future<void> updateSaleDetailQuantity(
    int sellDetailId,
    int newQuantity,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/sales/detail/$sellDetailId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'newQuantity': newQuantity}),
    );

    if (response.statusCode == 200) {
      print('Sale detail updated successfully: ${response.body}');
    } else {
      throw Exception(
        'Failed to update sale detail: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Method to delete a product from sale detail
  Future<void> deleteSaleDetail(int sellDetailId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/sales/detail/$sellDetailId'),
    );

    if (response.statusCode == 200) {
      print('Sale detail deleted successfully: ${response.body}');
    } else {
      throw Exception(
        'Failed to delete sale detail: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Method to delete an entire sale record
  Future<void> deleteSale(int sellId) async {
    final response = await http.delete(Uri.parse('$baseUrl/sales/$sellId'));

    if (response.statusCode == 200) {
      print('Sale deleted successfully: ${response.body}');
    } else {
      throw Exception(
        'Failed to delete sale: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

// pages/sales_history_page.dart
class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  late Future<List<Sale>> _salesHistory;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchSales();
  }

  Future<void> _fetchSales() async {
    setState(() {
      _salesHistory = _apiService.getSalesHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Sales History 🧾'),
        backgroundColor: Color(0xFFE45C58),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Color(0xFFE45C58),
      body: RefreshIndicator(
        onRefresh: _fetchSales,
        child: FutureBuilder<List<Sale>>(
          future: _salesHistory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final sale = snapshot.data![index];
                  return Card(
                    // Card theme applied from MyApp
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SaleDetailPage(sellId: sale.sellId),
                          ),
                        ).then((value) {
                          if (value == true) {
                            _fetchSales();
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sale ID: #${sale.sellId}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoChip(
                                  Icons.calendar_today,
                                  sale.formattedDate,
                                  color: Colors.indigo,
                                ),
                                _buildInfoChip(
                                  Icons.access_time,
                                  sale.time,
                                  color: Colors.teal,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Divider(color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total:',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                Text(
                                  formatCurrencyKip(sale.grandTotal),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE45C58),
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sold by: ${sale.employeeName ?? 'N/A'}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1) ?? Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? Colors.blueAccent),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color ?? Colors.blueAccent, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            Text(
              'Oops! Something went wrong.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 10),
            Text(
              'Error: $errorMessage',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.redAccent),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _fetchSales,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, color: Colors.grey[400], size: 100),
            const SizedBox(height: 20),
            Text(
              'No sales yet!',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            Text(
              'Start making sales to see them listed here.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _fetchSales,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

// pages/sale_detail_page.dart
class SaleDetailPage extends StatefulWidget {
  final int sellId;

  const SaleDetailPage({super.key, required this.sellId});

  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  late Future<FullSaleDetails> _saleDetails;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchSaleDetails();
  }

  Future<void> _fetchSaleDetails() async {
    setState(() {
      _saleDetails = _apiService.getSaleDetails(widget.sellId);
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _updateQuantity(int sellDetailId, int currentQuantity) async {
    TextEditingController quantityController = TextEditingController(
      text: currentQuantity.toString(),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Quantity'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'New Quantity',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.numbers),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newQuantity = int.tryParse(quantityController.text);
              if (newQuantity != null && newQuantity > 0) {
                try {
                  await _apiService.updateSaleDetailQuantity(
                    sellDetailId,
                    newQuantity,
                  );
                  _showSnackBar('Quantity updated successfully!');
                  _fetchSaleDetails(); // Refresh details after update
                  Navigator.pop(context);
                } catch (e) {
                  _showSnackBar(
                    'Failed to update quantity: ${e.toString()}',
                    isError: true,
                  );
                }
              } else {
                _showSnackBar(
                  'Please enter a valid positive number for quantity.',
                  isError: true,
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSaleDetail(int sellDetailId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion ⚠️'),
        content: const Text(
          'Are you sure you want to remove this product from the sale?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteSaleDetail(sellDetailId);
        _showSnackBar('Product removed from sale successfully!');
        _fetchSaleDetails(); // Refresh details after deletion
      } catch (e) {
        _showSnackBar(
          'Failed to remove product: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  Future<void> _deleteSale(int sellId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Confirm Sale Deletion ❗',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'Are you sure you want to delete this entire sale record? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Delete Sale'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteSale(sellId);
        _showSnackBar('Sale record deleted successfully!');
        Navigator.pop(
          context,
          true,
        ); // Pass true to indicate a refresh is needed
      } catch (e) {
        _showSnackBar('Failed to delete sale: ${e.toString()}', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sale Details (ID: #${widget.sellId})'),
        backgroundColor: Color(0xFFE45C58),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Delete Entire Sale',
            color: Colors.cyan,
            onPressed: () => _deleteSale(widget.sellId),
          ),
        ],
      ),
      backgroundColor: Color(0xFFE45C58),
      body: FutureBuilder<FullSaleDetails>(
        future: _saleDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData) {
            return _buildEmptyState();
          } else {
            final sale = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sale Header Information
                  Card(
                    // Card theme applied from MyApp
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sale Overview',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[800],
                                ),
                          ),
                          const Divider(height: 20, thickness: 1),
                          _buildDetailRow('Sale ID:', '#${sale.sellId}'),
                          _buildDetailRow(
                            'Date:',
                            DateFormat('dd/MM/yyyy').format(sale.date),
                          ),
                          _buildDetailRow('Time:', sale.time),
                          _buildDetailRow(
                            'Payment Method:',
                            sale.paymentMethod,
                            icon: Icons.payment,
                          ),
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            'Sub Total:',
                            formatCurrencyKip(sale.subTotal),
                            isBold: true,
                          ),
                          _buildDetailRow(
                            'Grand Total:',
                            formatCurrencyKip(sale.grandTotal),
                            isBold: true,
                            color: Colors.green[700],
                            fontSize: 18,
                            icon: Icons.money,
                          ),
                          _buildDetailRow(
                            'Money Received:',
                            formatCurrencyKip(sale.money),
                          ),
                          _buildDetailRow(
                            'Change:',
                            formatCurrencyKip(sale.changeTotal),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Employee Details
                  Card(
                    // Card theme applied from MyApp
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Employee Information',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[800],
                                ),
                          ),
                          const Divider(height: 20, thickness: 1),
                          _buildDetailRow(
                            'Name:',
                            sale.employeeName ?? 'N/A',
                            icon: Icons.person,
                          ),
                          _buildDetailRow(
                            'Role:',
                            sale.employeeRole ?? 'N/A',
                            icon: Icons.work_outline,
                          ),
                          _buildDetailRow(
                            'Phone:',
                            sale.employeePhone ?? 'N/A',
                            icon: Icons.phone,
                          ),
                          _buildDetailRow(
                            'Email:',
                            sale.employeeEmail ?? 'N/A',
                            icon: Icons.email,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Products in Sale
                  Text(
                    'Products in this Sale',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 10),
                  if (sale.details.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('No products found for this sale.'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sale.details.length,
                      itemBuilder: (context, index) {
                        final detail = sale.details[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detail.productName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple[700],
                                      ),
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                  'Product ID:',
                                  detail.productId,
                                ),
                                _buildDetailRow(
                                  'Category:',
                                  detail.categoryName ?? 'N/A',
                                ),
                                _buildDetailRow(
                                  'Unit:',
                                  detail.unitName ?? 'N/A',
                                ),
                                _buildDetailRow(
                                  'Price:',
                                  formatCurrencyKip(detail.price),
                                ),
                                _buildDetailRow(
                                  'Total:',
                                  formatCurrencyKip(detail.total),
                                  isBold: true,
                                  color: Colors.orange[700],
                                  fontSize: 16,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _updateQuantity(
                                        detail.sellDetailId,
                                        detail.quantity,
                                      ),
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('Edit'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueGrey,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton.icon(
                                      onPressed: () => _deleteSaleDetail(
                                        detail.sellDetailId,
                                      ),
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 18,
                                      ),
                                      label: const Text('Remove'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
    double fontSize = 15,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize - 1, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            Text(
              'Oops! Something went wrong.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 10),
            Text(
              'Error: $errorMessage',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.redAccent),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _fetchSaleDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.grey[400], size: 100),
            const SizedBox(height: 20),
            Text(
              'No details found for this sale.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _fetchSaleDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

String formatCurrencyKip(dynamic amount) {
  if (amount == null) return '0 ກີບ';
  double value = double.tryParse(amount.toString()) ?? 0.0;
  final formatter = NumberFormat('#,##0.00', 'en_US');
  return '${formatter.format(value)} ກີບ';
}
