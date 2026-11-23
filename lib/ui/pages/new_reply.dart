import 'package:lilypad/models/post.dart';
import 'package:lilypad/services/content.dart';
import 'package:lilypad/ui/widgets/post.dart';

import '../widgets/logo.dart';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wiggly_loaders/wiggly_loaders.dart';

import '../theme/theme.dart';
import '../../util/ui.dart';

class NewReplyWidget extends StatefulWidget {
  const NewReplyWidget({super.key, required this.replyingTo});

  final Post replyingTo;

  @override
  State<NewReplyWidget> createState() => _NewReplyWidgetState();
}

class _NewReplyWidgetState extends State<NewReplyWidget> {
  // State field(s) for username widget.
  FocusNode? contentFocusNode;
  TextEditingController? contentTextController;
  String? Function(BuildContext, String?)? contentTextControllerValidator;

  WigglyButtonState postButtonState = WigglyButtonState.idle;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    contentTextController ??= TextEditingController();
    contentFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    contentFocusNode?.dispose();
    contentTextController?.dispose();

    super.dispose();
  }

  void _submitReply() async {
    //init content
    final content = contentTextController?.text.trim() ?? '';

    //check if valid entry
    if (content.isEmpty && mounted) {
      //show error
      setState(() => postButtonState = WigglyButtonState.error);

      //hold state for user
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => postButtonState = WigglyButtonState.idle);
        }
      });
    }

    //set loading state
    if (mounted) {
      setState(() => postButtonState = WigglyButtonState.loading);
    }

    try {
      //attempt create reply
      await ContentService.newReply(widget.replyingTo.uuid, content);

      //show success
      if (mounted) {
        setState(() => postButtonState = WigglyButtonState.success);
      }

      //hold state for ui to show
      Future.delayed(const Duration(seconds: 1), () {
        //exit back to previous page
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
    } catch (_) {
      //show error
      if (mounted) {
        setState(() => postButtonState = WigglyButtonState.error);
      }

      //hold state for user
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => postButtonState = WigglyButtonState.idle);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonOptions = AppTheme.of(context).wigglyButtonOptions;

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
                            PostWidget(post: widget.replyingTo),
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
                                              'Back to Feed',
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
                                'New Reply.',
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
                                    controller: contentTextController,
                                    focusNode: contentFocusNode,
                                    onChanged: (_) => EasyDebounce.debounce(
                                      'usernameTextController',
                                      Duration(milliseconds: 2000),
                                      () => setState(() {}),
                                    ),
                                    autofocus: true,
                                    enabled: true,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'What would you like to say?',
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
                                          contentTextController!.text.isNotEmpty
                                          ? InkWell(
                                              onTap: () async {
                                                contentTextController?.clear();
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
                                  child: Material(
                                    color: Colors.transparent,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        buttonOptions.borderRadius,
                                      ),
                                    ),
                                    child: WigglyProgressButton(
                                      state: postButtonState,
                                      onPressed: _submitReply,
                                      width: buttonOptions.width,
                                      height: buttonOptions.height,
                                      borderRadius: buttonOptions.borderRadius,
                                      wiggleAmplitude: buttonOptions
                                          .wiggleAmplitudeFor(postButtonState),
                                      wiggleCount: buttonOptions.wiggleCount,
                                      wiggleDuration:
                                          buttonOptions.wiggleDuration,
                                      morphDuration:
                                          buttonOptions.morphDuration,
                                      progressColor:
                                          buttonOptions.progressColor,
                                      foregroundColor:
                                          buttonOptions.foregroundColor,
                                      successColor: buttonOptions.successColor,
                                      errorColor: buttonOptions.errorColor,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            FaIcon(
                                              FaIconData(
                                                const IconData(
                                                  /* paperPlane */ 0xf1d8,
                                                  fontFamily:
                                                      'FontAwesomeRegular',
                                                  fontPackage:
                                                      'font_awesome_flutter',
                                                ),
                                              ),
                                              size: 15,
                                            ),
                                            Text(
                                              'Post',
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
                                                    color: Colors.white,
                                                    letterSpacing: 0.0,
                                                    fontWeight: AppTheme.of(
                                                      context,
                                                    ).titleLarge.fontWeight,
                                                    fontStyle: AppTheme.of(
                                                      context,
                                                    ).titleLarge.fontStyle,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
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
