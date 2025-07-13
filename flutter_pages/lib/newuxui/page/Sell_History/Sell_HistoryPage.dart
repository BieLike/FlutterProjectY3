import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Models ---
class Sale {
  final int sellId;
  final String? employeeName;
  final DateTime? sellDateTime;
  final double grandTotal;

  Sale(
      {required this.sellId,
      this.employeeName,
      this.sellDateTime,
      required this.grandTotal});

  factory Sale.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    try {
      if (json['Date'] != null) {
        parsedDate =
            DateTime.parse('${json['Date']} ${json['Time'] ?? '00:00:00'}');
      }
    } catch (e) {/* Ignore */}
    return Sale(
      sellId: int.parse(json['SellID'].toString()),
      employeeName: json['EmployeeName'],
      sellDateTime: parsedDate,
      grandTotal: double.tryParse(json['GrandTotal'].toString()) ?? 0.0,
    );
  }
}

class SaleDetail {
  final int sellDetailId;
  final String productName, productId, categoryName, unitName;
  final int quantity;
  final double price, total;

  SaleDetail(
      {required this.sellDetailId,
      required this.productName,
      required this.productId,
      required this.quantity,
      required this.price,
      required this.total,
      required this.categoryName,
      required this.unitName});

  factory SaleDetail.fromJson(Map<String, dynamic> json) => SaleDetail(
        sellDetailId: int.parse(json['SellDetailID'].toString()),
        productName: json['ProductName'] ?? 'N/A',
        productId: json['ProductID'] ?? 'N/A',
        quantity: int.parse(json['Quantity'].toString()),
        price: double.parse(json['Price'].toString()),
        total: double.parse(json['Total'].toString()),
        categoryName: json['CategoryName'] ?? 'N/A',
        unitName: json['UnitName'] ?? 'N/A',
      );
}

class FullSaleDetails extends Sale {
  final List<SaleDetail> details;
  final double subTotal, moneyReceived, changeTotal;
  final String paymentMethod, employeeRole;
  final String? employeePhone, employeeEmail;

  FullSaleDetails({
    required super.sellId,
    super.employeeName,
    super.sellDateTime,
    required super.grandTotal,
    required this.details,
    required this.subTotal,
    required this.moneyReceived,
    required this.changeTotal,
    required this.paymentMethod,
    required this.employeeRole,
    this.employeePhone,
    this.employeeEmail,
  });

  factory FullSaleDetails.fromJson(Map<String, dynamic> json) {
    return FullSaleDetails(
      sellId: int.parse(json['SellID'].toString()),
      employeeName: json['EmployeeName'],
      sellDateTime: json['Date'] != null
          ? DateTime.parse('${json['Date']} ${json['Time'] ?? '00:00:00'}')
          : null,
      grandTotal: double.parse(json['GrandTotal'].toString()),
      details:
          (json['details'] as List).map((i) => SaleDetail.fromJson(i)).toList(),
      subTotal: double.parse(json['SubTotal'].toString()),
      moneyReceived: double.parse(json['Money'].toString()),
      changeTotal: double.parse(json['ChangeTotal'].toString()),
      paymentMethod: json['PaymentMethod'],
      employeeRole: json['EmployeeRole'],
      employeePhone: json['EmployeePhone'],
      employeeEmail: json['EmployeeEmail'],
    );
  }
}

// --- API Service ---
class SalesApiService {
  final String baseUrl = '${basePath().bpath()}/main';

  Future<List<Sale>> getSales() async {
    final response = await http.get(Uri.parse('$baseUrl/sales'));
    if (response.statusCode == 200)
      return (json.decode(response.body) as List)
          .map((sale) => Sale.fromJson(sale))
          .toList();
    throw Exception('Failed to load sales history');
  }

  Future<FullSaleDetails> getSaleDetails(int sellId) async {
    final response = await http.get(Uri.parse('$baseUrl/sales/$sellId'));
    if (response.statusCode == 200)
      return FullSaleDetails.fromJson(json.decode(response.body));
    throw Exception('Failed to load sale details for ID $sellId');
  }

