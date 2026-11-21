import 'package:lilypad/models/post.dart';

import '../widgets/logo.dart';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/theme.dart';
import '../../util/ui.dart';
import '../widgets/buttons.dart';

class EditPostWidget extends StatefulWidget {
  const EditPostWidget({super.key, required this.post});

  final Post post;

  static String routeName = 'editPost';
  static String routePath = '/editPost';

  @override
  State<EditPostWidget> createState() => _EditPostWidgetState();
}

class _EditPostWidgetState extends State<EditPostWidget> {
  // State field(s) for username widget.
  FocusNode? usernameFocusNode;
  TextEditingController? usernameTextController;
  String? Function(BuildContext, String?)? usernameTextControllerValidator;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    usernameTextController ??= TextEditingController(text: widget.post.content);
    usernameFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    usernameFocusNode?.dispose();
    usernameTextController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: SizedBox(
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
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                decoration: BoxDecoration(),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                    0,
                                    12,
                                    0,
                                    12,
                                  ),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Icon(
                                          Icons.arrow_back,
                                          color: AppTheme.of(context)
                                              .secondaryText,
                                          size: 32,
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: AlignmentDirectional(
                                              0,
                                              0,
                                            ),
                                            child: Text(
                                              'Back to Post',
                                              textAlign: TextAlign.center,
                                              style: AppTheme.of(context)
                                                  .labelLarge
                                                  .override(
                                                    font:
                                                        GoogleFonts.playfairDisplay(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                    context,
                                                                  )
                                                                  .labelLarge
                                                                  .fontStyle,
                                                        ),
                                                    fontSize: 18,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: AppTheme.of(
                                                      context,
                                                    ).labelLarge.fontStyle,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        Opacity(
                                          opacity: 0,
                                          child: Icon(
                                            Icons.arrow_back,
                                            size: 32,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0,
                                4,
                                0,
                                4,
                              ),
                              child: Text(
                                'Editing Post.',
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
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              12,
                              0,
                              12,
                              0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: usernameTextController,
                                    focusNode: usernameFocusNode,
                                    onChanged: (_) => EasyDebounce.debounce(
                                      'usernameTextController',
                                      Duration(milliseconds: 2000),
                                      () => setState(() {}),
                                    ),
                                    autofocus: true,
                                    enabled: true,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'Really changing it up?',
                                      labelStyle: AppTheme.of(context)
                                          .labelLarge
                                          .override(
                                            font: GoogleFonts.playfairDisplay(
                                              fontWeight: AppTheme.of(context)
                                                  .labelLarge
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .labelLarge
                                                  .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight: AppTheme.of(context)
                                                .labelLarge
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .labelLarge
                                                .fontStyle,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context).alternate,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context).primary,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context).error,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context).error,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.of(context)
                                          .secondaryBackground,
                                      contentPadding: EdgeInsets.all(24),
                                      suffixIcon:
                                          usernameTextController!
                                              .text
                                              .isNotEmpty
                                          ? InkWell(
                                              onTap: () async {
                                                usernameTextController?.clear();
                                                setState(() {});
                                              },
                                              child: Icon(
                                                Icons.clear,
                                                color: Color(0xFF757575),
                                                size: 22,
                                              ),
                                            )
                                          : null,
                                    ),
                                    style: AppTheme.of(context).bodyLarge
                                        .override(
                                          font: GoogleFonts.playfairDisplay(
                                            fontWeight: AppTheme.of(context)
                                                .bodyLarge
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .bodyLarge
                                                .fontStyle,
                                          ),
                                          fontSize: 18,
                                          letterSpacing: 0.0,
                                          fontWeight: AppTheme.of(context)
                                              .bodyLarge
                                              .fontWeight,
                                          fontStyle: AppTheme.of(context)
                                              .bodyLarge
                                              .fontStyle,
                                        ),
                                    maxLines: null,
                                    minLines: 6,
                                    maxLength: 255,
                                    maxLengthEnforcement:
                                        MaxLengthEnforcement.enforced,
                                    keyboardType: TextInputType.multiline,
                                    cursorColor: AppTheme.of(context).primary,
                                    enableInteractiveSelection: true,
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(1, 0),
                                  child: AppButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                    text: 'Update',
                                    icon: FaIcon(
                                      FaIconData(
                                        const IconData(
                                          /* edit */ 0xf044,
                                          fontFamily: 'FontAwesomeRegular',
                                          fontPackage: 'font_awesome_flutter',
                                        ),
                                      ),
                                      size: 15,
                                    ),
                                    options: AppButtonOptions(
                                      width: 120,
                                      height: 52,
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        0,
                                        0,
                                        0,
                                        0,
                                      ),
                                      iconPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                            0,
                                            0,
                                            0,
                                            0,
                                          ),
                                      color: AppTheme.of(context).primary,
                                      textStyle: AppTheme.of(context).titleLarge
                                          .override(
                                            font: GoogleFonts.playfairDisplay(
                                              fontWeight: AppTheme.of(context)
                                                  .titleLarge
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .titleLarge
                                                  .fontStyle,
                                            ),
                                            color: Colors.white,
                                            letterSpacing: 0.0,
                                            fontWeight: AppTheme.of(context)
                                                .titleLarge
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .titleLarge
                                                .fontStyle,
                                          ),
                                      elevation: 3,
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 12)).around(SizedBox(height: 12)),
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
            ],
          ),
        ),
      ),
    );
  }
}
