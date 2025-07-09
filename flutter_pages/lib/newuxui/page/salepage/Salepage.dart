import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/page/salepage/Payment_page.dart';
import 'package:flutter_lect2/newuxui/widget/app_drawer.dart';
import 'package:http/http.dart' as http;

class SalePage extends StatefulWidget {
  const SalePage({Key? key}) : super(key: key);

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  // --- State ---
  final String baseUrl = basePath().bpath();
  bool isLoading = true;
  List allProducts = [];
  List displayedProducts = [];
  List cartItems = [];
  double totalAmount = 0;

  TextEditingController searchController = TextEditingController();
  List allCategories = [];
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // --- Data Fetching ---
  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    await Future.wait([_fetchProducts(), _fetchCategories()]);
    setState(() => isLoading = false);
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/main/product"));
      if (response.statusCode == 200) {
        allProducts = json.decode(response.body);
        _filterProducts();
      }
    } catch (e) {
      _showFeedback("Error fetching products: $e", isError: true);
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/main/category"));
      if (response.statusCode == 200) {
        allCategories = json.decode(response.body);
      }
    } catch (e) {
      _showFeedback("Error fetching categories: $e", isError: true);
    }
  }

  // --- Filtering ---
  void _filterProducts() {
    setState(() {
      displayedProducts = allProducts.where((product) {
        final bool categoryMatch =
            selectedCategoryId == null ||
            product['CategoryID'] == selectedCategoryId;
        final bool searchMatch =
            searchController.text.isEmpty ||
            product['ProductName'].toString().toLowerCase().contains(
              searchController.text.toLowerCase(),
            );
        return categoryMatch && searchMatch;
      }).toList();
    });
  }

  // --- Cart Management ---
  void addToCart(Map<String, dynamic> product) {
    if ((product['Quantity'] ?? 0) <= 0) {
      _showFeedback("ສິນຄ້າໝົດແລ້ວ", isError: true);
      return;
    }

    setState(() {
      int existingIndex = cartItems.indexWhere(
        (item) => item['ProductID'] == product['ProductID'],
      );

      if (existingIndex >= 0) {
        if (cartItems[existingIndex]['quantity'] < product['Quantity']) {
          cartItems[existingIndex]['quantity']++;
          _showFeedback("ເພີ່ມ ${product['ProductName']} ລົງໃນກະຕ່າ");
        } else {
          _showFeedback("ບໍ່ສາມາດເພີ່ມໄດ້, ສິນຄ້າໃນສະຕັອກບໍ່ພໍ", isError: true);
        }
      } else {
        cartItems.add({...product, 'quantity': 1});
        _showFeedback("ເພີ່ມ ${product['ProductName']} ລົງໃນກະຕ່າ");
      }
      _calculateTotal();
    });
  }

  void incrementItem(int index, {StateSetter? updater}) {
    setState(() {
      if (cartItems[index]['quantity'] < cartItems[index]['Quantity']) {
        cartItems[index]['quantity']++;
        _calculateTotal();
        // ອັບເດດ UI ຂອງ Bottom Sheet ຖ້າມີ
        updater?.call(() {});
      } else {
        _showFeedback("ສິນຄ້າໃນສະຕັອກບໍ່ພໍ", isError: true);
      }
    });
  }

  void decrementItem(int index, {StateSetter? updater}) {
    setState(() {
      if (cartItems[index]['quantity'] > 1) {
        cartItems[index]['quantity']--;
      } else {
        cartItems.removeAt(index);
      }
      _calculateTotal();
      updater?.call(() {});
    });
  }

  void _calculateTotal() {
    totalAmount = cartItems.fold(0.0, (sum, item) {
      return sum + ((item['SellPrice'] ?? 0.0) * (item['quantity'] ?? 0));
    });
  }

  void _proceedToPayment() {
    if (cartItems.isEmpty) {
      _showFeedback("ກະລຸນາເພີ່ມສິນຄ້າລົງໃນກະຕ່າກ່ອນ", isError: true);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          cartItems: cartItems,
          totalAmount: totalAmount,
          onPaymentComplete: () {
            setState(() {
              cartItems.clear();
              totalAmount = 0;
            });
          },
        ),
      ),
    );
  }

  // --- UI ---
  void _showFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // *** ຟັງຊັນແກ້ໄຂຈຳນວນ ***
  void _showEditQuantityDialog(int index, {StateSetter? updater}) {
    final item = cartItems[index];
    final quantityController = TextEditingController(
      text: item['quantity'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("ແກ້ໄຂຈຳນວນສິນຄ້າ"),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "ໃສ່ຈຳນວນທີ່ຕ້ອງການ",
              hintText: "Enter quantity",
            ),
          ),
          actions: [
            TextButton(
              child: Text("ຍົກເລີກ"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("ຍືນຢັນ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE45C58),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final newQuantity = int.tryParse(quantityController.text);
                if (newQuantity != null && newQuantity > 0) {
                  if (newQuantity <= item['Quantity']) {
                    setState(() {
                      // ອັບເດດ State ຫຼັກ
                      cartItems[index]['quantity'] = newQuantity;
                      _calculateTotal();
                    });
                    updater?.call(() {}); // ອັບເດດ Bottom Sheet
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop();
                    _showFeedback('ສິນຄ້າໃນສະຕັອກບໍ່ພໍ ', isError: true);
                  }
                } else if (newQuantity != null && newQuantity <= 0) {
                  setState(() {
                    // ອັບເດດ State ຫຼັກ
                    cartItems.removeAt(index);
                    _calculateTotal();
                  });
                  updater?.call(() {}); // ອັບເດດ Bottom Sheet
                  Navigator.of(context).pop();
                } else {
                  _showFeedback('ກະລຸນາໃສ່ຈຳນວນທີ່ຖືກຕ້ອງ', isError: true);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ຂາຍສິນຄ້າ'),
        backgroundColor: Color(0xFFE45C58),
      ),
      drawer: AppDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    children: [
                      Expanded(flex: 7, child: _buildProductGridPanel()),
                      Expanded(flex: 3, child: _buildCartPanel()),
                    ],
                  );
                } else {
                  return _buildProductGridPanel();
                }
              },
            ),
      floatingActionButton: MediaQuery.of(context).size.width <= 800
          ? FloatingActionButton.extended(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  // ໃຊ້ StatefulBuilder ເພື່ອໃຫ້ Bottom Sheet ມີ State ຂອງຕົວເອງ
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter modalSetState) {
                      return FractionallySizedBox(
                        heightFactor: 0.6,
                        child: _buildCartPanel(
                          isBottomSheet: true,
                          updater:
                              modalSetState, // ສົ່ງຕົວອັບເດດ UI ກັບໄປຫາ Cart Panel
                        ),
                      );
                    },
                  );
                },
              ),
              label: Text("ກະຕ່າ (${cartItems.length})"),
              icon: Icon(Icons.shopping_cart),
              backgroundColor: Color(0xFFE45C58),
            )
          : null,
    );
  }

  Widget _buildProductGridPanel() {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: displayedProducts.isEmpty
              ? Center(child: Text("ບໍ່ມີສິນຄ້າຕາມການຄົ້ນຫາ"))
              : GridView.builder(
                  padding: EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(context),
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: displayedProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(displayedProducts[index]);
                  },
                ),
        ),
      ],
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    return 2;
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) => _filterProducts(),
              decoration: InputDecoration(
                hintText: "ຄົ້ນຫາສິນຄ້າ...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          SizedBox(width: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategoryId,
                hint: Text("ທັງໝົດ"),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text("ທັງໝົດ (All)"),
                  ),
                  ...allCategories.map<DropdownMenuItem<String>>((category) {
                    return DropdownMenuItem<String>(
                      value: category['CategoryID'],
                      child: Text(category['CategoryName']),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCategoryId = value;
                    _filterProducts();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: () => addToCart(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey.shade100,
                child:
                    (product['ProductImageURL'] != null &&
                        product['ProductImageURL'].isNotEmpty)
                    ? Image.network(
                        product['ProductImageURL'],
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) =>
                            Icon(Icons.image, color: Colors.grey.shade400),
                      )
                    : Icon(
                        Icons.inventory_2,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['ProductName'] ?? 'No Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product['SellPrice']} LAK',
                        style: TextStyle(
                          color: Color(0xFFE45C58),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Stock: ${product['Quantity']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartPanel({bool isBottomSheet = false, StateSetter? updater}) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: isBottomSheet ? EdgeInsets.zero : EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isBottomSheet
            ? BorderRadius.vertical(top: Radius.circular(20))
            : null,
        boxShadow: [
          BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.1)),
        ],
      ),
      child: Column(
        children: [
          Text(
            "ລາຍການຂາຍ ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Divider(),
          Expanded(
            child: cartItems.isEmpty
                ? Center(child: Text("ກະຕ່າວ່າງເປົ່າ"))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        title: Text(item['ProductName']),
                        subtitle: Text('${item['SellPrice']} LAK'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline, size: 22),
                              onPressed: () =>
                                  decrementItem(index, updater: updater),
                            ),
                            GestureDetector(
                              onTap: () => _showEditQuantityDialog(
                                index,
                                updater: updater,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['quantity'].toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle_outline,
                                size: 22,
                                color: Color(0xFFE45C58),
                              ),
                              onPressed: () =>
                                  incrementItem(index, updater: updater),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ຍອດລວມ:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '$totalAmount LAK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFE45C58),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _proceedToPayment,
              child: Text("ຊຳລະເງິນ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE45C58),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
