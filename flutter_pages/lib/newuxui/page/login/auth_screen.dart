import 'package:flutter/material.dart';

// แก้ import ให้ถูก path
import 'package:flutter_lect2/newuxui/page/login/login_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showLogin = true;

  void toggleAuth() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: showLogin
          ? LoginScreen(key: const ValueKey('login'))
          : const SizedBox(),
    );
  }
}
