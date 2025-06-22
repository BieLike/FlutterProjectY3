import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_lect2/Project/Component/Drawer.dart';
import 'package:http/http.dart' as http;

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List data = [];
  List Udata = [];
  List Cdata = [];
  String? selectedUnit;
  String? selectedCategory;
  final String baseurl =
      "http://192.168.189.224:3000"; //localhost  /pe 192.168.189.1 /ku http://192.168.189.224
  TextEditingController txtSearch = TextEditingController();
  TextEditingController txtID = TextEditingController();
  TextEditingController txtName = TextEditingController();
  TextEditingController txtNewID = TextEditingController();
  TextEditingController txtNewName = TextEditingController();
  TextEditingController txtQty = TextEditingController();
  TextEditingController txtImP = TextEditingController();
  TextEditingController txtSP = TextEditingController();
  TextEditingController txtBal = TextEditingController();
  TextEditingController txtLvl = TextEditingController();
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
      final String urlf = "$baseurl/main/product/$SearchTerm";
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
      final String url = "$baseurl/main/product";
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
    }
  }

  Future<void> FetchCategoryData() async {
    try {
      final String url = "$baseurl/main/category";
      final respons = await http.get(Uri.parse(url));
      if (respons.statusCode == 200) {
        setState(() {
          Cdata = json.decode(respons.body);
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

  Future<void> FetchUnitData() async {
    try {
      final String url = "$baseurl/main/unit";
      final respons = await http.get(Uri.parse(url));
      if (respons.statusCode == 200) {
        setState(() {
          Udata = json.decode(respons.body);
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

  Future<void> DeleteProduct(String PID) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.delete(
        Uri.parse("$baseurl/main/product/$PID"),
        headers: {'Content-Type': 'application/json'},
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        FetchAllData();
        final responseBody = json.decode(response.body);
        ShowSuccessMessage(
            responseBody['msg'] ?? "Product deleted successfully!");
      } else {
        final responseBody = json.decode(response.body);
        ShowErrorMessage(responseBody['msg'] ??
            "Failed to delete Product. Status: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      ShowErrorMessage("Failed to delete product: ${e.toString()}");
    }
  }

  void ShowDeleteConfirmation(String PID, String Pname) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Delete confirmation"),
              content: Text("You now deleting '$Pname' ('$PID')"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    DeleteProduct(PID);
                  },
                  child: Text("Delete"),
                )
              ],
            ));
  }

  void ShowDataDialog({Map<String, dynamic>? ProductData}) async {
    await FetchUnitData();
    await FetchCategoryData();
    if (ProductData != null) {
      txtID.text = ProductData['ProductID'].toString();
      txtNewID.text = "";
      txtName.text = ProductData['ProductName'].toString();
      txtNewName.text = "";
      txtQty.text = ProductData['Quantity'].toString();
      txtImP.text = ProductData['ImportPrice'].toString();
      txtSP.text = ProductData['SellPrice'].toString();
      selectedUnit = ProductData['UnitID'].toString();
      selectedCategory = ProductData['CategoryID'].toString();
      txtBal.text = ProductData['Balance'].toString();
      txtLvl.text = ProductData['Level'].toString();
    } else {
      clearAText();
    }

    Future<void> AddProduct() async {
      if (txtID.text.isEmpty ||
          txtName.text.isEmpty ||
          txtQty.text.isEmpty ||
          txtImP.text.isEmpty ||
          txtSP.text.isEmpty ||
          selectedUnit == null ||
          selectedCategory == null ||
          txtBal.text.isEmpty ||
          txtLvl.text.isEmpty) {
        ShowErrorMessage("All field are required! (Except green)");
        return;
      }
      setState(() {
        isLoading = true;
      });

      try {
        final int Qty = int.tryParse(txtQty.text) ?? 0;
        final double ImP = double.tryParse(txtImP.text) ?? 0.0;
        final double SP = double.tryParse(txtSP.text) ?? 0.0;
        final int Bal = int.tryParse(txtBal.text) ?? 0;
        final int Lvl = int.tryParse(txtLvl.text) ?? 0;

        final response = await http.post(Uri.parse("$baseurl/main/product"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "ProductID": txtID.text,
              "ProductName": txtName.text,
              "Quantity": Qty,
              "ImportPrice": ImP,
              "SellPrice": SP,
              "UnitID": selectedUnit,
              "CategoryID": selectedCategory,
              "Balance": Bal,
              "Level": Lvl,
            }));
        setState(() {
          isLoading = false;
        });
        if (response.statusCode == 200) {
          ShowSuccessMessage("Product added successfully");
          clearAText();
          FetchAllData();
          Navigator.of(context).pop();
        } else {
          final respondBody = json.decode(response.body);
          ShowErrorMessage(respondBody['msg'] ??
              "Failed to add Product. Status: ${response.statusCode}");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e);
        ShowErrorMessage("Failer to add Product: ${e.toString()}");
      }
    }

    Future<void> UpdateProduct(String PID) async {
      if (txtID.text.isEmpty ||
          txtName.text.isEmpty ||
          txtQty.text.isEmpty ||
          txtImP.text.isEmpty ||
          txtSP.text.isEmpty ||
          selectedUnit == null ||
          selectedCategory == null ||
          txtBal.text.isEmpty ||
          txtLvl.text.isEmpty) {
        ShowErrorMessage("All field are required! (Except green)");
        return;
      }
      setState(() {
        isLoading = true;
      });

      try {
        final int Qty = int.tryParse(txtQty.text) ?? 0;
        final double ImP = double.tryParse(txtImP.text) ?? 0.0;
        final double SP = double.tryParse(txtSP.text) ?? 0.0;
        final int Bal = int.tryParse(txtBal.text) ?? 0;
        final int Lvl = int.tryParse(txtLvl.text) ?? 0;
        final String ProID = txtID.text;

        final response =
            await http.put(Uri.parse("$baseurl/main/product/${ProID}"),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  "NewProductID": txtNewID.text,
                  "ProductName": txtName.text,
                  "NewProductName": txtNewName.text,
                  "Quantity": Qty,
                  "ImportPrice": ImP,
                  "SellPrice": SP,
                  "UnitID": selectedUnit,
                  "CategoryID": selectedCategory,
                  "Balance": Bal,
                  "Level": Lvl,
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
              responseBody['msg'] ?? "Product Updated successfully");
        } else {
          final respondBody = json.decode(response.body);
          ShowErrorMessage(respondBody['msg'] ??
              "Failed to update Product. Status: ${response.statusCode}");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e);
        ShowErrorMessage("Failure to update Product: ${e.toString()}");
      }
    }

    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text(ProductData != null ? "Update" : "Add"),
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
                              labelStyle: TextStyle(
                                color: Colors.red,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            enabled: ProductData == null,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: TextField(
                            controller: txtName,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(
                                color: Colors.red,
                              ),
                              enabled: ProductData == null,
                              border: OutlineInputBorder(),
                            ),
                            enabled: ProductData == null,
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
                              labelText: 'New ID ',
                              labelStyle: TextStyle(
                                color: ProductData != null
                                    ? Colors.green.shade500
                                    : Colors.green.shade200,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            enabled: ProductData != null,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: TextField(
                            controller: txtNewName,
                            decoration: InputDecoration(
                              labelText: 'New Name',
                              labelStyle: TextStyle(
                                color: ProductData != null
                                    ? Colors.green.shade500
                                    : Colors.green.shade200,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            enabled: ProductData != null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: txtQty,
                            decoration: InputDecoration(
                              labelText: 'Qty',
                              labelStyle: TextStyle(
                                color: Colors.red,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: TextField(
                            controller: txtImP,
                            decoration: InputDecoration(
                              labelText: 'ImportPrice',
                              labelStyle: TextStyle(
                                color: Colors.red,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: TextField(
                            controller: txtSP,
                            decoration: InputDecoration(
                              labelText: 'SellPrice',
                              labelStyle: TextStyle(
                                color: Colors.red,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Unit',
                                  labelStyle: TextStyle(
                                    color: Colors.red,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                value: selectedUnit,
                                items:
                                    Udata.map<DropdownMenuItem<String>>((unit) {
                                  return DropdownMenuItem<String>(
                                      value: unit['UnitID'].toString(),
                                      child: Text(unit['UnitName']));
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedUnit = value;
                                    //txtUnit.text = value ?? '';
                                  });
                                })),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                            child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                    labelText: 'Category',
                                    labelStyle: TextStyle(
                                      color: Colors.red,
                                    ),
                                    border: OutlineInputBorder()),
                                value: selectedCategory,
                                items:
                                    Cdata.map<DropdownMenuItem<String>>((cat) {
                                  return DropdownMenuItem<String>(
                                      value: cat['CategoryID'].toString(),
                                      child: Text(cat['CategoryName']));
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value;
                                    //txtCat.text = value ?? '';
                                  });
                                })),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: txtBal,
                            decoration: InputDecoration(
                              labelText: 'Balance',
                              labelStyle: TextStyle(
                                color: Colors.red,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: TextField(
                            controller: txtLvl,
                            decoration: InputDecoration(
                              labelText: 'Level',
                              labelStyle: TextStyle(
                                color: Colors.red,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
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
                    if (ProductData != null) {
                      UpdateProduct(ProductData['ProductID'].toString());
                    } else {
                      AddProduct();
                    }
                  },
                  child: Text(ProductData != null ? "Update" : "Add"),
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
    txtQty.clear();
    txtImP.clear();
    txtSP.clear();
    txtNewName.clear();
    txtNewID.clear();
    selectedUnit == null;
    selectedCategory == null;
    txtBal.clear();
    txtLvl.clear();
    selectedUnit = null;
    selectedCategory = null;
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
              child: Text('Product'),
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
                        '    ID: \n${getdata['ProductID']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                            color: Colors.red),
                      ),
                    ),
                    title: Text(
                      '${getdata['ProductName']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.orange,
                      ),
                    ),
                    subtitle: Text(
                      'Qty: ${getdata['Quantity']}, Price: ${getdata['SellPrice']}, Unit: ${getdata['UnitName']}, Balance: ${getdata['Balance']}, Level: ${getdata['Level']}  ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.green,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {
                              ShowDataDialog(ProductData: getdata);
                            },
                            icon: Icon(Icons.edit,
                                size: 25, color: Colors.green)),
                        IconButton(
                            onPressed: () {
                              ShowDeleteConfirmation(
                                  getdata['ProductID'].toString(),
                                  getdata['ProductName'].toString());
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
