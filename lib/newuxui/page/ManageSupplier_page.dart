import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;

class ManageSuppliersPage extends StatefulWidget {
  const ManageSuppliersPage({super.key});

  @override
  State<ManageSuppliersPage> createState() => _ManageSuppliersPageState();
}

class _ManageSuppliersPageState extends State<ManageSuppliersPage> {
  // Data lists
  List<dynamic> suppliers = [];
  List<dynamic> filteredSuppliers = [];

  // Base URL - Replace with your actual server URL
  final String baseUrl =
      "http://Localhost:3000"; // Match your existing baseurl

  // Controllers for form fields
  final TextEditingController searchController = TextEditingController();
  final TextEditingController supplierNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // State variables
  bool isLoading = false;
  String selectedStatus = 'Active'; // Default status

  @override
  void initState() {
    super.initState();
    fetchAllSuppliers();

    // Add search listener
    searchController.addListener(() {
      filterSuppliers(searchController.text);
    });
  }

  @override
  void dispose() {
    // Clean up controllers
    searchController.dispose();
    supplierNameController.dispose();
    contactPersonController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // ================= API METHODS =================

  /// Fetch all suppliers from the API
  Future<void> fetchAllSuppliers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/main/supplier"),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          suppliers = data;
          filteredSuppliers = data; // Initialize filtered list
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showErrorMessage(
            "Failed to fetch suppliers. Status: ${response.statusCode}");
      }
    } on http.ClientException catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorMessage("Network error: Please check your connection");
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorMessage("Failed to fetch suppliers: ${e.toString()}");
    }
  }

  /// Create new supplier
  Future<void> createSupplier() async {
    // Validate required fields
    if (supplierNameController.text.trim().isEmpty ||
        contactPersonController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      showErrorMessage(
          "Supplier Name, Contact Person, and Phone are required!");
      return;
    }

    // Validate email format if provided
    if (emailController.text.trim().isNotEmpty &&
        !_isValidEmail(emailController.text.trim())) {
      showErrorMessage("Please enter a valid email address");
      return;
    }

    // Validate phone number format
    if (!_isValidPhone(phoneController.text.trim())) {
      showErrorMessage("Please enter a valid phone number");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/main/supplier"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "SupplierName": supplierNameController.text.trim(),
              "ContactPerson": contactPersonController.text.trim(),
              "Phone": phoneController.text.trim(),
              "Email": emailController.text.trim().isEmpty
                  ? null
                  : emailController.text.trim(),
              "Address": addressController.text.trim().isEmpty
                  ? null
                  : addressController.text.trim(),
              "Status": selectedStatus,
            }),
          )
          .timeout(const Duration(seconds: 10));

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        showSuccessMessage(
            responseBody['msg'] ?? "Supplier created successfully!");
        clearFormFields();
        fetchAllSuppliers(); // Refresh the list
        Navigator.of(context).pop(); // Close dialog
      } else {
        final responseBody = json.decode(response.body);
        showErrorMessage(responseBody['msg'] ??
            "Failed to create supplier. Status: ${response.statusCode}");
      }
    } on http.ClientException catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorMessage("Network error: Please check your connection");
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorMessage("Failed to create supplier: ${e.toString()}");
    }
  }

  /// Update existing supplier
  Future<void> updateSupplier(int supplierID) async {
    // Validate email format if provided
    if (emailController.text.trim().isNotEmpty &&
        !_isValidEmail(emailController.text.trim())) {
      showErrorMessage("Please enter a valid email address");
      return;
    }

    // Validate phone number format if provided
    if (phoneController.text.trim().isNotEmpty &&
        !_isValidPhone(phoneController.text.trim())) {
      showErrorMessage("Please enter a valid phone number");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl/main/supplier/$supplierID"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "SupplierName": supplierNameController.text.trim().isEmpty
                  ? null
                  : supplierNameController.text.trim(),
              "ContactPerson": contactPersonController.text.trim().isEmpty
                  ? null
                  : contactPersonController.text.trim(),
              "Phone": phoneController.text.trim().isEmpty
                  ? null
                  : phoneController.text.trim(),
              "Email": emailController.text.trim().isEmpty
                  ? null
                  : emailController.text.trim(),
              "Address": addressController.text.trim().isEmpty
                  ? null
                  : addressController.text.trim(),
              "Status": selectedStatus,
            }),
          )
          .timeout(const Duration(seconds: 10));

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        showSuccessMessage(
            responseBody['msg'] ?? "Supplier updated successfully!");
        clearFormFields();
        fetchAllSuppliers(); // Refresh the list
        Navigator.of(context).pop(); // Close dialog
      } else {
        final responseBody = json.decode(response.body);
        showErrorMessage(responseBody['msg'] ??
            "Failed to update supplier. Status: ${response.statusCode}");
      }
    } on http.ClientException catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorMessage("Network error: Please check your connection");
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorMessage("Failed to update supplier: ${e.toString()}");
    }
  }

  /// Delete supplier
  Future<void> deleteSupplier(int supplierID) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/main/supplier/$supplierID"),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        showSuccessMessage(
            responseBody['msg'] ?? "Supplier deleted successfully!");
        fetchAllSuppliers(); // Refresh the list
      } else {
        final responseBody = json.decode(response.body);
        showErrorMessage(responseBody['msg'] ??
            "Failed to delete supplier. Status: ${response.statusCode}");
      }
    } on http.ClientException catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorMessage("Network error: Please check your connection");
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorMessage("Failed to delete supplier: ${e.toString()}");
    }
  }

  // ================= HELPER METHODS =================

  /// Filter suppliers based on search query
  void filterSuppliers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredSuppliers = suppliers;
      });
      return;
    }

    final filtered = suppliers.where((supplier) {
      final supplierName =
          (supplier['SupplierName'] ?? '').toString().toLowerCase();
      final contactPerson =
          (supplier['ContactPerson'] ?? '').toString().toLowerCase();
      final phone = (supplier['Phone'] ?? '').toString().toLowerCase();
      final email = (supplier['Email'] ?? '').toString().toLowerCase();
      final searchQuery = query.toLowerCase();

      return supplierName.contains(searchQuery) ||
          contactPerson.contains(searchQuery) ||
          phone.contains(searchQuery) ||
          email.contains(searchQuery);
    }).toList();

    setState(() {
      filteredSuppliers = filtered;
    });
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  /// Validate phone number format (basic validation)
  bool _isValidPhone(String phone) {
    // Remove spaces, dashes, and parentheses for validation
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]+'), '');
    // Check if it contains only digits and is between 8-15 characters
    return RegExp(r'^\d{8,15}$').hasMatch(cleanPhone);
  }

  /// Clear all form fields
  void clearFormFields() {
    supplierNameController.clear();
    contactPersonController.clear();
    phoneController.clear();
    emailController.clear();
    addressController.clear();
    selectedStatus = 'Active';
  }

  /// Show error message
  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show success message
  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show delete confirmation dialog
  void showDeleteConfirmation(int supplierID, String supplierName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Confirmation"),
        content: Text(
            "Are you sure you want to delete '$supplierName'?\n\nThis action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteSupplier(supplierID);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  /// Show supplier form dialog (for both add and edit)
  void showSupplierDialog({Map<String, dynamic>? supplierData}) {
    // Pre-fill form if editing
    if (supplierData != null) {
      supplierNameController.text =
          supplierData['SupplierName']?.toString() ?? '';
      contactPersonController.text =
          supplierData['ContactPerson']?.toString() ?? '';
      phoneController.text = supplierData['Phone']?.toString() ?? '';
      emailController.text = supplierData['Email']?.toString() ?? '';
      addressController.text = supplierData['Address']?.toString() ?? '';
      selectedStatus = supplierData['Status']?.toString() ?? 'Active';
    } else {
      clearFormFields();
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title:
              Text(supplierData != null ? "Edit Supplier" : "Add New Supplier"),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Supplier Name (Required)
                  TextField(
                    controller: supplierNameController,
                    decoration: InputDecoration(
                      labelText: 'Supplier Name *',
                      labelStyle: const TextStyle(color: Color(0xFFE45C58)),
                      border: const OutlineInputBorder(),
                      hintText: 'Enter supplier name',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),

                  // Contact Person (Required)
                  TextField(
                    controller: contactPersonController,
                    decoration: InputDecoration(
                      labelText: 'Contact Person *',
                      labelStyle: const TextStyle(color: Color(0xFFE45C58)),
                      border: const OutlineInputBorder(),
                      hintText: 'Enter contact person name',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),

                  // Phone (Required)
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone *',
                      labelStyle: const TextStyle(color: Color(0xFFE45C58)),
                      border: const OutlineInputBorder(),
                      hintText: 'Enter phone number',
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[\d\s\-\(\)]+'))
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Email (Optional)
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: const OutlineInputBorder(),
                      hintText: 'Enter email address (optional)',
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),

                  // Address (Optional)
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: const OutlineInputBorder(),
                      hintText: 'Enter address (optional)',
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: const TextStyle(color: Color(0xFFE45C58)),
                      border: const OutlineInputBorder(),
                    ),
                    value: selectedStatus,
                    items: ['Active', 'Inactive']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        selectedStatus = newValue ?? 'Active';
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Required fields note
                  const Text(
                    '* Required fields',
                    style: TextStyle(
                      color: Color(0xFFE45C58),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                clearFormFields();
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (supplierData != null) {
                        updateSupplier(supplierData['SupplierID']);
                      } else {
                        createSupplier();
                      }
                    },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFE45C58),
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(supplierData != null ? "Update" : "Add"),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI BUILD METHOD =================

  @override
  Widget build(BuildContext context) {
    // Responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 1; // Default for mobile

    if (screenWidth > 600 && screenWidth <= 900) {
      crossAxisCount = 2; // Tablet
    } else if (screenWidth > 900) {
      crossAxisCount = 3; // Desktop
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Management'),
        backgroundColor: const Color(0xFFE45C58),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search suppliers...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          filterSuppliers('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Suppliers List
          Expanded(
            child: isLoading && suppliers.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFE45C58)),
                        ),
                        SizedBox(height: 16),
                        Text("Loading suppliers..."),
                      ],
                    ),
                  )
                : filteredSuppliers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchController.text.isEmpty
                                  ? "No suppliers found"
                                  : "No suppliers match your search",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              searchController.text.isEmpty
                                  ? "Add your first supplier to get started"
                                  : "Try a different search term",
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: filteredSuppliers.length,
                          itemBuilder: (context, index) {
                            final supplier = filteredSuppliers[index];
                            final isActive = supplier['Status'] == 'Active';

                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isActive
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header with status and actions
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            supplier['Status'] ?? 'Unknown',
                                            style: TextStyle(
                                              color: isActive
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  size: 18),
                                              color: const Color(0xFFE45C58),
                                              onPressed: () =>
                                                  showSupplierDialog(
                                                supplierData: supplier,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              constraints: const BoxConstraints(
                                                minWidth: 32,
                                                minHeight: 32,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  size: 18),
                                              color: Colors.red,
                                              onPressed: () =>
                                                  showDeleteConfirmation(
                                                supplier['SupplierID'],
                                                supplier['SupplierName'] ??
                                                    'Unknown',
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              constraints: const BoxConstraints(
                                                minWidth: 32,
                                                minHeight: 32,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Supplier Name
                                    Text(
                                      supplier['SupplierName'] ??
                                          'Unknown Supplier',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE45C58),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 6),

                                    // Contact Person
                                    Row(
                                      children: [
                                        const Icon(Icons.person,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            supplier['ContactPerson'] ?? 'N/A',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 4),

                                    // Phone
                                    Row(
                                      children: [
                                        const Icon(Icons.phone,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            supplier['Phone'] ?? 'N/A',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Email (if available)
                                    if (supplier['Email'] != null &&
                                        supplier['Email']
                                            .toString()
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.email,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              supplier['Email'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                    // Address (if available)
                                    if (supplier['Address'] != null &&
                                        supplier['Address']
                                            .toString()
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              supplier['Address'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSupplierDialog(),
        backgroundColor: const Color(0xFFE45C58),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
