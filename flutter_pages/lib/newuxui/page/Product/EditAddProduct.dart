import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:http/http.dart' as http;

class AddEditProductPage extends StatefulWidget {
  final Map<String, dynamic>? productData;

  const AddEditProductPage({super.key, this.productData});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  basePath bp = basePath();
  late final String baseurl;

  List Udata = [];
  List Cdata = [];
  List Adata = [];
  String? selectedUnit;
  String? selectedCategory;
  String? selectedAuthor;
  bool isLoading = false;

  TextEditingController txtID = TextEditingController();
  TextEditingController txtName = TextEditingController();
  TextEditingController txtNewID = TextEditingController();
  TextEditingController txtNewName = TextEditingController();
  TextEditingController txtQty = TextEditingController();
  TextEditingController txtImP = TextEditingController();
  TextEditingController txtSP = TextEditingController();
  TextEditingController txtBal = TextEditingController();
  TextEditingController txtLvl = TextEditingController();

  @override
  void initState() {
    super.initState();
    baseurl = bp.bpath();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait(
        [FetchUnitData(), FetchCategoryData(), FetchAuthorData()]);

    if (widget.productData != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final data = widget.productData!;
    txtID.text = data['ProductID'].toString();
    txtName.text = data['ProductName'].toString();
    txtQty.text = data['Quantity'].toString();
    txtImP.text = data['ImportPrice'].toString();
    txtSP.text = data['SellPrice'].toString();
    selectedUnit = data['UnitID'].toString();
    selectedCategory = data['CategoryID'].toString();
    selectedAuthor = data['authorsID'].toString();
    txtBal.text = data['Balance'].toString();
    txtLvl.text = data['Level'].toString();
  }

  Future<void> FetchCategoryData() async {
    try {
      final String url = "$baseurl/main/category";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          Cdata = json.decode(response.body);
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> FetchAuthorData() async {
    try {
      final String url = "$baseurl/main/author";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          Adata = json.decode(response.body);
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> FetchUnitData() async {
    try {
      final String url = "$baseurl/main/unit";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          Udata = json.decode(response.body);
        });
      } else {
        print("Error: ${response.statusCode}");
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

  Future<void> AddProduct() async {
    if (txtID.text.isEmpty ||
        txtName.text.isEmpty ||
        txtQty.text.isEmpty ||
        txtImP.text.isEmpty ||
        txtSP.text.isEmpty ||
        selectedUnit == null ||
        selectedCategory == null ||
        selectedAuthor == null ||
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

      final response = await http.post(
        Uri.parse("$baseurl/main/product"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "ProductID": txtID.text,
          "ProductName": txtName.text,
          "Quantity": Qty,
          "ImportPrice": ImP,
          "SellPrice": SP,
          "UnitID": selectedUnit,
          "CategoryID": selectedCategory,
          "Authors": selectedAuthor,
          "Balance": Bal,
          "Level": Lvl,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        ShowSuccessMessage("Product added successfully");
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        final responseBody = json.decode(response.body);
        ShowErrorMessage(responseBody['msg'] ??
            "Failed to add Product. Status: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      ShowErrorMessage("Failed to add Product: ${e.toString()}");
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
        selectedAuthor == null ||
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

      final response = await http.put(
        Uri.parse("$baseurl/main/product/$PID"),
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
          "Authors": selectedAuthor,
          "Balance": Bal,
          "Level": Lvl,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        ShowSuccessMessage(
            responseBody['msg'] ?? "Product Updated successfully");
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        final responseBody = json.decode(response.body);
        ShowErrorMessage(responseBody['msg'] ??
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

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.productData != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'ແກ້ໄຂສິນຄ້າ' : 'ເພີ່ມສິນຄ້າ'),
        backgroundColor: Color(0xFFE45C58),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ID and Name Row
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
                          enabled: !isEditMode,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: txtName,
                          decoration: InputDecoration(
                            labelText: 'ຊື່',
                            labelStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          enabled: !isEditMode,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // New ID and New Name Row (only for edit mode)
                  if (isEditMode) ...[
                    Row(
                      children: [
                        Container(
                          width: 110,
                          child: TextField(
                            controller: txtNewID,
                            decoration: InputDecoration(
                              labelText: 'ID ໃໝ່',
                              labelStyle:
                                  TextStyle(color: Colors.green.shade500),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: txtNewName,
                            decoration: InputDecoration(
                              labelText: 'ຊື່ໃໝ່',
                              labelStyle:
                                  TextStyle(color: Colors.green.shade500),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],

                  // Quantity, Import Price, Sell Price Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: txtQty,
                          decoration: InputDecoration(
                            labelText: 'ຈຳນວນ',
                            labelStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: txtImP,
                          decoration: InputDecoration(
                            labelText: 'ລາຄານຳເຂົ້າ',
                            labelStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: txtSP,
                          decoration: InputDecoration(
                            labelText: 'ລາຄາຂາຍ',
                            labelStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Unit and Category Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'ຫົວໜ່ວຍ',
                            labelStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          value: selectedUnit,
                          items: Udata.map<DropdownMenuItem<String>>((unit) {
                            return DropdownMenuItem<String>(
                              value: unit['UnitID'].toString(),
                              child: Text(unit['UnitName']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedUnit = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'ປະເພດ',
                            labelStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          value: selectedCategory,
                          items: Cdata.map<DropdownMenuItem<String>>((cat) {
                            return DropdownMenuItem<String>(
                              value: cat['CategoryID'].toString(),
                              child: Text(cat['CategoryName']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'ຜູ້ແຕ່ງ',
                            labelStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          value: selectedAuthor,
                          items: Adata.map<DropdownMenuItem<String>>((Au) {
                            return DropdownMenuItem<String>(
                              value: Au['authorID'].toString(),
                              child: Text(Au['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedAuthor = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Balance and Level Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: txtBal,
                          decoration: InputDecoration(
                            labelText: 'ຍອດລວມຈຳນວນການນຳເຂົ້າ',
                            labelStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: txtLvl,
                          decoration: InputDecoration(
                            labelText: 'ຈຳນວນຂັ້ນຕໍ່າຂອງສິນຄ້າທີ່ຄວນມີ',
                            labelStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('ຍົກເລີກ'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Color(0xFFE45C58)),
                            foregroundColor: Color(0xFFE45C58),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (isEditMode) {
                                    UpdateProduct(widget
                                        .productData!['ProductID']
                                        .toString());
                                  } else {
                                    AddProduct();
                                  }
                                },
                          child: Text(isEditMode ? 'ອັບເດດ' : 'ເພີ່ມ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE45C58),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    txtID.dispose();
    txtName.dispose();
    txtNewID.dispose();
    txtNewName.dispose();
    txtQty.dispose();
    txtImP.dispose();
    txtSP.dispose();
    txtBal.dispose();
    txtLvl.dispose();
    super.dispose();
  }
}
