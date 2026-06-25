import 'package:flutter/material.dart';
import 'package:game_test/core/theme/app_theme.dart';
import 'package:game_test/core/widgets/g_button.dart';
import 'package:game_test/core/widgets/g_gap.dart';
import 'package:game_test/core/widgets/g_text.dart';
import 'package:game_test/features/elements/presentation/game/coffin_builder.dart';
import 'package:game_test/l10n/app_localizations.dart';

/// Overlay controls for previewing the Halloween coffin on the Elements page.
///
/// Shows title, status, and Open / Close buttons wired to [CoffinProp].
/// Example: `CoffinControlBar(coffin: coffin, onStateChanged: () => setState(() {}))`
class CoffinControlBar extends StatelessWidget {
  const CoffinControlBar({
    super.key,
    required this.coffin,
    required this.onStateChanged,
  });

  final CoffinProp coffin;
  final VoidCallback onStateChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final statusLabel = coffin.isFullyOpen
        ? l10n.elementsCoffinStateOpen
        : l10n.elementsCoffinStateClosed;

    return Material(
      color: AppColors.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GText(l10n.elementsCoffinTitle, style: GTextStyle.title),
            GGap.h8,
            GText(l10n.elementsCoffinSubtitle, style: GTextStyle.body),
            GGap.h12,
            GText(statusLabel, style: GTextStyle.subtitle),
            GGap.h16,
            Row(
              children: [
                Expanded(
                  child: GButton(
                    label: l10n.elementsOpenCoffin,
                    onPressed: coffin.isFullyOpen
                        ? null
                        : () {
                            coffin.setOpen(true);
                            onStateChanged();
                          },
                  ),
                ),
                GGap.w16,
                Expanded(
                  child: GButton(
                    label: l10n.elementsCloseCoffin,
                    onPressed: coffin.isFullyClosed
                        ? null
                        : () {
                            coffin.setOpen(false);
                            onStateChanged();
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
