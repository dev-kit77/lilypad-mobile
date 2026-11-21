import 'dart:io';

import 'package:flutter/foundation.dart';
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

  //start services
  await SessionService.init();
  //TODO: REMOVE WHEN AUTOLOGIN COMPLETED
  SessionService.clear();
  await GeolocationService.init();
  if (Platform.isAndroid || Platform.isIOS) {
    await BackgroundService.init();
  }

  LogService.log('Starting UI...');
  runApp(const MainApp());
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
      home: const LandingWidget(),
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
