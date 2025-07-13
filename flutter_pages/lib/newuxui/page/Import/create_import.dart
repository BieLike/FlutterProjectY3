import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateImportPage extends StatefulWidget {
  const CreateImportPage({super.key});

  @override
  State<CreateImportPage> createState() => _CreateImportPageState();
}

basePath bp = basePath();
final String bpt = bp.bpath();

class _CreateImportPageState extends State<CreateImportPage> {
  final String baseurl = bpt; // Update to match your IP
  final _formKey = GlobalKey<FormState>();

  // Controllers for header information
  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _supplierContactController =
      TextEditingController();
  final TextEditingController _invoiceNumberController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Date and time variables
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Product selection and import items
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _suppliers = [];
  List<Map<String, dynamic>> _importItems = [];

  final TextEditingController _supplierSearchController =
      TextEditingController();
  List<Map<String, dynamic>> _filteredSuppliers = [];
  bool _showSupplierSuggestions = false;

  // Loading states
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isLoadingProducts = true;
  bool _isLoadingSuppliers = true;

  final Map<int, TextEditingController> _productControllers = {};
  final Map<int, List<Map<String, dynamic>>> _filteredProducts = {};
  final Map<int, bool> _showProductSuggestions = {};
  // Selected supplier for auto-fill
  Map<String, dynamic>? _selectedSupplier;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Load products and suppliers data
  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadProducts(),
      _loadSuppliers(),
    ]);
  }

  // Load all products
  Future<void> _loadProducts() async {
    try {
      setState(() => _isLoadingProducts = true);

      final response = await http.get(Uri.parse("$baseurl/main/product"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _products = data.cast<Map<String, dynamic>>();
          _isLoadingProducts = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() => _isLoadingProducts = false);
      _showErrorMessage("Failed to load products: ${e.toString()}");
    }
  }

  // Load all suppliers
  Future<void> _loadSuppliers() async {
    try {
      setState(() => _isLoadingSuppliers = true);

      final response = await http.get(Uri.parse("$baseurl/main/supplier"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _suppliers = data.cast<Map<String, dynamic>>();
          _isLoadingSuppliers = false;
        });
      } else {
        throw Exception('Failed to load suppliers');
      }
    } catch (e) {
      setState(() => _isLoadingSuppliers = false);
      _showErrorMessage("Failed to load suppliers: ${e.toString()}");
    }
  }

  // Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  // Select date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now()
          .add(Duration(days: 30)), // Allow future dates for planning
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Select time
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Auto-fill supplier information when supplier is selected
  void _onSupplierSelected(Map<String, dynamic>? supplier) {
    setState(() {
      _selectedSupplier = supplier;
      if (supplier != null) {
        _supplierNameController.text = supplier['SupplierName'] ?? '';
        _supplierContactController.text = supplier['Phone'] ?? '';
      } else {
        _supplierNameController.clear();
        _supplierContactController.clear();
      }
    });
  }

  // Add new import item
  void _addImportItem() {
    if (_products.isEmpty) {
      _showErrorMessage("No products available. Please add products first.");
      return;
    }

    setState(() {
      _importItems.add({
        'ProductID': '',
        'ProductName': '',
        'ImportQuantity': '',
        'ImportPrice': '',
        'BatchNumber': '',
        'TotalCost': 0.0,
        'CurrentStock': 0,
      });
    });
  }

  // Remove import item
  // Remove import item
  void _removeImportItem(int index) {
    if (_importItems.length > 1) {
      setState(() {
        _importItems.removeAt(index);

        // Clean up controllers and suggestions for this index
        _productControllers[index]?.dispose();
        _productControllers.remove(index);
        _filteredProducts.remove(index);
        _showProductSuggestions.remove(index);

        // Reindex remaining controllers
        final tempControllers = <int, TextEditingController>{};
        final tempFiltered = <int, List<Map<String, dynamic>>>{};
        final tempSuggestions = <int, bool>{};

        for (int i = 0; i < _importItems.length; i++) {
          if (_productControllers.containsKey(i >= index ? i + 1 : i)) {
            tempControllers[i] = _productControllers[i >= index ? i + 1 : i]!;
          }
          if (_filteredProducts.containsKey(i >= index ? i + 1 : i)) {
            tempFiltered[i] = _filteredProducts[i >= index ? i + 1 : i]!;
          }
          if (_showProductSuggestions.containsKey(i >= index ? i + 1 : i)) {
            tempSuggestions[i] =
                _showProductSuggestions[i >= index ? i + 1 : i]!;
          }
        }

        _productControllers.clear();
        _filteredProducts.clear();
        _showProductSuggestions.clear();

        _productControllers.addAll(tempControllers);
        _filteredProducts.addAll(tempFiltered);
        _showProductSuggestions.addAll(tempSuggestions);
      });
    } else {
      _showErrorMessage("At least one item is required for import.");
    }
  }

  // Update import item
  void _updateImportItem(int index, String field, dynamic value) {
    setState(() {
      _importItems[index][field] = value;

      // If product is selected, auto-fill product name and current stock
      if (field == 'ProductID' && value.isNotEmpty) {
        final product = _products.firstWhere(
          (p) => p['ProductID'] == value,
          orElse: () => {},
        );
        if (product.isNotEmpty) {
          _importItems[index]['ProductName'] = product['ProductName'] ?? '';
          _importItems[index]['CurrentStock'] = product['Quantity'] ?? 0;
        }
      }

      // Calculate total cost when quantity or price changes
      if (field == 'ImportQuantity' || field == 'ImportPrice') {
        _calculateItemTotal(index);
      }
    });
  }

  // Calculate total cost for an item
  void _calculateItemTotal(int index) {
    final item = _importItems[index];
    final quantity = double.tryParse(item['ImportQuantity'].toString()) ?? 0.0;
    final price = double.tryParse(item['ImportPrice'].toString()) ?? 0.0;

    setState(() {
      _importItems[index]['TotalCost'] = quantity * price;
    });
  }

  // Calculate grand total
  double _calculateGrandTotal() {
    return _importItems.fold(0.0, (sum, item) {
      return sum + (item['TotalCost'] ?? 0.0);
    });
  }

  // Calculate total items
  int _calculateTotalItems() {
    return _importItems.fold(0, (sum, item) {
      return sum + (int.tryParse(item['ImportQuantity'].toString()) ?? 0);
    });
  }

  // Validate form data
  String? _validateForm() {
    if (_supplierNameController.text.trim().isEmpty) {
      return "Supplier name is required";
    }

    if (_importItems.isEmpty) {
      return "At least one import item is required";
    }

    for (int i = 0; i < _importItems.length; i++) {
      final item = _importItems[i];

      if (item['ProductID'].toString().trim().isEmpty) {
        return "Product selection is required for item ${i + 1}";
      }

      final quantity = int.tryParse(item['ImportQuantity'].toString());
      if (quantity == null || quantity <= 0) {
        return "Valid quantity is required for item ${i + 1} (must be greater than 0)";
      }

      final price = double.tryParse(item['ImportPrice'].toString());
      if (price == null || price < 0) {
        return "Valid import price is required for item ${i + 1} (must be 0 or greater)";
      }
    }

    // Check for duplicate products
    final productIds = _importItems.map((item) => item['ProductID']).toList();
    final uniqueProductIds = productIds.toSet();
    if (productIds.length != uniqueProductIds.length) {
      return "Duplicate products are not allowed. Please remove duplicate entries.";
    }

    return null;
  }

  // Submit import
  Future<void> _submitImport() async {
    final validationError = _validateForm();
    if (validationError != null) {
      _showErrorMessage(validationError);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. ດຶງຂໍ້ມູນຜູ້ໃຊ້ຈາກ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString == null) {
        _showErrorMessage("ບໍ່ພົບຂໍ້ມູນຜູ້ໃຊ້, ກະລຸນາລັອກອິນໃໝ່");
        setState(() => _isSubmitting = false);
        return;
      }
      final userData = json.decode(userDataString);
      final employeeID = userData['UID'];
      final employeeName = userData['UserFname'];

      final importData = {
        'ImportDate': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'ImportTime':
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00',
        'SupplierName': _supplierNameController.text.trim(),
        'SupplierContact': _supplierContactController.text.trim(),
        'InvoiceNumber': _invoiceNumberController.text.trim(),
        'Notes': _notesController.text.trim(),
        'CreatedBy': employeeID,
        'items': _importItems
            .map((item) => {
                  'ProductID': item['ProductID'],
                  'ImportQuantity':
                      int.parse(item['ImportQuantity'].toString()),
                  'ImportPrice': double.parse(item['ImportPrice'].toString()),
                  'BatchNumber': item['BatchNumber'].toString().trim().isEmpty
                      ? null
                      : item['BatchNumber'].toString().trim(),
                })
            .toList(),

        // ສົ່ງໄປ Activity Log ***
        'EmployeeID': employeeID,
        'EmployeeName': employeeName,
      };
      final response = await http.post(
        Uri.parse("$baseurl/main/import"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(importData),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        _showSuccessMessage(
            "Import created successfully! Import ID: ${responseData['importID']}");
        Navigator.pop(context);
      } else {
        final errorData = json.decode(response.body);
        _showErrorMessage(errorData['msg'] ?? 'Failed to create import');
      }
    } catch (e) {
      _showErrorMessage("Connection error: ${e.toString()}");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  @override
  // Handle supplier search
  void _onSupplierSearch(String searchTerm) {
    setState(() {
      if (searchTerm.trim().isEmpty) {
        _filteredSuppliers = [];
        _showSupplierSuggestions = false;
        _clearSupplierSelection();
      } else {
        // Filter suppliers by name (case insensitive)
        _filteredSuppliers = _suppliers.where((supplier) {
          final supplierName =
              supplier['SupplierName'].toString().toLowerCase();
          final search = searchTerm.toLowerCase();
          return supplierName.contains(search);
        }).toList();

        _showSupplierSuggestions = true;

        // Check if exact match exists
        final exactMatch = _suppliers.firstWhere(
          (supplier) =>
              supplier['SupplierName'].toString().toLowerCase() ==
              searchTerm.toLowerCase(),
          orElse: () => {},
        );

        if (exactMatch.isNotEmpty) {
          _selectSupplier(exactMatch);
        }
      }
    });
  }

// Select supplier from suggestions
  void _selectSupplier(Map<String, dynamic> supplier) {
    setState(() {
      _supplierSearchController.text = supplier['SupplierName'];
      _supplierNameController.text = supplier['SupplierName'];
      _supplierContactController.text = supplier['Phone'] ?? '';
      _showSupplierSuggestions = false;
      _filteredSuppliers = [];
      _selectedSupplier = supplier;
    });

    // Hide keyboard
    FocusScope.of(context).unfocus();
  }

// Clear supplier selection
  void _clearSupplierSelection() {
    setState(() {
      _supplierSearchController.clear();
      _supplierNameController.clear();
      _supplierContactController.clear();
      _showSupplierSuggestions = false;
      _filteredSuppliers = [];
      _selectedSupplier = null;
    });
  }

  void dispose() {
    _supplierNameController.dispose();
    _supplierContactController.dispose();
    _supplierSearchController.dispose(); // Add this line
    _invoiceNumberController.dispose();
    _notesController.dispose();

    // Dispose all product controllers
    for (final controller in _productControllers.values) {
      controller.dispose();
    }
    _productControllers.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE45C58),
      appBar: AppBar(
        title: Text('ສ້າງການນຳເຂົ້າ'),
        backgroundColor: Color(0xFFE45C58),
        foregroundColor: Colors.white,
        actions: [
          // Save button in app bar
          if (!_isSubmitting)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _submitImport,
            ),
        ],
      ),
      body: GestureDetector(
        onTap: _hideSuggestions, // Hide suggestions when tapping outside
        child: _isLoadingProducts || _isLoadingSuppliers
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Import Header Section
                            _buildSectionHeader('ຂໍ້ມູນການນຳເຂົ້າ'),
                            SizedBox(height: 12),
                            _buildImportHeaderSection(),

                            SizedBox(height: 24),

                            // Supplier Section
                            _buildSectionHeader('ຂໍ້ມູນຜູ້ສະໜອງ'),
                            SizedBox(height: 12),
                            _buildSupplierSection(),

                            SizedBox(height: 24),

                            // Import Items Section
                            _buildSectionHeader('ລາຍການນຳເຂົ້າ'),
                            SizedBox(height: 12),
                            _buildImportItemsSection(),

                            SizedBox(height: 24),

                            // Summary Section
                            _buildSummarySection(),

                            SizedBox(
                                height:
                                    100), // Space for floating action button
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addImportItem,
        icon: Icon(Icons.add, color: Colors.white),
        label:
            Text('ເພີ່ມລາຍການນຳເຂົ້າ', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFE45C58),
      ),
    );
  }

  // Build section header
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE45C58),
      ),
    );
  }

