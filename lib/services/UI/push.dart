import 'package:lilypad/services/log.dart';

class NotificationService {
  //Non-implemented Stub for push notifications
  static void push(String msg) {
    LogService.log(
      'Attemting to send notification to user: $msg',
      src: 'Notification Service',
    );
  }
}
