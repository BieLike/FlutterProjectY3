import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_lect2/Project/Component/Drawer.dart';
import 'package:http/http.dart' as http;

class UnitPage extends StatefulWidget {
  const UnitPage({super.key});

  @override
  State<UnitPage> createState() => _UnitPageState();
}

class _UnitPageState extends State<UnitPage> {
  List data = [];
  final String baseurl =
      "http://192.168.189.224:3000"; //localhost  /192.168.189.1 /ku http://192.168.189.224
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
    }
  }

  Future<void> FetchAllData() async {
    try {
      final String url = "$baseurl/main/unit";
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

  Future<void> DeleteUnit(String UID) async {
    setState(() {
      isLoading = true;
    });

    try {
      List check = [];
      final confirm = await http.get(
        Uri.parse("$baseurl/main/product/$UID"),
      );
      if (confirm.statusCode == 200) {
        check = json.decode(confirm.body);
        if (check.length > 0) {
          ShowErrorMessage("Still in use ");
        }
      } else if (confirm.statusCode == 300) {
        final response = await http.delete(
          Uri.parse("$baseurl/main/unit/$UID"),
          headers: {'Content-Type': 'application/json'},
        );

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          FetchAllData();
          final responseBody = json.decode(response.body);
          ShowSuccessMessage(
              responseBody['msg'] ?? "Unit deleted successfully!");
        } else {
          final responseBody = json.decode(response.body);
          ShowErrorMessage(responseBody['msg'] ??
              "Failed to delete unit. Status: ${response.statusCode}");
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      ShowErrorMessage("Failed to delete unit: ${e.toString()}");
    }
  }

  void ShowDeleteConfirmation(String UID, String Uname) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Delete confirmation"),
              content: Text("You now deleting '$Uname' ('$UID')"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    DeleteUnit(UID);
                  },
                  child: Text("Delete"),
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
        ShowErrorMessage("All field are required!");
        return;
      }
      setState(() {
        isLoading = true;
      });

      try {
        final response = await http.post(Uri.parse("$baseurl/main/unit"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "UnitID": txtID.text,
              "UnitName": txtName.text,
            }));
        setState(() {
          isLoading = false;
        });
        if (response.statusCode == 200) {
          ShowSuccessMessage("Unit added successfully");
          clearAText();
          FetchAllData();
          Navigator.of(context).pop();
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
        ShowErrorMessage("Failer to add unit: ${e.toString()}");
      }
    }

    Future<void> UpdateUnit(String PID) async {
      if (txtID.text.isEmpty || txtName.text.isEmpty) {
        ShowErrorMessage("All field are required! (except green)");
        return;
      }
      setState(() {
        isLoading = true;
      });

      try {
        final String UID = txtID.text;

        final response = await http.put(Uri.parse("$baseurl/main/unit/${UID}"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "NewUnitID": txtNewID.text,
              "UnitName": txtName.text,
              "NewUnitName": txtNewName.text,
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
              title: Text(UnitData != null ? "Update" : "Add"),
              content: Container(
                width: 400,
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
                              border: OutlineInputBorder(),
                            ),
                            enabled: UnitData == null,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          width: 250,
                          child: TextField(
                            controller: txtName,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(color: Colors.red),
                              border: OutlineInputBorder(),
                            ),
                            enabled: UnitData == null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 110,
                          child: TextField(
                            controller: txtNewID,
                            decoration: InputDecoration(
                              labelText: 'New ID',
                              labelStyle: TextStyle(
                                color: UnitData != null
                                    ? Colors.green.shade500
                                    : Colors.green.shade200,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            enabled: UnitData != null,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          width: 250,
                          child: TextField(
                            controller: txtNewName,
                            decoration: InputDecoration(
                              labelText: 'New Name',
                              labelStyle: TextStyle(
                                color: UnitData != null
                                    ? Colors.green.shade500
                                    : Colors.green.shade200,
                              ),
                              border: OutlineInputBorder(),
                              enabled: UnitData != null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    clearAText();
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (UnitData != null) {
                      UpdateUnit(UnitData['UnitID'].toString());
                    } else {
                      AddUnit();
                    }
                  },
                  child: Text(UnitData != null ? "Update" : "Add"),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 60, 0),
              child: Text('Unit'),
            ),
          ],
        ),
        leading: Builder(
          builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu)),
        ),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Padding(
              padding: EdgeInsets.all(10),
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
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25))),
              ),
            )),
        backgroundColor: Colors.green[500],
      ),
      drawer: DrawerTab(),
      body: Center(
        child: data.isEmpty
            ? CircularProgressIndicator()
            : Expanded(
                child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (c, indx) {
                  final getdata = data[indx];
                  return ListTile(
                    leading: Container(
                      width: 50,
                      child: Text(
                        '    ID: \n${getdata['UnitID']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                            color: Colors.red),
                      ),
                    ),
                    title: Text(
                      '${getdata['UnitName']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.orange,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {
                              ShowDataDialog(UnitData: getdata);
                            },
                            icon: Icon(Icons.edit,
                                size: 25, color: Colors.green)),
                        IconButton(
                            onPressed: () {
                              ShowDeleteConfirmation(
                                  getdata['UnitID'].toString(),
                                  getdata['UnitName'].toString());
                            },
                            icon:
                                Icon(Icons.delete, size: 25, color: Colors.red))
                      ],
                    ),
                  );
                },
              )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ShowDataDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
