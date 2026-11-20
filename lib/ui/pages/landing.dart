import '../widgets/logo.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/theme.dart';
import '../../util/ui.dart';
import '../widgets/buttons.dart';
import 'feed.dart' show FeedWidget;

class LandingWidget extends StatefulWidget {
  const LandingWidget({
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

  static String routeName = 'landing';
  static String routePath = '/landing';

  @override
  State<LandingWidget> createState() => _LandingWidgetState();
}

class _LandingWidgetState extends State<LandingWidget>
    with TickerProviderStateMixin {
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode1;
  TextEditingController? emailAddressTextController1;
  String? Function(BuildContext, String?)? emailAddressTextController1Validator;
  // State field(s) for password widget.
  late FocusNode passwordPasswordVisibilityFocusNode1;
  FocusNode? passwordFocusNode1;
  TextEditingController? passwordTextController1;
  late bool passwordVisibility1;
  String? Function(BuildContext, String?)? passwordTextController1Validator;
  // State field(s) for username widget.
  FocusNode? usernameFocusNode;
  TextEditingController? usernameTextController;
  String? Function(BuildContext, String?)? usernameTextControllerValidator;
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode2;
  TextEditingController? emailAddressTextController2;
  String? Function(BuildContext, String?)? emailAddressTextController2Validator;
  // State field(s) for password widget.
  late FocusNode passwordPasswordVisibilityFocusNode2;
  FocusNode? passwordFocusNode2;
  TextEditingController? passwordTextController2;
  late bool passwordVisibility2;
  String? Function(BuildContext, String?)? passwordTextController2Validator;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    passwordPasswordVisibilityFocusNode1 = FocusNode();
    passwordVisibility1 = false;
    passwordPasswordVisibilityFocusNode2 = FocusNode();
    passwordVisibility2 = false;

    tabBarController = TabController(vsync: this, length: 2, initialIndex: 0)
      ..addListener(() => setState(() {}));

    emailAddressTextController1 ??= TextEditingController();
    emailAddressFocusNode1 ??= FocusNode();

    passwordTextController1 ??= TextEditingController();
    passwordFocusNode1 ??= FocusNode();

    usernameTextController ??= TextEditingController();
    usernameFocusNode ??= FocusNode();

    emailAddressTextController2 ??= TextEditingController();
    emailAddressFocusNode2 ??= FocusNode();

    passwordTextController2 ??= TextEditingController();
    passwordFocusNode2 ??= FocusNode();
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    emailAddressFocusNode1?.dispose();
    emailAddressTextController1?.dispose();

    passwordFocusNode1?.dispose();
    passwordTextController1?.dispose();
    passwordPasswordVisibilityFocusNode1.dispose();
    usernameFocusNode?.dispose();
    usernameTextController?.dispose();

    emailAddressFocusNode2?.dispose();
    emailAddressTextController2?.dispose();

    passwordFocusNode2?.dispose();
    passwordTextController2?.dispose();
    passwordPasswordVisibilityFocusNode2.dispose();

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
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        0,
                                        36,
                                        0,
                                        36,
                                      ),
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
                                              'The Local Social Media.',
                                              textAlign: TextAlign.start,
                                              style: AppTheme.of(context)
                                                  .titleMedium
                                                  .override(
                                                    font:
                                                        GoogleFonts.playfairDisplay(
                                                          fontWeight:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .titleMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .titleMedium
                                                                  .fontStyle,
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
                                        ],
                                      ),
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
                        child: Container(
                          width: double.infinity,
                          height: MediaQuery.sizeOf(context).height,
                          decoration: BoxDecoration(),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment(0, 0),
                                child: TabBar(
                                  labelColor: AppTheme.of(context).primaryText,
                                  unselectedLabelColor: AppTheme.of(context)
                                      .secondaryText,
                                  labelStyle: AppTheme.of(context).displaySmall
                                      .override(
                                        font: GoogleFonts.playfairDisplay(
                                          fontWeight: AppTheme.of(context)
                                              .displaySmall
                                              .fontWeight,
                                          fontStyle: AppTheme.of(context)
                                              .displaySmall
                                              .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: AppTheme.of(context)
                                            .displaySmall
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .displaySmall
                                            .fontStyle,
                                        lineHeight: 1,
                                      ),
                                  unselectedLabelStyle: AppTheme.of(context)
                                      .displaySmall
                                      .override(
                                        font: GoogleFonts.playfairDisplay(
                                          fontWeight: AppTheme.of(context)
                                              .displaySmall
                                              .fontWeight,
                                          fontStyle: AppTheme.of(context)
                                              .displaySmall
                                              .fontStyle,
                                        ),
                                        fontSize: 32,
                                        letterSpacing: 0.0,
                                        fontWeight: AppTheme.of(context)
                                            .displaySmall
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .displaySmall
                                            .fontStyle,
                                        lineHeight: 1.5,
                                      ),
                                  indicatorColor: AppTheme.of(context).primary,
                                  tabs: [
                                    Tab(text: 'Sign In'),
                                    Tab(text: 'Sign Up'),
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
                                        16,
                                        0,
                                        16,
                                        0,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Welcome back! Please fill out your login Information below.',
                                            style: AppTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  font:
                                                      GoogleFonts.playfairDisplay(
                                                        fontWeight:
                                                            AppTheme.of(context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle: AppTheme.of(
                                                          context,
                                                        ).labelMedium.fontStyle,
                                                      ),
                                                  letterSpacing: 0.0,
                                                  fontWeight: AppTheme.of(
                                                    context,
                                                  ).labelMedium.fontWeight,
                                                  fontStyle: AppTheme.of(
                                                    context,
                                                  ).labelMedium.fontStyle,
                                                ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              controller:
                                                  emailAddressTextController1,
                                              focusNode: emailAddressFocusNode1,
                                              autofocus: true,
                                              enabled: true,
                                              autofillHints: [
                                                AutofillHints.email,
                                              ],
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                labelText: 'Email',
                                                labelStyle: AppTheme.of(context)
                                                    .labelLarge
                                                    .override(
                                                      font:
                                                          GoogleFonts.playfairDisplay(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelLarge
                                                                    .fontStyle,
                                                          ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle: AppTheme.of(
                                                        context,
                                                      ).labelLarge.fontStyle,
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).alternate,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).primary,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppTheme.of(context)
                                                        .error,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).error,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                filled: true,
                                                fillColor: AppTheme.of(context)
                                                    .secondaryBackground,
                                                contentPadding: EdgeInsets.all(
                                                  24,
                                                ),
                                              ),
                                              style: AppTheme.of(context)
                                                  .bodyLarge
                                                  .override(
                                                    font:
                                                        GoogleFonts.playfairDisplay(
                                                          fontWeight:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .bodyLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .bodyLarge
                                                                  .fontStyle,
                                                        ),
                                                    letterSpacing: 0.0,
                                                    fontWeight: AppTheme.of(
                                                      context,
                                                    ).bodyLarge.fontWeight,
                                                    fontStyle: AppTheme.of(
                                                      context,
                                                    ).bodyLarge.fontStyle,
                                                  ),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              cursorColor: AppTheme.of(context)
                                                  .primary,
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              controller:
                                                  passwordTextController1,
                                              focusNode: passwordFocusNode1,
                                              autofocus: false,
                                              enabled: true,
                                              autofillHints: [
                                                AutofillHints.password,
                                              ],
                                              obscureText: !passwordVisibility1,
                                              decoration: InputDecoration(
                                                labelText: 'Password',
                                                labelStyle: AppTheme.of(context)
                                                    .labelLarge
                                                    .override(
                                                      font:
                                                          GoogleFonts.playfairDisplay(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelLarge
                                                                    .fontStyle,
                                                          ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle: AppTheme.of(
                                                        context,
                                                      ).labelLarge.fontStyle,
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).alternate,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).primary,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppTheme.of(context)
                                                        .error,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).error,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                filled: true,
                                                fillColor: AppTheme.of(context)
                                                    .secondaryBackground,
                                                contentPadding: EdgeInsets.all(
                                                  24,
                                                ),
                                                suffixIcon: InkWell(
                                                  onTap: () async {
                                                    setState(
                                                      () => passwordVisibility1 =
                                                          !passwordVisibility1,
                                                    );
                                                  },
                                                  focusNode:
                                                      passwordPasswordVisibilityFocusNode1
                                                        ..skipTraversal =
                                                            !(false),
                                                  child: Icon(
                                                    passwordVisibility1
                                                        ? Icons
                                                              .visibility_outlined
                                                        : Icons
                                                              .visibility_off_outlined,
                                                    color: AppTheme.of(context)
                                                        .secondaryText,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                              style: AppTheme.of(context)
                                                  .bodyLarge
                                                  .override(
                                                    font:
                                                        GoogleFonts.playfairDisplay(
                                                          fontWeight:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .bodyLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .bodyLarge
                                                                  .fontStyle,
                                                        ),
                                                    letterSpacing: 0.0,
                                                    fontWeight: AppTheme.of(
                                                      context,
                                                    ).bodyLarge.fontWeight,
                                                    fontStyle: AppTheme.of(
                                                      context,
                                                    ).bodyLarge.fontStyle,
                                                  ),
                                              cursorColor: AppTheme.of(context)
                                                  .primary,
                                            ),
                                          ),
                                          Align(
                                            alignment: AlignmentDirectional(
                                              0,
                                              0,
                                            ),
                                            child: AppButton(
                                              onPressed: () async {
                                                Navigator.of(context)
                                                    .popAndPushNamed(
                                                      FeedWidget.routePath,
                                                    );
                                              },
                                              text: 'Sign In',
                                              icon: FaIcon(
                                                FaIconData(
                                                  const IconData(
                                                    /* signInAlt */ 0xf2f6,
                                                    fontFamily:
                                                        'FontAwesomeSolid',
                                                    fontPackage:
                                                        'font_awesome_flutter',
                                                  ),
                                                ),
                                                size: 24,
                                              ),
                                              options: AppButtonOptions(
                                                width: 230,
                                                height: 52,
                                                padding:
                                                    EdgeInsetsDirectional.fromSTEB(
                                                      0,
                                                      0,
                                                      0,
                                                      0,
                                                    ),
                                                iconAlignment:
                                                    IconAlignment.end,
                                                iconPadding:
                                                    EdgeInsetsDirectional.fromSTEB(
                                                      0,
                                                      0,
                                                      0,
                                                      0,
                                                    ),
                                                color: AppTheme.of(context)
                                                    .primary,
                                                textStyle: AppTheme.of(context)
                                                    .titleMedium
                                                    .override(
                                                      font:
                                                          GoogleFonts.playfairDisplay(
                                                            fontWeight:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .titleMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .titleMedium
                                                                    .fontStyle,
                                                          ),
                                                      color: Colors.white,
                                                      letterSpacing: 0.0,
                                                      fontWeight: AppTheme.of(
                                                        context,
                                                      ).titleMedium.fontWeight,
                                                      fontStyle: AppTheme.of(
                                                        context,
                                                      ).titleMedium.fontStyle,
                                                    ),
                                                elevation: 3,
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                              ),
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 16)).around(SizedBox(height: 16)),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        16,
                                        0,
                                        16,
                                        0,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Welcome to lilypad! Please enter a unique Username, Email and Password.',
                                            style: AppTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  font:
                                                      GoogleFonts.playfairDisplay(
                                                        fontWeight:
                                                            AppTheme.of(context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle: AppTheme.of(
                                                          context,
                                                        ).labelMedium.fontStyle,
                                                      ),
                                                  letterSpacing: 0.0,
                                                  fontWeight: AppTheme.of(
                                                    context,
                                                  ).labelMedium.fontWeight,
                                                  fontStyle: AppTheme.of(
                                                    context,
                                                  ).labelMedium.fontStyle,
                                                ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              controller:
                                                  usernameTextController,
                                              focusNode: usernameFocusNode,
                                              autofocus: true,
                                              enabled: true,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                labelText: 'Username',
                                                labelStyle: AppTheme.of(context)
                                                    .labelLarge
                                                    .override(
                                                      font:
                                                          GoogleFonts.playfairDisplay(
                                                            fontWeight:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelLarge
                                                                    .fontWeight,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelLarge
                                                                    .fontStyle,
                                                          ),
                                                      letterSpacing: 0.0,
                                                      fontWeight: AppTheme.of(
                                                        context,
                                                      ).labelLarge.fontWeight,
                                                      fontStyle: AppTheme.of(
                                                        context,
                                                      ).labelLarge.fontStyle,
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).alternate,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).primary,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppTheme.of(context)
                                                        .error,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).error,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                filled: true,
                                                fillColor: AppTheme.of(context)
                                                    .secondaryBackground,
                                                contentPadding: EdgeInsets.all(
                                                  24,
                                                ),
                                              ),
                                              style: AppTheme.of(context)
                                                  .bodyLarge
                                                  .override(
                                                    font:
                                                        GoogleFonts.playfairDisplay(
                                                          fontWeight:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .bodyLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .bodyLarge
                                                                  .fontStyle,
                                                        ),
                                                    letterSpacing: 0.0,
                                                    fontWeight: AppTheme.of(
                                                      context,
                                                    ).bodyLarge.fontWeight,
                                                    fontStyle: AppTheme.of(
                                                      context,
                                                    ).bodyLarge.fontStyle,
                                                  ),
                                              maxLength: 64,
                                              maxLengthEnforcement:
                                                  MaxLengthEnforcement.enforced,
                                              buildCounter: (
                                                context, {
                                                required currentLength,
                                                required isFocused,
                                                maxLength,
                                              }) => null,
                                              keyboardType: TextInputType.text,
                                              cursorColor: AppTheme.of(context)
                                                  .primary,
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              controller:
                                                  emailAddressTextController2,
                                              focusNode: emailAddressFocusNode2,
                                              autofocus: true,
                                              enabled: true,
                                              autofillHints: [
                                                AutofillHints.email,
                                              ],
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                labelText: 'Email',
                                                labelStyle: AppTheme.of(context)
                                                    .labelLarge
                                                    .override(
                                                      font:
                                                          GoogleFonts.playfairDisplay(
                                                            fontWeight:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelLarge
                                                                    .fontWeight,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelLarge
                                                                    .fontStyle,
                                                          ),
                                                      letterSpacing: 0.0,
                                                      fontWeight: AppTheme.of(
                                                        context,
                                                      ).labelLarge.fontWeight,
                                                      fontStyle: AppTheme.of(
                                                        context,
                                                      ).labelLarge.fontStyle,
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).alternate,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).primary,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppTheme.of(context)
                                                        .error,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).error,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                filled: true,
                                                fillColor: AppTheme.of(context)
                                                    .secondaryBackground,
                                                contentPadding: EdgeInsets.all(
                                                  24,
                                                ),
                                              ),
                                              style: AppTheme.of(context)
                                                  .bodyLarge
                                                  .override(
                                                    font:
                                                        GoogleFonts.playfairDisplay(
                                                          fontWeight:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .bodyLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .bodyLarge
                                                                  .fontStyle,
                                                        ),
                                                    letterSpacing: 0.0,
                                                    fontWeight: AppTheme.of(
                                                      context,
                                                    ).bodyLarge.fontWeight,
                                                    fontStyle: AppTheme.of(
                                                      context,
                                                    ).bodyLarge.fontStyle,
                                                  ),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              cursorColor: AppTheme.of(context)
                                                  .primary,
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              controller:
                                                  passwordTextController2,
                                              focusNode: passwordFocusNode2,
                                              autofocus: false,
                                              enabled: true,
                                              autofillHints: [
                                                AutofillHints.password,
                                              ],
                                              obscureText: !passwordVisibility2,
                                              decoration: InputDecoration(
                                                labelText: 'Password',
                                                labelStyle: AppTheme.of(context)
                                                    .labelLarge
                                                    .override(
                                                      font:
                                                          GoogleFonts.playfairDisplay(
                                                            fontWeight:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelLarge
                                                                    .fontWeight,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .labelLarge
                                                                    .fontStyle,
                                                          ),
                                                      letterSpacing: 0.0,
                                                      fontWeight: AppTheme.of(
                                                        context,
                                                      ).labelLarge.fontWeight,
                                                      fontStyle: AppTheme.of(
                                                        context,
                                                      ).labelLarge.fontStyle,
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).alternate,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).primary,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppTheme.of(context)
                                                        .error,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppTheme.of(
                                                          context,
                                                        ).error,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                filled: true,
                                                fillColor: AppTheme.of(context)
                                                    .secondaryBackground,
                                                contentPadding: EdgeInsets.all(
                                                  24,
                                                ),
                                                suffixIcon: InkWell(
                                                  onTap: () async {
                                                    setState(
                                                      () => passwordVisibility2 =
                                                          !passwordVisibility2,
                                                    );
                                                  },
                                                  focusNode:
                                                      passwordPasswordVisibilityFocusNode2
                                                        ..skipTraversal =
                                                            !(false),
                                                  child: Icon(
                                                    passwordVisibility2
                                                        ? Icons
                                                              .visibility_outlined
                                                        : Icons
                                                              .visibility_off_outlined,
                                                    color: AppTheme.of(context)
                                                        .secondaryText,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                              style: AppTheme.of(context)
                                                  .bodyLarge
                                                  .override(
                                                    font:
                                                        GoogleFonts.playfairDisplay(
                                                          fontWeight:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .bodyLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .bodyLarge
                                                                  .fontStyle,
                                                        ),
                                                    letterSpacing: 0.0,
                                                    fontWeight: AppTheme.of(
                                                      context,
                                                    ).bodyLarge.fontWeight,
                                                    fontStyle: AppTheme.of(
                                                      context,
                                                    ).bodyLarge.fontStyle,
                                                  ),
                                              cursorColor: AppTheme.of(context)
                                                  .primary,
                                            ),
                                          ),
                                          Align(
                                            alignment: AlignmentDirectional(
                                              0,
                                              0,
                                            ),
                                            child: AppButton(
                                              onPressed: () async {
                                                Navigator.of(context)
                                                    .popAndPushNamed(
                                                      FeedWidget.routePath,
                                                    );
                                              },
                                              text: 'Sign Up',
                                              icon: FaIcon(
                                                FaIconData(
                                                  const IconData(
                                                    /* userAlt */ 0xf007,
                                                    fontFamily:
                                                        'FontAwesomeRegular',
                                                    fontPackage:
                                                        'font_awesome_flutter',
                                                  ),
                                                ),
                                                size: 24,
                                              ),
                                              options: AppButtonOptions(
                                                width: 230,
                                                height: 52,
                                                padding:
                                                    EdgeInsetsDirectional.fromSTEB(
                                                      0,
                                                      0,
                                                      0,
                                                      0,
                                                    ),
                                                iconAlignment:
                                                    IconAlignment.end,
                                                iconPadding:
                                                    EdgeInsetsDirectional.fromSTEB(
                                                      0,
                                                      0,
                                                      0,
                                                      0,
                                                    ),
                                                color: AppTheme.of(context)
                                                    .primary,
                                                textStyle: AppTheme.of(context)
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
                                                      color: Colors.white,
                                                      letterSpacing: 0.0,
                                                      fontWeight: AppTheme.of(
                                                        context,
                                                      ).titleLarge.fontWeight,
                                                      fontStyle: AppTheme.of(
                                                        context,
                                                      ).titleLarge.fontStyle,
                                                    ),
                                                elevation: 3,
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                              ),
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 16)).around(SizedBox(height: 16)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
            ],
          ),
        ),
      ),
    );
  }
}
