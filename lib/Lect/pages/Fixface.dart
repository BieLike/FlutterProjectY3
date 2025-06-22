import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Home> {
  TextEditingController txtsearch = TextEditingController();
  TextEditingController txtbid = TextEditingController();
  TextEditingController txtbname = TextEditingController();
  TextEditingController txtbprice = TextEditingController();
  TextEditingController txtbpage = TextEditingController();
  List data = [];
  bool isLoading = false;
  final String baseUrl = "http://192.168.189.89:3000";

  @override
  void initState() {
    fetchAllData();
    super.initState();
  }

  // Fetch a specific book by ID or search term
  Future<void> fetchDataByVal(String searchTerm) async {
    if (searchTerm.isEmpty) {
      fetchAllData();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final String urlf = "$baseUrl/book/$searchTerm";
      final response = await http.get(Uri.parse(urlf));

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showErrorMessage("Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      showErrorMessage("Failed to fetch book: ${e.toString()}");
    }
  }

  // Fetch all books
  Future<void> fetchAllData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse("$baseUrl/book"));

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showErrorMessage("Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      showErrorMessage("Failed to fetch books: ${e.toString()}");
    }
  }

  // Add a new book
  Future<void> addBook() async {
    if (txtbid.text.isEmpty ||
        txtbname.text.isEmpty ||
        txtbprice.text.isEmpty ||
        txtbpage.text.isEmpty) {
      showErrorMessage("All fields are required!");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Convert price and page to numbers and handle parsing errors
      final double price = double.tryParse(txtbprice.text) ?? 0.0;
      final int page = int.tryParse(txtbpage.text) ?? 0;

      final response = await http.post(
        Uri.parse("$baseUrl/book/insert"), // Updated to match API endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'bookid': txtbid.text,
          'bookname': txtbname.text,
          'price': price,
          'page': page // Changed from 'pages' to 'page' to match API
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Clear text fields and refresh data
        clearTextFields();
        fetchAllData();
        Navigator.of(context).pop(); // Close dialog
        showSuccessMessage("Book added successfully!");
      } else {
        final responseBody = json.decode(response.body);
        showErrorMessage(responseBody['msg'] ??
            "Failed to add book. Status: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      showErrorMessage("Failed to add book: ${e.toString()}");
    }
  }

  // Update existing book
  Future<void> updateBook(String bookId) async {
    if (txtbname.text.isEmpty ||
        txtbprice.text.isEmpty ||
        txtbpage.text.isEmpty) {
      showErrorMessage("All fields are required!");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final double price = double.tryParse(txtbprice.text) ?? 0.0;
      final int page = int.tryParse(txtbpage.text) ?? 0;

      final response = await http.put(
        Uri.parse("$baseUrl/book/update"), // Updated to match API endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'bookid': bookId,
          'bookname': txtbname.text,
          'price': price,
          'page': page // Changed from 'pages' to 'page' to match API
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        clearTextFields();
        fetchAllData();
        Navigator.of(context).pop();

        final responseBody = json.decode(response.body);
        showSuccessMessage(responseBody['msg'] ?? "Book updated successfully!");
      } else {
        final responseBody = json.decode(response.body);
        showErrorMessage(responseBody['msg'] ??
            "Failed to update book. Status: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      showErrorMessage("Failed to update book: ${e.toString()}");
    }
  }

  // Delete a book
  Future<void> deleteBook(String bookId) async {
    setState(() {
      isLoading = true;
    });

    try {
      // API expects bookid in the body, not just in the URL
      final response = await http.delete(
        Uri.parse("$baseUrl/book/:delete"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'bookid': bookId}),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        fetchAllData();
        final responseBody = json.decode(response.body);
        showSuccessMessage(responseBody['msg'] ?? "Book deleted successfully!");
      } else {
        final responseBody = json.decode(response.body);
        showErrorMessage(responseBody['msg'] ??
            "Failed to delete book. Status: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      showErrorMessage("Failed to delete book: ${e.toString()}");
    }
  }

  // Show confirmation dialog before deleting
  void showDeleteConfirmation(String bookId, String bookName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("ຢືນຢັນການລຶບ"),
        content: Text("ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການລຶບປື້ມ '$bookName'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("ຍົກເລີກ"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteBook(bookId);
            },
            child: Text("ລຶບ"),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  // Show add/edit dialog
  void showDataDialog({Map<String, dynamic>? bookData}) {
    // If bookData is provided, populate fields for editing
    if (bookData != null) {
      txtbid.text = bookData['bookid'].toString();
      txtbname.text = bookData['bookname'].toString();
      txtbprice.text = bookData['price'].toString();
      txtbpage.text =
          bookData['page'].toString(); // Changed from 'pages' to 'page'
    } else {
      clearTextFields();
    }

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(bookData != null ? "ແກ້ໄຂຂໍ້ມູນປື້ມ" : "ເພີ່ມຂໍ້ມູນປື້ມ"),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: txtbid,
                decoration: InputDecoration(
                  labelText: "ລະຫັດປື້ມ",
                  border: OutlineInputBorder(),
                ),
                enabled: bookData == null, // Disable ID field when editing
              ),
              SizedBox(height: 10),
              TextField(
                controller: txtbname,
                decoration: InputDecoration(
                  labelText: "ຊື່ປື້ມ",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: txtbprice,
                decoration: InputDecoration(
                  labelText: "ລາຄາ",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: txtbpage,
                decoration: InputDecoration(
                  labelText: "ຈຳນວນໜ້າ",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              clearTextFields();
              Navigator.of(context).pop();
            },
            child: Text("ຍົກເລີກ"),
          ),
          TextButton(
            onPressed: () {
              if (bookData != null) {
                updateBook(bookData['bookid'].toString());
              } else {
                addBook();
              }
            },
            child: Text(bookData != null ? "ອັບເດດ" : "ບັນທຶກ"),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Clear text fields
  void clearTextFields() {
    txtbid.clear();
    txtbname.clear();
    txtbprice.clear();
    txtbpage.clear();
  }

  // Show error message
  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show success message
  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ຈັດການຂໍ້ມູນປື້ມ"),
        backgroundColor: Colors.blue,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            height: 50,
            margin: EdgeInsets.all(10),
            child: TextField(
              onChanged: (val) {
                if (txtsearch.text.isEmpty) {
                  fetchAllData();
                } else {
                  fetchDataByVal(txtsearch.text);
                }
              },
              controller: txtsearch,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(width: 1),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(
                  Icons.book_online,
                  color: Colors.blue,
                  size: 25,
                ),
                labelText: "ຂໍ້ມູນທີ່ຕ້ອງການຄົ້ນຫາ",
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        txtsearch.clear();
                        fetchAllData();
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.red.shade600,
                        size: 25,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        fetchDataByVal(txtsearch.text);
                      },
                      icon: Icon(
                        Icons.search,
                        color: Colors.blue.shade600,
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : data.isEmpty
              ? Center(
                  child:
                      Text("ບໍ່ມີຂໍ້ມູນປື້ມ", style: TextStyle(fontSize: 18)),
                )
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (c, index) {
                    final book = data[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            '${book['bookid']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                        title: Text(
                          '${book['bookname']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'ລາຄາ: ${book['price']} | ຈຳນວນໜ້າ: ${book['page']}', // Changed from 'pages' to 'page'
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                showDataDialog(bookData: book);
                              },
                              icon: Icon(
                                Icons.edit,
                                size: 25,
                                color: Colors.green.shade700,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showDeleteConfirmation(
                                    book['bookid'].toString(),
                                    book['bookname'].toString());
                              },
                              icon: Icon(
                                Icons.delete,
                                size: 25,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade800,
        onPressed: () {
          showDataDialog();
        },
        tooltip: "ເພີ່ມປື້ມໃໝ່",
        child: Icon(
          Icons.add,
          size: 35,
          color: Colors.white,
        ),
      ),
    );
  }
}