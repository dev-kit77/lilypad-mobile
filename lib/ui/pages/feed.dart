import 'dart:io';

import 'package:lilypad/models/post.dart';
import 'package:lilypad/services/content.dart';
import 'package:lilypad/services/geolocation.dart';
import 'package:lilypad/services/ui/dialog.dart';
import 'package:lilypad/services/user.dart';
import 'package:lilypad/util/api_ex.dart';

import '../widgets/logo.dart';
import '../widgets/post.dart';

import 'package:material_ui/material_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wiggly_loaders/wiggly_loaders.dart';

import '../theme/theme.dart';
import '../../util/ui.dart';
import 'new_post.dart' show NewPostWidget;
import '../widgets/navbar.dart';

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

  WigglyButtonState postButtonState = WigglyButtonState.idle;

  @override
  void initState() {
    super.initState();

    feedTabsController = TabController(vsync: this, length: 2, initialIndex: 0)
      ..addListener(() => setState(() {}));

    //wait for the first frame so dialogs have a navigator context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadContent(widget.noCache);
      }
    });
  }

  Future<void> _loadContent(bool refresh) async {
    //keep the header in sync with the current area
    currLocale = GeolocationService.locale;

    if (!GeolocationService.initalized) {
      if (mounted) {
        setState(() {
          feed = null;
          newest = null;
        });
      }
      if (mounted) {
        await DialogService.showAlert(
          'Geolocation Error',
          'Geolocation is not enabled. \nLilypad requires location services to show you posts.',
        );
      }
      return;
    }

    try {
      //attempt fetch current user
      await UserService.fetch(noCache: refresh);
    } on APIException catch (e) {
      if (mounted) {
        await DialogService.showAlert(
          'User Error ${e.statusCode}',
          '${e.message}. \nUnable to fetch Current User.',
        );
      }
    } on SocketException catch (e) {
      if (mounted) {
        await DialogService.showAlert(
          'Service Error ${e.osError?.errorCode ?? 0}',
          '${e.message}. \nCannot Connect to API.',
        );
      }
    } on Exception {
      if (mounted) {
        await DialogService.showAlert(
          'Unknown Error.',
          'Error fetching Current User.',
        );
      }
    }

    try {
      //attempt fetch feed
      final List<Post> f = await ContentService.fetchFeed(noCache: refresh);
      if (mounted) {
        setState(() {
          feed = f;
          newest = ContentService.newestFeed;
        });
      }
    } on APIException catch (e) {
      if (mounted) {
        await DialogService.showAlert(
          'Feed Error ${e.statusCode}',
          '${e.message}. \nUnable to fetch Current Feed.',
        );
      }
    } on SocketException catch (e) {
      if (mounted) {
        await DialogService.showAlert(
          'Service Error ${e.osError?.errorCode ?? 0}',
          '${e.message}. \nCannot Connect to API.',
        );
      }
    } on Exception {
      if (mounted) {
        await DialogService.showAlert(
          'Unknown Error.',
          'Error fetching Current Feed.',
        );
      }
    }
  }

  /// Re-read the location and reload the feed.
  Future<void> _retry() async {
    try {
      await GeolocationService.forceUpdate();
    } catch (e) {
      await DialogService.showAlert(
        'Geolocation Error',
        'Unable to refresh location.',
      );
      return;
    }
    await _loadContent(true);
  }

  void _openNewPost() async {
    //set loading state
    if (mounted) {
      setState(() => postButtonState = WigglyButtonState.loading);
    }

    //hold state for user
    Future.delayed(const Duration(milliseconds: 500), () async {
      //open post window
      if (mounted) {
        final newPost = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(builder: (context) => const NewPostWidget()),
        );

        //check created
        if (newPost == true) {
          //begin content reload
          _loadContent(true);

          //show success
          if (mounted) {
            setState(() => postButtonState = WigglyButtonState.success);
          }

          //hold state for user
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() => postButtonState = WigglyButtonState.idle);
            }
          });
        } else {
          //set back to idle
          if (mounted) {
            setState(() => postButtonState = WigglyButtonState.idle);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    feedTabsController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonOptions = AppTheme.of(context).wigglyButtonOptions
        .copyWith(width: 70, height: 70, borderRadius: 40);

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
                                                      ? Column(
                                                          children: [
                                                            Text(
                                                              'Could Not Fetch Posts.',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: AppTheme.of(context).titleLarge.override(
                                                                font: GoogleFonts.playfairDisplay(
                                                                  fontWeight:
                                                                      AppTheme.of(
                                                                        context,
                                                                      ).titleLarge.fontWeight,
                                                                  fontStyle:
                                                                      AppTheme.of(
                                                                        context,
                                                                      ).titleLarge.fontStyle,
                                                                ),
                                                                letterSpacing:
                                                                    0.0,
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
                                                            TextButton(
                                                              onPressed: _retry,
                                                              child: Text(
                                                                'Retry',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: AppTheme.of(context).labelLarge.override(
                                                                  font: GoogleFonts.playfairDisplay(
                                                                    fontWeight:
                                                                        AppTheme.of(
                                                                          context,
                                                                        ).labelLarge.fontWeight,
                                                                    fontStyle:
                                                                        AppTheme.of(
                                                                          context,
                                                                        ).labelLarge.fontStyle,
                                                                  ),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      AppTheme.of(
                                                                        context,
                                                                      ).labelLarge.fontWeight,
                                                                  fontStyle:
                                                                      AppTheme.of(
                                                                        context,
                                                                      ).labelLarge.fontStyle,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
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
                                                      ? Column(
                                                          children: [
                                                            Text(
                                                              'Could Not Fetch Posts.',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: AppTheme.of(context).titleLarge.override(
                                                                font: GoogleFonts.playfairDisplay(
                                                                  fontWeight:
                                                                      AppTheme.of(
                                                                        context,
                                                                      ).titleLarge.fontWeight,
                                                                  fontStyle:
                                                                      AppTheme.of(
                                                                        context,
                                                                      ).titleLarge.fontStyle,
                                                                ),
                                                                letterSpacing:
                                                                    0.0,
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
                                                            TextButton(
                                                              onPressed: _retry,
                                                              child: Text(
                                                                'Retry',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: AppTheme.of(context).labelLarge.override(
                                                                  font: GoogleFonts.playfairDisplay(
                                                                    fontWeight:
                                                                        AppTheme.of(
                                                                          context,
                                                                        ).labelLarge.fontWeight,
                                                                    fontStyle:
                                                                        AppTheme.of(
                                                                          context,
                                                                        ).labelLarge.fontStyle,
                                                                  ),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      AppTheme.of(
                                                                        context,
                                                                      ).labelLarge.fontWeight,
                                                                  fontStyle:
                                                                      AppTheme.of(
                                                                        context,
                                                                      ).labelLarge.fontStyle,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
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
                        child: WigglyProgressButton(
                          state: postButtonState,
                          onPressed: _openNewPost,
                          width: buttonOptions.width,
                          height: buttonOptions.height,
                          borderRadius: buttonOptions.borderRadius,
                          wiggleAmplitude: buttonOptions.wiggleAmplitudeFor(
                            postButtonState,
                          ),
                          wiggleCount: buttonOptions.wiggleCount,
                          wiggleDuration: buttonOptions.wiggleDuration,
                          morphDuration: buttonOptions.morphDuration,
                          progressColor: buttonOptions.progressColor,
                          foregroundColor: buttonOptions.foregroundColor,
                          successColor: buttonOptions.successColor,
                          errorColor: buttonOptions.errorColor,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: FaIcon(
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
