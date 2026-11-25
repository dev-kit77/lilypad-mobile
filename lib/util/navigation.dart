import 'package:material_ui/material_ui.dart';

import '../ui/pages/feed.dart' show FeedWidget;
import '../ui/pages/profile.dart' show ProfileWidget;
import '../ui/pages/settings.dart' show SettingsWidget;

/// Matches the root tab pages of the app.
bool isTabRootRoute(Route<dynamic> route) {
  final name = route.settings.name;
  return name == FeedWidget.routePath ||
      name == ProfileWidget.routePath ||
      name == SettingsWidget.routePath;
}
