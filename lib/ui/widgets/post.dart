import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lilypad/models/post.dart';
import 'package:lilypad/services/content.dart';
import 'package:lilypad/services/user.dart';
import 'package:lilypad/ui/pages/edit_post.dart';
import 'package:lilypad/ui/pages/post_view.dart';
import 'package:lilypad/ui/theme/theme.dart';
import 'package:lilypad/ui/widgets/buttons.dart';
import 'package:lilypad/util/ui.dart';

import 'user.dart';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:material_ui/material_ui.dart';

/// Component to take post data in and display
class PostWidget extends StatefulWidget {
  const PostWidget({super.key, required this.post, this.replyingTo});

  final Post post;
  final Post? replyingTo;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  // State field(s) for FlippableCard widget.
  final flippableCardController = FlipCardController();
  bool flippableCardIsFront = true;

  late final Post? fetchedReplyingTo;

  @override
  void initState() {
    super.initState();

    if (widget.replyingTo == null && widget.post.replying != null) {
      ContentService.fetchPost(widget.post.replying!).then(
        (r) => setState(() {
          fetchedReplyingTo = r;
        }),
      );
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
          widget.post.user.uuid != null &&
          widget.post.user.uuid != UserService.currentUser?.uuid,
      onFlip: () async => {
        if (widget.post.user.uuid != null)
          {
            widget.post.user = await ContentService.fetchUser(
              widget.post.user.uuid!,
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
                    widget.post.replying != null
                        ? GestureDetector(
                            onTap: () {
                              if (fetchedReplyingTo != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) => PostViewWidget(
                                      post: fetchedReplyingTo!,
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
                                        widget.post.user.username,
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
                                widget.post.user.username,
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
                                widget.post.content,
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
                      widget.post.updated == null
                          ? widget.post.created.toLocal().toString()
                          : 'Edited ${widget.post.updated!.toLocal().toString()}',
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
                    ContentService.upvotePost(widget.post.uuid);
                  },
                  text: formatNumber(
                    widget.post.upvotes,
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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => PostViewWidget(
                          post: widget.post,
                          replying: fetchedReplyingTo,
                        ),
                      ),
                    );
                  },
                  text: formatNumber(
                    widget.post.noReplies,
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
                  offstage: widget.post.uuid == UserService.currentUser?.uuid,
                  child: AppButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              EditPostWidget(post: widget.post),
                        ),
                      );
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
      back: UserWidget(user: widget.post.user),
    );
  }
}
