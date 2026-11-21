import 'package:lilypad/models/post.dart';
import 'package:lilypad/services/content.dart';
import 'package:lilypad/ui/widgets/base_reply.dart';

import '../widgets/logo.dart';
import '../widgets/post.dart';
import '../widgets/reply.dart';

import 'package:material_ui/material_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/theme.dart';
import '../../util/ui.dart';
import '../widgets/buttons.dart';
import 'new_post.dart' show NewPostWidget;

class PostViewWidget extends StatefulWidget {
  const PostViewWidget({super.key, required this.post, this.replying});

  final Post post;
  final Post? replying;

  static String routeName = 'postView';
  static String routePath = '/postView';

  @override
  State<PostViewWidget> createState() => _PostViewWidgetState();
}

class _PostViewWidgetState extends State<PostViewWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    ContentService.fetchReplies(widget.post.uuid).then(
      (r) => setState(() {
        widget.post.replies = r;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                                              widget.replying == null
                                                  ? PostWidget(
                                                      post: widget.post,
                                                    )
                                                  : ReplyWidget(
                                                      post: widget.post,
                                                      replying: widget.replying,
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
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        0,
                                        4,
                                        0,
                                        4,
                                      ),
                                      child: Text(
                                        widget.post.user.username,
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
                                        children: widget.post.replies
                                            .map(
                                              (r) => r.user.uuid != null
                                                  ? ReplyWidget(
                                                      post: r,
                                                      replying: widget.post,
                                                    )
                                                  : BaseReplyWidget(
                                                      post: r,
                                                      replying: widget.post,
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
                                  /* pencilAlt */ 0xf303,
                                  fontFamily: 'FontAwesomeSolid',
                                  fontPackage: 'font_awesome_flutter',
                                ),
                              ),
                              color: AppTheme.of(context).info,
                              size: 36,
                            ),
                            onPressed: () async {
                              Navigator.of(context)
                                  .pushNamed(NewPostWidget.routePath);
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
