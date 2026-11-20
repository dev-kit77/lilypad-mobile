import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/theme.dart';

class LogoWidget extends StatefulWidget {
  const LogoWidget({super.key});

  @override
  State<LogoWidget> createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          'lilypad',
          style: AppTheme.of(context).headlineLarge.override(
            font: GoogleFonts.asset(
              fontWeight: AppTheme.of(context).headlineLarge.fontWeight,
              fontStyle: AppTheme.of(context).headlineLarge.fontStyle,
            ),
            letterSpacing: 0.0,
            fontWeight: AppTheme.of(context).headlineLarge.fontWeight,
            fontStyle: AppTheme.of(context).headlineLarge.fontStyle,
          ),
        ),
        Text(
          '.',
          style: AppTheme.of(context).headlineLarge.override(
            font: GoogleFonts.asset(
              fontWeight: AppTheme.of(context).headlineLarge.fontWeight,
              fontStyle: AppTheme.of(context).headlineLarge.fontStyle,
            ),
            color: AppTheme.of(context).primary,
            letterSpacing: 0.0,
            fontWeight: AppTheme.of(context).headlineLarge.fontWeight,
            fontStyle: AppTheme.of(context).headlineLarge.fontStyle,
          ),
        ),
      ],
    );
  }
}