// Get or create product controller for specific item index
  TextEditingController _getProductController(int index) {
    if (!_productControllers.containsKey(index)) {
      _productControllers[index] = TextEditingController();
    }
    return _productControllers[index]!;
  }

// Handle product search input
  void _onProductSearch(int index, String searchTerm) {
    setState(() {
      if (searchTerm.trim().isEmpty) {
        _filteredProducts[index] = [];
        _showProductSuggestions[index] = false;
        // Clear product selection if search is empty
        _updateImportItem(index, 'ProductID', '');
        _updateImportItem(index, 'ProductName', '');
        _updateImportItem(index, 'CurrentStock', 0);
      } else {
        // Filter products by ID or Name (case insensitive)
        _filteredProducts[index] = _products.where((product) {
          final productId = product['ProductID'].toString().toLowerCase();
          final productName = product['ProductName'].toString().toLowerCase();
          final search = searchTerm.toLowerCase();

          return productId.contains(search) || productName.contains(search);
        }).toList();

        _showProductSuggestions[index] = true;

        // Check if exact match exists
        final exactMatch = _products.firstWhere(
          (product) =>
              product['ProductID'].toString().toLowerCase() ==
                  searchTerm.toLowerCase() ||
              product['ProductName'].toString().toLowerCase() ==
                  searchTerm.toLowerCase(),
          orElse: () => {},
        );

        if (exactMatch.isNotEmpty) {
          // Auto-select if exact match found
          _selectProduct(index, exactMatch);
        } else {
          // Clear selection if no exact match
          _updateImportItem(index, 'ProductID', '');
          _updateImportItem(index, 'ProductName', '');
          _updateImportItem(index, 'CurrentStock', 0);
        }
      }
    });
  }

