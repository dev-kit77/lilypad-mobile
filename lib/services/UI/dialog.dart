import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:lilypad/util/global.dart';

class DialogService {
  static Future<void> showAlert(String title, String msg) {
    final context = AppGlobal.navigatorKey.currentContext!;

    return showDialog(
      context: context,
      builder: (_) => AppAlert(header: title, content: msg),
    );
  }
}

class AppAlert extends StatelessWidget {
  final String header;
  final String content;

  const AppAlert({super.key, required this.header, required this.content});

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? AlertDialog(
            title: Text(header),
            content: SingleChildScrollView(
              child: ListBody(children: <Widget>[Text(content)]),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Dismiss'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          )
        : CupertinoAlertDialog(
            title: Text(header),
            content: SingleChildScrollView(
              child: ListBody(children: <Widget>[Text(content)]),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('Dismiss'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
  }
}
