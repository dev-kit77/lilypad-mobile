import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'dart:io';

import 'package:lilypad/util/global.dart';

class DialogService {
  static Future<void> showAlert(String title, String msg) async {
    final context = AppGlobal.navigatorKey.currentContext!;

    return await showDialog(
      context: context,
      builder: (_) => AppAlert(header: title, content: msg),
    );
  }

  static Future<void> getConfirmation(
    String title,
    String msg,
    VoidCallback runOnConfirmation,
  ) async {
    final context = AppGlobal.navigatorKey.currentContext!;

    await showDialog(
      context: context,
      builder: (_) => AppConfirmation(
        header: title,
        content: msg,
        callback: runOnConfirmation,
      ),
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

class AppConfirmation extends StatelessWidget {
  final String header;
  final String content;
  final VoidCallback callback;

  const AppConfirmation({
    super.key,
    required this.header,
    required this.content,
    required this.callback,
  });

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
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  callback.call();
                },
                child: Text('Yes'),
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
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                  callback.call();
                },
                child: Text('Yes'),
              ),
            ],
          );
  }
}
