import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;

class ManageAuthorPage extends StatefulWidget {
  const ManageAuthorPage({super.key});

  @override
  State<ManageAuthorPage> createState() => _AuthorPageState();
}

basePath bp = basePath();
final String bpt = bp.bpath();

class _AuthorPageState extends State<ManageAuthorPage> {
  List data = [];
  final String baseurl = bpt;
  TextEditingController txtSearch = TextEditingController();
  TextEditingController txtAuthorID = TextEditingController();
  TextEditingController txtAuthorName = TextEditingController();
  TextEditingController txtNewAuthorID = TextEditingController();
  TextEditingController txtNewAuthorName = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    FetchAllAuthors();
    super.initState();
  }

  // --- GET All Authors ---
  Future<void> FetchAllAuthors() async {
    setState(() {
      isLoading = true;
    });
    try {
      final String url = "$baseurl/main/author"; // Changed endpoint to /author
      final response = await http.get(Uri.parse(url));
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
        ShowErrorMessage("Failed to fetch authors. Status: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      ShowErrorMessage("Failed to connect to server: ${e.toString()}");
    }
  }

  // --- GET Author by ID or Name ---
  Future<void> FetchAuthorData(String searchTerm) async {
    if (searchTerm.isEmpty) {
      FetchAllAuthors(); // Fetch all if search term is empty
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final String urlf = "$baseurl/main/author/$searchTerm"; // Changed endpoint to /author/:search
      final response = await http.get(Uri.parse(urlf));
      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          data = []; // Clear data if not found
          isLoading = false;
        });
        ShowErrorMessage("No author found for '$searchTerm'");
      } else {
        print("Error: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
        ShowErrorMessage("Failed to search authors. Status: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      ShowErrorMessage("Failed to connect to server: ${e.toString()}");
    }
  }

  void ShowErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void ShowSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // --- DELETE Author ---
  Future<void> DeleteAuthor(String authorId) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Your API already handles the "in use" check with a 409 status code.
      // So, the separate /product check logic is not strictly needed here
      // if the backend is robust.
      // I'm simplifying this part to directly call the delete endpoint
      // and handle the 409 error as per your API spec.
      final response = await http.delete(
        Uri.parse("$baseurl/main/author/$authorId"), // Changed endpoint to /author/:id
        headers: {'Content-Type': 'application/json'},
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        FetchAllAuthors();
        final responseBody = json.decode(response.body);
        ShowSuccessMessage(responseBody['msg'] ?? "Author deleted successfully!");
      } else if (response.statusCode == 409) {
        final responseBody = json.decode(response.body);
        ShowErrorMessage(responseBody['message'] ?? "Cannot delete author: It is still in use.");
      } else {
        final responseBody = json.decode(response.body);
        ShowErrorMessage(responseBody['msg'] ?? "Failed to delete author. Status: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      ShowErrorMessage("Failed to delete author: ${e.toString()}");
    }
  }

  void ShowDeleteConfirmation(String authorId, String authorName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          "ລົບຂໍ້ມູນ",
          style: TextStyle(color: Color(0xFFE45C58)),
        ),
        content: Text("ກຳລັງລົບຂໍ້ມູນ '$authorName' ('$authorId')"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "ຍົກເລີກ",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              DeleteAuthor(authorId);
            },
            child: Text("ລຶບ"),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        ],
      ),
    );
  }

  void ShowAuthorDataDialog({Map<String, dynamic>? authorData}) {
    if (authorData != null) {
      txtAuthorID.text = authorData['authorID'].toString();
      txtAuthorName.text = authorData['name'].toString();
      txtNewAuthorID.text = ""; // Clear for update mode
      txtNewAuthorName.text = ""; // Clear for update mode
    } else {
      clearAText(); // Clear for add mode
    }

    // --- POST Insert New Author ---
    Future<void> AddAuthor() async {
      if (txtAuthorID.text.isEmpty || txtAuthorName.text.isEmpty) {
        ShowErrorMessage("Author ID and Name are required!");
        return;
      }
      setState(() {
        isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse("$baseurl/main/author"), // Changed endpoint to /author
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "authorID": txtAuthorID.text, // Changed key to authorID
            "name": txtAuthorName.text, // Changed key to name
          }),
        );

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          ShowSuccessMessage("Author added successfully");
          clearAText();
          FetchAllAuthors();
          Navigator.of(context).pop();
        } else if (response.statusCode == 300) {
          ShowErrorMessage("This author already Existed"); // Matched API message
        } else {
          final respondBody = json.decode(response.body);
          ShowErrorMessage(respondBody['msg'] ?? "Failed to add author. Status: ${response.statusCode}");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e);
        ShowErrorMessage("Failed to add author: ${e.toString()}");
      }
    }

    // --- PUT Update Author ---
    Future<void> UpdateAuthor(String originalAuthorID) async {
      // You can make these fields optional in the UI, but the API expects them for update.
      // If NewAuthorID or NewName are empty, the API will use the existing values.
      // However, it's good practice to send the values if they exist in the text controllers.
      if (txtAuthorID.text.isEmpty || txtAuthorName.text.isEmpty) {
         ShowErrorMessage("Original Author ID and Name are required for update.");
         return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        final response = await http.put(
          Uri.parse("$baseurl/main/author/$originalAuthorID"), // Changed endpoint to /author/:id
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "NewAuthorID": txtNewAuthorID.text.isEmpty ? txtAuthorID.text : txtNewAuthorID.text, // Use current if new is empty
            "name": txtAuthorName.text, // Existing name
            "NewName": txtNewAuthorName.text.isEmpty ? txtAuthorName.text : txtNewAuthorName.text, // Use current if new is empty
          }),
        );
        setState(() {
          isLoading = false;
        });
        if (response.statusCode == 200) {
          clearAText();
          FetchAllAuthors();
          Navigator.of(context).pop();
          final responseBody = json.decode(response.body);
          ShowSuccessMessage(responseBody['msg'] ?? "Author updated successfully"); // Matched API message
        } else if (response.statusCode == 409) {
          final respondBody = json.decode(response.body);
          ShowErrorMessage(respondBody['msg'] ?? "Author ID or name already exists."); // Matched API message
        }
        else {
          final respondBody = json.decode(response.body);
          ShowErrorMessage(respondBody['msg'] ?? "Failed to update author. Status: ${response.statusCode}");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e);
        ShowErrorMessage("Failure to update author: ${e.toString()}");
      }
    }

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          authorData != null ? "ແກ້ໄຂນັກຂຽນ" : "ເພີ່ມນັກຂຽນ", // Changed "ຫົວໜ່ວຍ" to "ນັກຂຽນ"
          style: TextStyle(color: Color(0xFFE45C58)),
        ),
        content: Container(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (authorData == null) ...[
                  // Add Mode
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: txtAuthorID, // Changed to txtAuthorID
                          decoration: InputDecoration(
                            labelText: 'ID ນັກຂຽນ *', // Changed label
                            hintText: 'ປ້ອນ ID ນັກຂຽນ', // Changed hint
                            labelStyle: TextStyle(color: Color(0xFFE45C58)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFFE45C58)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: txtAuthorName, // Changed to txtAuthorName
                          decoration: InputDecoration(
                            labelText: 'ຊື່ນັກຂຽນ *', // Changed label
                            hintText: 'ປ້ອນຊື່ນັກຂຽນ', // Changed hint
                            labelStyle: TextStyle(color: Color(0xFFE45C58)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFFE45C58)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Update Mode
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'ລາຍລະອຽດນັກຂຽນປັດຈຸບັນ', // Changed label
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: txtAuthorID, // Changed to txtAuthorID
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'ID ປັດຈຸບັນ', // Changed label
                                labelStyle: TextStyle(color: Colors.grey[600]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: txtAuthorName, // Changed to txtAuthorName
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'ຊື່ປັດຈຸບັນ', // Changed label
                                labelStyle: TextStyle(color: Colors.grey[600]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'ລາຍລະອຽດນັກຂຽນໃໝ່ (ທາງເລືອກ: ປ່ອຍຫວ່າງໄວ້ຖ້າຕ້ອງການໃຊ້ຕົວເກົ່າ)', // Changed label
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: txtNewAuthorID, // Changed to txtNewAuthorID
                              decoration: InputDecoration(
                                labelText: 'ID ໃໝ່', // Changed label
                                hintText: 'ປ້ອນ ID ນັກຂຽນໃໝ່', // Changed hint
                                labelStyle: TextStyle(color: Colors.green),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: txtNewAuthorName, // Changed to txtNewAuthorName
                              decoration: InputDecoration(
                                labelText: 'ຊື່ໃໝ່', // Changed label
                                hintText: 'ປ້ອນຊື່ໃໝ່', // Changed hint
                                labelStyle: TextStyle(color: Colors.green),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              clearAText();
              Navigator.of(context).pop();
            },
            child: Text(
              "ຍົກເລີກ",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              if (authorData != null) {
                UpdateAuthor(authorData['authorID'].toString()); // Changed to authorData['authorID']
              } else {
                AddAuthor();
              }
            },
            child: Text(authorData != null ? "ແກ້ໄຂ" : "ເພີ່ມ"),
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFFE45C58),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void clearAText() {
    txtAuthorID.clear();
    txtAuthorName.clear();
    txtNewAuthorID.clear();
    txtNewAuthorName.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ຈັດການນັກຂຽນ'), // Changed title
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
                  FetchAllAuthors(); // Changed to FetchAllAuthors
                } else {
                  FetchAuthorData(val); // Changed to FetchAuthorData
                }
              },
              controller: txtSearch,
              decoration: InputDecoration(
                hintText: "ຄົ້ນຫານັກຂຽນ...", // Changed hint
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // Authors List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : data.isEmpty
                    ? Center(
                        child: Text(
                          "ບໍ່ພົບນັກຂຽນ", // Changed text
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final author = data[index]; // Changed variable name
                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                leading: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFE45C58).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'ID: ${author['authorID']}', // Changed key to authorID
                                    style: TextStyle(
                                      color: Color(0xFFE45C58),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '${author['name']}', // Changed key to name
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Color(0xFFE45C58)),
                                      onPressed: () => ShowAuthorDataDialog(authorData: author), // Changed function name and parameter
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => ShowDeleteConfirmation(
                                        author['authorID'].toString(), // Changed key to authorID
                                        author['name'].toString(), // Changed key to name
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
        onPressed: () => ShowAuthorDataDialog(), // Changed function name
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFFE45C58),
      ),
    );
  }
}