import 'package:lilypad/models/post.dart';
import 'package:lilypad/services/content.dart';
import 'package:lilypad/services/geolocation.dart';
import 'package:lilypad/services/user.dart';

import '../widgets/logo.dart';
import '../widgets/post.dart';

import 'package:material_ui/material_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/theme.dart';
import '../../util/ui.dart';
import 'new_post.dart' show NewPostWidget;
import '../widgets/navbar.dart';
import '../widgets/buttons.dart';

class FeedWidget extends StatefulWidget {
  const FeedWidget({super.key, this.noCache = false});

  /// Skip cached data when fetching this page's content.
  final bool noCache;

  static String routeName = 'feed';
  static String routePath = '/feed';

  @override
  State<FeedWidget> createState() => _FeedWidgetState();
}

class _FeedWidgetState extends State<FeedWidget> with TickerProviderStateMixin {
  // State field(s) for feedTabs widget.
  TabController? feedTabsController;
  int get feedTabsCurrentIndex =>
      feedTabsController != null ? feedTabsController!.index : 0;
  int get feedTabsPreviousIndex =>
      feedTabsController != null ? feedTabsController!.previousIndex : 0;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? currLocale;
  List<Post>? feed;
  List<Post>? newest;

  @override
  void initState() {
    super.initState();

    //fetch content
    _loadContent(widget.noCache);

    feedTabsController = TabController(vsync: this, length: 2, initialIndex: 0)
      ..addListener(() => setState(() {}));
  }

  void _loadContent(bool refresh) {
    currLocale = GeolocationService.locale;
    UserService.fetch().then(
      (u) => ContentService.fetchFeed(noCache: refresh).then(
        (f) => {
          setState(() {
            refresh = false;
            feed = f;
            newest = ContentService.newestFeed;
          }),
        },
      ),
    );
  }

