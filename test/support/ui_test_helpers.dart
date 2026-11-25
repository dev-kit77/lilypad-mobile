import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lilypad/ui/theme/theme.dart';

/// Records the routes pushed during a widget test.
class RouteRecorder extends NavigatorObserver {
  final List<Route<dynamic>> pushed = <Route<dynamic>>[];
  final List<Route<dynamic>> replaced = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) replaced.add(newRoute);
  }

  /// Route names in the order they were pushed.
  List<String?> get pushedNames => pushed.map((r) => r.settings.name).toList();
}

/// Pumps [child] inside a material app using the app's light theme.
///
/// Google fonts are not available in the test environment, so runtime font
/// fetching is disabled; widgets fall back to their theme text styles.
Future<RouteRecorder> pumpThemed(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(800, 800),
  bool recordRoutes = false,
}) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final recorder = RouteRecorder();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light().themeData,
      navigatorObservers: recordRoutes
          ? <NavigatorObserver>[recorder]
          : const <NavigatorObserver>[],
      home: Scaffold(body: child),
    ),
  );

  // Ignore the route created by pumpWidget so the recorder only sees
  // navigations triggered by the test.
  recorder.pushed.clear();
  recorder.replaced.clear();

  return recorder;
}
