import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// --- Data Models ---
class DashboardStats {
  final double sales;
  final double salesCash;
  final double salesTransfer;
  final int transactions;
  final int pendingImports;

  DashboardStats({
    this.sales = 0.0,
    this.salesCash = 0.0,
    this.salesTransfer = 0.0,
    this.transactions = 0,
    this.pendingImports = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        sales: (json['sales'] ?? 0).toDouble(),
        salesCash: (json['salesCash'] ?? 0).toDouble(),
        salesTransfer: (json['salesTransfer'] ?? 0).toDouble(),
        transactions: json['transactions'] ?? 0,
        pendingImports: json['pendingImports'] ?? 0,
      );
}

class ActivityLog {
  final String message;
  final DateTime timestamp;
  final String table;
  final String action;
  final String employeeName;

  ActivityLog.fromJson(Map<String, dynamic> json)
      : message = json['ChangeDetails'] ?? 'N/A',
        timestamp =
            DateTime.tryParse(json['LogTimestamp'] ?? '') ?? DateTime.now(),
        table = json['TargetTable'] ?? 'N/A',
        action = json['ActionType'] ?? 'N/A',
        employeeName = json['EmployeeName'] ?? 'System';
}

class TopProduct {
  final String productName;
  final int totalQuantitySold;

  TopProduct.fromJson(Map<String, dynamic> json)
      : productName = json['ProductName'] ?? 'Unknown',
        totalQuantitySold = json['total_quantity_sold'] ?? 0;
}

// *** NEW MODEL for Low Stock Products ***
class LowStockProduct {
  final String productName;
  final int quantity;
  final int level;

  LowStockProduct.fromJson(Map<String, dynamic> json)
      : productName = json['ProductName'] ?? 'Unknown',
        quantity = json['Quantity'] ?? 0,
        level = json['Level'] ?? 0;
}

class DashboardAndLogPage extends StatefulWidget {
  const DashboardAndLogPage({Key? key}) : super(key: key);

  @override
  State<DashboardAndLogPage> createState() => _DashboardAndLogPageState();
}

class _DashboardAndLogPageState extends State<DashboardAndLogPage> {
  final String baseUrl = basePath().bpath();
  List<ActivityLog> logs = [];
  DashboardStats stats = DashboardStats();
  List<TopProduct> topProducts = [];
  List<LowStockProduct> lowStockProducts = []; // *** NEW State ***
  bool isLoading = true;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String _filterDisplayTitle = 'ຂໍ້ມູນມື້ນີ້';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    if (!isRefresh) setState(() => isLoading = true);

    DateFormat apiDateFormat = DateFormat('yyyy-MM-dd');
    String startDateStr = apiDateFormat.format(_startDate);
    String endDateStr = apiDateFormat.format(_endDate);

    if (startDateStr == endDateStr) {
      _filterDisplayTitle =
          'ຂໍ້ມູນວັນທີ ${DateFormat('dd/MM/yyyy').format(_startDate)}';
    } else {
      _filterDisplayTitle =
          'ຂໍ້ມູນຊ່ວງ ${DateFormat('dd/MM/yy').format(_startDate)} - ${DateFormat('dd/MM/yy').format(_endDate)}';
    }

    final queryParams = '?startDate=$startDateStr&endDate=$endDateStr';

    try {
      await Future.wait([
        _fetchLogs(queryParams),
        _fetchDashboardStats(queryParams),
        _fetchTopProducts(queryParams),
        _fetchLowStockProducts(),
      ]);
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchLogs(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/main/logs$query'));
      if (response.statusCode == 200 && mounted) {
        setState(() => logs = (json.decode(response.body) as List)
            .map((item) => ActivityLog.fromJson(item))
            .toList());
      }
    } catch (e) {
      print('Error fetching logs: $e');
    }
  }

  Future<void> _fetchDashboardStats(String query) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/main/dashboard/stats$query'));
      if (response.statusCode == 200 && mounted) {
        setState(
            () => stats = DashboardStats.fromJson(json.decode(response.body)));
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

  Future<void> _fetchTopProducts(String query) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/main/dashboard/top-products$query'));
      if (response.statusCode == 200 && mounted) {
        setState(() => topProducts = (json.decode(response.body) as List)
            .map((item) => TopProduct.fromJson(item))
            .toList());
      }
    } catch (e) {
      print('Error fetching top products: $e');
    }
  }

