import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/page/create_import.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Add this to pubspec.yaml: intl: ^0.17.0

class ManageImportPage extends StatefulWidget {
  const ManageImportPage({super.key});

  @override
  State<ManageImportPage> createState() => _ManageImportPageState();
}

basePath bp = basePath();
final String bpt = bp.bpath();

class _ManageImportPageState extends State<ManageImportPage> {
  List data = [];
  List filteredData = [];
  final String baseurl = bpt; // Update to match your IP
  TextEditingController txtSearch = TextEditingController();
  bool isLoading = false;

  // Filter variables
  String selectedStatus = 'All';
  String selectedDateRange = 'All Time';
  DateTime? startDate;
  DateTime? endDate;
  // Add these new state variables
  Map<String, TextEditingController> qtyControllers = {};
  Map<String, bool> itemChecked = {};
  String tempStatus = '';

  @override
  void initState() {
    super.initState();
    FetchAllImports();
  }

  // Fetch all imports from API
  Future<void> FetchAllImports() async {
    setState(() {
      isLoading = true;
    });
    try {
      final String url = "$baseurl/main/import";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          data = responseData;
          filteredData = List.from(data);
          isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode}");
        ShowErrorMessage("Failed to load imports: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      ShowErrorMessage("Connection error: ${e.toString()}");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Add this function to update import status via API
  Future<void> updateImportStatus(int importID, String newStatus) async {
    try {
      String endpoint;
      Map<String, dynamic> body = {};

      // Choose the correct API endpoint based on status
      if (newStatus == 'Completed') {
        endpoint = "$baseurl/main/import/$importID/confirm";
      } else if (newStatus == 'Cancelled') {
        endpoint = "$baseurl/main/import/$importID/cancel";
        body = {"reason": "Status changed from app"};
      } else {
        throw Exception("Cannot change status to $newStatus via API");
      }

      final response = await http.put(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['msg'] ?? 'Failed to update status');
      }
    } catch (e) {
      throw Exception("Failed to update import status: ${e.toString()}");
    }
  }

  // Search and filter function
  void FilterImports() {
    List<dynamic> filtered = List.from(data);

    // Apply search filter
    if (txtSearch.text.isNotEmpty) {
      String searchTerm = txtSearch.text.toLowerCase();
      filtered = filtered.where((import) {
        return import['SupplierName']
                .toString()
                .toLowerCase()
                .contains(searchTerm) ||
            import['InvoiceNumber']
                .toString()
                .toLowerCase()
                .contains(searchTerm) ||
            import['ImportID'].toString().contains(searchTerm);
      }).toList();
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

    setState(() {
      filteredData = filtered;
    });
  }

  // Show success message
  void ShowSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Show error message
  void ShowErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Format currency
  String FormatCurrency(dynamic amount) {
    if (amount == null) return '\$0.00';
    double value = double.tryParse(amount.toString()) ?? 0.0;
    return '\$${value.toStringAsFixed(2)}';
  }

  // Format date
  String FormatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  // Get status color
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

  // Get status icon
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

  // Show date picker for filtering
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

  // Clear date range filter
  void ClearDateRange() {
    setState(() {
      startDate = null;
      endDate = null;
      selectedDateRange = 'All Time';
    });
    FilterImports();
  }

  // Fixed ShowImportDetails function in Import_page.dart
  void ShowImportDetails(Map<String, dynamic> import) async {
    setState(() {
      isLoading = true;
    });

    try {
      final String url = "$baseurl/main/import/${import['ImportID']}";
      final response = await http.get(Uri.parse(url));

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final detailData = json.decode(response.body);

        // ADD THE INITIALIZATION CODE HERE - after you have the data
        final details = detailData['details'] as List<dynamic>;
        final header = detailData['header'];

        // Initialize controllers and checkboxes for each item
        qtyControllers.clear(); // Clear existing controllers first
        itemChecked.clear(); // Clear existing checkboxes first

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
      setState(() {
        isLoading = false;
      });
      ShowErrorMessage("Error loading details: ${e.toString()}");
    }
  }

  // Show detailed import dialog
  void _ShowImportDetailsDialog(Map<String, dynamic> detailData) {
    final header = detailData['header'];
    final details = detailData['details'] as List<dynamic>;

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setDialogState) => Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.8,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Import Details',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE45C58),
                            ),
                          ),
                          // Replace the existing status container with clickable dropdown
                          GestureDetector(
                            onTap: () {
                              _showStatusDropdown(context, setDialogState);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    GetStatusColor(tempStatus).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: GetStatusColor(tempStatus)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(GetStatusIcon(tempStatus),
                                      color: GetStatusColor(tempStatus),
                                      size: 16),
                                  SizedBox(width: 4),
                                  Text(tempStatus,
                                      style: TextStyle(
                                          color: GetStatusColor(tempStatus),
                                          fontWeight: FontWeight.bold)),
                                  Icon(Icons.arrow_drop_down,
                                      color: GetStatusColor(tempStatus),
                                      size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Import info section
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Basic info card
                              Card(
                                elevation: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Import Information',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE45C58),
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      _InfoRow('Import ID:',
                                          header['ImportID'].toString()),
                                      _InfoRow('Date:',
                                          FormatDate(header['ImportDate'])),
                                      _InfoRow('Time:',
                                          header['ImportTime'] ?? 'N/A'),
                                      _InfoRow('Invoice Number:',
                                          header['InvoiceNumber'] ?? 'N/A'),
                                      _InfoRow('Total Items:',
                                          header['TotalItems'].toString()),
                                      _InfoRow('Total Cost:',
                                          FormatCurrency(header['TotalCost'])),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),

                              // Supplier info card
                              Card(
                                elevation: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Supplier Information',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE45C58),
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      _InfoRow('Supplier:',
                                          header['SupplierName'] ?? 'N/A'),
                                      _InfoRow('Contact Person:',
                                          header['ContactPerson'] ?? 'N/A'),
                                      _InfoRow(
                                          'Phone:', header['Phone'] ?? 'N/A'),
                                      _InfoRow(
                                          'Email:', header['Email'] ?? 'N/A'),
                                      if (header['Notes'] != null &&
                                          header['Notes'].toString().isNotEmpty)
                                        _InfoRow('Notes:', header['Notes']),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),

                              // Products details
                              // Products details section with Check All functionality
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Import Items',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE45C58),
                                    ),
                                  ),
                                  // Add Check All button
                                  TextButton.icon(
                                    onPressed: () {
                                      setDialogState(() {
                                        bool allChecked = itemChecked.values
                                            .every((checked) => checked);
                                        // If all are checked, uncheck all. Otherwise, check all
                                        for (String key in itemChecked.keys) {
                                          itemChecked[key] = !allChecked;
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      itemChecked.values
                                              .every((checked) => checked)
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      size: 18,
                                    ),
                                    label: Text(
                                      itemChecked.values
                                              .every((checked) => checked)
                                          ? 'Uncheck All'
                                          : 'Check All',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Color(0xFFE45C58),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),

// Add summary row showing checked items
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Items checked: ${itemChecked.values.where((checked) => checked).length}/${itemChecked.length}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    if (itemChecked.values
                                        .any((checked) => checked))
                                      Text(
                                        'Ready for confirmation',
                                        style: TextStyle(
                                          color: Colors.green[600],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12),

                              // Replace each item card with this enhanced version
                              ...details.map((detail) {
                                String key =
                                    detail['ImportDetailID'].toString();
                                bool isChecked = itemChecked[key] ?? false;

                                return Card(
                                  elevation: 1,
                                  margin: EdgeInsets.only(bottom: 8),
                                  // Add border color based on checked status
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: isChecked
                                          ? Color(0xFFE45C58)
                                          : Colors.grey[300]!,
                                      width: isChecked ? 2 : 1,
                                    ),
                                  ),
                                  child: Container(
                                    // Add background color for checked items
                                    decoration: BoxDecoration(
                                      color: isChecked
                                          ? Color(0xFFE45C58).withOpacity(0.05)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Product name and total cost row with check indicator
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    // Add check indicator
                                                    Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: isChecked
                                                            ? Color(0xFFE45C58)
                                                            : Colors
                                                                .transparent,
                                                        border: Border.all(
                                                          color: isChecked
                                                              ? Color(
                                                                  0xFFE45C58)
                                                              : Colors
                                                                  .grey[400]!,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: isChecked
                                                          ? Icon(Icons.check,
                                                              color:
                                                                  Colors.white,
                                                              size: 14)
                                                          : null,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        detail['ProductName'] ??
                                                            'Unknown Product',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: isChecked
                                                              ? Color(
                                                                  0xFFE45C58)
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                FormatCurrency(
                                                    detail['TotalCost']),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFE45C58),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),

                                          // Quantity input row
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: TextField(
                                                  controller:
                                                      qtyControllers[key],
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    labelText: 'Received Qty',
                                                    border:
                                                        OutlineInputBorder(),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4),
                                                    // Change border color based on checked status
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: isChecked
                                                            ? Color(0xFFE45C58)
                                                            : Colors.blue,
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    _checkAllItemsAndUpdateStatus(
                                                        setDialogState);
                                                  },
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                    'Expected: ${detail['ImportQuantity']}'),
                                              ),
                                              Checkbox(
                                                value: isChecked,
                                                activeColor: Color(0xFFE45C58),
                                                onChanged: (bool? value) {
                                                  setDialogState(() {
                                                    itemChecked[key] =
                                                        value ?? false;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),

                                          // Show quantity comparison
                                          if (qtyControllers[key]
                                                  ?.text
                                                  .isNotEmpty ==
                                              true) ...[
                                            SizedBox(height: 4),
                                            Builder(
                                              builder: (context) {
                                                int receivedQty = int.tryParse(
                                                        qtyControllers[key]
                                                                ?.text ??
                                                            '0') ??
                                                    0;
                                                int expectedQty =
                                                    detail['ImportQuantity'] ??
                                                        0;
                                                bool isMatch =
                                                    receivedQty == expectedQty;

                                                return Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: isMatch
                                                        ? Colors.green[50]
                                                        : Colors.orange[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    border: Border.all(
                                                      color: isMatch
                                                          ? Colors.green[200]!
                                                          : Colors.orange[200]!,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        isMatch
                                                            ? Icons.check_circle
                                                            : Icons.warning,
                                                        size: 16,
                                                        color: isMatch
                                                            ? Colors.green[600]
                                                            : Colors
                                                                .orange[600],
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        isMatch
                                                            ? 'Quantity matches'
                                                            : 'Quantity differs',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: isMatch
                                                              ? Colors
                                                                  .green[600]
                                                              : Colors
                                                                  .orange[600],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],

                                          // Add existing product details here...
                                          SizedBox(height: 8),
                                          _InfoRow('Product ID:',
                                              detail['ProductID'] ?? 'N/A'),
                                          _InfoRow(
                                              'Import Price:',
                                              FormatCurrency(
                                                  detail['ImportPrice'])),
                                          _InfoRow(
                                              'Previous Stock:',
                                              detail['PreviousQuantity']
                                                  .toString()),
                                          _InfoRow('New Stock:',
                                              detail['NewQuantity'].toString()),
                                          if (detail['BatchNumber'] != null &&
                                              detail['BatchNumber']
                                                  .toString()
                                                  .isNotEmpty)
                                            _InfoRow('Batch Number:',
                                                detail['BatchNumber']),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),

                      // Close button
                      SizedBox(height: 16),
                      // Replace the close button section with confirm and close buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Close'),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                _confirmChanges(header['ImportID']),
                            child: Text('Confirm Changes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFE45C58),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  // Helper widget for info rows
  Widget _InfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Add status dropdown function
  void _showStatusDropdown(BuildContext context, StateSetter setDialogState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Pending', 'Completed', 'Cancelled'].map((status) {
            return ListTile(
              title: Text(status),
              leading:
                  Icon(GetStatusIcon(status), color: GetStatusColor(status)),
              onTap: () {
                setDialogState(() {
                  tempStatus = status;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

// Add auto status check function
  void _checkAllItemsAndUpdateStatus(StateSetter setDialogState) {
    bool allMatched = true;
    for (var entry in qtyControllers.entries) {
      String key = entry.key;
      String inputValue = entry.value.text;

      if (inputValue.isEmpty || int.tryParse(inputValue) == null) {
        allMatched = false;
        break;
      }
    }

    if (allMatched && tempStatus != 'Completed') {
      setDialogState(() {
        tempStatus = 'Completed';
      });
    }
  }

// Add confirm changes function
  // Add confirm changes function
// Add confirm changes function
  void _confirmChanges(int importID) async {
    int matchedItems = 0;
    int notMatchedItems = 0;
    int zeroItems = 0;

    // Count items based on quantities
    for (var entry in qtyControllers.entries) {
      String inputValue = entry.value.text;
      int inputQty = int.tryParse(inputValue) ?? 0;

      if (inputQty == 0) {
        zeroItems++;
      } else {
        // You'll need to compare with expected quantity
        // This is a simplified version - you may need to store expected quantities
        bool isChecked = itemChecked[entry.key] ?? false;
        if (isChecked) {
          matchedItems++;
        } else {
          notMatchedItems++;
        }
      }
    }

    // SHOW CONFIRMATION DIALOG FIRST
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Changes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to make these changes?'),
            SizedBox(height: 16),
            Text('Status: $tempStatus',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Matched items: $matchedItems'),
            Text('Not matched items: $notMatchedItems'),
            Text('Zero quantity items: $zeroItems'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close confirmation dialog
              Navigator.of(context).pop(); // Close import details dialog

              // Show loading indicator
              setState(() {
                isLoading = true;
              });

              // NOW make the ACTUAL API call
              try {
                await updateImportStatus(
                    importID, tempStatus); // ← UNCOMMENTED AND IMPLEMENTED!
                ShowSuccessMessage(
                    'Status changed to $tempStatus. Matched: $matchedItems, Not matched: $notMatchedItems, Zero: $zeroItems');
                await FetchAllImports(); // Refresh the list
              } catch (e) {
                ShowErrorMessage("Failed to update import: ${e.toString()}");
              } finally {
                setState(() {
                  isLoading = false;
                });
              }
            },
            child: Text('OK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE45C58),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Management'),
        backgroundColor: Color(0xFFE45C58),
        foregroundColor: Colors.white,
        actions: [
          // Add new import button in app bar
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to create import page (Part 2)
              ShowErrorMessage("Create Import functionality - Part 2");
            },
          ),
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
                // Search bar
                TextField(
                  controller: txtSearch,
                  onChanged: (value) => FilterImports(),
                  decoration: InputDecoration(
                    hintText: "Search by supplier, invoice, or import ID...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 12),

                // Filter row
                Row(
                  children: [
                    // Status filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['All', 'Pending', 'Completed', 'Cancelled']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value!;
                          });
                          FilterImports();
                        },
                      ),
                    ),
                    SizedBox(width: 12),

                    // Date range filter
                    Expanded(
                      child: TextButton.icon(
                        onPressed: SelectDateRange,
                        icon: Icon(Icons.date_range),
                        label: Text(
                          selectedDateRange == 'Custom Range'
                              ? '${DateFormat('MMM dd').format(startDate!)} - ${DateFormat('MMM dd').format(endDate!)}'
                              : selectedDateRange,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFFE45C58),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),

                    // Clear filters button
                    if (selectedStatus != 'All' ||
                        selectedDateRange != 'All Time')
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
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No imports found",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Try adjusting your search or filters",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: FetchAllImports,
                        child: ListView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final import = filteredData[index];
                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                onTap: () => ShowImportDetails(import),
                                borderRadius: BorderRadius.circular(15),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header row
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
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFE45C58),
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  import['SupplierName'] ??
                                                      'Unknown Supplier',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: GetStatusColor(
                                                      import['Status'])
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  GetStatusIcon(
                                                      import['Status']),
                                                  color: GetStatusColor(
                                                      import['Status']),
                                                  size: 16,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  import['Status'],
                                                  style: TextStyle(
                                                    color: GetStatusColor(
                                                        import['Status']),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),

                                      // Details row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _InfoChip(
                                              Icons.calendar_today,
                                              FormatDate(import['ImportDate']),
                                            ),
                                          ),
                                          Expanded(
                                            child: _InfoChip(
                                              Icons.inventory,
                                              '${import['TotalItems']} items',
                                            ),
                                          ),
                                          Expanded(
                                            child: _InfoChip(
                                              Icons.attach_money,
                                              FormatCurrency(
                                                  import['TotalCost']),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Invoice number if available
                                      if (import['InvoiceNumber'] != null &&
                                          import['InvoiceNumber']
                                              .toString()
                                              .isNotEmpty) ...[
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.receipt,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Invoice: ${import['InvoiceNumber']}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
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
                          },
                        ),
                      ),
          ),
        ],
      ),

      // Floating Action Button for creating new import
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateImportPage()),
          );
        },
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('New Import', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFE45C58),
      ),
    );
  }

  // Helper widget for info chips
  Widget _InfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