  Future<void> updateSaleDetailQuantity(int sellDetailId, int newQuantity,
      Map<String, dynamic> employeeData, double originalPrice) async {
    final response = await http.put(
      Uri.parse('$baseUrl/sales/detail/$sellDetailId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'newQuantity': newQuantity,
        'EmployeeID': employeeData['UID'],
        'EmployeeName': employeeData['UserFname'],
        'originalPrice': originalPrice // ส่งราคาต่อหน่วยเพื่อคำนวณเงินทอน
      }),
    );
    if (response.statusCode != 200)
      throw Exception(
          json.decode(response.body)['msg'] ?? 'Failed to update sale detail');
  }

  Future<void> deleteSaleDetail(
      int sellDetailId, Map<String, dynamic> employeeData) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/sales/detail/$sellDetailId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'EmployeeID': employeeData['UID'],
        'EmployeeName': employeeData['UserFname']
      }),
    );
    if (response.statusCode != 200)
      throw Exception(
          json.decode(response.body)['msg'] ?? 'Failed to delete sale detail');
  }

  Future<void> deleteEntireSale(
      int sellId, Map<String, dynamic> employeeData) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/sales/$sellId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'EmployeeID': employeeData['UID'],
        'EmployeeName': employeeData['UserFname']
      }),
    );
    if (response.statusCode != 200)
      throw Exception(
          json.decode(response.body)['msg'] ?? 'Failed to delete sale');
  }
}

// --- Main Page ---
class SalesHistoryPage extends StatefulWidget {
  @override
  _SalesHistoryPageState createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  final SalesApiService _apiService = SalesApiService();
  List<Sale> _allSales = [];
  List<Sale> _filteredSales = [];
  bool _isLoading = true;
  String _error = '';
  DateTime? _startDate, _endDate;

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
      final sales = await _apiService.getSales();
      sales.sort((a, b) => (b.sellDateTime ?? DateTime(0))
          .compareTo(a.sellDateTime ?? DateTime(0)));
      setState(() {
        _allSales = sales;
        _filterSales();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSales() {
    setState(() {
      if (_startDate == null || _endDate == null) {
        _filteredSales = _allSales;
        return;
      }
      _filteredSales = _allSales.where((sale) {
        if (sale.sellDateTime == null) return false;
        final saleDate = DateUtils.dateOnly(sale.sellDateTime!);
        return !saleDate.isBefore(DateUtils.dateOnly(_startDate!)) &&
            !saleDate.isAfter(DateUtils.dateOnly(_endDate!));
      }).toList();
    });
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 1)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
        _filterSales();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE45C58),
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Sales History 🧾'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
            tooltip: 'Filter by Date Range',
          ),
          if (_startDate != null)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => setState(() {
                _startDate = null;
                _endDate = null;
                _filterSales();
              }),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSales,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : _error.isNotEmpty
                ? _buildErrorState(_error)
                : _filteredSales.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(12.0),
                        itemCount: _filteredSales.length,
                        itemBuilder: (context, index) {
                          final sale = _filteredSales[index];
                          return Card(
                            child: InkWell(
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SaleDetailPage(
                                            sellId: sale.sellId)));
                                // Auto refresh when returning from detail page
                                _loadSales();
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Sale ID: #${sale.sellId}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueAccent)),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildInfoChip(
                                            Icons.calendar_today,
                                            sale.sellDateTime != null
                                                ? DateFormat('dd/MM/yyyy')
                                                    .format(sale.sellDateTime!)
                                                : 'N/A',
                                            color: Colors.indigo),
                                        _buildInfoChip(
                                            Icons.access_time,
                                            sale.sellDateTime != null
                                                ? DateFormat('HH:mm')
                                                    .format(sale.sellDateTime!)
                                                : 'N/A',
                                            color: Colors.teal),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Divider(),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total:',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                        Text(
                                            '${NumberFormat("#,##0.00").format(sale.grandTotal)} ກີບ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(
                                                        0xFFE45C58))),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(children: [
                                      const Icon(Icons.person,
                                          size: 18, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                          'Sold by: ${sale.employeeName ?? 'N/A'}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color: Colors.grey[700])),
                                    ]),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, {Color? color}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: color?.withOpacity(0.1) ?? Colors.blue[50],
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: color ?? Colors.blueAccent),
          const SizedBox(width: 6),
          Text(text,
              style:
                  TextStyle(color: color ?? Colors.blueAccent, fontSize: 14)),
        ]),
      );

  Widget _buildErrorState(String error) => Center(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.error_outline, color: Colors.yellow, size: 80),
            const SizedBox(height: 20),
            Text('Oops! Something went wrong.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white)),
            const SizedBox(height: 10),
            Text(error,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white70)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
                onPressed: _loadSales,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry')),
          ])));

  Widget _buildEmptyState() => Center(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.inbox_outlined, color: Colors.white70, size: 100),
            const SizedBox(height: 20),
            Text('No sales yet!',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white)),
            const SizedBox(height: 10),
            Text('Start making sales to see them listed here.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white70)),
          ])));
}

