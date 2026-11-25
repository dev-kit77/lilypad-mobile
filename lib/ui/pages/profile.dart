import 'dart:io';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lilypad/models/post.dart';
import 'package:lilypad/models/user.dart';
import 'package:lilypad/services/content.dart';
import 'package:lilypad/services/ui/dialog.dart';
import 'package:lilypad/services/user.dart';
import 'package:lilypad/ui/pages/new_post.dart';
import 'package:lilypad/ui/widgets/post.dart';
import 'package:lilypad/util/api_ex.dart';
import 'package:page_transition/page_transition.dart';

import '../widgets/logo.dart';
import '../widgets/user.dart';

import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wiggly_loaders/wiggly_loaders.dart';

import '../theme/theme.dart';
import '../../util/ui.dart';
import '../widgets/navbar.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key, this.noCache = false});

  /// Skip cached data when fetching this page's content.
  final bool noCache;

  static String routeName = 'profile';
  static String routePath = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget>
    with TickerProviderStateMixin {
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  CurrentUser? currUser;
  List<Post>? userPosts;
  List<Post>? userReplies;

  bool loadingUser = true;
  bool loadingPosts = true;

  WigglyButtonState postButtonState = WigglyButtonState.idle;

  @override
  void initState() {
    super.initState();

    _loadUser(widget.noCache);
    _loadPost(widget.noCache);

    tabBarController = TabController(vsync: this, length: 2, initialIndex: 0)
      ..addListener(() => setState(() {}));
  }

  void _syncPost(Post p) {
    if (mounted && userPosts != null && userReplies != null) {
      setState(() {
        //for both lists
        for (final list in <List<Post>?>[userPosts, userReplies]) {
          //find indexes where post ids equal
          final i = list?.indexWhere((e) => e.uuid == p.uuid) ?? -1;

          //replace if found
          if (i >= 0) list![i] = p;
        }
      });
    }
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
          PageTransition<bool>(
            type: PageTransitionType.fade,
            duration: const Duration(milliseconds: 300),
            reverseDuration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
            opaque: true,
            settings: RouteSettings(name: NewPostWidget.routePath),
            child: const NewPostWidget(),
          ),
        );

        //check if post made
        if (newPost == true) {
          //begin content reload
          _loadPost(true);

          if (mounted) {
            //show success
            setState(() => postButtonState = WigglyButtonState.success);
          }

          //hold state for user
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() => postButtonState = WigglyButtonState.idle);
            }
          });
        } else {
          if (mounted) {
            //set back to idle
            setState(() => postButtonState = WigglyButtonState.idle);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    tabBarController?.dispose();

    super.dispose();
  }

  Future<void> _loadUser(bool refresh) async {
    try {
      setState(() {
        loadingUser = true;
      });
      //attempt fetch current user
      CurrentUser u = await UserService.fetch(noCache: refresh);
      setState(() {
        currUser = u;
        loadingUser = false;
      });
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
  }

  Future<void> _loadPost(bool refresh) async {
    try {
      setState(() {
        loadingPosts = true;
      });

      //attempt fetch feed
      final postMap = await ContentService.fetchUserContent(noCache: refresh);

      if (mounted) {
        setState(() {
          userPosts = postMap['posts']!;
          userReplies = postMap['replies']!;
          loadingPosts = false;
        });
      }
    } on APIException catch (e) {
      if (mounted) {
        await DialogService.showAlert(
          'Feed Error ${e.statusCode}',
          '${e.message}. \nUnable to fetch User Feed.',
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
          'Error fetching User Feed.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonOptions = AppTheme.of(context).wigglyButtonOptions
        .copyWith(width: 70, height: 70, borderRadius: 40);

    return Scaffold(
      key: scaffoldKey,
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
                              16,
                              0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Stack(
                                  children: [
                                    SafeArea(
                                      left: false,
                                      top: false,
                                      right: false,
                                      bottom: false,
                                      child: Container(
                                        key: ValueKey('header'),
                                        width: MediaQuery.sizeOf(context).width,
                                        decoration: BoxDecoration(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          textBaseline: TextBaseline.alphabetic,
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
                                            Padding(
                                              padding:
                                                  EdgeInsetsDirectional.fromSTEB(
                                                    0,
                                                    4,
                                                    0,
                                                    4,
                                                  ),
                                              child: Text(
                                                'Your Profile.',
                                                textAlign: TextAlign.start,
                                                style: AppTheme.of(context)
                                                    .title
                                                    .override(
                                                      font:
                                                          GoogleFonts.playfairDisplay(
                                                            fontWeight:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .title
                                                                    .fontWeight,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .title
                                                                    .fontStyle,
                                                          ),
                                                      letterSpacing: 0.0,
                                                      fontWeight: AppTheme.of(
                                                        context,
                                                      ).title.fontWeight,
                                                      fontStyle: AppTheme.of(
                                                        context,
                                                      ).title.fontStyle,
                                                    ),
                                              ),
                                            ),
                                            UserWidget(user: currUser!),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
                                            AppTheme.of(context).title.override(
                                              font: GoogleFonts.playfairDisplay(
                                                fontWeight: AppTheme.of(context)
                                                    .title
                                                    .fontWeight,
                                                fontStyle: AppTheme.of(context)
                                                    .title
                                                    .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight: AppTheme.of(context)
                                                  .title
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .title
                                                  .fontStyle,
                                            ),
                                        indicatorColor: AppTheme.of(context)
                                            .primary,
                                        tabs: [
                                          Tab(text: 'Your Posts'),
                                          Tab(text: 'Your Replies'),
                                        ],
                                        controller: tabBarController,
                                        onTap: (i) async {
                                          [() async {}, () async {}][i]();
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        controller: tabBarController,
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
                                                    children:
                                                        userPosts
                                                            ?.map(
                                                              (p) => PostWidget(
                                                                post: p,
                                                                onUpdate:
                                                                    _syncPost,
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
                                                  userPosts == null
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
                                                              onPressed: () =>
                                                                  _loadPost(
                                                                    true,
                                                                  ),
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
                                                        userReplies
                                                            ?.map(
                                                              (p) => PostWidget(
                                                                post: p,
                                                                onUpdate:
                                                                    _syncPost,
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
                                                  userReplies == null
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
                                                              onPressed: () =>
                                                                  _loadPost(
                                                                    true,
                                                                  ),
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
                  SafeArea(
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
                  const NavBarWidget(selectedIndex: 0),
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
