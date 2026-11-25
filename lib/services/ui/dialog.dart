import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'dart:io';

import 'package:lilypad/services/log.dart';
import 'package:lilypad/util/global.dart';

class DialogService {
  static Future<void> showAlert(String title, String msg) async {
    // The navigator may not be mounted yet during startup/session invalidation.
    final context = AppGlobal.navigatorKey.currentContext;
    if (context == null) {
      LogService.warn(
        'Navigator not ready, skipping alert: $title - $msg',
        src: 'Dialog Service',
      );
      return;
    }

    return await showDialog(
      context: context,
      builder: (_) => AppAlert(header: title, content: msg),
    );
  }

  /// Shows a confirmation dialog and returns true only when the user taps
  /// "Yes". Cancelling or dismissing the dialog returns false.
  static Future<bool> getConfirmation(String title, String msg) async {
    // Never treat a missing navigator as a confirmation.
    final context = AppGlobal.navigatorKey.currentContext;
    if (context == null) {
      LogService.warn(
        'Navigator not ready, skipping confirmation: $title - $msg',
        src: 'Dialog Service',
      );
      return false;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AppConfirmation(
        header: title,
        content: msg,
      ),
    );

    return confirmed ?? false;
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

  const AppConfirmation({
    super.key,
    required this.header,
    required this.content,
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
                  Navigator.pop(context, false);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
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
                  Navigator.pop(context, false);
                },
                child: Text('Cancel'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text('Yes'),
              ),
            ],
          );
  }
}