// Select product from suggestions
  void _selectProduct(int index, Map<String, dynamic> product) {
    setState(() {
      _getProductController(index).text =
          '${product['ProductID']} - ${product['ProductName']}';
      _updateImportItem(index, 'ProductID', product['ProductID']);
      _updateImportItem(index, 'ProductName', product['ProductName']);
      _updateImportItem(index, 'CurrentStock', product['Quantity'] ?? 0);
      _showProductSuggestions[index] = false;
      _filteredProducts[index] = [];
    });

    // Hide keyboard
    FocusScope.of(context).unfocus();
  }

// Clear product selection
  void _clearProductSelection(int index) {
    setState(() {
      _getProductController(index).clear();
      _updateImportItem(index, 'ProductID', '');
      _updateImportItem(index, 'ProductName', '');
      _updateImportItem(index, 'CurrentStock', 0);
      _showProductSuggestions[index] = false;
      _filteredProducts[index] = [];
    });
  }

// Hide suggestions when tapping outside
  void _hideSuggestions() {
    setState(() {
      _showProductSuggestions.updateAll((key, value) => false);
      _showSupplierSuggestions = false; // Add this line
    });
  }

  // Build import header section
  Widget _buildImportHeaderSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Date picker
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Color(0xFFE45C58)),
                          SizedBox(width: 8),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),

                // Time picker
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Color(0xFFE45C58)),
                          SizedBox(width: 8),
                          Text(
                            _selectedTime.format(context),
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Invoice number
            TextFormField(
              controller: _invoiceNumberController,
              decoration: InputDecoration(
                labelText: 'ໃບແຈ້ງໜີ້ (ທາງເລືອກ)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.receipt),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build supplier section
  Widget _buildSupplierSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Supplier name (required)
            // Supplier search field with suggestions
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _supplierSearchController,
                  decoration: InputDecoration(
                    labelText: 'ຄົ້ນຫາຊື່ຜູ້ສະໜອງ *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.search),
                    hintText: 'ພິມຊື່ຜູ້ສະໜອງ...',
                    suffixIcon: _supplierNameController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: _clearSupplierSelection,
                          )
                        : null,
                  ),
                  onChanged: _onSupplierSearch,
                  onTap: () => setState(() => _showSupplierSuggestions = true),
                  validator: (value) {
                    if (_supplierNameController.text.trim().isEmpty) {
                      return 'Supplier selection is required';
                    }
                    return null;
                  },
                ),

                // Supplier suggestions list
                if (_showSupplierSuggestions && _filteredSuppliers.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredSuppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = _filteredSuppliers[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            supplier['ຊື່ຜູ້ສະໜອງ'] ?? 'N/A',
                            style: TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            'Contact: ${supplier['Phone'] ?? 'N/A'}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          onTap: () => _selectSupplier(supplier),
                        );
                      },
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),

            // Supplier contact
            TextFormField(
              controller: _supplierContactController,
              decoration: InputDecoration(
                labelText: 'ການຕິດຕໍ່ຜູ້ສະໜອງ (ທາງເລືອກ)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'ໝາຍເຫດ (ທາງເລືອກ)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // Build import items section
  Widget _buildImportItemsSection() {
    return Column(
      children: [
        // Import items list
        if (_importItems.isEmpty) ...[
          Container(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'ຍັງບໍ່ມີລາຍການນຳເຂົ້າ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'ກົດ "ເພີ່ມລາຍການນຳເຂົ້າ" ເພື່ອເລີ່ມຕົ້ນ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ...List.generate(
              _importItems.length, (index) => _buildImportItemCard(index)),
        ],
      ],
    );
  }

  // Build individual import item card
  Widget _buildImportItemCard(int index) {
    final item = _importItems[index];

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item header with remove button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item ${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE45C58),
                  ),
                ),
                IconButton(
                  onPressed: () => _removeImportItem(index),
                  icon: Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Remove Item',
                ),
              ],
            ),
            SizedBox(height: 12),

            // Product search field with suggestions
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _getProductController(index),
                  decoration: InputDecoration(
                    labelText: 'ຄົ້ນຫາສິນຄ້າ (ID ຫຼື ຊື່) *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.search),
                    hintText: 'ພິມ ID ຫຼື ຊື່ສິນຄ້າ...',
                    suffixIcon: item['ProductID'].toString().isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () => _clearProductSelection(index),
                          )
                        : null,
                  ),
                  onChanged: (value) => _onProductSearch(index, value),
                  onTap: () => _showProductSuggestions[index] = true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Product selection is required';
                    }
                    if (item['ProductID'].toString().isEmpty) {
                      return 'Please select a valid product from suggestions';
                    }
                    return null;
                  },
                ),

                // Product suggestions list
                if (_showProductSuggestions[index] == true &&
                    (_filteredProducts[index]?.isNotEmpty ?? false))
                  Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredProducts[index]?.length ?? 0,
                      itemBuilder: (context, suggestionIndex) {
                        final product =
                            _filteredProducts[index]![suggestionIndex];
                        return ListTile(
                          dense: true,
                          title: Text(
                            '${product['ProductID']} - ${product['ProductName']}',
                            style: TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            'Stock: ${product['Quantity']} | Price: \$${product['SellPrice']}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          onTap: () => _selectProduct(index, product),
                        );
                      },
                    ),
                  ),
              ],
            ),

            // Show current stock if product selected
            if (item['ProductID'].toString().isNotEmpty) ...[
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  'ສິນຄ້າໃນສະຕັອກປັດຈຸບັນ: ${item['CurrentStock']} ',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            SizedBox(height: 16),

            // Quantity and Price row
            Row(
              children: [
                // Import quantity
                Expanded(
                  child: TextFormField(
                    initialValue: item['ImportQuantity'].toString(),
                    decoration: InputDecoration(
                      labelText: 'ຈຳນວນການນຳເຂົ້າ *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) =>
                        _updateImportItem(index, 'ImportQuantity', value),
                    validator: (value) {
                      final qty = int.tryParse(value ?? '');
                      if (qty == null || qty <= 0) {
                        return 'Enter valid quantity (> 0)';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12),

                // Import price
                Expanded(
                  child: TextFormField(
                    initialValue: item['ImportPrice'].toString(),
                    decoration: InputDecoration(
                      labelText: 'ລາຄານຳເຂົ້າ *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    onChanged: (value) =>
                        _updateImportItem(index, 'ImportPrice', value),
                    validator: (value) {
                      final price = double.tryParse(value ?? '');
                      if (price == null || price < 0) {
                        return 'Enter valid price (≥ 0)';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Batch number
            TextFormField(
              initialValue: item['BatchNumber'].toString(),
              decoration: InputDecoration(
                labelText: 'ເລກຊຸດສິນຄ້າ (ທາງເລືອກ)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.qr_code),
              ),
              onChanged: (value) =>
                  _updateImportItem(index, 'BatchNumber', value),
            ),

            // Total cost display
            if (item['TotalCost'] > 0) ...[
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFE45C58).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFE45C58).withOpacity(0.3)),
                ),
                child: Text(
                  'Total Cost: \$${item['TotalCost'].toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE45C58),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Build summary section
  Widget _buildSummarySection() {
    final totalItems = _calculateTotalItems();
    final grandTotal = _calculateGrandTotal();

    return Card(
      elevation: 3,
      color: Color(0xFFE45C58).withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ສະຫຼຸບການນຳເຂົ້າ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE45C58),
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ຈຳນວນທັງໝົດ:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  '$totalItems items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ຍອດລວມທັງໝົດ:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${grandTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE45C58),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Move this INSIDE the children list
            // Create Import Button
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitImport,
                icon: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.save),
                label: Text(_isSubmitting
                    ? 'ກຳລັງສ້າງການນຳເຂົ້າ...'
                    : 'ສ້າງການນຳເຂົ້າ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE45C58),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
