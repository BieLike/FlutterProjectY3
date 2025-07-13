import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
// import 'package:flutter_lect2/newuxui/DBpath.dart';
// import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Model class for Role data
class RoleModel {
  final int rid;
  final String roleName;
  final int baseSalary;

  RoleModel({
    required this.rid,
    required this.roleName,
    required this.baseSalary,
  });

  // Convert JSON to RoleModel object
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      rid: json['RID'] ?? 0,
      roleName: json['RoleName'] ?? '',
      baseSalary: json['BaseSalary'] ?? 0,
    );
  }

  // Convert RoleModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'RID': rid,
      'RoleName': roleName,
      'BaseSalary': baseSalary,
    };
  }
}

class RolePage extends StatefulWidget {
  @override
  _RolePageState createState() => _RolePageState();
}

basePath bp = basePath();
final String bpt = bp.bpath();

class _RolePageState extends State<RolePage> {
  // Base URL for API - Replace with your server URL
  final String baseUrl = bpt; // Change to your server URL

  List<RoleModel> roles = [];
  List<RoleModel> filteredRoles = [];
  bool isLoading = false;

  // Controllers for form inputs
  final TextEditingController _ridController = TextEditingController();
  final TextEditingController _roleNameController = TextEditingController();
  final TextEditingController _baseSalaryController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchRoles(); // Load roles when page opens
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _ridController.dispose();
    _roleNameController.dispose();
    _baseSalaryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Fetch all roles from API
  Future<void> fetchRoles() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/main/role'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          roles = data.map((json) => RoleModel.fromJson(json)).toList();
          filteredRoles = roles; // Initialize filtered list
          isLoading = false;
        });
      } else {
        _showErrorSnackBar('Failed to load roles: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Network error: Please check your connection');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Search roles by ID or Name
  void searchRoles(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredRoles = roles;
      });
      return;
    }

    setState(() {
      filteredRoles = roles.where((role) {
        return role.rid.toString().contains(query.toLowerCase()) ||
            role.roleName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Add new role
  Future<void> addRole() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional validation for RID (must be unique and within range)
    final int rid = int.parse(_ridController.text);
    if (rid.toString().length > 5) {
      _showErrorSnackBar('Role ID must be maximum 5 digits');
      return;
    }

    // Check if RID already exists in local list
    if (roles.any((role) => role.rid == rid)) {
      _showErrorSnackBar('Role ID already exists');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/main/role'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'RID': int.parse(_ridController.text),
          'RoleName': _roleNameController.text.trim(),
          'BaseSalary': int.parse(_baseSalaryController.text),
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Role added successfully');
        _clearForm();
        await fetchRoles(); // Refresh the list
        Navigator.of(context).pop(); // Close dialog
      } else {
        final errorData = json.decode(response.body);
        _showErrorSnackBar(errorData['msg'] ?? 'Failed to add role');
      }
    } catch (e) {
      _showErrorSnackBar('Network error: Please check your connection');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update existing role
  Future<void> updateRole(RoleModel role) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/main/role/${role.rid}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'NewRID': int.parse(_ridController.text),
          'NewRoleName': _roleNameController.text.trim(),
          'NewBaseSalary': int.parse(_baseSalaryController.text),
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Role updated successfully');
        _clearForm();
        await fetchRoles(); // Refresh the list
        Navigator.of(context).pop(); // Close dialog
      } else {
        final errorData = json.decode(response.body);
        _showErrorSnackBar(errorData['msg'] ?? 'Failed to update role');
      }
    } catch (e) {
      _showErrorSnackBar('Network error: Please check your connection');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Delete role with confirmation
  Future<void> deleteRole(int rid) async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'ຢືນຢັນການລຶບ',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'ທ່ານແນ່ໃຈບໍ່ວ່າຈະລຶບຕຳແໜ່ງນີ້?',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red[100],
              ),
              child: Text('Delete', style: TextStyle(color: Colors.red[800])),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/main/role/$rid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Role deleted successfully');
        await fetchRoles(); // Refresh the list
      } else {
        final errorData = json.decode(response.body);
        _showErrorSnackBar(errorData['msg'] ?? 'Failed to delete role');
      }
    } catch (e) {
      _showErrorSnackBar('Network error: Please check your connection');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Show form dialog for add/edit
  void _showRoleDialog({RoleModel? role}) {
    final bool isEdit = role != null;

    // Pre-fill form if editing
    if (isEdit) {
      _ridController.text = role.rid.toString();
      _roleNameController.text = role.roleName;
      _baseSalaryController.text = role.baseSalary.toString();
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            isEdit ? 'Edit Role' : 'Add New Role',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Role ID input
                  TextFormField(
                    controller: _ridController,
                    decoration: InputDecoration(
                      labelText: 'ID ຕຳແໜ່ງ *',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFE45C58)!),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5), // Max 5 digits
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Role ID is required';
                      }
                      final int? rid = int.tryParse(value);
                      if (rid == null || rid < 1) {
                        return 'Role ID must be a positive number';
                      }
                      if (value.length > 5) {
                        return 'Role ID must be maximum 5 digits';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Role Name input
                  TextFormField(
                    controller: _roleNameController,
                    decoration: InputDecoration(
                      labelText: 'ຊື່ຕຳແໜ່ງ *',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFE45C58)!),
                      ),
                    ),
                    maxLength: 20, // varchar(20) limit
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Role Name is required';
                      }
                      if (value.trim().length > 20) {
                        return 'Role Name must be maximum 20 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Base Salary input
                  TextFormField(
                    controller: _baseSalaryController,
                    decoration: InputDecoration(
                      labelText: 'ເງິນເດືອນພື້ນຖານ *',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFE45C58)!),
                      ),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8), // Max 8 digits
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Base Salary is required';
                      }
                      final int? salary = int.tryParse(value);
                      if (salary == null || salary < 0) {
                        return 'Base Salary must be a positive number';
                      }
                      if (value.length > 8) {
                        return 'Base Salary must be maximum 8 digits';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearForm();
                Navigator.of(context).pop();
              },
              child: Text('ຍົກເລີກ', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => isEdit ? updateRole(role) : addRole(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE45C58),
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  // Clear form inputs
  void _clearForm() {
    _ridController.clear();
    _roleNameController.clear();
    _baseSalaryController.clear();
  }

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE45C58),
      appBar: AppBar(
        title: Text(
          'ຈັດການຕຳແໜ່ງ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFE45C58),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFE45C58),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ຄົ້ນຫາຕຳແໜ່ງດ້ວຍ ID ຫຼື ຕຳແໜ່ງ...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red[300]!),
                ),
                fillColor: Colors.grey[50],
                filled: true,
              ),
              onChanged: searchRoles,
            ),
          ),

          // Main content
          Expanded(
            child: isLoading && roles.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFE45C58)!),
                    ),
                  )
                : filteredRoles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'ບໍ່ມີຕຳແໜ່ງທີ່ຄົ້ນຫາ'
                                  : 'ບໍ່ມີຕຳແໜ່ງທີ່ເຂົ້າກັບການຄົ້ນຫາ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: Color(0xFFE45C58),
                        onRefresh: fetchRoles,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: filteredRoles.length,
                          itemBuilder: (context, index) {
                            final role = filteredRoles[index];
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.only(bottom: 12),
                              color: Colors.white,
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red[100],
                                  child: Text(
                                    role.rid.toString(),
                                    style: TextStyle(
                                      color: Colors.red[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  role.roleName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  'ເງິນເດືອນພື້ນຖານ: \$${role.baseSalary.toString()}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Edit button
                                    IconButton(
                                      icon: Icon(Icons.edit,
                                          color: Colors.blue[600]),
                                      onPressed: () =>
                                          _showRoleDialog(role: role),
                                      tooltip: 'ແກ້ໄຂຕຳແໜ່ງ',
                                    ),
                                    // Delete button
                                    IconButton(
                                      icon: Icon(Icons.delete,
                                          color: Colors.red[600]),
                                      onPressed: () => deleteRole(role.rid),
                                      tooltip: 'ລຶບຕຳແໜ່ງ',
                                    ),
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

      // Floating Action Button for adding new role
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRoleDialog(),
        backgroundColor: Colors.red[300],
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'ເພີ່ມຕຳແໜ່ງໃໝ່',
      ),
    );
  }
}
