import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/page/Import/create_import.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ManagesImportPage extends StatefulWidget {
  const ManagesImportPage({super.key});

  @override
  State<ManagesImportPage> createState() => _ManageImportPageState();
}

basePath bp = basePath();
final String bpt = bp.bpath();

class _ManageImportPageState extends State<ManagesImportPage> {
  // Consolidated state variables
  List data = [], filteredData = [];
  final String baseurl = bpt;
  final TextEditingController txtSearch = TextEditingController();
  bool isLoading = false;

  // Filter variables
  String selectedStatus = 'All', selectedDateRange = 'All Time';
  DateTime? startDate, endDate;

  // Dialog state
  Map<String, TextEditingController> qtyControllers = {};
  Map<String, bool> itemChecked = {};
  String tempStatus = '';

  @override
  void initState() {
    super.initState();
    fetchAllImports();
  }

  // API calls - consolidated error handling
  Future<void> fetchAllImports() async {
    await _apiCall(() async {
      final response = await http.get(Uri.parse("$baseurl/main/import"));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          data = responseData;
          filteredData = List.from(data);
        });
      } else {
        throw Exception("Failed to load imports: ${response.statusCode}");
      }
    });
  }

  Future<void> updateImportStatus(int importID, String newStatus) async {
    String endpoint = newStatus == 'Completed'
        ? "$baseurl/main/import/$importID/confirm"
        : "$baseurl/main/import/$importID/cancel";

    Map<String, dynamic> body =
        newStatus == 'Cancelled' ? {"reason": "Status changed from app"} : {};

    final response = await http.put(
      Uri.parse(endpoint),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['msg'] ?? 'Failed to update status');
    }
  }

  // Generic API call wrapper with loading and error handling
  Future<void> _apiCall(Future<void> Function() apiFunction) async {
    setState(() => isLoading = true);
    try {
      await apiFunction();
    } catch (e) {
      _showMessage("Error: ${e.toString()}", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Consolidated message display
  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // Search and filter logic
  void filterImports() {
    List<dynamic> filtered = List.from(data);

    // Apply search filter
    if (txtSearch.text.isNotEmpty) {
      String searchTerm = txtSearch.text.toLowerCase();
      filtered = filtered
          .where((import) =>
              import['SupplierName']
                  .toString()
                  .toLowerCase()
                  .contains(searchTerm) ||
              import['InvoiceNumber']
                  .toString()
                  .toLowerCase()
                  .contains(searchTerm) ||
              import['ImportID'].toString().contains(searchTerm))
          .toList();
    }

    // Apply status filter
    if (selectedStatus != 'All') {
      filtered = filtered
          .where((import) => import['Status'].toString() == selectedStatus)
          .toList();
    }

    // Apply date filter
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

  // Utility functions - consolidated
  String formatCurrency(dynamic amount) {
    if (amount == null) return '\$0.00';
    double value = double.tryParse(amount.toString()) ?? 0.0;
    return '\$${value.toStringAsFixed(2)}';
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
    }
  }

  // Status helpers - using maps for efficiency
  static const Map<String, Color> statusColors = {
    'completed': Colors.green,
    'pending': Colors.orange,
    'cancelled': Colors.red,
  };

  static const Map<String, IconData> statusIcons = {
    'completed': Icons.check_circle,
    'pending': Icons.pending,
    'cancelled': Icons.cancel,
  };

  Color getStatusColor(String status) =>
      statusColors[status.toLowerCase()] ?? Colors.grey;

  IconData getStatusIcon(String status) =>
      statusIcons[status.toLowerCase()] ?? Icons.help;

  // Date picker
  Future<void> selectDateRange() async {
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
      filterImports();
    }
  }

  void clearDateRange() {
    setState(() {
      startDate = null;
      endDate = null;
      selectedDateRange = 'All Time';
    });
    filterImports();
  }

// Add this method to automatically handle status changes based on checked items
  void _handleAutoStatusChange(StateSetter setDialogState) {
    bool hasCheckedItems = itemChecked.values.any((checked) => checked);
    String oldStatus = tempStatus;

    // Auto change to Completed if items are checked and status is Pending
    if (hasCheckedItems && tempStatus == 'Pending') {
      setDialogState(() {
        tempStatus = 'Completed';
      });
      // Optional: Show brief feedback
      if (oldStatus != tempStatus) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status automatically changed to Completed'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
    // Auto change to Pending if no items are checked and status is Completed
    else if (!hasCheckedItems && tempStatus == 'Completed') {
      setDialogState(() {
        tempStatus = 'Pending';
      });
      // Optional: Show brief feedback
      if (oldStatus != tempStatus) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status automatically changed to Pending'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Import details - simplified
  void showImportDetails(Map<String, dynamic> import) async {
    await _apiCall(() async {
      final response = await http
          .get(Uri.parse("$baseurl/main/import/${import['ImportID']}"));
      if (response.statusCode == 200) {
        final detailData = json.decode(response.body);
        _initializeDialogState(detailData);
        _showImportDetailsDialog(detailData);
      } else {
        throw Exception(
            "Failed to load import details: ${response.statusCode}");
      }
    });
  }

  void _initializeDialogState(Map<String, dynamic> detailData) {
    final details = detailData['details'] as List<dynamic>;
    final header = detailData['header'];

    qtyControllers.clear();
    itemChecked.clear();

    for (var detail in details) {
      String key = detail['ImportDetailID'].toString();
      qtyControllers[key] =
          TextEditingController(text: detail['ImportQuantity'].toString());
      itemChecked[key] = false;
    }
    tempStatus = header['Status'];
  }

  // Simplified dialog
  void _showImportDetailsDialog(Map<String, dynamic> detailData) {
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
                _buildDialogHeader(setDialogState),
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard('Import Information', [
                          _infoRow('Import ID:', header['ImportID'].toString()),
                          _infoRow('Date:', formatDate(header['ImportDate'])),
                          _infoRow('Time:', header['ImportTime'] ?? 'N/A'),
                          _infoRow('Invoice Number:',
                              header['InvoiceNumber'] ?? 'N/A'),
                          _infoRow(
                              'Total Items:', header['TotalItems'].toString()),
                          _infoRow('Total Cost:',
                              formatCurrency(header['TotalCost'])),
                        ]),
                        SizedBox(height: 16),
                        _buildInfoCard('Supplier Information', [
                          _infoRow(
                              'Supplier:', header['SupplierName'] ?? 'N/A'),
                          _infoRow('Contact Person:',
                              header['ContactPerson'] ?? 'N/A'),
                          _infoRow('Phone:', header['Phone'] ?? 'N/A'),
                          _infoRow('Email:', header['Email'] ?? 'N/A'),
                          if (header['Notes'] != null &&
                              header['Notes'].toString().isNotEmpty)
                            _infoRow('Notes:', header['Notes']),
                        ]),
                        SizedBox(height: 16),
                        _buildItemsSection(details, setDialogState),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                _buildDialogButtons(header['ImportID'], details),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dialog components
  Widget _buildDialogHeader(StateSetter setDialogState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('ລາຍລະອຽດການນຳເຂົ້າ',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE45C58))),
        GestureDetector(
          onTap: () => _showStatusDropdown(setDialogState),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: getStatusColor(tempStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: getStatusColor(tempStatus)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(getStatusIcon(tempStatus),
                    color: getStatusColor(tempStatus), size: 16),
                SizedBox(width: 4),
                Text(tempStatus,
                    style: TextStyle(
                        color: getStatusColor(tempStatus),
                        fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_drop_down,
                    color: getStatusColor(tempStatus), size: 16),
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildItemsSection(List<dynamic> details, StateSetter setDialogState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ສິນຄ້າທີ່ນຳເຂົ້າ',
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
                  // Auto-change status based on checked items
                  _handleAutoStatusChange(setDialogState);
                });
              },
              icon: Icon(
                  itemChecked.values.every((checked) => checked)
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 18),
              label: Text(itemChecked.values.every((checked) => checked)
                  ? 'Uncheck All'
                  : 'Check All'),
              style: TextButton.styleFrom(foregroundColor: Color(0xFFE45C58)),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
          child: Text(
              'Items checked: ${itemChecked.values.where((checked) => checked).length}/${itemChecked.length}'),
        ),
        SizedBox(height: 12),
        ...details
            .map((detail) => _buildItemCard(detail, setDialogState))
            .toList(),
      ],
    );
  }

  Widget _buildItemCard(
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
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isChecked ? Color(0xFFE45C58) : Colors.transparent,
                      border: Border.all(
                          color:
                              isChecked ? Color(0xFFE45C58) : Colors.grey[400]!,
                          width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: isChecked
                        ? Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(detail['ProductName'] ?? 'Unknown Product',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isChecked
                                  ? Color(0xFFE45C58)
                                  : Colors.black))),
                  Text(formatCurrency(detail['TotalCost']),
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
                      decoration: InputDecoration(
                        labelText: 'ຈຳນວນທີ່ໄດ້ຮັບ',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('Expected: ${detail['ImportQuantity']}')),
                  Checkbox(
                    value: isChecked,
                    activeColor: Color(0xFFE45C58),
                    onChanged: (bool? value) {
                      setDialogState(() {
                        itemChecked[key] = value ?? false;
                        // Auto-change status based on checked items
                        _handleAutoStatusChange(setDialogState);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateImportStatusWithItems(int importID, String newStatus,
      List<Map<String, dynamic>> checkedItems) async {
    String endpoint = "$baseurl/main/import/$importID/update-status";

    Map<String, dynamic> body = {
      "status": newStatus,
      "checkedItems": checkedItems,
      "reason": newStatus == 'Cancelled' ? "Status changed from app" : null
    };

    final response = await http.put(
      Uri.parse(endpoint),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['msg'] ?? 'Failed to update import');
    }
  }

  Widget _buildDialogButtons(int importID, List<dynamic> details) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('ປິດ'),
          style: TextButton.styleFrom(
              backgroundColor: Colors.grey[300], foregroundColor: Colors.black),
        ),
        ElevatedButton(
          onPressed: () =>
              _confirmChanges(importID, details), // Pass details here
          child: Text('ຢືນຢັນການແກ້ໄຂ'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE45C58),
              foregroundColor: Colors.white),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ປ່ຽນສະຖານະ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Pending', 'Completed', 'Cancelled']
              .map(
                (status) => ListTile(
                  title: Text(status),
                  leading: Icon(getStatusIcon(status),
                      color: getStatusColor(status)),
                  onTap: () {
                    setDialogState(() => tempStatus = status);
                    Navigator.of(context).pop();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _confirmChanges(int importID, List<dynamic> details) async {
    // Get only checked items with their quantities
    List<Map<String, dynamic>> checkedItemsData = [];
    List<String> checkedItemsDisplay = []; // For display purposes

    itemChecked.forEach((key, isChecked) {
      if (isChecked) {
        String qtyText = qtyControllers[key]?.text ?? '0';
        int receivedQty = int.tryParse(qtyText) ?? 0;

        // Validate quantity is positive
        if (receivedQty <= 0) {
          _showMessage('Invalid quantity for checked item', Colors.red);
          return;
        }

        // Find the product name for this detail
        var detail = details.firstWhere(
            (d) => d['ImportDetailID'].toString() == key,
            orElse: () => {'ProductName': 'Unknown Product'});

        checkedItemsData.add({
          'ImportDetailID': int.parse(key),
          'ReceivedQuantity': receivedQty
        });

        // Add display info with product name
        checkedItemsDisplay.add(
            '${detail['ProductName']} (ID: ${detail['ImportDetailID']}) - $receivedQty units');
      }
    });

    // Rest of validation...
    if (checkedItemsData.isEmpty && tempStatus == 'Completed') {
      _showMessage(
          'Please check at least one item to complete import', Colors.orange);
      return;
    }

    int checkedItems = checkedItemsData.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ຢືນຢັນການແກ້ໄຂ'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: $tempStatus'),
              Text('Checked items: $checkedItems/${itemChecked.length}'),
              if (checkedItemsDisplay.isNotEmpty) ...[
                SizedBox(height: 8),
                Text('Items to update:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                // Wrap the list in a constrained container
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 200, // Limit height to prevent overflow
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: checkedItemsDisplay
                          .map((itemInfo) => Padding(
                                padding: EdgeInsets.symmetric(vertical: 2),
                                child: Text('• $itemInfo',
                                    style: TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ຍົກເລີກ')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              await _apiCall(() async {
                await updateImportStatusWithItems(
                    importID, tempStatus, checkedItemsData);
                _showMessage('Import updated successfully', Colors.green);
                await fetchAllImports();
              });
            },
            child: Text('ຕົກລົງ'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE45C58),
                foregroundColor: Colors.white),
          ),
        ],
      ),
    );
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
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreateImportPage())))
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                TextField(
                  controller: txtSearch,
                  onChanged: (value) => filterImports(),
                  decoration: InputDecoration(
                    hintText:
                        "ຄົ້ນຫາດ້ວຍຜູ້ສະໜອງ, ໃບແຈ້ງໜີ້, ຫຼື ID ນຳເຂົ້າ...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
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
                            labelText: 'ສະຖານະ', border: OutlineInputBorder()),
                        items: ['All', 'Pending', 'Completed', 'Cancelled']
                            .map((status) => DropdownMenuItem(
                                value: status, child: Text(status)))
                            .toList(),
                        onChanged: (value) {
                          setState(() => selectedStatus = value!);
                          filterImports();
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: selectDateRange,
                        icon: Icon(Icons.date_range),
                        label: Text(selectedDateRange == 'Custom Range' &&
                                startDate != null &&
                                endDate != null
                            ? '${DateFormat('MMM dd').format(startDate!)} - ${DateFormat('MMM dd').format(endDate!)}'
                            : selectedDateRange),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFFE45C58)),
                      ),
                    ),
                    if (selectedStatus != 'All' ||
                        selectedDateRange != 'All Time')
                      IconButton(
                        onPressed: () {
                          setState(() {
                            selectedStatus = 'All';
                            selectedDateRange = 'All Time';
                            txtSearch.clear();
                          });
                          clearDateRange();
                        },
                        icon: Icon(Icons.clear),
                        color: Colors.red,
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Import list
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredData.isEmpty
                    ? Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text("ບໍ່ພົບເຫັນການນຳເຂົ້າ",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600])),
                        ],
                      ))
                    : RefreshIndicator(
                        onRefresh: fetchAllImports,
                        child: ListView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final import = filteredData[index];
                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: InkWell(
                                onTap: () => showImportDetails(import),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'Import #${import['ImportID']}',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFFE45C58))),
                                                Text(
                                                    import['SupplierName'] ??
                                                        'Unknown Supplier',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: getStatusColor(
                                                      import['Status'])
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                    getStatusIcon(
                                                        import['Status']),
                                                    color: getStatusColor(
                                                        import['Status']),
                                                    size: 16),
                                                SizedBox(width: 4),
                                                Text(import['Status'],
                                                    style: TextStyle(
                                                        color: getStatusColor(
                                                            import['Status']),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: _infoChip(
                                                  Icons.calendar_today,
                                                  formatDate(
                                                      import['ImportDate']))),
                                          Expanded(
                                              child: _infoChip(Icons.inventory,
                                                  '${import['TotalItems']} items')),
                                          Expanded(
                                              child: _infoChip(
                                                  Icons.attach_money,
                                                  formatCurrency(
                                                      import['TotalCost']))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
