import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;

class ManageUserPage extends StatefulWidget {
  const ManageUserPage({super.key});

  @override
  State<ManageUserPage> createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  List data = [];
  List roles = []; // Store roles for dropdown
  final String baseurl = "http://Localhost:3000";

  // Search controller
  TextEditingController txtSearch = TextEditingController();

  // Form controllers
  TextEditingController txtFname = TextEditingController();
  TextEditingController txtLname = TextEditingController();
  TextEditingController txtDOB = TextEditingController();
  TextEditingController txtPhone = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  String selectedGender = 'ຊາຍ'; // Default gender
  int? selectedPosition; // Store selected role ID
  bool isLoading = false;

  @override
  void initState() {
    FetchAllData();
    FetchRoles(); // Load roles for dropdown
    super.initState();
  }

  // Fetch all roles for position dropdown
  Future<void> FetchRoles() async {
    try {
      final response = await http.get(Uri.parse("$baseurl/main/role"));
      if (response.statusCode == 200) {
        setState(() {
          roles = json.decode(response.body);
        });
      }
    } catch (e) {
      print("Error fetching roles: $e");
    }
  }

  // Search users by any field
  Future<void> FetchValData(String searchTerm) async {
    if (searchTerm.isEmpty) {
      FetchAllData();
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse("$baseurl/main/user/$searchTerm"));
      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch all users
  Future<void> FetchAllData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse("$baseurl/main/user"));
      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
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

  // Show success message
  void ShowSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Delete user with confirmation
  Future<void> DeleteUser(String uid) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.delete(
        Uri.parse("$baseurl/main/user/$uid"),
        headers: {'Content-Type': 'application/json'},
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        FetchAllData();
        final responseBody = json.decode(response.body);
        ShowSuccessMessage(responseBody['msg'] ?? "User deleted successfully!");
      } else {
        final responseBody = json.decode(response.body);
        ShowErrorMessage(responseBody['msg'] ??
            "Failed to delete user. Status: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      ShowErrorMessage("Failed to delete user: ${e.toString()}");
    }
  }

