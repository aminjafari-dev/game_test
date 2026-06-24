import 'package:flutter/material.dart';
import 'package:game_test/core/theme/app_theme.dart';
import 'package:game_test/core/widgets/g_text.dart';

/// Styled button used throughout the horror survival UI.
///
/// Example: `GButton(label: l10n.retryButton, onPressed: _restart)`
class GButton extends StatelessWidget {
  const GButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isDanger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDanger ? AppColors.bloodRed : AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: GText(label, style: GTextStyle.subtitle),
    );
  }
}