  @override
  void dispose() {
    feedTabsController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.sizeOf(context).height,
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional(0, -1),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              16,
                              0,
                              0,
                              0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        0,
                                        0,
                                        0,
                                        4,
                                      ),
                                      child: SafeArea(
                                        left: false,
                                        top: false,
                                        right: false,
                                        bottom: false,
                                        child: Container(
                                          key: ValueKey('header'),
                                          width: MediaQuery.sizeOf(context)
                                              .width,
                                          decoration: BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            children: [
                                              Stack(
                                                children: [
                                                  SafeArea(
                                                    left: false,
                                                    top: true,
                                                    right: false,
                                                    bottom: false,
                                                    child: Container(
                                                      width: double.infinity,
                                                      height:
                                                          MediaQuery.sizeOf(
                                                            context,
                                                          ).height *
                                                          0,
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).secondaryBackground,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              LogoWidget(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  currLocale ?? '',
                                  textAlign: TextAlign.start,
                                  style: AppTheme.of(context).titleMedium
                                      .override(
                                        font: GoogleFonts.playfairDisplay(
                                          fontWeight: AppTheme.of(context)
                                              .titleMedium
                                              .fontWeight,
                                          fontStyle: AppTheme.of(context)
                                              .titleMedium
                                              .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: AppTheme.of(context)
                                            .titleMedium
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.sizeOf(context).height -
                                MediaQuery.paddingOf(context).top,
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0,
                                0,
                                0,
                                90,
                              ),
                              child: Container(
                                width: double.infinity,
                                height: MediaQuery.sizeOf(context).height,
                                decoration: BoxDecoration(),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment(0, 0),
                                      child: TabBar(
                                        labelColor: AppTheme.of(context)
                                            .primaryText,
                                        unselectedLabelColor: AppTheme.of(
                                          context,
                                        ).secondaryText,
                                        labelStyle: AppTheme.of(context)
                                            .titleLarge
                                            .override(
                                              font: GoogleFonts.playfairDisplay(
                                                fontWeight: AppTheme.of(context)
                                                    .titleLarge
                                                    .fontWeight,
                                                fontStyle: AppTheme.of(context)
                                                    .titleLarge
                                                    .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight: AppTheme.of(context)
                                                  .titleLarge
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .titleLarge
                                                  .fontStyle,
                                            ),
                                        unselectedLabelStyle:
                                            AppTheme.of(
                                              context,
                                            ).titleMedium.override(
                                              font: GoogleFonts.playfairDisplay(
                                                fontWeight: AppTheme.of(context)
                                                    .titleMedium
                                                    .fontWeight,
                                                fontStyle: AppTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight: AppTheme.of(context)
                                                  .titleMedium
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                            ),
                                        indicatorColor: AppTheme.of(context)
                                            .primary,
                                        tabs: [
                                          Tab(text: 'Top Posts'),
                                          Tab(text: 'Latest'),
                                        ],
                                        controller: feedTabsController,
                                      ),
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        controller: feedTabsController,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                  12,
                                                  0,
                                                  12,
                                                  0,
                                                ),
                                            child: SingleChildScrollView(
                                              primary: false,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  ListView(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    primary: false,
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    //TODO: Add Sorting of feed
                                                    children:
                                                        feed
                                                            ?.map(
                                                              (p) => PostWidget(
                                                                post: p,
                                                              ),
                                                            )
                                                            .toList()
                                                            .divide(
                                                              SizedBox(
                                                                height: 12,
                                                              ),
                                                            ) ??
                                                        [],
                                                  ),
                                                  feed == null
                                                      ? Text(
                                                          'Could Not Fetch Posts.',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: AppTheme.of(context).titleLarge.override(
                                                            font: GoogleFonts.playfairDisplay(
                                                              fontWeight:
                                                                  AppTheme.of(
                                                                        context,
                                                                      )
                                                                      .titleLarge
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  AppTheme.of(
                                                                        context,
                                                                      )
                                                                      .titleLarge
                                                                      .fontStyle,
                                                            ),
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .titleLarge
                                                                    .fontWeight,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .titleLarge
                                                                    .fontStyle,
                                                          ),
                                                        )
                                                      : Text(
                                                          'You\'re all caught up!',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: AppTheme.of(context).titleLarge.override(
                                                            font: GoogleFonts.playfairDisplay(
                                                              fontWeight:
                                                                  AppTheme.of(
                                                                        context,
                                                                      )
                                                                      .titleLarge
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  AppTheme.of(
                                                                        context,
                                                                      )
                                                                      .titleLarge
                                                                      .fontStyle,
                                                            ),
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .titleLarge
                                                                    .fontWeight,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .titleLarge
                                                                    .fontStyle,
                                                          ),
                                                        ),
                                                ].addToEnd(SizedBox(height: 12)),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                  12,
                                                  0,
                                                  12,
                                                  0,
                                                ),
                                            child: SingleChildScrollView(
                                              primary: false,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  ListView(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    primary: false,
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    children:
                                                        newest
                                                            ?.map(
                                                              (p) => PostWidget(
                                                                post: p,
                                                              ),
                                                            )
                                                            .toList()
                                                            .divide(
                                                              SizedBox(
                                                                height: 12,
                                                              ),
                                                            ) ??
                                                        [],
                                                  ),
                                                  newest == null
                                                      ? Text(
                                                          'Could Not Fetch Posts.',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: AppTheme.of(context).titleLarge.override(
                                                            font: GoogleFonts.playfairDisplay(
                                                              fontWeight:
                                                                  AppTheme.of(
                                                                        context,
                                                                      )
                                                                      .titleLarge
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  AppTheme.of(
                                                                        context,
                                                                      )
                                                                      .titleLarge
                                                                      .fontStyle,
                                                            ),
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .titleLarge
                                                                    .fontWeight,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .titleLarge
                                                                    .fontStyle,
                                                          ),
                                                        )
                                                      : Text(
                                                          'You\'re all caught up!',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: AppTheme.of(context).titleLarge.override(
                                                            font: GoogleFonts.playfairDisplay(
                                                              fontWeight:
                                                                  AppTheme.of(
                                                                        context,
                                                                      )
                                                                      .titleLarge
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  AppTheme.of(
                                                                        context,
                                                                      )
                                                                      .titleLarge
                                                                      .fontStyle,
                                                            ),
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .titleLarge
                                                                    .fontWeight,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .titleLarge
                                                                    .fontStyle,
                                                          ),
                                                        ),
                                                ].addToEnd(SizedBox(height: 12)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: SafeArea(
                      left: false,
                      top: false,
                      right: false,
                      bottom: false,
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery.paddingOf(context).top,
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).primaryBackground,
                        ),
                      ),
                    ),
                  ),
                  const NavBarWidget(selectedIndex: 1),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 106),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Material(
                        color: Colors.transparent,
                        elevation: 3,
                        shape: const CircleBorder(),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: AppIconButton(
                            borderRadius: 40,
                            buttonSize: 70,
                            fillColor: AppTheme.of(context).primary,
                            icon: FaIcon(
                              FaIconData(
                                const IconData(
                                  /* pencilAlt */ 0xf303,
                                  fontFamily: 'FontAwesomeSolid',
                                  fontPackage: 'font_awesome_flutter',
                                ),
                              ),
                              color: AppTheme.of(context).info,
                              size: 36,
                            ),
                            onPressed: () async {
                              final bool newPost =
                                  await Navigator.of(context).push<bool>(
                                    MaterialPageRoute<bool>(
                                      builder: (context) => NewPostWidget(),
                                    ),
                                  ) as bool;

                              if (newPost == true && mounted) {
                                _loadContent(true);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