// --- Detail Page ---
class SaleDetailPage extends StatefulWidget {
  final int sellId;
  const SaleDetailPage({super.key, required this.sellId});
  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  final SalesApiService _apiService = SalesApiService();
  FullSaleDetails? _saleDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    try {
      final details = await _apiService.getSaleDetails(widget.sellId);
      if (mounted) setState(() => _saleDetails = details);
    } catch (e) {
      _showSnackBar(e.toString(), true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, bool isError) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green));
  }

  Future<Map<String, dynamic>?> _getEmployeeData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString == null) {
      _showSnackBar("User not found. Please log in again.", true);
      return null;
    }
    return json.decode(userDataString);
  }

  Future<void> _handleUpdateQuantity(SaleDetail detail) async {
    final qtyController =
        TextEditingController(text: detail.quantity.toString());
    final newQty = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Return Items - ${detail.productName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Quantity: ${detail.quantity}'),
            SizedBox(height: 10),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Quantity to Return',
                  border: OutlineInputBorder(),
                  helperText: 'Enter how many items to return'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(qtyController.text),
              child: Text('Return')),
        ],
      ),
    );

    if (newQty != null && int.tryParse(newQty) != null) {
      final returnQty = int.parse(newQty);
      if (returnQty <= 0) {
        _showSnackBar('Please enter a valid positive number.', true);
        return;
      }
      if (returnQty >= detail.quantity) {
        _showSnackBar(
            'Return quantity must be less than current quantity. Use delete if returning all items.',
            true);
        return;
      }

      final employeeData = await _getEmployeeData();
      if (employeeData == null) return;
      try {
        final newQuantity = detail.quantity - returnQty;
        await _apiService.updateSaleDetailQuantity(detail.sellDetailId,
            newQuantity, employeeData, detail.price // ส่งราคาต่อหน่วยไปด้วย
            );
        _showSnackBar('Items returned successfully', false);
        _loadDetails();
      } catch (e) {
        _showSnackBar(e.toString(), true);
      }
    }
  }

  Future<void> _handleDeleteDetail(SaleDetail detail) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('Delete Item'),
              content: Text(
                  'Are you sure you want to remove ${detail.productName}?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text('Cancel')),
                ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text('Delete'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red)),
              ],
            ));

    if (confirmed == true) {
      final employeeData = await _getEmployeeData();
      if (employeeData == null) return;
      try {
        await _apiService.deleteSaleDetail(detail.sellDetailId, employeeData);
        _showSnackBar('Item removed', false);
        _loadDetails();
      } catch (e) {
        _showSnackBar(e.toString(), true);
      }
    }
  }

  Future<void> _handleDeleteSale() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('ລົບການຂາຍ'),
              content: Text('ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການລົບການຂາຍນີ້ທັງໝົດ?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text('ຍົກເລີກ')),
                ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text('ລົບ'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red)),
              ],
            ));

    if (confirmed == true) {
      final employeeData = await _getEmployeeData();
      if (employeeData == null) return;
      try {
        await _apiService.deleteEntireSale(widget.sellId, employeeData);
        _showSnackBar('Sale record deleted successfully', false);
        Navigator.of(context).pop(true);
      } catch (e) {
        _showSnackBar(e.toString(), true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE45C58),
      appBar: AppBar(
        title: Text('Sale Details (ID: #${widget.sellId})'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: Icon(Icons.delete_forever),
              tooltip: 'Delete Entire Sale',
              onPressed: _handleDeleteSale)
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : _saleDetails == null
              ? Center(
                  child: Text('ບໍ່ພົບຂໍ້ມູນ',
                      style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard('ການຂາຍໂດຍລວມ', [
                        _buildDetailRow('Sale ID:', '#${_saleDetails!.sellId}'),
                        _buildDetailRow(
                            'ວັນທີ:',
                            _saleDetails!.sellDateTime != null
                                ? DateFormat('dd/MM/yyyy')
                                    .format(_saleDetails!.sellDateTime!)
                                : 'N/A'),
                        _buildDetailRow(
                            'ເວລາ:',
                            _saleDetails!.sellDateTime != null
                                ? DateFormat('HH:mm:ss')
                                    .format(_saleDetails!.sellDateTime!)
                                : 'N/A'),
                        _buildDetailRow(
                            'ວິທີການຊຳລະ:', _saleDetails!.paymentMethod,
                            icon: Icons.payment),
                        SizedBox(height: 10),
                        _buildDetailRow('ຍອດ:',
                            '${NumberFormat("#,##0.00").format(_saleDetails!.subTotal)} ກີບ'),
                        _buildDetailRow('ຍອດລວມ:',
                            '${NumberFormat("#,##0.00").format(_saleDetails!.grandTotal)} ກີບ',
                            isBold: true,
                            color: Colors.green[700],
                            fontSize: 18,
                            icon: Icons.monetization_on),
                        _buildDetailRow('ເງິນທີ່ໄດ້ຮັບ:',
                            '${NumberFormat("#,##0.00").format(_saleDetails!.moneyReceived)} ກີບ',
                            color: Colors.blue[700], fontSize: 16),
                        _buildDetailRow('ເງິນທອນ:',
                            '${NumberFormat("#,##0.00").format(_saleDetails!.changeTotal)} ກີບ',
                            color: Colors.orange[700], fontSize: 16)
                      ]),
                      const SizedBox(height: 20),
                      _buildInfoCard('ຂໍ້ມູນພະນັກງານ', [
                        _buildDetailRow(
                            'ຊື່:', _saleDetails!.employeeName ?? 'N/A',
                            icon: Icons.person),
                        _buildDetailRow('ຕຳແໜ່ງ:', _saleDetails!.employeeRole,
                            icon: Icons.work_outline),
                        _buildDetailRow('ເບີໂທ:',
                            _saleDetails!.employeePhone ?? 'Not provided',
                            icon: Icons.phone),
                        _buildDetailRow('Email:',
                            _saleDetails!.employeeEmail ?? 'Not provided',
                            icon: Icons.email),
                      ]),
                      const SizedBox(height: 20),
                      Text('ສິນຄ້າທີ່ຂາຍ',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                      const SizedBox(height: 10),
                      if (_saleDetails!.details.isEmpty)
                        Center(
                            child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text('No products found for this sale.',
                                    style: TextStyle(color: Colors.white))))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _saleDetails!.details.length,
                          itemBuilder: (context, index) {
                            final detail = _saleDetails!.details[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(detail.productName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepPurple[700])),
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                        'ID ສິນຄ້າ:', detail.productId),
                                    _buildDetailRow(
                                        'ໝວດໝູ່:', detail.categoryName),
                                    _buildDetailRow(
                                        'ຫົວໜ່ວຍ:', detail.unitName),
                                    _buildDetailRow('ລາຄາ:',
                                        '${NumberFormat("#,##0.00").format(detail.price)} ກີບ x ${detail.quantity}'),
                                    _buildDetailRow('ລວມ:',
                                        '${NumberFormat("#,##0.00").format(detail.total)} ກີບ',
                                        isBold: true,
                                        color: Colors.orange[700],
                                        fontSize: 16),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _handleUpdateQuantity(detail),
                                          icon:
                                              const Icon(Icons.edit, size: 18),
                                          label: const Text('ແກ້ໄຂ'),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blueGrey,
                                              foregroundColor: Colors.white),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _handleDeleteDetail(detail),
                                          icon: const Icon(
                                              Icons.remove_circle_outline,
                                              size: 18),
                                          label: const Text('ລົບ'),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              foregroundColor: Colors.white),
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
                ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800])),
              const Divider(height: 20, thickness: 1),
              ...children,
            ],
          ),
        ),
      );

  Widget _buildDetailRow(String label, String value,
          {bool isBold = false,
          Color? color,
          double fontSize = 15,
          IconData? icon}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize - 1, color: Colors.grey[600]),
            const SizedBox(width: 8)
          ],
          SizedBox(
              width: 130,
              child: Text(label,
                  style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700]))),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      color: color ?? Colors.black87))),
        ]),
      );
}
