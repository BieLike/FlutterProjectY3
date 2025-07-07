import 'package:flutter/material.dart';
import 'package:flutter_application_1/newuxui/DBpath.dart';
import 'package:flutter_application_1/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// Models
class Sale {
  final int sellId;
  final String sellDate;
  final String? sellTime;
  final DateTime? sellDateTime;
  final double subTotal;
  final double grandTotal;
  final String? customerName;
  final String? customerPhone;
  final List<SaleDetail>? details;

  Sale({
    required this.sellId,
    required this.sellDate,
    this.sellTime,
    this.sellDateTime,
    required this.subTotal,
    required this.grandTotal,
    this.customerName,
    this.customerPhone,
    this.details,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    // Accept both 'SellDate' and 'Date' for compatibility
    String dateStr =
        json['SellDate']?.toString() ?? json['Date']?.toString() ?? '';
    String? timeStr = json['Time']?.toString();
    DateTime? dateTime;

    try {
      if (dateStr.isNotEmpty) {
        if (timeStr != null && timeStr.isNotEmpty) {
          // Combine date and time if both exist
          dateTime = DateFormat('dd/MM/yyyy HH:mm').parse('$dateStr $timeStr');
        } else {
          // Only date
          if (dateStr.contains('-')) {
            dateTime = DateFormat('yyyy-MM-dd').parse(dateStr);
          } else if (dateStr.contains('/')) {
            dateTime = DateFormat('dd/MM/yyyy').parse(dateStr);
          } else {
            dateTime = DateTime.tryParse(dateStr);
          }
        }
      }
    } catch (e) {
      // If parsing fails, dateTime remains null
    }

    return Sale(
      sellId: int.tryParse(json['SellID'].toString()) ?? 0,
      sellDate: dateStr,
      sellTime: timeStr,
      sellDateTime: dateTime,
      subTotal: double.tryParse(json['SubTotal'].toString()) ?? 0.0,
      grandTotal: double.tryParse(json['GrandTotal'].toString()) ?? 0.0,
      customerName: json['CustomerName']?.toString(),
      customerPhone: json['CustomerPhone']?.toString(),
      details: json['details'] != null
          ? (json['details'] as List)
                .map((detail) => SaleDetail.fromJson(detail))
                .toList()
          : null,
    );
  }

  String get formattedDate {
    if (sellDateTime != null) {
      return DateFormat('dd/MM/yyyy HH:mm').format(sellDateTime!);
    }
    if (sellTime != null && sellTime!.isNotEmpty) {
      return '$sellDate $sellTime';
    }
    return sellDate;
  }

  String get formattedDateOnly {
    if (sellDateTime != null) {
      return DateFormat('dd/MM/yyyy').format(sellDateTime!);
    }
    return sellDate;
  }
}

class SaleDetail {
  final int sellDetailId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double total;

  SaleDetail({
    required this.sellDetailId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory SaleDetail.fromJson(Map<String, dynamic> json) {
    return SaleDetail(
      sellDetailId: int.tryParse(json['SellDetailID'].toString()) ?? 0,
      productId: int.tryParse(json['ProductID'].toString()) ?? 0,
      productName: json['ProductName']?.toString() ?? '',
      price: double.tryParse(json['Price'].toString()) ?? 0.0,
      quantity: int.tryParse(json['Quantity'].toString()) ?? 0,
      total: double.tryParse(json['Total'].toString()) ?? 0.0,
    );
  }
}

basePath bp = basePath();
final String baseUrl1 = bp.bpath();
final String baseUrl = '${baseUrl1}/main';

// API Service
class SalesApiService {
  // static const String baseUrl =
  //     'http://192.168.100.5:3000/main'; // ປ່ຽນ URL ຕາມເຊີຟເວີຂອງທ່ານ

  Future<List<Sale>> getAllSales() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sales'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Sale.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load sales');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Sale> getSaleDetails(int sellId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sales/$sellId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Sale.fromJson(data);
      } else {
        throw Exception('Failed to load sale details');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> updateSaleDetail(
    int sellDetailId, {
    int? newQuantity,
    double? newPrice,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (newQuantity != null) body['newQuantity'] = newQuantity;
      if (newPrice != null) body['newPrice'] = newPrice;

      final response = await http.put(
        Uri.parse('$baseUrl/sales/detail/$sellDetailId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSaleDetail(int sellDetailId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/sales/detail/$sellDetailId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// Main Sales History Page
class SalesHistoryPage extends StatefulWidget {
  @override
  _SalesHistoryPageState createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  final SalesApiService _apiService = SalesApiService();
  List<Sale> _sales = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final sales = await _apiService.getAllSales();

      // Sort sales by date (newest first)
      sales.sort((a, b) {
        if (a.sellDateTime != null && b.sellDateTime != null) {
          return b.sellDateTime!.compareTo(a.sellDateTime!);
        } else if (a.sellDateTime != null) {
          return -1;
        } else if (b.sellDateTime != null) {
          return 1;
        } else {
          return b.sellId.compareTo(a.sellId);
        }
      });

      setState(() {
        _sales = sales;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('ປະຫວັດການຂາຍ', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFE45C58),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadSales,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('ເກີດຂໍ້ຜິດພາດ: $_error'),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadSales, child: Text('ລອງໃໝ່')),
          ],
        ),
      );
    }

    if (_sales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'ບໍ່ມີການຂາຍ',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSales,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _sales.length,
        itemBuilder: (context, index) {
          final sale = _sales[index];

          // Group by date
          String currentDate = sale.formattedDateOnly;
          String? previousDate;
          if (index > 0) {
            previousDate = _sales[index - 1].formattedDateOnly;
          }

          bool showDateHeader = previousDate != currentDate;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Header
              if (showDateHeader) ...[
                if (index > 0) SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    currentDate,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 8),
              ],

              // Sale Card
              Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      '${sale.sellId}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  title: Text(
                    'ບິນເລກທີ: ${sale.sellId}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            sale.sellDateTime != null
                                ? DateFormat('HH:mm').format(sale.sellDateTime!)
                                : 'ບໍ່ມີເວລາ',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      if (sale.customerName != null) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text('ລູກຄ້າ: ${sale.customerName}'),
                          ],
                        ),
                      ],
                      if (sale.customerPhone != null) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text('ເບີໂທ: ${sale.customerPhone}'),
                          ],
                        ),
                      ],
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ຍອດລວມ:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${sale.grandTotal.toStringAsFixed(0)} ກີບ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SaleDetailPage(sellId: sale.sellId),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Sale Detail Page
class SaleDetailPage extends StatefulWidget {
  final int sellId;

