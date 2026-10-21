import 'package:flutter/material.dart';
import 'package:lilypad/connection/connection.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String success = 'Pinging...';

  @override
  void initState() {
    testPing().then((result) {
      setState(() {
        success = result.toString();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: Text(success))),
    );
  }

  Future<bool> testPing() async {
    Connector connect = Connector('localhost:3000');
    return connect.ping();
  }
}
