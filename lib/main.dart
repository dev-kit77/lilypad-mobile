import 'dart:io';

import 'package:lilypad/services/cache.dart';
import 'package:lilypad/services/content.dart';
import 'package:lilypad/services/ui/push.dart';
import 'package:lilypad/services/user.dart';
import 'package:lilypad/ui/theme/theme.dart';
import 'package:lilypad/services/background.dart';
import 'package:material_ui/material_ui.dart';
import 'package:lilypad/services/ui/dialog.dart';
import 'package:lilypad/services/geolocation.dart';
import 'package:lilypad/services/log.dart';
import 'package:lilypad/services/session.dart';
import 'package:lilypad/util/global.dart';
import 'package:lilypad/ui/pages/landing.dart';
import 'package:lilypad/ui/pages/feed.dart';
import 'package:lilypad/ui/pages/profile.dart';
import 'package:lilypad/ui/pages/settings.dart';

void main() async {
  //bind widgets so we can run pre-ui startup code
  WidgetsFlutterBinding.ensureInitialized();

  //start ui
  LogService.log('Starting UI...');
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool loading = true;

  @override
  void initState() {
    super.initState();

    _startServices();
  }

  void _sessionInvalidCallback() async {
    ContentService.clear();
    UserService.clear();
    CacheService.clear();
    AppTheme.resetToSystem();

    if (mounted) {
      await DialogService.showAlert(
        'Session Logout',
        'You have been logged out.',
      );
    }

    await AppGlobal.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      LandingWidget.routePath,
      (_) => false,
    );
  }

  ///Reads the `noCache` flag from a named route's arguments.
  bool _noCacheFromRoute(RouteSettings settings) =>
      switch (settings.arguments) {
        final bool value => value,
        final Map arguments => arguments['noCache'] == true,
        _ => false,
      };

  ///Generates the single route set used for both the startup splash and the
  ///rest of the app. Keeping one Navigator avoids rebuilding WidgetsApp while
  ///a route is being generated (which breaks the `home` route builder).
  Route<dynamic>? _generateRoute(RouteSettings settings) {
    if (loading) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const _LoadingScreen(),
      );
    }

    final noCache = _noCacheFromRoute(settings);
    if (settings.name == FeedWidget.routePath) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => FeedWidget(noCache: noCache),
      );
    }
    if (settings.name == ProfileWidget.routePath) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => ProfileWidget(noCache: noCache),
      );
    }
    if (settings.name == SettingsWidget.routePath) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => SettingsWidget(noCache: noCache),
      );
    }
    if (settings.name == LandingWidget.routePath) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const LandingWidget(),
      );
    }
    return null;
  }

  void _startServices() async {
    setState(() {
      loading = true;
    });

    //start session service and link invaliation callback
    await SessionService.init();
    SessionService.onSessionInvalidated = _sessionInvalidCallback;

    //start Geolocation
    try {
      await GeolocationService.init().timeout(const Duration(seconds: 15));
    } catch (e) {
      GeolocationService.initializationError ??= 'Location setup failed: $e';
      LogService.err(
        'Geolocation init failed, continuing without location: $e',
        src: 'main',
        ex: e is Exception ? e : null,
      );
    }

    //start notification & background service for notifications on mobile
    if (Platform.isAndroid || Platform.isIOS) {
      //start notifications
      await NotificationService.init();

      try {
        await BackgroundService.init();
      } catch (e) {
        LogService.err(
          'Background service init failed: $e',
          src: 'main',
          ex: e is Exception ? e : null,
        );
      }
    }

    if (!mounted) return;
    setState(() {
      loading = false;
    });

    // Swap the splash route for the real initial route once services are up.
    // Do this after the frame so `loading` is reflected in onGenerateRoute.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppGlobal.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        SessionService.activeSession
            ? FeedWidget.routePath
            : LandingWidget.routePath,
        (_) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (_, mode, _) => MaterialApp(
        navigatorKey: AppGlobal.navigatorKey,
        theme: AppTheme.light().themeData,
        darkTheme: AppTheme.dark().themeData,
        themeMode: mode,
        onGenerateRoute: _generateRoute,
      ),
    );
  }
}

///Full-screen spinner shown while startup services initialize.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            color: AppTheme.of(context).primary,
          ),
        ),
      ),
    );
  }
}