  SaleDetailPage({required this.sellId});

  @override
  _SaleDetailPageState createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  final SalesApiService _apiService = SalesApiService();
  Sale? _sale;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadSaleDetails();
  }

  Future<void> _loadSaleDetails() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final sale = await _apiService.getSaleDetails(widget.sellId);
      setState(() {
        _sale = sale;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: AppDrawer(),
      appBar: AppBar(
        title: Text(
          'ລາຍລະອຽດການຂາຍ #${widget.sellId}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFE45C58),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('ເກີດຂໍ້ຜິດພາດ: $_error'),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadSaleDetails, child: Text('ລອງໃໝ່')),
          ],
        ),
      );
    }

    if (_sale == null) {
      return Center(child: Text('ບໍ່ພົບຂໍ້ມູນ'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sale Information
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ຂໍ້ມູນການຂາຍ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.receipt, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('ບິນເລກທີ: ${_sale!.sellId}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.date_range, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('ວັນທີ: ${_sale!.sellDate}'),
                    ],
                  ),
                  if (_sale!.customerName != null) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('ລູກຄ້າ: ${_sale!.customerName}'),
                      ],
                    ),
                  ],
                  if (_sale!.customerPhone != null) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('ເບີໂທ: ${_sale!.customerPhone}'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Product Details
          if (_sale!.details != null && _sale!.details!.isNotEmpty) ...[
            Text(
              'ລາຍການສິນຄ້າ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _sale!.details!.length,
              itemBuilder: (context, index) {
                final detail = _sale!.details![index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Text(
                        '${detail.quantity}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      detail.productName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ລາຄາ: ${detail.price.toStringAsFixed(0)} ກີບ'),
                        Text('ຈໍານວນ: ${detail.quantity} ຊິ້ນ'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${detail.total.toStringAsFixed(0)} ກີບ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditDialog(detail);
                            } else if (value == 'delete') {
                              _showDeleteDialog(detail);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('ແກ້ໄຂ'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('ລົບ'),
                                ],
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

          SizedBox(height: 16),

          // Total Summary
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ຍອດລວມທັງໝົດ:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_sale!.grandTotal.toStringAsFixed(0)} ກີບ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Edit Dialog
  void _showEditDialog(SaleDetail detail) {
    final TextEditingController quantityController = TextEditingController(
      text: detail.quantity.toString(),
    );
    final TextEditingController priceController = TextEditingController(
      text: detail.price.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ແກ້ໄຂສິນຄ້າ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ສິນຄ້າ: ${detail.productName}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'ຈໍານວນ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: 'ລາຄາ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ຍົກເລີກ'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newQuantity = int.tryParse(quantityController.text);
              final newPrice = double.tryParse(priceController.text);

              if (newQuantity != null &&
                  newPrice != null &&
                  newQuantity > 0 &&
                  newPrice > 0) {
                Navigator.pop(context);
                await _updateSaleDetail(
                  detail.sellDetailId,
                  newQuantity,
                  newPrice,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ກະລຸນາໃສ່ຂໍ້ມູນທີ່ຖືກຕ້ອງ')),
                );
              }
            },
            child: Text('ບັນທຶກ'),
          ),
        ],
      ),
    );
  }

  // Delete Dialog
  void _showDeleteDialog(SaleDetail detail) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ລົບສິນຄ້າ'),
        content: Text(
          'ທ່ານຕ້ອງການລົບສິນຄ້າ "${detail.productName}" ອອກຈາກບິນນີ້ບໍ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ຍົກເລີກ'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteSaleDetail(detail.sellDetailId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('ລົບ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Update Sale Detail
  Future<void> _updateSaleDetail(
    int sellDetailId,
    int newQuantity,
    double newPrice,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await _apiService.updateSaleDetail(
        sellDetailId,
        newQuantity: newQuantity,
        newPrice: newPrice,
      );

      Navigator.pop(context); // Close loading dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ແກ້ໄຂສຳເລັດແລ້ວ'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadSaleDetails(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ແກ້ໄຂບໍ່ສຳເລັດ'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ເກີດຂໍ້ຜິດພາດ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Delete Sale Detail
  Future<void> _deleteSaleDetail(int sellDetailId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await _apiService.deleteSaleDetail(sellDetailId);

      Navigator.pop(context); // Close loading dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ລົບສຳເລັດແລ້ວ'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadSaleDetails(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ລົບບໍ່ສຳເລັດ'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ເກີດຂໍ້ຜິດພາດ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Usage Example
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Sales History',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: SalesHistoryPage(),
//     );
//   }
// }

// void main() {
//   runApp(MyApp());
// }
