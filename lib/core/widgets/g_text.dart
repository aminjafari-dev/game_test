import 'package:flutter/material.dart';
import 'package:game_test/core/theme/app_theme.dart';

/// Project-wide text widget that applies horror theme styling.
///
/// Use instead of raw [Text] so colors and typography stay consistent.
/// Example: `GText(l10n.healthLabel(health), style: GTextStyle.title)`
class GText extends StatelessWidget {
  const GText(
    this.data, {
    super.key,
    this.style = GTextStyle.body,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final GTextStyle style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = switch (style) {
      GTextStyle.title => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      GTextStyle.subtitle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      GTextStyle.body => const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      GTextStyle.caption => const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
      GTextStyle.danger => const TextStyle(
        fontSize: 14,
        color: AppColors.bloodRed,
        fontWeight: FontWeight.bold,
      ),
    };

    return Text(
      data,
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Predefined text styles for [GText].
enum GTextStyle { title, subtitle, body, caption, danger }
