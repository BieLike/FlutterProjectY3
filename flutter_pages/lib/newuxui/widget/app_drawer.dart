import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/backupManagement.dart';
import 'package:flutter_lect2/newuxui/page/Import/Import_page.dart';
import 'package:flutter_lect2/newuxui/page/UnC/ManageCategoriesPage.dart';
import 'package:flutter_lect2/newuxui/page/UnC/ManageUnitPage.dart';
import 'package:flutter_lect2/newuxui/page/UsrNRole/ManageRole.dart';
import 'package:flutter_lect2/newuxui/page/UsrNRole/ManageSupplier_page.dart';
import 'package:flutter_lect2/newuxui/page/UsrNRole/ManageUser.dart';
import 'package:flutter_lect2/newuxui/page/product/ManageProductsPage.dart';
import 'package:flutter_lect2/newuxui/page/Sell_History/Sell_HistoryPage.dart';
import 'package:flutter_lect2/newuxui/page/author/ManageAuthor.dart';
import 'package:flutter_lect2/newuxui/page/login/login_screen.dart';
import 'package:flutter_lect2/newuxui/page/mornitor/Mornitoring_page.dart';
import 'package:flutter_lect2/newuxui/page/salepage/Salepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String userRole = '';
  String userName = 'Guest';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // [EDIT] ปรับปรุงฟังก์ชันการดึงข้อมูลผู้ใช้
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = json.decode(userDataString);
      setState(() {
        userRole = userData['RoleName'] ?? '';
        userName = userData['UserFname'] ?? 'User';
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ล้างข้อมูลทั้งหมดใน SharedPreferences
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // แปลงชื่อ Role เป็น Case-insensitive เพื่อความเสถียร
    final String role = userRole.toLowerCase();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFE45C58)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFFE45C58)),
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  userRole,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // --- เมนูสำหรับ Cashier และ Admin ---
          if (role == 'cashier' || role == 'admin') ...[
            ListTile(
              leading: Icon(Icons.point_of_sale_outlined),
              title: Text('ຂາຍສິນຄ້າ'),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const SalePage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.history_outlined),
              title: Text('ປະຫວັດການຂາຍ'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SalesHistoryPage()));
              },
            ),
            const Divider(),
          ],

          // --- เมนูสำหรับ Stocker และ Admin ---
          if (role == 'stocker' || role == 'admin') ...[
            ListTile(
              leading: Icon(Icons.local_shipping_outlined),
              title: Text('ຈັດການຜູ້ສະໜອງ'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageSuppliersPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.archive_outlined),
              title: Text('ການນຳເຂົ້າສິນຄ້າ'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageImportPage()));
              },
            ),
            const Divider(),
          ],

          // --- เมนูสำหรับ Admin เท่านั้น ---
          if (role == 'admin') ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text("ການຕັ້ງຄ່າຫຼັກ",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: Icon(Icons.inventory_2_outlined),
              title: Text('ຈັດການສິນຄ້າ'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageProductsPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.category_outlined),
              title: Text('ຈັດການໝວດໝູ່'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageCategoriesPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.square_foot_outlined),
              title: Text('ຈັດການຂໍ້ມູນຫົວໜ່ວຍ'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageUnitPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.person_pin_outlined),
              title: Text('ຈັດການຂໍ້ມູນຜູ້ແຕ່ງ'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageAuthorPage()));
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text("ການຈັດການລະບົບ",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: Icon(Icons.badge_outlined),
              title: Text('ຈັດການຕຳແໜ່ງ'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RolePage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.people_alt_outlined),
              title: Text('ຈັດການຜູ້ໃຊ້'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageUserPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.dashboard_outlined),
              title: Text('Dashboard & Logs'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DashboardAndLogPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.recycling_outlined),
              title: Text('Backup & Restore'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BackupRestorePage()));
              },
            ),
          ],

          // --- เมนูสำหรับทุกคน ---
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('ອອກຈາກລະບົບ'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
