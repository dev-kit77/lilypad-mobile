import 'dart:io';

import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lilypad/services/ui/dialog.dart';
import 'package:lilypad/services/user.dart';
import 'package:lilypad/util/api_ex.dart';
import 'package:material_ui/material_ui.dart';

import '../../util/ui.dart';
import '../theme/theme.dart';
import '../widgets/buttons.dart';
import '../widgets/logo.dart';
import 'feed.dart' show FeedWidget;

class LandingWidget extends StatefulWidget {
  static String routeName = 'landing';

  static String routePath = '/landing';
  const LandingWidget({super.key});

  @override
  State<LandingWidget> createState() => _LandingWidgetState();
}

class _LandingWidgetState extends State<LandingWidget>
    with TickerProviderStateMixin {
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  // State field(s) for emailAddress widget.
  FocusNode? emailFocusNodeSignIn;
  TextEditingController? emailTextControllerSignIn;
  // State field(s) for password widget.
  late FocusNode passwordVisibilityFocusNodeSignIn;
  FocusNode? passwordFocusNodeSignIn;
  TextEditingController? passwordTextControllerSignIn;
  late bool passwordVisibilitySignIn;
  // State field(s) for username widget.
  FocusNode? usernameFocusNode;
  TextEditingController? usernameTextController;
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode2;
  TextEditingController? emailTextControllerSignUp;
  // State field(s) for password widget.
  late FocusNode passwordVisibilityFocusNodeSignUp;
  FocusNode? passwordFocusNodeSignUp;
  TextEditingController? passwordTextControllerSignUp;
  late bool passwordVisibilitySignUp;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  String? _emailValidate(String? ipt) {
    final String email = ipt?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email Required.';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]$').hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _passwordValidate(String? ipt) {
    final String password = ipt?.trim() ?? '';

    if (password.isEmpty) {
      return 'Password Required.';
    } else if (password.length < 8) {
      return 'Password must at least 8 characters.';
    }

    return null;
  }

  String? _usernameValidate(String? ipt) {
    final String username = ipt?.trim() ?? '';

    if (username.isEmpty) {
      return 'Username Required.';
    } else if (username.length > 64) {
      return 'Username too long.';
    }

    return null;
  }

  void _signIn() async {
    if (_signInFormKey.currentState?.validate() ?? false) {
      bool login = false;
      try {
        login = await UserService.login(
          emailTextControllerSignIn!.text,
          passwordTextControllerSignIn!.text,
        );
      } on APIException catch (e) {
        if (e.statusCode == 400) {
          DialogService.showAlert(
            'Sign In Error',
            'Invalid Email format. Please Check Email then try again.',
          );
        } else if (e.statusCode == 401) {
          DialogService.showAlert(
            'Sign In Error',
            'Incorrect Credentials. Please Check Email & Password then try again.',
          );
        } else {
          DialogService.showAlert(
            'Sign In Error',
            '${e.statusCode} - ${e.message}',
          );
        }
        return;
      } on SocketException catch (e) {
        DialogService.showAlert('Sign In Error', e.message);
        return;
      } catch (e) {
        DialogService.showAlert('Sign In Error', 'Unexpected error: $e');
        return;
      }

      if (mounted && login) {
        Navigator.of(context).popAndPushNamed(FeedWidget.routePath);
      } else if (mounted) {
        DialogService.showAlert('Sign In Error', 'Unknown Error');
      }
    }
  }

  void _signUp() async {
    if (_signUpFormKey.currentState?.validate() ?? false) {
      bool created = false;
      try {
        created = await UserService.createAccount(
          usernameTextController!.text,
          emailTextControllerSignUp!.text,
          passwordTextControllerSignUp!.text,
        );
      } on APIException catch (e) {
        if (e.statusCode == 400) {
          DialogService.showAlert(
            'Sign In Error',
            'Invalid Email format. Please Check Email then try again.',
          );
        } else if (e.statusCode == 422) {
          DialogService.showAlert(
            'Sign In Error',
            'Email/Username Taken. Please try a different option then try again.',
          );
        } else {
          DialogService.showAlert(
            'Sign In Error',
            '${e.statusCode} - ${e.message}',
          );
        }
        return;
      } on SocketException catch (e) {
        DialogService.showAlert('Sign In Error', e.message);
        return;
      } catch (e) {
        DialogService.showAlert('Sign Up Error', 'Unexpected error: $e');
        return;
      }

      if (mounted && created) {
        Navigator.of(context).popAndPushNamed(FeedWidget.routePath);
      } else if (mounted) {
        DialogService.showAlert('Sign Up Error', 'Unknown Error');
      }
    }
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
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: tabBarController,
                                  children: [
                                    Form(
                                      key: _signInFormKey,
                                      child: Padding(
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
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelMedium
                                                                  .fontStyle,
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
                                            SizedBox(
                                              width: double.infinity,
                                              child: TextFormField(
                                                controller:
                                                    emailTextControllerSignIn,
                                                validator: _emailValidate,
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                focusNode: emailFocusNodeSignIn,
                                                autofocus: true,
                                                enabled: true,
                                                autofillHints: [
                                                  AutofillHints.email,
                                                ],
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  labelText: 'Email',
                                                  labelStyle:
                                                      AppTheme.of(
                                                        context,
                                                      ).labelLarge.override(
                                                        font: GoogleFonts.playfairDisplay(
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
                                                  fillColor: AppTheme.of(
                                                    context,
                                                  ).secondaryBackground,
                                                  contentPadding:
                                                      EdgeInsets.all(24),
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
                                                cursorColor: AppTheme.of(
                                                  context,
                                                ).primary,
                                              ),
                                            ),
                                            SizedBox(
                                              width: double.infinity,
                                              child: TextFormField(
                                                controller:
                                                    passwordTextControllerSignIn,
                                                focusNode:
                                                    passwordFocusNodeSignIn,
                                                validator: _passwordValidate,
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                enabled: true,
                                                autofillHints: [
                                                  AutofillHints.password,
                                                ],
                                                obscureText:
                                                    !passwordVisibilitySignIn,
                                                decoration: InputDecoration(
                                                  labelText: 'Password',
                                                  labelStyle:
                                                      AppTheme.of(
                                                        context,
                                                      ).labelLarge.override(
                                                        font: GoogleFonts.playfairDisplay(
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
                                                  fillColor: AppTheme.of(
                                                    context,
                                                  ).secondaryBackground,
                                                  contentPadding:
                                                      EdgeInsets.all(24),
                                                  suffixIcon: InkWell(
                                                    onTap: () async {
                                                      setState(
                                                        () => passwordVisibilitySignIn =
                                                            !passwordVisibilitySignIn,
                                                      );
                                                    },
                                                    focusNode:
                                                        passwordVisibilityFocusNodeSignIn
                                                          ..skipTraversal =
                                                              !(false),
                                                    child: Icon(
                                                      passwordVisibilitySignIn
                                                          ? Icons
                                                                .visibility_outlined
                                                          : Icons
                                                                .visibility_off_outlined,
                                                      color: AppTheme.of(
                                                        context,
                                                      ).secondaryText,
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
                                                cursorColor: AppTheme.of(
                                                  context,
                                                ).primary,
                                              ),
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                0,
                                                0,
                                              ),
                                              child: AppButton(
                                                onPressed: () async =>
                                                    _signIn(),
                                                text: 'Sign In',
                                                icon: FaIcon(
                                                  FaIconData(
                                                    const IconData(
                                                      /* signInAlt */ 0xf2f6,
                                                      fontFamily:
                                                          'FontAwesomeSolid',
                                                      fontPackage: 'font_awesome_flutter',
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
                                                  textStyle:
                                                      AppTheme.of(
                                                        context,
                                                      ).titleMedium.override(
                                                        font: GoogleFonts.playfairDisplay(
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
                                                        fontWeight:
                                                            AppTheme.of(context)
                                                                .titleMedium
                                                                .fontWeight,
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
                                    ),
                                    Form(
                                      key: _signUpFormKey,
                                      child: Padding(
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
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelMedium
                                                                  .fontStyle,
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
                                            SizedBox(
                                              width: double.infinity,
                                              child: TextFormField(
                                                controller:
                                                    usernameTextController,
                                                focusNode: usernameFocusNode,
                                                validator: _usernameValidate,
                                                enabled: true,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  labelText: 'Username',
                                                  labelStyle:
                                                      AppTheme.of(
                                                        context,
                                                      ).labelLarge.override(
                                                        font: GoogleFonts.playfairDisplay(
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
                                                  fillColor: AppTheme.of(
                                                    context,
                                                  ).secondaryBackground,
                                                  contentPadding:
                                                      EdgeInsets.all(24),
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
                                                    MaxLengthEnforcement
                                                        .enforced,
                                                buildCounter: (
                                                  context, {
                                                  required currentLength,
                                                  required isFocused,
                                                  maxLength,
                                                }) => null,
                                                keyboardType:
                                                    TextInputType.text,
                                                cursorColor: AppTheme.of(
                                                  context,
                                                ).primary,
                                              ),
                                            ),
                                            SizedBox(
                                              width: double.infinity,
                                              child: TextFormField(
                                                controller:
                                                    emailTextControllerSignUp,
                                                validator: _emailValidate,
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                focusNode:
                                                    emailAddressFocusNode2,
                                                enabled: true,
                                                autofillHints: [
                                                  AutofillHints.email,
                                                ],
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  labelText: 'Email',
                                                  labelStyle:
                                                      AppTheme.of(
                                                        context,
                                                      ).labelLarge.override(
                                                        font: GoogleFonts.playfairDisplay(
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
                                                  fillColor: AppTheme.of(
                                                    context,
                                                  ).secondaryBackground,
                                                  contentPadding:
                                                      EdgeInsets.all(24),
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
                                                cursorColor: AppTheme.of(
                                                  context,
                                                ).primary,
                                              ),
                                            ),
                                            SizedBox(
                                              width: double.infinity,
                                              child: TextFormField(
                                                controller:
                                                    passwordTextControllerSignUp,
                                                focusNode:
                                                    passwordFocusNodeSignUp,
                                                validator: _passwordValidate,
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                enabled: true,
                                                autofillHints: [
                                                  AutofillHints.password,
                                                ],
                                                obscureText:
                                                    !passwordVisibilitySignUp,
                                                decoration: InputDecoration(
                                                  labelText: 'Password',
                                                  labelStyle:
                                                      AppTheme.of(
                                                        context,
                                                      ).labelLarge.override(
                                                        font: GoogleFonts.playfairDisplay(
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
                                                  fillColor: AppTheme.of(
                                                    context,
                                                  ).secondaryBackground,
                                                  contentPadding:
                                                      EdgeInsets.all(24),
                                                  suffixIcon: InkWell(
                                                    onTap: () async {
                                                      setState(
                                                        () => passwordVisibilitySignUp =
                                                            !passwordVisibilitySignUp,
                                                      );
                                                    },
                                                    focusNode:
                                                        passwordVisibilityFocusNodeSignUp
                                                          ..skipTraversal =
                                                              !(false),
                                                    child: Icon(
                                                      passwordVisibilitySignUp
                                                          ? Icons
                                                                .visibility_outlined
                                                          : Icons
                                                                .visibility_off_outlined,
                                                      color: AppTheme.of(
                                                        context,
                                                      ).secondaryText,
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
                                                cursorColor: AppTheme.of(
                                                  context,
                                                ).primary,
                                              ),
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                0,
                                                0,
                                              ),
                                              child: AppButton(
                                                onPressed: () async =>
                                                    _signUp(),
                                                text: 'Sign Up',
                                                icon: FaIcon(
                                                  FaIconData(
                                                    const IconData(
                                                      /* userAlt */ 0xf007,
                                                      fontFamily:
                                                          'FontAwesomeRegular',
                                                      fontPackage: 'font_awesome_flutter',
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
                                                  textStyle:
                                                      AppTheme.of(
                                                        context,
                                                      ).titleLarge.override(
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

  @override
  void dispose() {
    tabBarController?.dispose();
    emailFocusNodeSignIn?.dispose();
    emailTextControllerSignIn?.dispose();

    passwordFocusNodeSignIn?.dispose();
    passwordTextControllerSignIn?.dispose();
    passwordVisibilityFocusNodeSignIn.dispose();
    usernameFocusNode?.dispose();
    usernameTextController?.dispose();

    emailAddressFocusNode2?.dispose();
    emailTextControllerSignUp?.dispose();

    passwordFocusNodeSignUp?.dispose();
    passwordTextControllerSignUp?.dispose();
    passwordVisibilityFocusNodeSignUp.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    passwordVisibilityFocusNodeSignIn = FocusNode();
    passwordVisibilitySignIn = false;
    passwordVisibilityFocusNodeSignUp = FocusNode();
    passwordVisibilitySignUp = false;

    tabBarController = TabController(vsync: this, length: 2, initialIndex: 0)
      ..addListener(() => setState(() {}));

    emailTextControllerSignIn ??= TextEditingController();
    emailFocusNodeSignIn ??= FocusNode();

    passwordTextControllerSignIn ??= TextEditingController();
    passwordFocusNodeSignIn ??= FocusNode();

    usernameTextController ??= TextEditingController();
    usernameFocusNode ??= FocusNode();

    emailTextControllerSignUp ??= TextEditingController();
    emailAddressFocusNode2 ??= FocusNode();

    passwordTextControllerSignUp ??= TextEditingController();
    passwordFocusNodeSignUp ??= FocusNode();
  }
}
