import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/DBpath.dart';
import 'package:flutter_lect2/newuxui/page/Import/Import_page.dart';
import 'package:flutter_lect2/newuxui/page/mornitor/Mornitoring_page.dart';
import 'package:flutter_lect2/newuxui/page/salepage/Salepage.dart';
import 'package:flutter_lect2/newuxui/widget/Custom_Button.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final String baseUrl = basePath().bpath();
  bool isLoading = false;
  bool showPassword = false;

  void showMessage(String message, bool isError) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // [EDIT] ปรับปรุงฟังก์ชัน Login ใหม่ทั้งหมด
  Future<void> login() async {
    final String phone = phoneController.text.trim();
    final String password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      showMessage("ກະລຸນາປ້ອນເບີໂທ ແລະ ລະຫັດຜ່ານ", true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/main/user/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "Phone": int.tryParse(phone) ?? 0, // แปลงเป็น int
          "UserPassword": password
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final Map<String, dynamic> user = data['user'];

        // บันทึกข้อมูลผู้ใช้ทั้งหมดลง SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(user));
        await prefs.setBool('is_logged_in', true);

        showMessage("Login Successful!", false);

        // นำทางตามตำแหน่ง
        final String role = user['RoleName'] ?? '';
        _navigateBasedOnRole(role);
      } else {
        showMessage(data['msg'] ?? "Login failed", true);
      }
    } catch (e) {
      showMessage("Error: ${e.toString()}", true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _navigateBasedOnRole(String role) {
    Widget landingPage;
    switch (role.toLowerCase()) {
      case 'admin':
        landingPage = const DashboardAndLogPage();
        break;
      case 'cashier':
        landingPage = const SalePage();
        break;
      case 'stocker':
        landingPage = const ManageImportPage();
        break;
      default:
        //
        landingPage = const Scaffold(
            body: Center(child: Text("You do not have access to any page.")));
        break;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => landingPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: Color(0xFFE45C58),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: isTablet ? 500 : double.infinity,
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  FadeInDown(
                    duration: Duration(milliseconds: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF4A154B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            "Welcome",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 18 : 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Log In\nPOS Book Store",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            fontSize: isTablet ? 42 : 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  FadeInUp(
                    duration: Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              color: Color(0xFF1D1C1D),
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                CupertinoIcons.phone,
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Phone",
                              hintStyle: TextStyle(
                                color: Color(0xFF1D1C1D).withOpacity(0.5),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // ช่องกรอกรหัสผ่าน
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: passwordController,
                            obscureText: !showPassword,
                            style: TextStyle(
                              color: Color(0xFF1D1C1D),
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                CupertinoIcons.lock,
                                color: Colors.grey,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Password",
                              hintStyle: TextStyle(
                                color: Color(0xFF1D1C1D).withOpacity(0.5),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  FadeInUp(
                    duration: Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 400),
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : CustomButton(
                            onPressed: login,
                            text: "Log In",
                          ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
