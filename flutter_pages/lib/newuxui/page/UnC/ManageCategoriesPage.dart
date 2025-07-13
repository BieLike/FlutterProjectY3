import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
// import 'package:flutter_lect2/newuxui/DBpath.dart';
// import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _CategoryPageState();
}

basePath bp = basePath();
final String bpt = bp.bpath();

class _CategoryPageState extends State<ManageCategoriesPage> {
  List data = [];
  final String baseurl = bpt; //localhost  /pe 192.168.189.1
  TextEditingController txtSearch = TextEditingController();
  TextEditingController txtNewID = TextEditingController();
  TextEditingController txtNewName = TextEditingController();
  TextEditingController txtID = TextEditingController();
  TextEditingController txtName = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    FetchAllData();
    super.initState();
  }

  Future<Map<String, dynamic>?> _getEmployeeData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString == null) {
      ShowErrorMessage("ບໍ່ພົບຜູ້ໃຊ້ ກະລຸນາລັອກອິນໃໝ່");
      return null;
    }
    return json.decode(userDataString);
  }

  Future<void> FetchValData(String SearchTerm) async {
    if (SearchTerm.isEmpty) {
      FetchAllData();
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final String urlf = "$baseurl/main/category/$SearchTerm";
      final respons = await http.get(Uri.parse(urlf));
      if (respons.statusCode == 200) {
        setState(() {
          data = json.decode(respons.body);
          isLoading = false;
        });
      } else {
        print("Error: ${respons.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> FetchAllData() async {
    try {
      final String url = "$baseurl/main/category";
      final respons = await http.get(Uri.parse(url));
      if (respons.statusCode == 200) {
        data = json.decode(respons.body);
        setState(() {
          isLoading = false;
        });
      } else {
        print("Error: ${respons.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
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

  Future<void> DeleteCategory(String CID) async {
    setState(() {
      isLoading = true;
    });

    final employeeData = await _getEmployeeData();
    if (employeeData == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse("$baseurl/main/category/$CID"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "EmployeeID": employeeData['UID'],
          "EmployeeName": employeeData['UserFname']
        }),
      );

      if (response.statusCode == 200) {
        FetchAllData();
        final responseBody = json.decode(response.body);
        ShowSuccessMessage(
            responseBody['msg'] ?? "Category deleted successfully!");
      } else if (response.statusCode == 409) {
        final responseBody = json.decode(response.body);
        ShowErrorMessage(responseBody['message'] ??
            "Cannot delete: Category is still in use.");
      } else {
        final responseBody = json.decode(response.body);
        ShowErrorMessage(responseBody['msg'] ??
            "Failed to delete category. Status: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
      ShowErrorMessage("Failed to delete category: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void ShowDeleteConfirmation(String CID, String Cname) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                "ລຶບຂໍ້ມູນ",
                style: TextStyle(color: Color(0xFFE45C58)),
              ),
              content: Text("ກຳລັງລົບຂໍ້ມູນ '$Cname' ('$CID')"),
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
                    DeleteCategory(CID);
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
            ));
  }

  void ShowDataDialog({Map<String, dynamic>? CatData}) {
    if (CatData != null) {
      txtID.text = CatData['CategoryID'].toString();
      txtName.text = CatData['CategoryName'].toString();
      txtNewID.text = "";
      txtNewName.text = "";
    } else {
      clearAText();
    }

    Future<void> AddCategory() async {
      if (txtID.text.isEmpty || txtName.text.isEmpty) {
        ShowErrorMessage("All field are required!");
        return;
      }
      setState(() {
        isLoading = true;
      });
      final employeeData = await _getEmployeeData();
      if (employeeData == null) return;

      try {
        final response = await http.post(Uri.parse("$baseurl/main/category"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "CategoryID": txtID.text,
              "CategoryName": txtName.text,
              "EmployeeID": employeeData['UID'],
              "EmployeeName": employeeData['UserFname']
            }));
        setState(() {
          isLoading = false;
        });
        if (response.statusCode == 200) {
          ShowSuccessMessage("Category added successfully");
          clearAText();
          FetchAllData();
          Navigator.of(context).pop();
        } else {
          final respondBody = json.decode(response.body);
          ShowErrorMessage(respondBody['msg'] ??
              "Failed to add category. Status: ${response.statusCode}");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e);
        ShowErrorMessage("Failer to add category: ${e.toString()}");
      }
    }

    Future<void> UpdateCategory(String PID) async {
      if (txtID.text.isEmpty || txtName.text.isEmpty) {
        ShowErrorMessage("All field are required!");
        return;
      }
      setState(() {
        isLoading = true;
      });
      final employeeData = await _getEmployeeData();
      if (employeeData == null) return;

      try {
        final String CID = txtID.text;

        final response =
            await http.put(Uri.parse("$baseurl/main/category/${CID}"),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  "NewCategoryID": txtNewID.text,
                  "CategoryName": txtName.text,
                  "NewCategoryName": txtNewName.text,
                  "EmployeeID": employeeData['UID'],
                  "EmployeeName": employeeData['UserFname']
                }));
        setState(() {
          isLoading = false;
        });
        if (response.statusCode == 200) {
          clearAText();
          FetchAllData();
          Navigator.of(context).pop();
          final responseBody = json.decode(response.body);
          ShowSuccessMessage(
              responseBody['msg'] ?? "Category Updated successfully");
        } else {
          final respondBody = json.decode(response.body);
          ShowErrorMessage(respondBody['msg'] ??
              "Failed to update category. Status: ${response.statusCode}");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e);
        ShowErrorMessage("Failure to update category: ${e.toString()}");
      }
    }

    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                CatData != null ? "Update Category" : "Add Category",
                style: TextStyle(color: Color(0xFFE45C58)),
              ),
              content: Container(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 110,
                            child: TextField(
                              controller: txtID,
                              decoration: InputDecoration(
                                labelText: 'ID',
                                labelStyle: TextStyle(color: Colors.red),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Color(0xFFE45C58)),
                                ),
                              ),
                              enabled: CatData == null,
                            ),
                          ),
                          SizedBox(width: 5),
                          Container(
                            width: 250,
                            child: TextField(
                              controller: txtName,
                              decoration: InputDecoration(
                                labelText: 'ຊື່',
                                labelStyle: TextStyle(color: Colors.red),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Color(0xFFE45C58)),
                                ),
                              ),
                              enabled: CatData == null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 110,
                            child: TextField(
                              controller: txtNewID,
                              decoration: InputDecoration(
                                labelText: 'ID ໃໝ່',
                                labelStyle: TextStyle(
                                  color: CatData != null
                                      ? Colors.green.shade500
                                      : Colors.green.shade200,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Colors.green.shade500),
                                ),
                              ),
                              enabled: CatData != null,
                            ),
                          ),
                          SizedBox(width: 5),
                          Container(
                            width: 250,
                            child: TextField(
                              controller: txtNewName,
                              decoration: InputDecoration(
                                labelText: 'ຊື່ໃໝ່',
                                labelStyle: TextStyle(
                                  color: CatData != null
                                      ? Colors.green.shade500
                                      : Colors.green.shade200,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Colors.green.shade500),
                                ),
                              ),
                              enabled: CatData != null,
                            ),
                          ),
                        ],
                      ),
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
                    if (CatData != null) {
                      UpdateCategory(CatData['CategoryID'].toString());
                    } else {
                      AddCategory();
                    }
                  },
                  child: Text(CatData != null ? "ແກ້ໄຂ" : "ເພີ່ມ"),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFE45C58),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ));
  }

  void clearAText() {
    txtID.clear();
    txtName.clear();
    txtNewID.clear();
    txtNewName.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE45C58),
      appBar: AppBar(
        title: Text(
          'ຈັດການປະເພດສິນຄ້າ',
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
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) {
                if (txtSearch.text.isEmpty) {
                  FetchAllData();
                } else {
                  FetchValData(txtSearch.text);
                }
              },
              controller: txtSearch,
              decoration: InputDecoration(
                hintText: "ຄົ້ນຫາປະເພດສິນຄ້າ...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // Categories List
          Expanded(
            child: data.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final category = data[index];
                        return Card(
                          elevation: 3,
                          margin:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                                'ID: ${category['CategoryID']}',
                                style: TextStyle(
                                  color: Color(0xFFE45C58),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              '${category['CategoryName']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: Color(0xFFE45C58)),
                                  onPressed: () =>
                                      ShowDataDialog(CatData: category),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => ShowDeleteConfirmation(
                                    category['CategoryID'].toString(),
                                    category['CategoryName'].toString(),
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
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFE45C58),
      ),
    );
  }
}
