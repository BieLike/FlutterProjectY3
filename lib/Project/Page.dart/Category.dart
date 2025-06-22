import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_lect2/Project/Component/Drawer.dart';
import 'package:http/http.dart' as http;

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List data = [];
  final String baseurl =
      "http://192.168.189.224:3000"; //localhost  /pe 192.168.189.1 /ku http://192.168.189.224
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

    try {
      List check = [];
      final confirm = await http.get(
        Uri.parse("$baseurl/main/product/$CID"),
      );
      if (confirm.statusCode == 200) {
        check = json.decode(confirm.body);
        if (check.isNotEmpty) {
          ShowErrorMessage("Still in use ");
        }
      } else if (confirm.statusCode == 300) {
        final response = await http.delete(
          Uri.parse("$baseurl/main/category/$CID"),
          headers: {'Content-Type': 'application/json'},
        );

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          FetchAllData();
          final responseBody = json.decode(response.body);
          ShowSuccessMessage(
              responseBody['msg'] ?? "Category deleted successfully!");
        } else {
          final responseBody = json.decode(response.body);
          ShowErrorMessage(responseBody['msg'] ??
              "Failed to delete Category. Status: ${response.statusCode}");
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      ShowErrorMessage("Failed to delete category: ${e.toString()}");
    }
  }

  void ShowDeleteConfirmation(String CID, String Cname) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Delete confirmation"),
              content: Text("You now deleting '$Cname' ('$CID')"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    DeleteCategory(CID);
                  },
                  child: Text("Delete"),
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

      try {
        final response = await http.post(Uri.parse("$baseurl/main/category"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "CategoryID": txtID.text,
              "CategoryName": txtName.text,
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

      try {
        final String CID = txtID.text;

        final response =
            await http.put(Uri.parse("$baseurl/main/category/${CID}"),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  "NewCategoryID": txtNewID.text,
                  "CategoryName": txtName.text,
                  "NewCategoryName": txtNewName.text,
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
              title: Text(CatData != null ? "Update" : "Add"),
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
                            enabled: CatData == null,
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
                            enabled: CatData == null,
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
                                color: CatData != null
                                    ? Colors.green.shade500
                                    : Colors.green.shade200,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            enabled: CatData != null,
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
                                color: CatData != null
                                    ? Colors.green.shade500
                                    : Colors.green.shade200,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            enabled: CatData != null,
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
                    if (CatData != null) {
                      UpdateCategory(CatData['CategoryID'].toString());
                    } else {
                      AddCategory();
                    }
                  },
                  child: Text(CatData != null ? "Update" : "Add"),
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
              child: Text('Category'),
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
                    hintText: "Search",
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
                        '    ID: \n${getdata['CategoryID']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                            color: Colors.red),
                      ),
                    ),
                    title: Text(
                      '${getdata['CategoryName']}',
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
                              ShowDataDialog(CatData: getdata);
                            },
                            icon: Icon(Icons.edit,
                                size: 25, color: Colors.green)),
                        IconButton(
                            onPressed: () {
                              ShowDeleteConfirmation(
                                  getdata['CategoryID'].toString(),
                                  getdata['CategoryName'].toString());
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
