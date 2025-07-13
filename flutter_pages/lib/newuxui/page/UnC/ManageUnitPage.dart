import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
// import 'package:flutter_lect2/newuxui/DBpath.dart';
// import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ManageUnitPage extends StatefulWidget {
  const ManageUnitPage({super.key});

  @override
  State<ManageUnitPage> createState() => _UnitPageState();
}

basePath bp = basePath();
final String bpt = bp.bpath();

class _UnitPageState extends State<ManageUnitPage> {
  List data = [];
  final String baseurl =
      bpt; //localhost  /192.168.189.1 /ku http://192.168.189.224
  TextEditingController txtSearch = TextEditingController();
  TextEditingController txtID = TextEditingController();
  TextEditingController txtName = TextEditingController();
  TextEditingController txtNewID = TextEditingController();
  TextEditingController txtNewName = TextEditingController();
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
      ShowErrorMessage("ບໍ່ພົບຂໍ້ມູນຜູ້ໃຊ້, ກະລຸນາລັອກອິນໃໝ່");
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
      final String urlf = "$baseurl/main/unit/$SearchTerm";
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
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> FetchAllData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final String url = "$baseurl/main/unit";
      final respons = await http.get(Uri.parse(url));
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
      setState(() {
        isLoading = false;
      });
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

