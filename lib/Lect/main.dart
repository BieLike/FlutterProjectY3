import 'package:flutter/material.dart';
import 'package:flutter_lect2/Lect/pages/Fixface.dart';
import 'package:flutter_lect2/Lect/pages/HomePage.dart';
import 'package:flutter_lect2/Lect/pages/tpage.dart';

void main() {
  runApp(runner());
}

class runner extends StatelessWidget {
  const runner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: tpage(),
    );
  }
}
