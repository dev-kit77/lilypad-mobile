import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lilypad/models/post.dart';
import 'package:lilypad/services/content.dart';
import 'package:lilypad/services/user.dart';
import 'package:lilypad/ui/pages/edit_post.dart';
import 'package:lilypad/ui/pages/view_post.dart';
import 'package:lilypad/ui/theme/theme.dart';
import 'package:lilypad/ui/widgets/buttons.dart';
import 'package:lilypad/util/ui.dart';

import 'user.dart';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:material_ui/material_ui.dart';

/// Component to take post data in and display
class PostWidget extends StatefulWidget {
  const PostWidget({
    super.key,
    required this.post,
    this.replyingTo,
    this.onUpdate,
    this.noCache = false,
  });

  final Function(Post p)? onUpdate;
  final Post post;
  final Post? replyingTo;

  /// Skip cached data when fetching this widget's content.
  final bool noCache;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  // State field(s) for FlippableCard widget.
  final flippableCardController = FlipCardController();
  bool flippableCardIsFront = true;

  Post? updatedPost;
  Post? fetchedReplyingTo;

  @override
  void initState() {
    super.initState();

    updatedPost ??= widget.post;
    fetchedReplyingTo ??= widget.replyingTo;

    if (fetchedReplyingTo == null && updatedPost!.replying != null) {
      ContentService.fetchPost(
        updatedPost!.replying!,
        noCache: widget.noCache,
      ).then((r) => setState(() => fetchedReplyingTo = r));
    } else {
      fetchedReplyingTo = widget.replyingTo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      fill: Fill.fillBack,
      controller: flippableCardController,
      flipOnTouch:
          updatedPost!.user.uuid != null &&
          updatedPost!.user.uuid != UserService.currentUser?.uuid,
      onFlip: () async => {
        if (updatedPost!.user.uuid != null)
          {
            updatedPost!.user = await ContentService.fetchUser(
              updatedPost!.user.uuid!,
              noCache: widget.noCache,
            ),
          },

        flippableCardIsFront = !flippableCardIsFront,
      },
      direction: FlipDirection.VERTICAL,
      speed: 400,
      front: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: AppTheme.of(context).secondaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16, 16, 0, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    updatedPost!.replying != null
                        ? GestureDetector(
                            onTap: () {
                              if (fetchedReplyingTo != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) => ViewPostWidget(
                                      post: fetchedReplyingTo!,
                                      noCache: widget.noCache,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 0,
                                    runSpacing: 0,
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    direction: Axis.horizontal,
                                    runAlignment: WrapAlignment.start,
                                    verticalDirection: VerticalDirection.down,
                                    clipBehavior: Clip.none,
                                    children: [
                                      Text(
                                        updatedPost!.user.username,
                                        style: AppTheme.of(context).bodyMedium
                                            .override(
                                              font: GoogleFonts.playfairDisplay(
                                                fontWeight: AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                                fontStyle: AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                              ),
                                              color: AppTheme.of(context)
                                                  .primaryText,
                                              letterSpacing: 0.0,
                                              fontWeight: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        ' replied to ',
                                        style: AppTheme.of(context).bodyMedium
                                            .override(
                                              font: GoogleFonts.playfairDisplay(
                                                fontWeight: AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                                fontStyle: AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                      ),
                                      Text(
                                        fetchedReplyingTo?.user.username ??
                                            'Unknown',
                                        style: AppTheme.of(context).bodyMedium
                                            .override(
                                              font: GoogleFonts.playfairDisplay(
                                                fontWeight: AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                                fontStyle: AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                              ),
                                              color: AppTheme.of(context)
                                                  .primaryText,
                                              letterSpacing: 0.0,
                                              fontWeight: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                          4,
                                          0,
                                          0,
                                          0,
                                        ),
                                        child: Icon(
                                          Icons.reply,
                                          color: AppTheme.of(context)
                                              .secondaryText,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                updatedPost!.user.username,
                                style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.playfairDisplay(
                                    fontWeight: AppTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: AppTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: AppTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                ' said...',
                                style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.playfairDisplay(
                                    fontWeight: AppTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: AppTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                              ),
                            ],
                          ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 0,
                            runSpacing: 0,
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            direction: Axis.horizontal,
                            runAlignment: WrapAlignment.start,
                            verticalDirection: VerticalDirection.down,
                            clipBehavior: Clip.none,
                            children: [
                              Text(
                                updatedPost!.content,
                                textAlign: TextAlign.start,
                                style: AppTheme.of(context).bodyLarge.override(
                                  font: GoogleFonts.playfairDisplay(
                                    fontWeight: AppTheme.of(context)
                                        .bodyLarge
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .bodyLarge
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: AppTheme.of(context)
                                      .bodyLarge
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .bodyLarge
                                      .fontStyle,
                                ),
                                overflow: TextOverflow.fade,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      updatedPost!.updated == null
                          ? updatedPost!.created.toLocal().toString()
                          : 'Edited ${updatedPost!.updated!.toLocal().toString()}',
                      style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.playfairDisplay(
                          fontWeight: AppTheme.of(context).bodySmall.fontWeight,
                          fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight: AppTheme.of(context).bodySmall.fontWeight,
                        fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                      ),
                    ),
                  ].divide(SizedBox(height: 4)),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              textBaseline: TextBaseline.alphabetic,
              children: [
                AppButton(
                  onPressed: () {
                    ContentService.upvotePost(updatedPost!.uuid).then(
                      (p) => setState(() {
                        widget.onUpdate?.call(p);
                        updatedPost = p;
                      }),
                    );
                  },
                  text: formatNumber(
                    updatedPost!.upvotes,
                    formatType: NumberFormatType.compact,
                  ),
                  icon: FaIcon(
                    FaIconData(
                      const IconData(
                        /* arrowAltCircleUp */ 0xf35b,
                        fontFamily: 'FontAwesomeRegular',
                        fontPackage: 'font_awesome_flutter',
                      ),
                    ),
                    size: 20,
                  ),
                  options: AppButtonOptions(
                    height: 30,
                    padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    iconAlignment: IconAlignment.end,
                    iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: Color(0x00FFFFFF),
                    textStyle: AppTheme.of(context).labelLarge.override(
                      font: GoogleFonts.playfairDisplay(
                        fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                        fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                      fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                    ),
                    elevation: 0,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  showLoadingIndicator: false,
                ),
                AppButton(
                  onPressed: () async {
                    Post? updated = await Navigator.of(context).push<Post>(
                      MaterialPageRoute<Post>(
                        builder: (context) => ViewPostWidget(
                          post: updatedPost!,
                          replying: fetchedReplyingTo,
                          noCache: widget.noCache,
                        ),
                      ),
                    );

                    if (updated != updatedPost! && mounted) {
                      setState(() {
                        updatedPost = updated;
                      });
                    }
                  },
                  text: formatNumber(
                    updatedPost!.noReplies,
                    formatType: NumberFormatType.compact,
                  ),
                  icon: FaIcon(
                    FaIconData(
                      const IconData(
                        /* comments */ 0xf086,
                        fontFamily: 'FontAwesomeRegular',
                        fontPackage: 'font_awesome_flutter',
                      ),
                    ),
                    size: 20,
                  ),
                  options: AppButtonOptions(
                    height: 30,
                    padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    iconAlignment: IconAlignment.end,
                    iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: Color(0x00FFFFFF),
                    textStyle: AppTheme.of(context).labelLarge.override(
                      font: GoogleFonts.playfairDisplay(
                        fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                        fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                      fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                    ),
                    elevation: 0,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Offstage(
                  offstage: updatedPost!.uuid == UserService.currentUser?.uuid,
                  child: AppButton(
                    onPressed: () async {
                      final Post? updated = await Navigator.of(context)
                          .push<Post>(
                            MaterialPageRoute<Post>(
                              builder: (context) =>
                                  EditPostWidget(post: updatedPost!),
                            ),
                          );

                      if (updated != null && mounted) {
                        setState(() {
                          widget.onUpdate?.call(updated);
                          updatedPost = updated;
                        });
                      }
                    },
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
                      height: 30,
                      padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      iconAlignment: IconAlignment.end,
                      iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: Color(0x00FFFFFF),
                      textStyle: AppTheme.of(context).labelLarge.override(
                        font: GoogleFonts.playfairDisplay(
                          fontWeight: AppTheme.of(context)
                              .labelLarge
                              .fontWeight,
                          fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                        fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                      ),
                      elevation: 0,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    showLoadingIndicator: false,
                  ),
                ),
              ].divide(SizedBox(height: 5)),
            ),
          ],
        ),
      ),
      back: UserWidget(user: updatedPost!.user),
    );
  }
}
