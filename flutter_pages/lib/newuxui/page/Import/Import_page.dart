import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/page/import/create_import.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageImportPage extends StatefulWidget {
  const ManageImportPage({super.key});

  @override
  State<ManageImportPage> createState() => _ManageImportPageState();
}

class _ManageImportPageState extends State<ManageImportPage> {
  List data = [];
  List filteredData = [];
  final String baseurl = basePath().bpath();
  final TextEditingController txtSearch = TextEditingController();

  bool isLoading = false;
  Map<int, bool> isConfirming = {};

  // Filter states
  String selectedStatus = 'All';
  DateTime? startDate, endDate;

  // Dialog states
  Map<String, TextEditingController> qtyControllers = {};
  Map<String, bool> itemChecked = {};
  String tempStatus = '';

  @override
  void initState() {
    super.initState();
    FetchAllImports();
  }

  // --- Data & Filtering ---
  Future<void> FetchAllImports() async {
    setState(() => isLoading = true);
    isConfirming.clear();
    try {
      final response = await http.get(Uri.parse("$baseurl/main/import"));
      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          FilterImports(); // Apply current filters after fetching
        });
      } else {
        ShowErrorMessage("Failed to load imports: ${response.statusCode}");
      }
    } catch (e) {
      ShowErrorMessage("Connection error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void FilterImports() {
    setState(() {
      filteredData = data.where((import) {
        final searchMatch = txtSearch.text.isEmpty ||
            (import['SupplierName']
                    ?.toString()
                    .toLowerCase()
                    .contains(txtSearch.text.toLowerCase()) ??
                false) ||
            (import['ImportID']
                    ?.toString()
                    .contains(txtSearch.text.toLowerCase()) ??
                false);

        final statusMatch =
            selectedStatus == 'All' || import['Status'] == selectedStatus;

        bool dateMatch = true;
        if (startDate != null && endDate != null) {
          try {
            DateTime importDate = DateTime.parse(import['ImportDate']);
            dateMatch = !importDate.isBefore(startDate!) &&
                !importDate.isAfter(endDate!
                    .add(const Duration(days: 1))
                    .subtract(const Duration(microseconds: 1)));
          } catch (e) {
            dateMatch = false;
          }
        }
        return searchMatch && statusMatch && dateMatch;
      }).toList();
    });
  }

  // --- API Actions (Unified)---
  Future<Map<String, dynamic>?> _getEmployeeData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString == null) {
      ShowErrorMessage("ບໍ່ພົບຂໍ້ມູນຜູ້ໃຊ້, ກະລຸນາລັອກອິນໃໝ່");
      return null;
    }
    return json.decode(userDataString);
  }

  Future<void> performStatusUpdate(int importID, String newStatus,
      {String? reason, List<Map<String, dynamic>>? checkedItems}) async {
    // Prevent double-clicks
    if (isConfirming[importID] == true) return;

    final employeeData = await _getEmployeeData();
    if (employeeData == null) return;

    setState(() => isConfirming[importID] = true);

    try {
      Map<String, dynamic> body = {
        "status": newStatus,
        "EmployeeID": employeeData['UID'],
        "EmployeeName": employeeData['UserFname'],
        if (reason != null) "reason": reason,
        if (checkedItems != null) "checkedItems": checkedItems,
      };

      final response = await http.put(
        Uri.parse("$baseurl/main/import/$importID/update-status"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        ShowSuccessMessage(
            responseBody['msg'] ?? 'Status updated successfully');
        await FetchAllImports();
      } else {
        ShowErrorMessage(responseBody['msg'] ?? 'Failed to update status');
      }
    } catch (e) {
      ShowErrorMessage("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isConfirming[importID] = false);
    }
  }

  // --- UI & Dialogs ---
  void showQuickActionConfirmation(int importID, String newStatus) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Action'),
        content:
            Text('Are you sure you want to mark this import as "$newStatus"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirm'),
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    newStatus == 'Completed' ? Colors.green : Colors.red,
                foregroundColor: Colors.white),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        performStatusUpdate(importID, newStatus, reason: 'Cancelled from App');
      }
    });
  }

  void showDetailedConfirmation(int importID, String status) {
    List<Map<String, dynamic>> checkedItemsList = itemChecked.entries
        .where((entry) => entry.value)
        .map((entry) => {
              "ImportDetailID": int.parse(entry.key),
              "ReceivedQuantity":
                  int.parse(qtyControllers[entry.key]?.text ?? '0')
            })
        .toList();

    if (status == 'Completed' && checkedItemsList.isEmpty) {
      ShowErrorMessage("Please check at least one item to confirm.");
      return;
    }

    Navigator.of(context).pop(); // Close the details dialog first
    performStatusUpdate(importID, status,
        checkedItems: checkedItemsList, reason: 'Cancelled from App');
  }

  void ShowMessage(String message, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void ShowSuccessMessage(String message) => ShowMessage(message, Colors.green);
  void ShowErrorMessage(String message) => ShowMessage(message, Colors.red);

  String FormatCurrency(dynamic amount) {
    if (amount == null) return '\$0.00';
    double value = double.tryParse(amount.toString()) ?? 0.0;
    return '\$${value.toStringAsFixed(2)}';
  }

  String FormatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('MM/dd/yyyy').format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
    }
  }

  Color GetStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData GetStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Future<void> SelectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        FilterImports();
      });
    }
  }

  void ClearDateRange() {
    setState(() {
      startDate = null;
      endDate = null;
      FilterImports();
    });
  }

  void ShowImportDetails(Map<String, dynamic> import) async {
    setState(() => isLoading = true);
    try {
      final response = await http
          .get(Uri.parse("$baseurl/main/import/${import['ImportID']}"));

      if (response.statusCode == 200) {
        final detailData = json.decode(response.body);

        // Initialize controllers and checkboxes for the dialog
        final details = detailData['details'] as List<dynamic>;
        qtyControllers.clear();
        itemChecked.clear();
        for (var detail in details) {
          String key = detail['ImportDetailID'].toString();
          qtyControllers[key] =
              TextEditingController(text: detail['ImportQuantity'].toString());
          itemChecked[key] = true; // Default to checked
        }
        tempStatus = detailData['header']['Status'];

        if (mounted) setState(() => isLoading = false);
        _ShowImportDetailsDialog(detailData);
      } else {
        ShowErrorMessage(
            "Failed to load import details: ${response.statusCode}");
      }
    } catch (e) {
      ShowErrorMessage("Error loading details: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _ShowImportDetailsDialog(Map<String, dynamic> detailData) {
    final header = detailData['header'];
    final details = detailData['details'] as List<dynamic>;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ລາຍລະອຽດການນຳເຂົ້າ',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE45C58))),
                    DropdownButton<String>(
                      value: tempStatus,
                      items: ['Pending', 'Completed', 'Cancelled']
                          .map((status) => DropdownMenuItem(
                              value: status, child: Text(status)))
                          .toList(),
                      onChanged: header['Status'] != 'Pending'
                          ? null
                          : (value) =>
                              setDialogState(() => tempStatus = value!),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildInfoCard('ຂໍ້ມູນການນຳເຂົ້າ', [
                        _InfoRow('ID ນຳເຂົ້າ:', header['ImportID'].toString()),
                        _InfoRow('ວັນທີ:', FormatDate(header['ImportDate'])),
                        _InfoRow(
                            'ໃບແຈ້ງໜີ້:', header['InvoiceNumber'] ?? 'N/A'),
                      ]),
                      SizedBox(height: 16),
                      _buildProductsList(details, setDialogState),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('ປິດ')),
                    if (header['Status'] == 'Pending')
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ElevatedButton(
                          onPressed: () => showDetailedConfirmation(
                              header['ImportID'], tempStatus),
                          child: Text('ຢືນຢັນ'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFE45C58),
                              foregroundColor: Colors.white),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) => Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE45C58))),
            SizedBox(height: 12),
            ...children,
          ]),
        ),
      );

  Widget _InfoRow(String label, String value) => Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.grey[600]))),
          Expanded(
              child:
                  Text(value, style: TextStyle(fontWeight: FontWeight.w500))),
        ]),
      );

  Widget _buildProductsList(List<dynamic> details, StateSetter setDialogState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ລາຍການນຳເຂົ້າ',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE45C58))),
            TextButton.icon(
              onPressed: () {
                setDialogState(() {
                  bool allChecked =
                      itemChecked.values.every((checked) => checked);
                  itemChecked.updateAll((key, value) => !allChecked);
                });
              },
              icon: Icon(itemChecked.values.every((checked) => checked)
                  ? Icons.check_box
                  : Icons.check_box_outline_blank),
              label: Text(itemChecked.values.every((checked) => checked)
                  ? 'Uncheck All'
                  : 'Check All'),
            ),
          ],
        ),
        ...details
            .map((detail) => _buildProductCardForDialog(detail, setDialogState))
            .toList(),
      ],
    );
  }

  Widget _buildProductCardForDialog(
      Map<String, dynamic> detail, StateSetter setDialogState) {
    String key = detail['ImportDetailID'].toString();
    bool isChecked = itemChecked[key] ?? false;
    bool canEdit = tempStatus == 'Pending';

    return Card(
      color: isChecked ? Color(0xFFE45C58).withOpacity(0.05) : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(children: [
          Checkbox(
            value: isChecked,
            activeColor: Color(0xFFE45C58),
            onChanged: canEdit
                ? (bool? value) =>
                    setDialogState(() => itemChecked[key] = value ?? false)
                : null,
          ),
          Expanded(
              child: Text(detail['ProductName'] ?? 'Unknown Product',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: TextField(
              controller: qtyControllers[key],
              enabled: canEdit,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'ຈຳນວນທີ່ໄດ້ຮັບ',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8)),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE45C58),
      appBar: AppBar(
        title: Text(
          'ຈັດການການນຳເຂົ້າ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFE45C58),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredData.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: FetchAllImports,
                        child: ListView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) =>
                              _buildImportCard(filteredData[index]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateImportPage()));
          if (result == true) FetchAllImports();
        },
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('ການນຳເຂົ້າໃໝ່', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFE45C58),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: txtSearch,
            onChanged: (value) => FilterImports(),
            decoration: InputDecoration(
              hintText: "ຄົ້ນຫາຕາມຜູ້ສະໜອງ, ຫຼື ID...",
              prefixIcon: Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                      labelText: 'ສະຖານະ',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                  items: ['All', 'Pending', 'Completed', 'Cancelled']
                      .map((status) =>
                          DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedStatus = value!);
                    FilterImports();
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: SelectDateRange,
                  icon: Icon(Icons.date_range),
                  label: Text(startDate != null && endDate != null
                      ? '${FormatDate(startDate.toString())} - ${FormatDate(endDate.toString())}'
                      : 'All Time'),
                  style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
              if (startDate != null || selectedStatus != 'All')
                IconButton(
                    icon: Icon(Icons.clear, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        txtSearch.clear();
                        selectedStatus = 'All';
                        startDate = null;
                        endDate = null;
                      });
                      FilterImports();
                    }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
        SizedBox(height: 16),
        Text("ບໍ່ພົບເຫັນການນຳເຂັ້າ",
            style: TextStyle(fontSize: 18, color: Colors.grey[600])),
        Text("ລອງແກ້ໄຂການຄົ້ນຫາ ຫຼື ປ່ອນຂໍ້ມູນໃໝ່",
            style: TextStyle(fontSize: 14, color: Colors.grey[500])),
      ]));

  Widget _buildImportCard(Map<String, dynamic> import) {
    bool isPending = import['Status'] == 'Pending';
    bool isActionLoading = isConfirming[import['ImportID']] ?? false;

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () => ShowImportDetails(import),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('ນຳເຂົ້າ #${import['ImportID']}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE45C58))),
                      SizedBox(height: 4),
                      Text(import['SupplierName'] ?? 'Unknown Supplier',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ])),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: GetStatusColor(import['Status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(GetStatusIcon(import['Status']),
                        color: GetStatusColor(import['Status']), size: 16),
                    SizedBox(width: 4),
                    Text(import['Status'],
                        style: TextStyle(
                            color: GetStatusColor(import['Status']),
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ]),
              SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _InfoChip(Icons.calendar_today,
                        FormatDate(import['ImportDate']))),
                Expanded(
                    child: _InfoChip(
                        Icons.inventory, '${import['TotalItems']} items')),
                Expanded(
                    child: _InfoChip(Icons.attach_money,
                        FormatCurrency(import['TotalCost']))),
              ]),
              if (isPending) ...[
                SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton.icon(
                    onPressed: isActionLoading
                        ? null
                        : () => showQuickActionConfirmation(
                            import['ImportID'], 'Cancelled'),
                    icon: Icon(Icons.cancel, size: 16),
                    label: Text('Cancel'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: isActionLoading
                        ? null
                        : () => showQuickActionConfirmation(
                            import['ImportID'], 'Completed'),
                    icon: isActionLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Icon(Icons.check, size: 16),
                    label: Text(isActionLoading ? 'Processing...' : 'Complete'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                  ),
                ]),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _InfoChip(IconData icon, String text) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis)),
      ]);
}
