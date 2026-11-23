import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lilypad/models/user.dart';
import 'package:lilypad/services/session.dart';
import 'package:lilypad/services/ui/dialog.dart';
import 'package:lilypad/services/user.dart';
import 'package:lilypad/ui/widgets/buttons.dart';

import '../widgets/logo.dart';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/theme.dart';
import '../../util/ui.dart';
import '../widgets/navbar.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  static String routeName = 'settings';
  static String routePath = '/settings';

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  // State field(s) for Switch widget.
  bool? anonSwitchValue;
  // State field(s) for username widget.
  FocusNode? usernameFocusNode;
  TextEditingController? usernameTextController;
  String? Function(BuildContext, String?)? usernameTextControllerValidator;
  // State field(s) for status widget.
  FocusNode? statusFocusNode;
  TextEditingController? statusTextController;
  String? Function(BuildContext, String?)? statusTextControllerValidator;
  // State field(s) for bio widget.
  FocusNode? bioFocusNode;
  TextEditingController? bioTextController;
  String? Function(BuildContext, String?)? bioTextControllerValidator;
  // State field(s) for Switch widget.
  bool? darkSwitchValue;
  // State field(s) for Switch widget.
  bool? pushSwitchValue;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late final CurrentUser? currUser;

  @override
  void initState() {
    super.initState();

    usernameTextController ??= TextEditingController();
    usernameFocusNode ??= FocusNode();

    statusTextController ??= TextEditingController();
    statusFocusNode ??= FocusNode();

    bioTextController ??= TextEditingController();
    bioFocusNode ??= FocusNode();

    anonSwitchValue = false;
    darkSwitchValue = false;
    pushSwitchValue = false;

    UserService.fetch().then(
      (u) => {
        setState(() {
          currUser = u;
          anonSwitchValue = u.anon;
          usernameTextController!.text = u.username;
          statusTextController!.text = u.status ?? '';
          bioTextController!.text = u.bio ?? '';
          darkSwitchValue = u.dark;
        }),
      },
    );
  }

  @override
  void dispose() {
    usernameFocusNode?.dispose();
    usernameTextController?.dispose();

    statusFocusNode?.dispose();
    statusTextController?.dispose();

    bioFocusNode?.dispose();
    bioTextController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                                                'Your Settings.',
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
                                height: MediaQuery.sizeOf(context).height,
                                decoration: BoxDecoration(),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
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
                                        Container(
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
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                textBaseline:
                                                    TextBaseline.alphabetic,
                                                children: [
                                                  Text(
                                                    'Profile Settings',
                                                    style: AppTheme.of(context)
                                                        .displaySmall
                                                        .override(
                                                          font: GoogleFonts.playfairDisplay(
                                                            fontWeight:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .displaySmall
                                                                    .fontWeight,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .displaySmall
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .displaySmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .displaySmall
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional.fromSTEB(
                                                          0,
                                                          4,
                                                          0,
                                                          4,
                                                        ),
                                                    child: Text(
                                                      'Here you can update your User profile.',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: AppTheme.of(context)
                                                          .titleMedium
                                                          .override(
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
                                                            letterSpacing: 0.0,
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
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Switch.adaptive(
                                                    value: anonSwitchValue!,
                                                    onChanged: (newValue) async {
                                                      setState(
                                                        () => anonSwitchValue =
                                                            newValue,
                                                      );
                                                    },
                                                    activeThumbColor:
                                                        AppTheme.of(context)
                                                            .primary,
                                                    activeTrackColor:
                                                        AppTheme.of(context)
                                                            .primary,
                                                    inactiveTrackColor:
                                                        AppTheme.of(context)
                                                            .alternate,
                                                    inactiveThumbColor:
                                                        AppTheme.of(
                                                          context,
                                                        ).secondaryBackground,
                                                  ),
                                                  Text(
                                                    'Anonymous Profile',
                                                    style: AppTheme.of(context)
                                                        .labelLarge
                                                        .override(
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
                                                  ),
                                                ].divide(SizedBox(width: 12)).around(SizedBox(width: 12)),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: TextFormField(
                                                        controller:
                                                            usernameTextController,
                                                        focusNode:
                                                            usernameFocusNode,
                                                        autofocus: true,
                                                        enabled: true,
                                                        obscureText: false,
                                                        decoration: InputDecoration(
                                                          labelText: 'Username',
                                                          labelStyle: AppTheme.of(context).labelLarge.override(
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
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color:
                                                                  AppTheme.of(
                                                                    context,
                                                                  ).alternate,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  40,
                                                                ),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      AppTheme.of(
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
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      AppTheme.of(
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
                                                                  color:
                                                                      AppTheme.of(
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
                                                              EdgeInsets.all(
                                                                24,
                                                              ),
                                                        ),
                                                        style: AppTheme.of(context).bodyLarge.override(
                                                          font: GoogleFonts.playfairDisplay(
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
                                                        cursorColor:
                                                            AppTheme.of(context)
                                                                .primary,
                                                      ),
                                                    ),
                                                  ),
                                                ].divide(SizedBox(width: 12)).around(SizedBox(width: 12)),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: TextFormField(
                                                        controller:
                                                            statusTextController,
                                                        focusNode:
                                                            statusFocusNode,
                                                        onChanged: (_) =>
                                                            EasyDebounce.debounce(
                                                              'statusTextController',
                                                              Duration(
                                                                milliseconds:
                                                                    2000,
                                                              ),
                                                              () => setState(
                                                                () {},
                                                              ),
                                                            ),
                                                        autofocus: true,
                                                        enabled: true,
                                                        obscureText: false,
                                                        decoration: InputDecoration(
                                                          labelText: 'Status',
                                                          labelStyle: AppTheme.of(context).labelLarge.override(
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
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color:
                                                                  AppTheme.of(
                                                                    context,
                                                                  ).alternate,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  40,
                                                                ),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      AppTheme.of(
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
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      AppTheme.of(
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
                                                                  color:
                                                                      AppTheme.of(
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
                                                              EdgeInsets.all(
                                                                24,
                                                              ),
                                                          suffixIcon:
                                                              statusTextController!
                                                                  .text
                                                                  .isNotEmpty
                                                              ? InkWell(
                                                                  onTap: () async {
                                                                    statusTextController
                                                                        ?.clear();
                                                                    setState(
                                                                      () {},
                                                                    );
                                                                  },
                                                                  child: Icon(
                                                                    Icons.clear,
                                                                    color: Color(
                                                                      0xFF757575,
                                                                    ),
                                                                    size: 22,
                                                                  ),
                                                                )
                                                              : null,
                                                        ),
                                                        style: AppTheme.of(context).bodyLarge.override(
                                                          font: GoogleFonts.playfairDisplay(
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
                                                        cursorColor:
                                                            AppTheme.of(context)
                                                                .primary,
                                                      ),
                                                    ),
                                                  ),
                                                ].divide(SizedBox(width: 12)).around(SizedBox(width: 12)),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: TextFormField(
                                                        controller:
                                                            bioTextController,
                                                        focusNode: bioFocusNode,
                                                        onChanged: (_) =>
                                                            EasyDebounce.debounce(
                                                              'bioTextController',
                                                              Duration(
                                                                milliseconds:
                                                                    2000,
                                                              ),
                                                              () => setState(
                                                                () {},
                                                              ),
                                                            ),
                                                        autofocus: true,
                                                        enabled: true,
                                                        obscureText: false,
                                                        decoration: InputDecoration(
                                                          labelText: 'Bio',
                                                          labelStyle: AppTheme.of(context).labelLarge.override(
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
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color:
                                                                  AppTheme.of(
                                                                    context,
                                                                  ).alternate,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  40,
                                                                ),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      AppTheme.of(
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
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      AppTheme.of(
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
                                                                  color:
                                                                      AppTheme.of(
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
                                                              EdgeInsets.all(
                                                                24,
                                                              ),
                                                          suffixIcon:
                                                              bioTextController!
                                                                  .text
                                                                  .isNotEmpty
                                                              ? InkWell(
                                                                  onTap: () async {
                                                                    bioTextController
                                                                        ?.clear();
                                                                    setState(
                                                                      () {},
                                                                    );
                                                                  },
                                                                  child: Icon(
                                                                    Icons.clear,
                                                                    color: Color(
                                                                      0xFF757575,
                                                                    ),
                                                                    size: 22,
                                                                  ),
                                                                )
                                                              : null,
                                                        ),
                                                        style: AppTheme.of(context).bodyLarge.override(
                                                          font: GoogleFonts.playfairDisplay(
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
                                                        maxLines: null,
                                                        minLines: 2,
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
                                                        cursorColor:
                                                            AppTheme.of(context)
                                                                .primary,
                                                      ),
                                                    ),
                                                  ),
                                                ].divide(SizedBox(width: 12)).around(SizedBox(width: 12)),
                                              ),
                                            ].divide(SizedBox(height: 12)).addToEnd(SizedBox(height: 12)),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            children: [
                                              Text(
                                                'App Settings',
                                                style: AppTheme.of(context)
                                                    .displaySmall
                                                    .override(
                                                      font: GoogleFonts.playfairDisplay(
                                                        fontWeight:
                                                            AppTheme.of(context)
                                                                .displaySmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            AppTheme.of(context)
                                                                .displaySmall
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight: AppTheme.of(
                                                        context,
                                                      ).displaySmall.fontWeight,
                                                      fontStyle: AppTheme.of(
                                                        context,
                                                      ).displaySmall.fontStyle,
                                                    ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsetsDirectional.fromSTEB(
                                                      0,
                                                      4,
                                                      0,
                                                      4,
                                                    ),
                                                child: Text(
                                                  'Change how your app responds.',
                                                  textAlign: TextAlign.start,
                                                  style: AppTheme.of(context)
                                                      .titleMedium
                                                      .override(
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
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            AppTheme.of(context)
                                                                .titleMedium
                                                                .fontWeight,
                                                        fontStyle: AppTheme.of(
                                                          context,
                                                        ).titleMedium.fontStyle,
                                                      ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Switch.adaptive(
                                                    value: darkSwitchValue!,
                                                    onChanged: (newValue) async {
                                                      setState(
                                                        () => darkSwitchValue =
                                                            newValue,
                                                      );
                                                    },
                                                    activeThumbColor:
                                                        AppTheme.of(context)
                                                            .primary,
                                                    activeTrackColor:
                                                        AppTheme.of(context)
                                                            .primary,
                                                    inactiveTrackColor:
                                                        AppTheme.of(context)
                                                            .alternate,
                                                    inactiveThumbColor:
                                                        AppTheme.of(
                                                          context,
                                                        ).secondaryBackground,
                                                  ),
                                                  Text(
                                                    'Dark Mode',
                                                    style: AppTheme.of(context)
                                                        .labelLarge
                                                        .override(
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
                                                  ),
                                                ].divide(SizedBox(width: 12)).around(SizedBox(width: 12)),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Switch.adaptive(
                                                    value: pushSwitchValue!,
                                                    onChanged: (newValue) async {
                                                      setState(
                                                        () => pushSwitchValue =
                                                            newValue,
                                                      );
                                                    },
                                                    activeThumbColor:
                                                        AppTheme.of(context)
                                                            .primary,
                                                    activeTrackColor:
                                                        AppTheme.of(context)
                                                            .primary,
                                                    inactiveTrackColor:
                                                        AppTheme.of(context)
                                                            .alternate,
                                                    inactiveThumbColor:
                                                        AppTheme.of(
                                                          context,
                                                        ).secondaryBackground,
                                                  ),
                                                  Text(
                                                    'Push Notifications',
                                                    style: AppTheme.of(context)
                                                        .labelLarge
                                                        .override(
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
                                                  ),
                                                ].divide(SizedBox(width: 12)).around(SizedBox(width: 12)),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  AppButton(
                                                    onPressed: () async {
                                                      await UserService.logout();
                                                      SessionService.invalidate();
                                                    },
                                                    text: 'Log Out',
                                                    icon: FaIcon(
                                                      FaIconData(
                                                        const IconData(
                                                          /* signOutAlt */ 0xf2f5,
                                                          fontFamily: 'FontAwesomeSolid',
                                                          fontPackage: 'font_awesome_flutter',
                                                        ),
                                                      ),
                                                      size: 24,
                                                    ),
                                                    options: AppButtonOptions(
                                                      width: 180,
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
                                                      color: AppTheme.of(
                                                        context,
                                                      ).error,
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
                                                      elevation: 3,
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.transparent,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                    ),
                                                  ),
                                                ].divide(SizedBox(width: 12)).around(SizedBox(width: 12)),
                                              ),
                                            ].divide(SizedBox(height: 12)).addToEnd(SizedBox(height: 12)),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                          -1,
                                                          0,
                                                        ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      textBaseline: TextBaseline
                                                          .alphabetic,
                                                      children: [
                                                        Text(
                                                          'App Info',
                                                          style: AppTheme.of(context).displaySmall.override(
                                                            font: GoogleFonts.playfairDisplay(
                                                              fontWeight:
                                                                  AppTheme.of(
                                                                        context,
                                                                      )
                                                                      .displaySmall
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  AppTheme.of(
                                                                        context,
                                                                      )
                                                                      .displaySmall
                                                                      .fontStyle,
                                                            ),
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .displaySmall
                                                                    .fontWeight,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                      context,
                                                                    )
                                                                    .displaySmall
                                                                    .fontStyle,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional.fromSTEB(
                                                                0,
                                                                4,
                                                                0,
                                                                4,
                                                              ),
                                                          child: Text(
                                                            'Lilypad Client Version 1.00\nCopyright 2026 Kit Cochrane\nAll Rights Reserved',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: AppTheme.of(context).titleMedium.override(
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
                                                              letterSpacing:
                                                                  0.0,
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
                                                          ),
                                                        ),
                                                      ].divide(SizedBox(height: 12)).addToEnd(SizedBox(height: 12)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                  const NavBarWidget(selectedIndex: 2),
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
                                  /* save */ 0xf0c7,
                                  fontFamily: 'FontAwesomeSolid',
                                  fontPackage: 'font_awesome_flutter',
                                ),
                              ),
                              color: AppTheme.of(context).info,
                              size: 36,
                            ),
                            onPressed: () async {
                              await DialogService.getConfirmation(
                                'Apply Settings',
                                'Are You Sure?',
                                () async {
                                  await UserService.update(
                                    username: usernameTextController?.text,
                                    status: statusTextController?.text,
                                    bio: bioTextController?.text,
                                    anon: anonSwitchValue,
                                    dark: darkSwitchValue,
                                  );

                                  //update state
                                  setState(() {});
                                },
                              );
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