  Future<void> DeleteUnit(String UID) async {
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
        Uri.parse("$baseurl/main/unit/$UID"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "EmployeeID": employeeData['UID'],
          "EmployeeName": employeeData['UserFname']
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        ShowSuccessMessage(responseBody['msg'] ?? "Unit deleted successfully!");
        FetchAllData();
      } else if (response.statusCode == 409) {
        final responseBody = json.decode(response.body);
        ShowErrorMessage(
            responseBody['message'] ?? "Cannot delete: Unit is still in use.");
      } else {
        final responseBody = json.decode(response.body);
        ShowErrorMessage(responseBody['msg'] ??
            "Failed to delete unit. Status: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
      ShowErrorMessage("Failed to delete unit: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void ShowDeleteConfirmation(String UID, String Uname) {
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
              content: Text("ກຳລັງລົບຂໍ້ມູນ '$Uname' ('$UID')"),
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
                    DeleteUnit(UID);
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

  void ShowDataDialog({Map<String, dynamic>? UnitData}) {
    if (UnitData != null) {
      txtID.text = UnitData['UnitID'].toString();
      txtName.text = UnitData['UnitName'].toString();
      txtNewID.text = "";
      txtNewName.text = "";
    } else {
      clearAText();
    }

    Future<void> AddUnit() async {
      if (txtID.text.isEmpty || txtName.text.isEmpty) {
        ShowErrorMessage("Unit ID and Name are required!");
        return;
      }
      final employeeData = await _getEmployeeData();
      if (employeeData == null) return;
      setState(() {
        isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse("$baseurl/main/unit"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "UnitID": txtID.text,
            "UnitName": txtName.text,
            "EmployeeID": employeeData['UID'],
            "EmployeeName": employeeData['UserFname']
          }),
        );

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          ShowSuccessMessage("Unit added successfully");
          clearAText();
          FetchAllData();
          Navigator.of(context).pop();
        } else if (response.statusCode == 300) {
          ShowErrorMessage("This Unit already exists");
        } else {
          final respondBody = json.decode(response.body);
          ShowErrorMessage(respondBody['msg'] ??
              "Failed to add unit. Status: ${response.statusCode}");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e);
        ShowErrorMessage("Failed to add unit: ${e.toString()}");
      }
    }

    Future<void> UpdateUnit(String PID) async {
      if (txtID.text.isEmpty || txtName.text.isEmpty) {
        ShowErrorMessage("All field are required! (except green)");
        return;
      }
      final employeeData = await _getEmployeeData();
      if (employeeData == null) return;
      setState(() {
        isLoading = true;
      });

      try {
        final String UID = txtID.text;

        final response = await http.put(Uri.parse("$baseurl/main/unit/$UID"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "NewUnitID": txtNewID.text,
              "UnitName": txtName.text,
              "NewUnitName": txtNewName.text,
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
              responseBody['msg'] ?? "Unit Updated successfully");
        } else {
          final respondBody = json.decode(response.body);
          ShowErrorMessage(respondBody['msg'] ??
              "Failed to update unit. Status: ${response.statusCode}");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e);
        ShowErrorMessage("Failure to update unit: ${e.toString()}");
      }
    }

    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                UnitData != null ? "ແກ້ໄຂຫົວໜ່ວຍ" : "ເພີ່ມຫົວໜ່ວຍ",
                style: TextStyle(color: Color(0xFFE45C58)),
              ),
              content: Container(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (UnitData == null) ...[
                        // Add Mode
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: txtID,
                                decoration: InputDecoration(
                                  labelText: 'ID ຫົວໜ່ວຍ *',
                                  hintText: 'ປ້ອນ ID ຫົວໜ່ວຍ',
                                  labelStyle:
                                      TextStyle(color: Color(0xFFE45C58)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Color(0xFFE45C58)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: txtName,
                                decoration: InputDecoration(
                                  labelText: 'ຊື່ຫົວໜ່ວຍ *',
                                  hintText: 'ປ້ອນຊື່ຫົວໜ່ວຍ',
                                  labelStyle:
                                      TextStyle(color: Color(0xFFE45C58)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Color(0xFFE45C58)),
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
                                'ລາຍລະອຽດຫົວໜ່ວຍປັດຈຸບັນ',
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
                                    controller: txtID,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      labelText: ' ID ປັດຈຸບັນ',
                                      labelStyle:
                                          TextStyle(color: Colors.grey[600]),
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
                                    controller: txtName,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      labelText: 'ຊື່ປັດຈຸບັນ',
                                      labelStyle:
                                          TextStyle(color: Colors.grey[600]),
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
                                'ລາຍລະອຽດຫົວໜ່ວຍໃໝ່(ທາງເລືອກ:ປ່ອຍຫວ່າງໄວ້ຖ້າຕ້ອງການໃຊ້ຕົວເກົ່າ)',
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
                                    controller: txtNewID,
                                    decoration: InputDecoration(
                                      labelText: 'ID ໃໝ່',
                                      hintText: 'ປ້ອນ ID ຫົວໜ່ວຍໃໝ່',
                                      labelStyle:
                                          TextStyle(color: Colors.green),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            BorderSide(color: Colors.green),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: txtNewName,
                                    decoration: InputDecoration(
                                      labelText: 'ຊື່ໃໝ່',
                                      hintText: 'ປ້ອນຊື່ໃໝ່',
                                      labelStyle:
                                          TextStyle(color: Colors.green),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            BorderSide(color: Colors.green),
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
                    if (UnitData != null) {
                      UpdateUnit(UnitData['UnitID'].toString());
                    } else {
                      AddUnit();
                    }
                  },
                  child: Text(UnitData != null ? "ແກ້ໄຂ" : "ເພີ່ມ"),
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
        title: Text('ຈັດການຫົວໜ່ວຍ'),
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
                hintText: "ຄົ້ນຫາ ຫົວໜ່ວຍ...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // Units List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : data.isEmpty
                    ? Center(
                        child: Text(
                          "ບໍ່ພົບຫົວໜ່ວຍ",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final unit = data[index];
                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
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
                                    'ID: ${unit['UnitID']}',
                                    style: TextStyle(
                                      color: Color(0xFFE45C58),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '${unit['UnitName']}',
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
                                          ShowDataDialog(UnitData: unit),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => ShowDeleteConfirmation(
                                        unit['UnitID'].toString(),
                                        unit['UnitName'].toString(),
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
