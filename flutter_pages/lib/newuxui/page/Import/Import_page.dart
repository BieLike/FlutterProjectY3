import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/page/Import/create_import.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  Set<int> confirmedImports = Set<int>();
  Map<int, bool> isConfirming = {};

  String selectedStatus = 'All';
  String selectedDateRange = 'All Time';
  DateTime? startDate, endDate;

  Map<String, TextEditingController> qtyControllers = {};
  Map<String, bool> itemChecked = {};
  String tempStatus = '';

  @override
  void initState() {
    super.initState();
    FetchAllImports();
  }

  Future<void> FetchAllImports() async {
    setState(() {
      isLoading = true;
      // Clear confirmation states when refreshing
      confirmedImports = data
          .where((import) => import['Status'] == 'Completed')
          .map((import) => import['ImportID'] as int)
          .toSet();
      isConfirming.clear();
    });
    try {
      final response = await http.get(Uri.parse("$baseurl/main/import"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          data = responseData;
          filteredData = List.from(data);
        });
      } else {
        ShowErrorMessage("Failed to load imports: ${response.statusCode}");
      }
    } catch (e) {
      ShowErrorMessage("Connection error: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateImportStatus(int importID, String newStatus) async {
    String endpoint;

    // Fix the endpoint logic
    if (newStatus == 'Completed') {
      endpoint = "$baseurl/main/import/$importID/confirm";
    } else if (newStatus == 'Cancelled') {
      endpoint = "$baseurl/main/import/$importID/cancel";
    } else {
      endpoint = "$baseurl/main/import/$importID/pending";
      throw Exception("status change: $newStatus");
    }

    Map<String, dynamic> body =
        newStatus == 'Cancelled' ? {"reason": "Status changed from app"} : {};

    final response = await http.put(
      Uri.parse(endpoint),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      if (errorData['alreadyCompleted'] == true) {
        throw Exception("This import is already completed");
      }
      throw Exception(errorData['msg'] ?? 'Failed to update status');
    }
  }

  Future<void> _quickStatusUpdate(int importID, String newStatus) async {
    // Prevent double-clicks
    if (isConfirming[importID] == true) return;

    setState(() => isConfirming[importID] = true);

    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Action'),
          content: Text('Are you sure you want to $newStatus this import?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Confirm'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    newStatus == 'Completed' ? Color(0xFFE45C58) : Colors.red,
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await updateImportStatus(importID, newStatus);
        if (newStatus == 'Completed') {
          confirmedImports.add(importID);
        }
        ShowSuccessMessage('Import $newStatus successfully');
        await FetchAllImports(); // Refresh the list
      }
    } catch (e) {
      ShowErrorMessage('Failed to update: ${e.toString()}');
    } finally {
      setState(() => isConfirming[importID] = false);
    }
  }

  void FilterImports() {
    List<dynamic> filtered = List.from(data);

    // Search filter
    if (txtSearch.text.isNotEmpty) {
      String search = txtSearch.text.toLowerCase();
      filtered = filtered
          .where((import) =>
              import['SupplierName']
                  .toString()
                  .toLowerCase()
                  .contains(search) ||
              import['InvoiceNumber']
                  .toString()
                  .toLowerCase()
                  .contains(search) ||
              import['ImportID'].toString().contains(search))
          .toList();
    }

    // Status filter
    if (selectedStatus != 'All') {
      filtered = filtered
          .where((import) => import['Status'].toString() == selectedStatus)
          .toList();
    }

    // Date filter
    if (startDate != null && endDate != null) {
      filtered = filtered.where((import) {
        try {
          DateTime importDate = DateTime.parse(import['ImportDate']);
          return importDate.isAfter(startDate!.subtract(Duration(days: 1))) &&
              importDate.isBefore(endDate!.add(Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    setState(() => filteredData = filtered);
  }

  void ShowMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
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
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(dateStr));
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
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        selectedDateRange = 'Custom Range';
      });
      FilterImports();
    }
  }

  void ClearDateRange() {
    setState(() {
      startDate = null;
      endDate = null;
      selectedDateRange = 'All Time';
    });
    FilterImports();
  }

  void ShowImportDetails(Map<String, dynamic> import) async {
    setState(() => isLoading = true);
    try {
      final response = await http
          .get(Uri.parse("$baseurl/main/import/${import['ImportID']}"));
      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final detailData = json.decode(response.body);
        final details = detailData['details'] as List<dynamic>;
        final header = detailData['header'];

        // Initialize controllers and checkboxes
        qtyControllers.clear();
        itemChecked.clear();
        for (var detail in details) {
          String key = detail['ImportDetailID'].toString();
          qtyControllers[key] =
              TextEditingController(text: detail['ImportQuantity'].toString());
          itemChecked[key] = false;
        }
        tempStatus = header['Status'];
        _ShowImportDetailsDialog(detailData);
      } else {
        ShowErrorMessage(
            "Failed to load import details: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ShowErrorMessage("Error loading details: ${e.toString()}");
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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ລາຍລະອຽດການນຳເຂົ້າ',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE45C58))),
                    _buildStatusContainer(setDialogState, header['ImportID']),
                  ],
                ),
                SizedBox(height: 20),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard('ຂໍ້ມູນການນຳເຂົ້າ', [
                          _InfoRow(
                              'ID ນຳເຂົ້າ:', header['ImportID'].toString()),
                          _InfoRow('ວັນທີ:', FormatDate(header['ImportDate'])),
                          _InfoRow('ເວລາ:', header['ImportTime'] ?? 'N/A'),
                          _InfoRow(
                              'ໃບແຈ້ງໜີ້:', header['InvoiceNumber'] ?? 'N/A'),
                          _InfoRow(
                              'ຈຳນວນທັງໝົດ:', header['TotalItems'].toString()),
                          _InfoRow(
                              'ລາຄາລວມ:', FormatCurrency(header['TotalCost'])),
                        ]),
                        SizedBox(height: 16),
                        _buildInfoCard('ຂໍ້ມູນຜູ້ສະໜອງ', [
                          _InfoRow(
                              'ຜູ້ສະໜອງ:', header['SupplierName'] ?? 'N/A'),
                          _InfoRow(
                              'ຜູ້ຕິດຕໍ່:', header['ContactPerson'] ?? 'N/A'),
                          _InfoRow('ເບີໂທ:', header['Phone'] ?? 'N/A'),
                          _InfoRow('Email:', header['Email'] ?? 'N/A'),
                        ]),
                        SizedBox(height: 16),
                        _buildProductsList(details, setDialogState),
                      ],
                    ),
                  ),
                ),

                // Replace the existing actions Row with this:
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('ປິດ'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                    ),
                    // Check original status, not tempStatus
                    if (header['Status'] != 'Cancelled' &&
                        header['Status'] != 'Completed' &&
                        !confirmedImports.contains(header['ImportID']))
                      ElevatedButton(
                        onPressed: () => _confirmChanges(header['ImportID']),
                        child: Text('ຢືນຢັນ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE45C58),
                          foregroundColor: Colors.white,
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

  Widget _buildStatusContainer(StateSetter setDialogState, int importID) {
    return GestureDetector(
      onTap: tempStatus == 'Completed'
          ? null
          : () => _showStatusDropdown(setDialogState),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: GetStatusColor(tempStatus).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GetStatusColor(tempStatus)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(GetStatusIcon(tempStatus),
                color: GetStatusColor(tempStatus), size: 16),
            SizedBox(width: 4),
            Text(tempStatus,
                style: TextStyle(
                    color: GetStatusColor(tempStatus),
                    fontWeight: FontWeight.bold)),
            if (tempStatus != 'Completed')
              Icon(Icons.arrow_drop_down,
                  color: GetStatusColor(tempStatus), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE45C58))),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

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
                  for (String key in itemChecked.keys) {
                    itemChecked[key] = !allChecked;
                  }
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
            .map((detail) => _buildProductCard(detail, setDialogState))
            .toList(),
      ],
    );
  }

  Widget _buildProductCard(
      Map<String, dynamic> detail, StateSetter setDialogState) {
    String key = detail['ImportDetailID'].toString();
    bool isChecked = itemChecked[key] ?? false;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
            color: isChecked ? Color(0xFFE45C58) : Colors.grey[300]!,
            width: isChecked ? 2 : 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isChecked ? Color(0xFFE45C58).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(detail['ProductName'] ?? 'Unknown Product',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  Text(FormatCurrency(detail['TotalCost']),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE45C58))),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: qtyControllers[key],
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        // Add validation logic here
                        if (value.isNotEmpty) {
                          int? enteredQty = int.tryParse(value);
                          int maxQty = detail['ImportQuantity'] ?? 0;

                          if (enteredQty != null && enteredQty > maxQty) {
                            // Reset to max quantity
                            qtyControllers[key]?.text = maxQty.toString();
                            // Move cursor to end
                            qtyControllers[key]?.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: maxQty.toString().length),
                            );
                            // Show error message
                            ShowErrorMessage(
                                'ຈຳນວນທີ່ໄດ້ຮັບບໍ່ສາມາດເກີນ ${maxQty}');
                          }
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'ຈຳນວນທີ່ໄດ້ຮັບ',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        // Add helper text showing the limit
                        helperText: 'ສູງສຸດ: ${detail['ImportQuantity']}',
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(child: Text('ຄາດໝາຍ: ${detail['ImportQuantity']}')),
                  Checkbox(
                    value: isChecked,
                    activeColor: Color(0xFFE45C58),
                    onChanged: (bool? value) =>
                        setDialogState(() => itemChecked[key] = value ?? false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _InfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.grey[600]))),
          Expanded(
              child:
                  Text(value, style: TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _showStatusDropdown(StateSetter setDialogState) {
    if (tempStatus == 'Completed') {
      ShowErrorMessage('ການນຳເຂົ້ານີ້ສຳເລັດແລ້ວ - ບໍ່ສາມາດປ່ຽນສະຖານະໄດ້');
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ປ່ຽນສະຖານະ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Pending', 'Completed', 'Cancelled'].map((status) {
            return ListTile(
              title: Text(status),
              leading:
                  Icon(GetStatusIcon(status), color: GetStatusColor(status)),
              onTap: () {
                setDialogState(() => tempStatus = status);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _confirmChanges(int importID) async {
    if (confirmedImports.contains(importID)) {
      ShowErrorMessage(
          "This import has already been confirmed in this session");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ຢືນຢັນການປ່ຽນແປງ'),
        content: Text('ເຈົ້າແນ່ໃນທີ່ຈະປ່ຽນແປງບໍ?\n\nສະຖານະ: $tempStatus'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ຍົກເລີກ')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pop();

              setState(() => isLoading = true);
              try {
                // Use the new update-status endpoint
                await updateImportStatusWithItems(importID, tempStatus);
                if (tempStatus == 'Completed') confirmedImports.add(importID);
                ShowSuccessMessage('Status changed to $tempStatus');
                await FetchAllImports();
              } catch (e) {
                ShowErrorMessage("Failed to update import: ${e.toString()}");
              } finally {
                setState(() => isLoading = false);
              }
            },
            child: Text('OK'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE45C58),
                foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> updateImportStatusWithItems(
      int importID, String newStatus) async {
    String endpoint = "$baseurl/main/import/$importID/update-status";

    Map<String, dynamic> body = {
      "status": newStatus,
    };

    // If status is Completed, include checked items with quantities
    if (newStatus == 'Completed') {
      List<Map<String, dynamic>> checkedItems = [];

      itemChecked.forEach((key, isChecked) {
        if (isChecked) {
          String receivedQty = qtyControllers[key]?.text ?? '0';
          // Add validation to ensure quantity is not empty or zero
          if (receivedQty.isNotEmpty &&
              int.tryParse(receivedQty) != null &&
              int.parse(receivedQty) > 0) {
            checkedItems.add({
              "ImportDetailID": int.parse(key),
              "ReceivedQuantity": receivedQty
            });
          }
        }
      });

      // Only add checkedItems if there are valid items
      if (checkedItems.isNotEmpty) {
        body["checkedItems"] = checkedItems;
      }
    }

    // If status is Cancelled, add reason
    if (newStatus == 'Cancelled') {
      body["reason"] = "Status changed from app";
    }

    print("Sending request to: $endpoint");
    print("Request body: ${json.encode(body)}");

    final response = await http.put(
      Uri.parse(endpoint),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      if (errorData['alreadyCompleted'] == true) {
        throw Exception("This import is already completed");
      }
      throw Exception(errorData['msg'] ?? 'Failed to update status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ຈັດການການນຳເຂົ້າ'),
        backgroundColor: Color(0xFFE45C58),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () =>
                ShowErrorMessage("Create Import functionality - Part 2"),
          ),
        ],
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
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => CreateImportPage())),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('ການນຳເຂົ້າໃໝ່', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFE45C58),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          TextField(
            controller: txtSearch,
            onChanged: (value) => FilterImports(),
            decoration: InputDecoration(
              hintText: "ຄົ້ນຫາຕາມຜູ້ສະໜອງ, ໃບແຈ້ງໜີ້, ຫຼື ID ການນຳເຂົ້າ...",
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
                        borderRadius: BorderRadius.circular(8)),
                  ),
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
                child: TextButton.icon(
                  onPressed: SelectDateRange,
                  icon: Icon(Icons.date_range),
                  label: Text(selectedDateRange == 'Custom Range'
                      ? '${DateFormat('MMM dd').format(startDate!)} - ${DateFormat('MMM dd').format(endDate!)}'
                      : selectedDateRange),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFFE45C58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
              ),
              if (selectedStatus != 'All' || selectedDateRange != 'All Time')
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedStatus = 'All';
                      selectedDateRange = 'All Time';
                      txtSearch.clear();
                    });
                    ClearDateRange();
                  },
                  icon: Icon(Icons.clear),
                  color: Colors.red,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text("ບໍ່ພົບເຫັນການນຳເຂັ້າ",
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          SizedBox(height: 8),
          Text("ລອງແກ້ໄຂການຄົ້ນຫາ ຫຼື ປ່ອນຂໍ້ມູນໃໝ່",
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildImportCard(Map<String, dynamic> import) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => ShowImportDetails(import),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: GetStatusColor(import['Status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(GetStatusIcon(import['Status']),
                            color: GetStatusColor(import['Status']), size: 16),
                        SizedBox(width: 4),
                        Text(import['Status'],
                            style: TextStyle(
                                color: GetStatusColor(import['Status']),
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _InfoChip(Icons.calendar_today,
                          FormatDate(import['ImportDate']))),
                  Expanded(
                      child: _InfoChip(
                          Icons.inventory, '${import['TotalItems']} items')),
                  Expanded(
                      child: _InfoChip(Icons.attach_money,
                          FormatCurrency(import['TotalCost']))),
                ],
              ),
              if (import['InvoiceNumber'] != null &&
                  import['InvoiceNumber'].toString().isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text('ໃບແຈ້ງໜີ້: ${import['InvoiceNumber']}',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ],
              if (import['Status'] == 'Pending') ...[
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: isConfirming[import['ImportID']] == true
                          ? null
                          : () => _quickStatusUpdate(
                              import['ImportID'], 'Cancelled'),
                      icon: Icon(Icons.cancel, size: 16),
                      label: Text('Cancel'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: isConfirming[import['ImportID']] == true
                          ? null
                          : () => _quickStatusUpdate(
                              import['ImportID'], 'Completed'),
                      icon: isConfirming[import['ImportID']] == true
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.check, size: 16),
                      label: Text(isConfirming[import['ImportID']] == true
                          ? 'Processing...'
                          : 'Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE45C58),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _InfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
