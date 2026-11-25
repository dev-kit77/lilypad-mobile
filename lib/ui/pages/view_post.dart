import 'dart:io';

import 'package:lilypad/models/post.dart';
import 'package:lilypad/services/content.dart';
import 'package:lilypad/services/ui/dialog.dart';
import 'package:lilypad/ui/pages/new_reply.dart';
import 'package:lilypad/util/api_ex.dart';
import 'package:lilypad/util/navigation.dart';
import 'package:page_transition/page_transition.dart';

import '../widgets/logo.dart';
import '../widgets/post.dart';

import 'package:material_ui/material_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wiggly_loaders/wiggly_loaders.dart';

import '../theme/theme.dart';
import '../../util/ui.dart';

class ViewPostWidget extends StatefulWidget {
  const ViewPostWidget({
    super.key,
    required this.post,
    this.replying,
    this.noCache = false,
  });

  final Post post;
  final Post? replying;

  /// Skip cached data when fetching this page's content.
  final bool noCache;

  static String routeName = 'postView';
  static String routePath = '/postView';

  @override
  State<ViewPostWidget> createState() => _ViewPostWidgetState();
}

class _ViewPostWidgetState extends State<ViewPostWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Post? updatedPost;

  WigglyButtonState replyButtonState = WigglyButtonState.idle;

  @override
  void initState() {
    super.initState();

    updatedPost ??= widget.post;

    _loadContent(widget.noCache);
  }

  void _loadContent(bool refresh) async {
    try {
      //attempt fetch replies
      final List<Post> r = await ContentService.fetchReplies(
        updatedPost!.uuid,
        noCache: refresh,
      );

      if (mounted) {
        setState(() => updatedPost = updatedPost!.copyWith(replies: r));
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

  void _openNewReply() async {
    //set loading state
    if (mounted) {
      setState(() => replyButtonState = WigglyButtonState.loading);
    }

    //hold state for user
    Future.delayed(const Duration(milliseconds: 500), () async {
      //attempt to create reply
      if (mounted) {
        final newReply = await Navigator.of(context).push<bool>(
          PageTransition<bool>(
            type: PageTransitionType.fade,
            duration: const Duration(milliseconds: 300),
            reverseDuration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
            opaque: true,
            settings: RouteSettings(name: NewReplyWidget.routePath),
            child: NewReplyWidget(replyingTo: updatedPost!),
          ),
        );

        //begin content reload
        if (newReply == true) {
          _loadContent(true);

          //show success
          if (mounted) {
            setState(() => replyButtonState = WigglyButtonState.success);
          }

          //hold state for user
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() => replyButtonState = WigglyButtonState.idle);
            }
          });
        } else {
          //set back to idle
          if (mounted) {
            setState(() => replyButtonState = WigglyButtonState.idle);
          }
        }
      }
    });
  }

  void _syncPost(Post p) {
    if (mounted && updatedPost!.replies.isNotEmpty) {
      //find indexes where post ids equal
      final i = updatedPost!.replies.indexWhere((r) => r.uuid == p.uuid);

      //replace immutably if found
      if (i >= 0) {
        setState(() {
          final replies = List<Post>.from(updatedPost!.replies);
          replies[i] = p;
          updatedPost = updatedPost!.copyWith(replies: replies);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fabOptions = AppTheme.of(context).wigglyButtonOptions
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
                                              PostWidget(
                                                post: updatedPost!,
                                                replyingTo: widget.replying,
                                                onUpdate: (p) {
                                                  _syncPost(p);
                                                  setState(() {
                                                    updatedPost = p.copyWith(
                                                      replies:
                                                          updatedPost!.replies,
                                                    );
                                                  });
                                                },
                                                noCache: true,
                                              ),
                                            ],
                                          ),
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
                                    Navigator.of(context).popUntilWithResult(
                                      isTabRootRoute,
                                      updatedPost,
                                    );
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
                                                        font: GoogleFonts.playfairDisplay(
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
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        0,
                                        4,
                                        0,
                                        4,
                                      ),
                                      child: Text(
                                        'Replies to ',
                                        textAlign: TextAlign.start,
                                        style: AppTheme.of(context).title
                                            .override(
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
                                        updatedPost!.user.username,
                                        textAlign: TextAlign.start,
                                        style: AppTheme.of(context).title
                                            .override(
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
                                        '.',
                                        textAlign: TextAlign.start,
                                        style: AppTheme.of(context).title
                                            .override(
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
                                      ListView(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        primary: false,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        children: updatedPost!.replies
                                            .map(
                                              (r) => PostWidget(
                                                post: r,
                                                replyingTo: updatedPost!,
                                                onUpdate: _syncPost,
                                                noCache: widget.noCache,
                                              ),
                                            )
                                            .toList()
                                            .divide(SizedBox(height: 12)),
                                      ),
                                    ].addToEnd(SizedBox(height: 12)),
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
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
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
                          state: replyButtonState,
                          onPressed: _openNewReply,
                          width: fabOptions.width,
                          height: fabOptions.height,
                          borderRadius: fabOptions.borderRadius,
                          wiggleAmplitude: fabOptions.wiggleAmplitudeFor(
                            replyButtonState,
                          ),
                          wiggleCount: fabOptions.wiggleCount,
                          wiggleDuration: fabOptions.wiggleDuration,
                          morphDuration: fabOptions.morphDuration,
                          progressColor: fabOptions.progressColor,
                          foregroundColor: fabOptions.foregroundColor,
                          successColor: fabOptions.successColor,
                          errorColor: fabOptions.errorColor,
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
