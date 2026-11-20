import '../widgets/logo.dart';
import '../widgets/user_post.dart';
import '../widgets/user.dart';

import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/theme.dart';
import '../../util/ui.dart';
import '../widgets/navbar.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({
    super.key,
    String? username,
    String? status,
    String? bio,
  }) : this.username = username ?? 'devkit',
       this.status = status ?? 'Developing lilypad',
       this.bio = bio ?? 'I am the lilypad guy!';

  final String username;
  final String status;
  final String bio;

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

  @override
  void initState() {
    super.initState();

    tabBarController = TabController(vsync: this, length: 2, initialIndex: 0)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    tabBarController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        decoration: BoxDecoration(),
        child: Container(
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
                        padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
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
                                                    MediaQuery.sizeOf(context)
                                                        .height *
                                                    0,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.of(context)
                                                      .secondaryBackground,
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
                                                .titleMedium
                                                .override(
                                                  font:
                                                      GoogleFonts.playfairDisplay(
                                                        fontWeight:
                                                            AppTheme.of(context)
                                                                .titleMedium
                                                                .fontWeight,
                                                        fontStyle: AppTheme.of(
                                                          context,
                                                        ).titleMedium.fontStyle,
                                                      ),
                                                  letterSpacing: 0.0,
                                                  fontWeight: AppTheme.of(
                                                    context,
                                                  ).titleMedium.fontWeight,
                                                  fontStyle: AppTheme.of(
                                                    context,
                                                  ).titleMedium.fontStyle,
                                                ),
                                          ),
                                        ),
                                        UserWidget(
                                          username: widget.username,
                                          userStatus: widget.status,
                                          userBio: widget.bio,
                                        ),
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
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 90),
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
                                    unselectedLabelColor: AppTheme.of(context)
                                        .secondaryText,
                                    labelStyle: AppTheme.of(context).titleLarge
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
                                    unselectedLabelStyle: AppTheme.of(context)
                                        .titleMedium
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
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                          12,
                                          0,
                                          12,
                                          0,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            ListView(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              primary: false,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              children: [
                                                UserPostWidget(
                                                  username: widget.username,
                                                  content:
                                                      'I am dying to this ui',
                                                  noUpvotes: 667,
                                                  noReplies: 34,
                                                ),
                                              ].divide(SizedBox(height: 12)),
                                            ),
                                            Text(
                                              'You\'re all caught up!',
                                              textAlign: TextAlign.center,
                                              style: AppTheme.of(context)
                                                  .titleLarge
                                                  .override(
                                                    font:
                                                        GoogleFonts.playfairDisplay(
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
                                                    fontWeight: AppTheme.of(
                                                      context,
                                                    ).titleLarge.fontWeight,
                                                    fontStyle: AppTheme.of(
                                                      context,
                                                    ).titleLarge.fontStyle,
                                                  ),
                                            ),
                                          ].addToEnd(SizedBox(height: 12)),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                          12,
                                          0,
                                          12,
                                          0,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            ListView(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              primary: false,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              children: <Widget>[].divide(
                                                SizedBox(height: 12),
                                              ),
                                            ),
                                            Text(
                                              'You\'re all caught up!',
                                              textAlign: TextAlign.center,
                                              style: AppTheme.of(context)
                                                  .titleLarge
                                                  .override(
                                                    font:
                                                        GoogleFonts.playfairDisplay(
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
                                                    fontWeight: AppTheme.of(
                                                      context,
                                                    ).titleLarge.fontWeight,
                                                    fontStyle: AppTheme.of(
                                                      context,
                                                    ).titleLarge.fontStyle,
                                                  ),
                                            ),
                                          ].addToEnd(SizedBox(height: 12)),
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
    );
  }
}
