import 'package:flutter/material.dart';
import 'package:lilypad/util/api.dart';
import 'package:lilypad/util/dialog.dart';
import 'package:lilypad/util/global.dart';

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
    APIService.ping().then((result) {
      DialogService.showAlert('Ping Test', result.toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppGlobal.navigatorKey,
      home: Scaffold(body: Center(child: Text('Welcome to Lilypad'))),
    );
  }
}
