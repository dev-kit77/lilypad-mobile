import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/theme.dart';
import '../../util/ui.dart';

class UserWidget extends StatefulWidget {
  const UserWidget({super.key, this.username, this.userStatus, this.userBio});

  final String? username;
  final String? userStatus;
  final String? userBio;

  @override
  State<UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: AppTheme.of(context).secondaryBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  widget.username ?? 'Anonymous',
                  style: AppTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.playfairDisplay(
                      fontWeight: AppTheme.of(context).bodyLarge.fontWeight,
                      fontStyle: AppTheme.of(context).bodyLarge.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight: AppTheme.of(context).bodyLarge.fontWeight,
                    fontStyle: AppTheme.of(context).bodyLarge.fontStyle,
                  ),
                ),
                Text(
                  widget.userStatus ?? 'I am on lilypad',
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
                Text(
                  widget.userBio ?? 'lilypad User',
                  style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.playfairDisplay(
                      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                    fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                  ),
                ),
              ].divide(SizedBox(height: 4)),
            ),
          ),
        ],
      ),
    );
  }
}
