import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lilypad/services/log.dart';
import 'package:lilypad/services/user.dart';
import 'package:lilypad/ui/pages/feed.dart';
import 'package:lilypad/util/global.dart';

class NotificationService {
  static bool _initialized = false;
  static bool _enabled = false;

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._();

  ///init fo
  static Future<void> init() async {
    if ((!Platform.isAndroid && !Platform.isIOS) || _initialized == true) {
      return;
    }

    //init notif plugin
    await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: const DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _onTap,
    );

    //request android specific plugins
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    //set initalized
    _initialized = true;

    //set enabled
    _enabled = UserService.currentUser?.push ?? false;
  }

  //push notifications function for new posts in the area
  static void newPosts(String msg) async {
    LogService.log(
      'Attemting to send notification to user: $msg',
      src: 'Notification Service',
    );

    //guard for platform and
    if (!Platform.isAndroid && !Platform.isIOS && _enabled == false) return;

    try {
      if (!_initialized) await init();
      await _plugin.show(
        id: 2001,
        title: 'Lilypad',
        body: msg,
        payload: 'lilypad_new_posts',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'new_posts',
            'New Posts',
            channelDescription: 'Notifications about new posts near you',
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      LogService.err(
        'Failed to display notification: $e',
        src: 'Notification Service',
        ex: e is Exception ? e : null,
      );
    }
  }

  static Future<void> _onTap(NotificationResponse response) async {
    if (response.payload == 'lilypad_new_posts') {
      await AppGlobal.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        FeedWidget.routePath,
        (_) => false,
        arguments: true, // noCache: refresh feed on arrival
      );
    }
  }
}