  // *** NEW Function to fetch low stock products ***
  Future<void> _fetchLowStockProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/main/dashboard/low-stock-products'));
      if (response.statusCode == 200 && mounted) {
        setState(() => lowStockProducts = (json.decode(response.body) as List)
            .map((item) => LowStockProduct.fromJson(item))
            .toList());
      }
    } catch (e) {
      print('Error fetching low stock products: $e');
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'ເລືອກຊ່ວງວັນທີທີ່ຕ້ອງການ',
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
              primary: Color(0xFFE45C58),
              onPrimary: Colors.white,
              onSurface: Colors.black),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _loadData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE45C58),
      appBar: AppBar(
        title: Text(
          'Dashboard & Log',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFE45C58),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadData(isRefresh: true),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  _buildDashboardGrid(),
                  SliverToBoxAdapter(child: _buildTopProductsSection()),
                  SliverToBoxAdapter(child: _buildLowStockSection()),
                  SliverToBoxAdapter(child: _buildLogHeader()),
                  _buildLogList(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_filterDisplayTitle,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            ActionChip(
              onPressed: _selectDateRange,
              avatar: Icon(Icons.calendar_today,
                  size: 16, color: Color(0xFFE45C58)),
              label: Text('ປ່ຽນຊ່ວງເວລາ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300)),
            )
          ],
        ),
      );

  Widget _buildDashboardGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      sliver: SliverGrid.count(
        crossAxisCount: MediaQuery.of(context).size.width > 900
            ? 2
            : 2, // ปรับให้แสดง 2 column
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
        children: [
          _buildSalesStatCard(
            totalSales: stats.sales,
            cashSales: stats.salesCash,
            transferSales: stats.salesTransfer,
          ),
          _buildStatCard(
            'ຈຳນວນບິນ',
            stats.transactions.toString(),
            Icons.receipt_long_outlined,
            Colors.blue,
          ),
          _buildStatCard('ຖ້າຢືນຢັນນຳເຂົ້າ', stats.pendingImports.toString(),
              Icons.pending_actions_outlined, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 28, color: color),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Spacer(),
            Text(title,
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesStatCard({
    required double totalSales,
    required double cashSales,
    required double transferSales,
  }) {
    final formatCurrency = NumberFormat("#,##0", "en_US");
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.monetization_on_outlined,
                    size: 28, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${formatCurrency.format(totalSales)} LAK',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text("ຍອດຂາຍລວມ",
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            Spacer(),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ເງິນສົດ",
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                    Text('${formatCurrency.format(cashSales)}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ເງິນໂອນ",
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                    Text('${formatCurrency.format(transferSales)}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsSection() => Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.star_border, color: Colors.amber.shade800),
                  SizedBox(width: 8),
                  Text('5 ອັນດັບສິນຄ້າຂາຍດີ',
                      style: Theme.of(context).textTheme.titleLarge),
                ]),
                Divider(height: 24),
                if (topProducts.isEmpty)
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text("ບໍ່ມີຂໍ້ມູນການຂາຍໃນຊ່ວງເວລານີ້")))
                else
                  ...topProducts.asMap().entries.map((entry) {
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(child: Text('${entry.key + 1}')),
                      title: Text(entry.value.productName,
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      trailing: Text('${entry.value.totalQuantitySold} ລາຍການ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800)),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
      );

  // *** NEW WIDGET for displaying low stock products ***
  Widget _buildLowStockSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade800),
                  SizedBox(width: 8),
                  Text('ສິນຄ້າໃກ້ໝົດ',
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              Divider(height: 24),
              if (lowStockProducts.isEmpty)
                Center(
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text("ບໍ່ມີສິນຄ້າໃກ້ໝົດ")))
              else
                ...lowStockProducts.asMap().entries.map((entry) {
                  LowStockProduct product = entry.value;
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                        backgroundColor: Colors.orange.shade100,
                        child: Icon(Icons.inventory_2_outlined,
                            color: Colors.orange.shade800, size: 20)),
                    title: Text(product.productName,
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Text(
                        'ເຫຼືອ ${product.quantity} (ຂັ້ນຕໍ່າ ${product.level})',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900)),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
        child: Row(
          children: [
            Icon(Icons.history_toggle_off, color: Color(0xFFE45C58), size: 28),
            const SizedBox(width: 12),
            Text(
              'Activity Log',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      );

  Widget _buildLogList() {
    if (logs.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48.0),
            child: Text('ບໍ່ມີກິດຈະກຳໃດໆໃນຊ່ວງເວລານີ້.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ),
        ),
      );
    }
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (context, index) => _buildLogItem(logs[index]),
            childCount: logs.length));
  }

  Widget _buildLogItem(ActivityLog log) {
    final colors = {
      'CREATE': Colors.green,
      'UPDATE': Colors.orange,
      'DELETE': Colors.red
    };
    final icons = {
      'CREATE': Icons.add_circle,
      'UPDATE': Icons.edit,
      'DELETE': Icons.remove_circle
    };
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: (colors[log.action] ?? Colors.grey).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  Icon(icons[log.action] ?? Icons.info,
                      color: colors[log.action] ?? Colors.grey, size: 16),
                  SizedBox(width: 6),
                  Text(log.action,
                      style: TextStyle(
                          color: colors[log.action] ?? Colors.grey,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
              Text(DateFormat('HH:mm:ss, MM/dd/yy').format(log.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ]),
            const SizedBox(height: 10),
            Text(log.message, style: const TextStyle(fontSize: 14)),
            const Divider(height: 20),
            Row(children: [
              Icon(Icons.person_outline, size: 14, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Text('By: ${log.employeeName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
              const Spacer(),
              Icon(Icons.table_chart_outlined,
                  size: 14, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Text(log.table,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
            ]),
          ],
        ),
      ),
    );
  }
}
