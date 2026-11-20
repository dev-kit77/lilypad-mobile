import '../widgets/logo.dart';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/theme.dart';
import '../../util/ui.dart';
import '../widgets/navbar.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({
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

  static String routeName = 'settings';
  static String routePath = '/settings';

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  // State field(s) for Switch widget.
  bool? switchValue1;
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
  bool? switchValue2;
  // State field(s) for Switch widget.
  bool? switchValue3;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    switchValue1 = false;
    usernameTextController ??= TextEditingController(text: widget.username);
    usernameFocusNode ??= FocusNode();

    statusTextController ??= TextEditingController(text: widget.status);
    statusFocusNode ??= FocusNode();

    bioTextController ??= TextEditingController(text: widget.bio);
    bioFocusNode ??= FocusNode();

    switchValue2 = false;
    switchValue3 = false;
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
                                            'Your Settings.',
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
                                      width: MediaQuery.sizeOf(context).width,
                                      decoration: BoxDecoration(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        textBaseline: TextBaseline.alphabetic,
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
                                                  'Here you can update your User profile.',
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
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Switch.adaptive(
                                                value: switchValue1!,
                                                onChanged: (newValue) async {
                                                  setState(
                                                    () =>
                                                        switchValue1 = newValue,
                                                  );
                                                },
                                                activeColor: AppTheme.of(
                                                  context,
                                                ).primary,
                                                activeTrackColor: AppTheme.of(
                                                  context,
                                                ).primary,
                                                inactiveTrackColor: AppTheme.of(
                                                  context,
                                                ).alternate,
                                                inactiveThumbColor: AppTheme.of(
                                                  context,
                                                ).secondaryBackground,
                                              ),
                                              Text(
                                                'Anonymous Profile',
                                                style: AppTheme.of(context)
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
                                              ),
                                            ].divide(SizedBox(width: 12)).around(SizedBox(width: 12)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: Container(
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
                                                      enabledBorder:
                                                          OutlineInputBorder(
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
                                                      focusedBorder:
                                                          OutlineInputBorder(
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
                                                    cursorColor: AppTheme.of(
                                                      context,
                                                    ).primary,
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 12)).around(SizedBox(width: 12)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller:
                                                        statusTextController,
                                                    focusNode: statusFocusNode,
                                                    onChanged: (_) =>
                                                        EasyDebounce.debounce(
                                                          'statusTextController',
                                                          Duration(
                                                            milliseconds: 2000,
                                                          ),
                                                          () => setState(() {}),
                                                        ),
                                                    autofocus: true,
                                                    enabled: true,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      labelText: 'Status',
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
                                                      enabledBorder:
                                                          OutlineInputBorder(
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
                                                      focusedBorder:
                                                          OutlineInputBorder(
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
                                                      filled: true,
                                                      fillColor: AppTheme.of(
                                                        context,
                                                      ).secondaryBackground,
                                                      contentPadding:
                                                          EdgeInsets.all(24),
                                                      suffixIcon:
                                                          statusTextController!
                                                              .text
                                                              .isNotEmpty
                                                          ? InkWell(
                                                              onTap: () async {
                                                                statusTextController
                                                                    ?.clear();
                                                                setState(() {});
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
                                                    style: AppTheme.of(context)
                                                        .bodyLarge
                                                        .override(
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
                                                    cursorColor: AppTheme.of(
                                                      context,
                                                    ).primary,
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 12)).around(SizedBox(width: 12)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller:
                                                        bioTextController,
                                                    focusNode: bioFocusNode,
                                                    onChanged: (_) =>
                                                        EasyDebounce.debounce(
                                                          'bioTextController',
                                                          Duration(
                                                            milliseconds: 2000,
                                                          ),
                                                          () => setState(() {}),
                                                        ),
                                                    autofocus: true,
                                                    enabled: true,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      labelText: 'Bio',
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
                                                      enabledBorder:
                                                          OutlineInputBorder(
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
                                                      focusedBorder:
                                                          OutlineInputBorder(
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
                                                      filled: true,
                                                      fillColor: AppTheme.of(
                                                        context,
                                                      ).secondaryBackground,
                                                      contentPadding:
                                                          EdgeInsets.all(24),
                                                      suffixIcon:
                                                          bioTextController!
                                                              .text
                                                              .isNotEmpty
                                                          ? InkWell(
                                                              onTap: () async {
                                                                bioTextController
                                                                    ?.clear();
                                                                setState(() {});
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
                                                    style: AppTheme.of(context)
                                                        .bodyLarge
                                                        .override(
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
                                                    cursorColor: AppTheme.of(
                                                      context,
                                                    ).primary,
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
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            'App Settings',
                                            style: AppTheme.of(context)
                                                .displaySmall
                                                .override(
                                                  font:
                                                      GoogleFonts.playfairDisplay(
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
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Switch.adaptive(
                                                value: switchValue2!,
                                                onChanged: (newValue) async {
                                                  setState(
                                                    () =>
                                                        switchValue2 = newValue,
                                                  );
                                                },
                                                activeColor: AppTheme.of(
                                                  context,
                                                ).primary,
                                                activeTrackColor: AppTheme.of(
                                                  context,
                                                ).primary,
                                                inactiveTrackColor: AppTheme.of(
                                                  context,
                                                ).alternate,
                                                inactiveThumbColor: AppTheme.of(
                                                  context,
                                                ).secondaryBackground,
                                              ),
                                              Text(
                                                'Dark Mode',
                                                style: AppTheme.of(context)
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
                                              ),
                                            ].divide(SizedBox(width: 12)).around(SizedBox(width: 12)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Switch.adaptive(
                                                value: switchValue3!,
                                                onChanged: (newValue) async {
                                                  setState(
                                                    () =>
                                                        switchValue3 = newValue,
                                                  );
                                                },
                                                activeColor: AppTheme.of(
                                                  context,
                                                ).primary,
                                                activeTrackColor: AppTheme.of(
                                                  context,
                                                ).primary,
                                                inactiveTrackColor: AppTheme.of(
                                                  context,
                                                ).alternate,
                                                inactiveThumbColor: AppTheme.of(
                                                  context,
                                                ).secondaryBackground,
                                              ),
                                              Text(
                                                'Push Notifications',
                                                style: AppTheme.of(context)
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
                                                alignment: AlignmentDirectional(
                                                  -1,
                                                  0,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  textBaseline:
                                                      TextBaseline.alphabetic,
                                                  children: [
                                                    Text(
                                                      'App Info',
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
    );
  }
}
