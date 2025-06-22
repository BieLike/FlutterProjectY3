import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class tpage extends StatefulWidget {
  const tpage({super.key});

  @override
  State<tpage> createState() => _tpageState();
}

class _tpageState extends State<tpage> {
  List data = [];
  final String url = "http://localhost:3000/book";
  TextEditingController SearchControl = TextEditingController();
  String SearchData = "";

  @override
  void initState() {
    fetchAllData();
    super.initState();
  }

  Future<void> fetchAllData() async {
    try {
      final respons = await http.get(Uri.parse(url));
      if (respons.statusCode == 200) {
        setState(() {
          data = json.decode(respons.body);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Management'),
        backgroundColor: Colors.blue,
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Padding(
                padding: EdgeInsets.all(12),
                child: TextField(
                  
                    decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  hintText: "Search bar",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25)),
                  filled: true,
                  fillColor: Colors.white,
                )))),
      ),
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
                        child: Center(
                          child: Text(
                            '${getdata['BID']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.red),
                          ),
                        ),
                      ),
                      title: Text('${getdata['Bname']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.orange,
                          )),
                      subtitle: Text(
                          'Page: ${getdata['Bpage']}, Price: ${getdata['Bprice']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.green,
                          )),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.edit,
                                  size: 25, color: Colors.green)),
                          IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.delete,
                                  size: 25, color: Colors.red))
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
