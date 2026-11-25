import 'package:material_ui/material_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../pages/feed.dart' show FeedWidget;
import '../pages/profile.dart' show ProfileWidget;
import '../pages/settings.dart' show SettingsWidget;
import '../theme/theme.dart';
import '../../util/ui.dart';

/// The bottom navigation bar used by the main pages.
///
/// [selectedIndex] maps to the same tab order as the original design:
/// 0 = Profile, 1 = Posts, 2 = Settings. The widget positions itself at the
/// bottom of the enclosing [Stack] and handles tab navigation itself.
class NavBarWidget extends StatefulWidget {
  const NavBarWidget({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  State<NavBarWidget> createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends State<NavBarWidget> {
  PageTransition<void> _route({
    required BuildContext context,
    required String routeName,
    required PageTransitionType type,
    required Widget child,
  }) {
    return PageTransition<void>(
      type: type,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInBack,
      opaque: true,
      settings: RouteSettings(name: routeName),
      childCurrent: context.currentRoute,
      child: child,
    );
  }

  Future<void> _navigate(BuildContext context, int index) async {
    if (index == widget.selectedIndex) return;

    // Tabs sit on a horizontal axis: Profile is left of the feed, Settings
    // right of it. Slide the destination in from the side we came from so the
    // trip back to the feed keeps the matching direction. `reverseType` cannot
    // do this: the package never reads it, and each page gets a fresh nav bar
    // whose `lastTransition` is always null.
    final route = switch (index) {
      0 => _route(
        context: context,
        routeName: ProfileWidget.routePath,
        type: PageTransitionType.leftToRight,
        child: const ProfileWidget(),
      ),
      1 => _route(
        context: context,
        routeName: FeedWidget.routePath,
        type: switch (widget.selectedIndex) {
          0 => PageTransitionType.leftToRight,
          2 => PageTransitionType.rightToLeft,
          _ => PageTransitionType.fade,
        },
        child: const FeedWidget(),
      ),
      2 => _route(
        context: context,
        routeName: SettingsWidget.routePath,
        type: PageTransitionType.rightToLeft,
        child: const SettingsWidget(),
      ),
      _ => null,
    };

    // Replace instead of pushing so tab hops do not stack duplicate pages and
    // nav bars on top of each other.
    if (route != null) {
      await Navigator.of(context).pushReplacement(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        color: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Container(
          width: double.infinity,
          height: 90,
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Align(
            alignment: AlignmentDirectional(0, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 8),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        await _navigate(context, 0);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 3, 0, 0),
                            child: FaIcon(
                              FaIconData(
                                const IconData(
                                  /* userAlt */ 0xf007,
                                  fontFamily: 'FontAwesomeRegular',
                                  fontPackage: 'font_awesome_flutter',
                                ),
                              ),
                              color: widget.selectedIndex == 0
                                  ? AppTheme.of(context).primary
                                  : AppTheme.of(context).secondaryText,
                              size: 24,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 3, 0, 0),
                            child: Text(
                              'Profile',
                              style: AppTheme.of(context).labelSmall.override(
                                font: GoogleFonts.playfairDisplay(
                                  fontWeight: AppTheme.of(context)
                                      .labelSmall
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .labelSmall
                                      .fontStyle,
                                ),
                                color: widget.selectedIndex == 0
                                    ? AppTheme.of(context).primary
                                    : AppTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: AppTheme.of(context)
                                    .labelSmall
                                    .fontWeight,
                                fontStyle: AppTheme.of(context)
                                    .labelSmall
                                    .fontStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        await _navigate(context, 1);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FaIcon(
                            FaIconData(
                              const IconData(
                                /* comment */ 0xf075,
                                fontFamily: 'FontAwesomeRegular',
                                fontPackage: 'font_awesome_flutter',
                              ),
                            ),
                            color: widget.selectedIndex == 1
                                ? AppTheme.of(context).primary
                                : AppTheme.of(context).secondaryText,
                            size: 36,
                          ),
                          Text(
                            'Posts',
                            style: AppTheme.of(context).labelSmall.override(
                              font: GoogleFonts.playfairDisplay(
                                fontWeight: AppTheme.of(context)
                                    .labelSmall
                                    .fontWeight,
                                fontStyle: AppTheme.of(context)
                                    .labelSmall
                                    .fontStyle,
                              ),
                              color: widget.selectedIndex == 1
                                  ? AppTheme.of(context).primary
                                  : AppTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              fontWeight: AppTheme.of(context)
                                  .labelSmall
                                  .fontWeight,
                              fontStyle: AppTheme.of(context)
                                  .labelSmall
                                  .fontStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 8),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        await _navigate(context, 2);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0, 1),
                            child: Icon(
                              Icons.settings_outlined,
                              color: widget.selectedIndex == 2
                                  ? AppTheme.of(context).primary
                                  : AppTheme.of(context).secondaryText,
                              size: 30,
                            ),
                          ),
                          Text(
                            'Settings',
                            style: AppTheme.of(context).labelSmall.override(
                              font: GoogleFonts.playfairDisplay(
                                fontWeight: AppTheme.of(context)
                                    .labelSmall
                                    .fontWeight,
                                fontStyle: AppTheme.of(context)
                                    .labelSmall
                                    .fontStyle,
                              ),
                              color: widget.selectedIndex == 2
                                  ? AppTheme.of(context).primary
                                  : AppTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              fontWeight: AppTheme.of(context)
                                  .labelSmall
                                  .fontWeight,
                              fontStyle: AppTheme.of(context)
                                  .labelSmall
                                  .fontStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ].divide(SizedBox(width: 36)),
            ),
          ),
        ),
      ),
    );
  }
}
