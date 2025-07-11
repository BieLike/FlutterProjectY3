import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/backupManagement.dart';
import 'package:flutter_lect2/newuxui/page/Import/Import_page.dart';
import 'package:flutter_lect2/newuxui/page/Sell_History/new_sellHistory.dart';
import 'package:flutter_lect2/newuxui/page/UnC/ManageCategoriesPage.dart';
import 'package:flutter_lect2/newuxui/page/Product/ManageProductsPage.dart';
import 'package:flutter_lect2/newuxui/page/UsrNRole/ManageRole.dart';
import 'package:flutter_lect2/newuxui/page/UsrNRole/ManageSupplier_page.dart';
import 'package:flutter_lect2/newuxui/page/UnC/ManageUnitPage.dart';
import 'package:flutter_lect2/newuxui/page/UsrNRole/ManageUser.dart';
import 'package:flutter_lect2/newuxui/page/SettingsPage.dart';
import 'package:flutter_lect2/newuxui/page/author/ManageAuthor.dart';
import 'package:flutter_lect2/newuxui/page/login/login_screen.dart';
import 'package:flutter_lect2/newuxui/page/salepage/Salepage.dart';
import 'package:flutter_lect2/newuxui/page/Import/shortImp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String userRole = '';
  String userName = '';

  @override
  void initState() {
    super.initState();
    loadUserRole();
  }

  Future<void> loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? '';
      userName = prefs.getString('UserFname') ?? '';
    });
  }

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
                  '${userName}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                if (userRole == 'Admin') ...{
                  Text(
                    'admin@bookstore.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                } else if (userRole == 'Cashier') ...{
                  Text(
                    'Cashier@bookstore.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                } else if (userRole == 'Stocker') ...{
                  Text(
                    'Stocker@bookstore.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                } else ...{
                  Text(
                    'user@bookstore.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                }
              ],
            ),
          ),
          if (userRole == 'Cashier' || userRole == 'Admin') ...[
            ListTile(
              leading: Icon(Icons.home),
              title: Text('ຂາຍສິນຄ້າ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SalePage()));
              },
            ),
          ],
          if (userRole == 'Cashier' || userRole == 'Admin') ...[
            ListTile(
              leading: Icon(Icons.watch_later_outlined),
              title: Text('ປະຫວັດການຂາຍ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SalesHistoryPage()));
              },
            ),
            Divider(
              endIndent: 15.0,
              indent: 15.0,
            ),
          ],
          if (userRole == 'Admin') ...[
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
                  MaterialPageRoute(
                      builder: (context) => ManageCategoriesPage()),
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
              leading: Icon(Icons.person_pin_outlined),
              title: Text('ຈັດການຂໍ້ມູນຜູ້ແຕ່ງ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ManageAuthorPage()));
              },
            ),
            Divider(
              endIndent: 15.0,
              indent: 15.0,
            ),
          ],
          if (userRole == 'Stocker' || userRole == 'Admin') ...[
            ListTile(
              leading: Icon(Icons.emoji_transportation_rounded),
              title: Text('ຈັດການຜູ້ສະໜອງ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ManageSuppliersPage()),
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
                    MaterialPageRoute(
                        builder: (context) => ManageImportPage()));
              },
            ),
            Divider(
              endIndent: 15.0,
              indent: 15.0,
            ),
          ],
          if (userRole == 'Admin') ...[
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
          ],
          if (userRole == 'Admin') ...[
            Divider(
              endIndent: 15.0,
              indent: 15.0,
            ),
            ListTile(
              leading: Icon(Icons.recycling),
              title: Text('Restore'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BackupRestorePage()),
                );
              },
            ),
          ],
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
