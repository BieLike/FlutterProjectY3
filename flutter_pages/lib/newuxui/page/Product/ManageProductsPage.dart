import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/page/Product/EditAddProduct.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ProductPageState();
}

basePath bp = basePath();
final String bpt = bp.bpath();

class _ProductPageState extends State<ManageProductsPage> {
  List data = [];
  final String baseurl = bpt;
  TextEditingController txtSearch = TextEditingController();
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
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                )
              ],
            ));
  }

  // Navigate to AddEditProductPage
  Future<void> navigateToAddEditPage(
      {Map<String, dynamic>? productData}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductPage(productData: productData),
      ),
    );

    // If the operation was successful, refresh the data
    if (result == true) {
      FetchAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2; // Default for small screens

    if (screenWidth > 600 && screenWidth <= 900) {
      crossAxisCount = 3;
    } else if (screenWidth > 900) {
      crossAxisCount = 4;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ຈັດການສິນຄ້າ'),
        backgroundColor: Color(0xFFE45C58),
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
                hintText: "ຄົ້ນຫາສິນຄ້າ...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // Product Grid
          Expanded(
            child: data.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final product = data[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xFFE45C58).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'ID: ${product['ProductID']}',
                                        style: TextStyle(
                                          color: Color(0xFFE45C58),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Color(0xFFE45C58),
                                              size: 20),
                                          onPressed: () =>
                                              navigateToAddEditPage(
                                                  productData: product),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red, size: 20),
                                          onPressed: () =>
                                              ShowDeleteConfirmation(
                                            product['ProductID'].toString(),
                                            product['ProductName'].toString(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${product['ProductName']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'ຈຳນວນ: ${product['Quantity']}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'ລາຄາ: \$${product['SellPrice']}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'ຫົວໜ່ວຍ: ${product['UnitName'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'ຍອດລວມຈຳນວນການນຳເຂົ້າ: ${product['Balance']}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'ຈຳນວນຂັ້ນຕໍ່າຂອງສິນຄ້າທີ່ຄວນມີ: ${product['Level']}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
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
        onPressed: () => navigateToAddEditPage(),
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFE45C58),
      ),
    );
  }
}
