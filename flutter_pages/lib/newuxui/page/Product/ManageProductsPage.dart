import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/page/product/addedit_page.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  List data = [];
  final String baseurl = basePath().bpath();
  TextEditingController txtSearch = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$baseurl/main/product"));
      if (response.statusCode == 200 && mounted) {
        setState(() => data = json.decode(response.body));
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> fetchValData(String searchTerm) async {
    if (searchTerm.isEmpty) {
      fetchAllData();
      return;
    }
    setState(() => isLoading = true);
    try {
      final response =
          await http.get(Uri.parse("$baseurl/main/product/$searchTerm"));
      if (response.statusCode == 200 && mounted) {
        setState(() => data = json.decode(response.body));
      } else if (mounted) {
        setState(() => data = []);
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> deleteProduct(String pID) async {
    final employeeData = await _getEmployeeData();
    if (employeeData == null) return;

    setState(() => isLoading = true);
    try {
      final response = await http.delete(
        Uri.parse("$baseurl/main/product/$pID"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "EmployeeID": employeeData['UID'],
          "EmployeeName": employeeData['UserFname']
        }),
      );
      if (response.statusCode == 200) {
        showSuccessMessage("Product deleted successfully!");
        await fetchAllData();
      } else {
        final body = json.decode(response.body);
        showErrorMessage(body['message'] ?? body['msg'] ?? "Failed to delete");
      }
    } catch (e) {
      showErrorMessage("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showDeleteConfirmation(String pID, String pName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("ຢືນຢັນການລົບ"),
        content: Text("ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການລົບ '$pName'?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("ຍົກເລີກ")),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteProduct(pID);
            },
            child: Text("ລົບ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> navigateToAddEditPage(
      {Map<String, dynamic>? productData}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductPage(productData: productData),
      ),
    );
    if (result == true) {
      fetchAllData();
    }
  }

  Future<Map<String, dynamic>?> _getEmployeeData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString == null) {
      showErrorMessage("User data not found. Please log in again.");
      return null;
    }
    return json.decode(userDataString);
  }

  void showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

    return Scaffold(
      backgroundColor: Color(0xFFE45C58),
      appBar: AppBar(
        title: Text(
          'ຈັດການປຶ້ມ',
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: fetchValData,
              controller: txtSearch,
              decoration: InputDecoration(
                hintText: "ຄົ້ນหาປຶ້ມ...",
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : data.isEmpty
                    ? Center(child: Text("No products found"))
                    : GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final product = data[index];
                          final imageUrl = product['ProductImageURL'] != null
                              ? baseurl + product['ProductImageURL']
                              : null;

                          return Card(
                            elevation: 3,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    color: Colors.grey[200],
                                    child: imageUrl != null &&
                                            imageUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2)),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey),
                                          )
                                        : Icon(Icons.inventory_2_outlined,
                                            size: 40, color: Colors.grey[400]),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${product['ProductName']}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        // [ADD] เพิ่มการแสดงจำนวนหน้า
                                        Row(
                                          children: [
                                            Icon(Icons.menu_book,
                                                size: 12,
                                                color: Colors.grey[600]),
                                            SizedBox(width: 4),
                                            Text(
                                              '${product['Bpage'] ?? 'N/A'} ໜ້າ',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[700]),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'ຜູ້ແຕ່ງ: ${product['AuthorName'] ?? 'N/A'}',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey[700]),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                'ຈຳນວນ: ${product['Quantity']}',
                                                style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 12)),
                                            Text('${product['SellPrice']} LAK',
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13)),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              onPressed: () =>
                                                  navigateToAddEditPage(
                                                      productData: product),
                                              icon: Icon(Icons.edit_outlined,
                                                  color: Colors.blue.shade700,
                                                  size: 20),
                                              tooltip: 'ແກ້ໄຂ',
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  showDeleteConfirmation(
                                                product['ProductID'].toString(),
                                                product['ProductName']
                                                    .toString(),
                                              ),
                                              icon: Icon(Icons.delete_outline,
                                                  color: Colors.red.shade700,
                                                  size: 20),
                                              tooltip: 'ລົບ',
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
