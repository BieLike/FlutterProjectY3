import 'package:flutter/material.dart';
import 'package:mornitor_backend/mornitoring_backend.dart';

void main() {
  runApp(Monitor());
}

class Monitor extends StatelessWidget {
  const Monitor({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme: AppBarTheme(
        color: Colors.lightBlue[800],
      )),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Monitor',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: MornitoringBackend(),
      ),
    );
  }
}
