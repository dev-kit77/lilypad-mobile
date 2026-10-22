import 'package:flutter/foundation.dart';
import 'dialog.dart';

class LogService {
  static void log(String msg, {String? src}) {
    print('${DateTime.now()} (${src ?? 'App'}) MESSAGE: $msg');
  }

  static void warn(String msg, {String? src}) {
    if (kDebugMode) {
      print('${DateTime.now()} (${src ?? 'App'}) WARNING: $msg');
    }
  }

  static void dbg(String msg, {String? src}) {
    if (kDebugMode) {
      print('${DateTime.now()} (${src ?? 'App'}) DEBUG: $msg');
    }
  }

  static void err(String msg, {int? code, String? src, Exception? ex}) {
    if (kDebugMode) {
      if (ex != null) {
        print('${DateTime.now()} (${src ?? 'App'}) ERROR: Logged Exception ${ex.runtimeType}');
      }
    }

    if (code != null){
      print('${DateTime.now()} (${src ?? 'App'}) ERROR: $msg (Type: $code)');
    } else {
      print('${DateTime.now()} (${src ?? 'App'}) ERROR: $msg');
    }
  }
}
