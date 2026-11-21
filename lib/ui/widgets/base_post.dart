import 'package:lilypad/models/post.dart';
import 'package:material_ui/material_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/log.dart';
import '../pages/post_view.dart' show PostViewWidget;
import '../theme/theme.dart';
import '../../util/ui.dart';
import '../widgets/buttons.dart';

class BasePostWidget extends StatefulWidget {
  const BasePostWidget({super.key, required this.post});

  final Post post;

  @override
  State<BasePostWidget> createState() => _BasePostWidgetState();
}

class _BasePostWidgetState extends State<BasePostWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
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
                  Row(
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
                          fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
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
                          fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AppButton(
                onPressed: () {
                  LogService.dbg(
                    'upvoteButton pressed ...',
                    src: 'BasePostWidget',
                  );
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
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => PostViewWidget(post: widget.post),
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
            ].divide(SizedBox(height: 5)),
          ),
        ],
      ),
    );
  }
}
