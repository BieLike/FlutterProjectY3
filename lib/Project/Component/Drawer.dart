import 'package:flutter/material.dart';
import 'package:flutter_lect2/Project/Page.dart/Category.dart';
import 'package:flutter_lect2/Project/Page.dart/Product.dart';
import 'package:flutter_lect2/Project/Page.dart/Unit.dart';

class DrawerTab extends StatelessWidget {
  const DrawerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.green[200],
      child: Builder(
          builder: (context) => ListView(
                padding: EdgeInsets.all(5),
                children: [
                  DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
                                  child: Text(
                                    'Pic',
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                                  child: Text(
                                    'Management',
                                    style: TextStyle(color: Colors.white),
                                  ))
                            ],
                          ),
                        ],
                      )),
                  ListTile(
                    leading: Icon(Icons.list),
                    title: Text('Product'),
                    tileColor: Colors.green[300],
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductPage()));
                    },
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  ListTile(
                    leading: Icon(Icons.straighten),
                    title: Text('Unit'),
                    tileColor: Colors.green[300],
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => UnitPage()));
                    },
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  ListTile(
                    leading: Icon(Icons.category),
                    title: Text('Category'),
                    tileColor: Colors.green[300],
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CategoryPage()));
                    },
                  )
                ],
              )),
    );
  }
}
