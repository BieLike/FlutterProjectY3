import 'package:flutter/material.dart';
import 'package:flutter_lect2/newuxui/page/home_page.dart';

void main() {
  runApp(MainPage());
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: nHomePage(),
    );
  }
}