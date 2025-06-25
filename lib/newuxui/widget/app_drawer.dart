import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/page/Import_page.dart';
import 'package:flutter_lect2/newuxui/page/ManageCategoriesPage.dart';
import 'package:flutter_lect2/newuxui/page/ManageProductsPage.dart';
import 'package:flutter_lect2/newuxui/page/ManageRole.dart';
import 'package:flutter_lect2/newuxui/page/ManageSupplier_page.dart';
import 'package:flutter_lect2/newuxui/page/ManageUnitPage.dart';
import 'package:flutter_lect2/newuxui/page/ManageUser.dart';
import 'package:flutter_lect2/newuxui/page/SalesHistoryPage.dart';
import 'package:flutter_lect2/newuxui/page/SettingsPage.dart';
import 'package:flutter_lect2/newuxui/page/home_page.dart';
import 'package:flutter_lect2/newuxui/page/login_screen.dart';
import 'package:flutter_lect2/newuxui/page/shortImp.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFFE45C58),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                SizedBox(height: 10),
                Text(
                  'ຜູ້ຈັດການຮ້ານ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'admin@bookstore.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('ໜ້າຫຼັກ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => nHomePage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.inventory),
            title: Text('ຈັດການສິນຄ້າ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageProductsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.category),
            title: Text('ຈັດການໝວດໝູ່'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageCategoriesPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.table_view),
            title: Text('ຈັດການຂໍ້ມູນຫົວໜ່ວຍ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ManageUnitPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.point_of_sale),
            title: Text('ການຂາຍ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SalesHistoryPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.download),
            title: Text('ການນຳເຂົ້າສິນຄ້າ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManagesImportPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('ຈັດການຕຳແໜ່ງ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RolePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.emoji_people),
            title: Text('ຈັດການຜູ້ໃຊ້'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageUserPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.emoji_transportation_rounded),
            title: Text('ຈັດການຜູ້ສະໜອງ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageSuppliersPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('ຕັ້ງຄ່າ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('ອອກຈາກລະບົບ'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