  // Show delete confirmation dialog
  void ShowDeleteConfirmation(String uid, String fname, String lname) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Delete confirmation",
            style: TextStyle(color: Color(0xFFE45C58))),
        content: Text("You are now deleting '$fname $lname' (ID: $uid)"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              DeleteUser(uid);
            },
            child: Text("Delete"),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          )
        ],
      ),
    );
  }

  // Add/Update user dialog
  void ShowDataDialog({Map<String, dynamic>? userData}) {
    if (userData != null) {
      // Pre-fill form for update
      txtFname.text = userData['UserFname']?.toString() ?? '';
      txtLname.text = userData['UserLname']?.toString() ?? '';
      txtDOB.text = userData['DateOfBirth']?.toString() ?? '';
      txtPhone.text = userData['Phone']?.toString() ?? '';
      txtEmail.text = userData['Email']?.toString() ?? '';
      txtPassword.text = userData['UserPassword']?.toString() ?? '';
      selectedGender = userData['Gender']?.toString() ?? 'ຊາຍ';
      selectedPosition = userData['Position'];
    } else {
      clearFields();
    }

    // Add new user
    Future<void> AddUser() async {
      // Input validation
      if (txtFname.text.isEmpty ||
          txtLname.text.isEmpty ||
          txtPhone.text.isEmpty ||
          txtEmail.text.isEmpty ||
          txtPassword.text.isEmpty ||
          selectedPosition == null) {
        ShowErrorMessage("All fields are required!");
        return;
      }

      // Phone validation (basic)
      if (!RegExp(r'^\d+$').hasMatch(txtPhone.text)) {
        ShowErrorMessage("Phone must contain only numbers");
        return;
      }

      // Email validation (basic)
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
          .hasMatch(txtEmail.text)) {
        ShowErrorMessage("Please enter a valid email address");
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse("$baseurl/main/user"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "UserFname": txtFname.text.trim(),
            "UserLname": txtLname.text.trim(),
            "DateOfBirth": txtDOB.text.isEmpty ? null : txtDOB.text,
            "Gender": selectedGender,
            "Phone": txtPhone.text.trim(),
            "Email": txtEmail.text.trim(),
            "Position": selectedPosition,
            "UserPassword": txtPassword.text,
          }),
        );

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          ShowSuccessMessage("User added successfully");
          clearFields();
          FetchAllData();
          Navigator.of(context).pop();
        } else if (response.statusCode == 300) {
          ShowErrorMessage("This phone/email/password already exists");
        } else {
          final responseBody = json.decode(response.body);
          ShowErrorMessage(responseBody['msg'] ??
              "Failed to add user. Status: ${response.statusCode}");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e);
        ShowErrorMessage("Failed to add user: ${e.toString()}");
      }
    }

    // Update existing user
    Future<void> UpdateUser(String uid) async {
      // Input validation
      if (txtFname.text.isEmpty ||
          txtLname.text.isEmpty ||
          txtPhone.text.isEmpty ||
          txtEmail.text.isEmpty ||
          txtPassword.text.isEmpty ||
          selectedPosition == null) {
        ShowErrorMessage("All fields are required!");
        return;
      }

      // Phone validation
      if (!RegExp(r'^\d+$').hasMatch(txtPhone.text)) {
        ShowErrorMessage("Phone must contain only numbers");
        return;
      }

      // Email validation
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
          .hasMatch(txtEmail.text)) {
        ShowErrorMessage("Please enter a valid email address");
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        final response = await http.put(
          Uri.parse("$baseurl/main/user/$uid"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "UserFname": txtFname.text.trim(),
            "UserLname": txtLname.text.trim(),
            "DateOfBirth": txtDOB.text.isEmpty ? null : txtDOB.text,
            "Gender": selectedGender,
            "Phone": txtPhone.text.trim(),
            "Email": txtEmail.text.trim(),
            "Position": selectedPosition,
            "UserPassword": txtPassword.text,
          }),
        );

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          clearFields();
          FetchAllData();
          Navigator.of(context).pop();
          final responseBody = json.decode(response.body);
          ShowSuccessMessage(
              responseBody['msg'] ?? "User updated successfully");
        } else {
          final responseBody = json.decode(response.body);
          ShowErrorMessage(responseBody['msg'] ??
              "Failed to update user. Status: ${response.statusCode}");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e);
        ShowErrorMessage("Failed to update user: ${e.toString()}");
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          userData != null ? "Update User" : "Add User",
          style: TextStyle(color: Color(0xFFE45C58)),
        ),
        content: Container(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // First Name and Last Name
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: txtFname,
                        decoration: InputDecoration(
                          labelText: 'First Name *',
                          labelStyle: TextStyle(color: Color(0xFFE45C58)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color(0xFFE45C58)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: txtLname,
                        decoration: InputDecoration(
                          labelText: 'Last Name *',
                          labelStyle: TextStyle(color: Color(0xFFE45C58)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color(0xFFE45C58)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Date of Birth (optional)
                TextField(
                  controller: txtDOB,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFE45C58)),
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Gender dropdown
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender *',
                    labelStyle: TextStyle(color: Color(0xFFE45C58)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFE45C58)),
                    ),
                  ),
                  items: ['ຊາຍ', 'ຍິງ', 'ເດິຣອກສົງໃສ'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGender = newValue!;
                    });
                  },
                ),
                SizedBox(height: 12),

                // Phone and Email
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: txtPhone,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone *',
                          labelStyle: TextStyle(color: Color(0xFFE45C58)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color(0xFFE45C58)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: txtEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email *',
                          labelStyle: TextStyle(color: Color(0xFFE45C58)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color(0xFFE45C58)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Position dropdown
                DropdownButtonFormField<int>(
                  value: selectedPosition,
                  decoration: InputDecoration(
                    labelText: 'Position *',
                    labelStyle: TextStyle(color: Color(0xFFE45C58)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFE45C58)),
                    ),
                  ),
                  items: roles.map<DropdownMenuItem<int>>((role) {
                    return DropdownMenuItem<int>(
                      value: role['RID'],
                      child: Text(role['RoleName']),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedPosition = newValue;
                    });
                  },
                ),
                SizedBox(height: 12),

                // Password
                TextField(
                  controller: txtPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    labelStyle: TextStyle(color: Color(0xFFE45C58)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFE45C58)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              clearFields();
              Navigator.of(context).pop();
            },
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              if (userData != null) {
                UpdateUser(userData['UID'].toString());
              } else {
                AddUser();
              }
            },
            child: Text(userData != null ? "Update" : "Add"),
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFFE45C58),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // Clear all form fields
  void clearFields() {
    txtFname.clear();
    txtLname.clear();
    txtDOB.clear();
    txtPhone.clear();
    txtEmail.clear();
    txtPassword.clear();
    selectedGender = 'ຊາຍ';
    selectedPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users Management'),
        backgroundColor: Color(0xFFE45C58),
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) {
                if (val.isEmpty) {
                  FetchAllData();
                } else {
                  FetchValData(val);
                }
              },
              controller: txtSearch,
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Users List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : data.isEmpty
                    ? Center(
                        child: Text(
                          "No users found",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final user = data[index];
                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Color(0xFFE45C58).withOpacity(0.1),
                                  child: Text(
                                    '${user['UserFname']?[0] ?? ''}${user['UserLname']?[0] ?? ''}',
                                    style: TextStyle(
                                      color: Color(0xFFE45C58),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '${user['UserFname'] ?? ''} ${user['UserLname'] ?? ''}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ID: ${user['UID']}'),
                                    Text('Phone: ${user['Phone'] ?? 'N/A'}'),
                                    Text('Email: ${user['Email'] ?? 'N/A'}'),
                                    Text(
                                        'Position: ${user['RoleName'] ?? 'N/A'}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit,
                                          color: Color(0xFFE45C58)),
                                      onPressed: () =>
                                          ShowDataDialog(userData: user),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => ShowDeleteConfirmation(
                                        user['UID'].toString(),
                                        user['UserFname']?.toString() ?? '',
                                        user['UserLname']?.toString() ?? '',
                                      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => ShowDataDialog(),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFFE45C58),
      ),
    );
  }
}
