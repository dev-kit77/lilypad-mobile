import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lilypad/services/cache.dart';
import 'package:lilypad/services/content.dart';
import 'package:lilypad/services/user.dart';
import 'package:lilypad/ui/theme/theme.dart';
import 'package:lilypad/services/background.dart';
import 'package:material_ui/material_ui.dart';
import 'package:lilypad/services/api.dart';
import 'package:lilypad/services/ui/dialog.dart';
import 'package:lilypad/services/geolocation.dart';
import 'package:lilypad/services/log.dart';
import 'package:lilypad/services/session.dart';
import 'package:lilypad/util/global.dart';
import 'package:lilypad/ui/pages/landing.dart';
import 'package:lilypad/ui/pages/feed.dart';
import 'package:lilypad/ui/pages/new_post.dart';
import 'package:lilypad/ui/pages/profile.dart';
import 'package:lilypad/ui/pages/settings.dart';

void main() async {
  //bind widgets so we can run pre-ui startup code
  WidgetsFlutterBinding.ensureInitialized();

  //start session service and link invaliation callback
  await SessionService.init();
  SessionService.onSessionInvalidated = sessionInvalidCallback;

  //start Geolocation
  //TODO: Guard application for not initalized due to permissions
  await GeolocationService.init();

  //start background service for push notifications on mobile
  if (Platform.isAndroid || Platform.isIOS) {
    await BackgroundService.init();
  }

  LogService.log('Starting UI...');
  runApp(const MainApp());
}

void sessionInvalidCallback() async {
  ContentService.clear();
  UserService.clear();
  CacheService.clear();

  await DialogService.showAlert('Session Logout', 'You have been logged out.');

  await AppGlobal.navigatorKey.currentState?.pushNamedAndRemoveUntil(
    LandingWidget.routePath,
    (_) => false,
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    LogService.log('Building Core App...', src: 'MainApp');

    //check api connection in debug
    if (kDebugMode) {
      APIService.ping().then((result) {
        DialogService.showAlert('Ping Test', result.toString());
      });
    }

    return MaterialApp(
      navigatorKey: AppGlobal.navigatorKey,
      initialRoute: SessionService.activeSession
          ? FeedWidget.routePath
          : LandingWidget.routePath,
      theme: AppTheme.of(context).themeData,
      routes: {
        LandingWidget.routePath: (_) => const LandingWidget(),
        FeedWidget.routePath: (_) => const FeedWidget(),
        NewPostWidget.routePath: (_) => const NewPostWidget(),
        ProfileWidget.routePath: (_) => const ProfileWidget(),
        SettingsWidget.routePath: (_) => const SettingsWidget(),
      },
    );
  }
}
