import 'package:flutter/material.dart';
import 'package:game_test/core/theme/app_theme.dart';
import 'package:game_test/core/widgets/g_button.dart';
import 'package:game_test/core/widgets/g_gap.dart';
import 'package:game_test/core/widgets/g_text.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/providers/game_provider.dart';
import 'package:game_test/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Win or lose overlay shown when game phase changes.
class GameEndOverlay extends StatelessWidget {
  const GameEndOverlay({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        if (game.phase == GamePhase.playing) return const SizedBox.shrink();

        final isWin = game.phase == GamePhase.won;
        return Positioned.fill(
          child: Container(
            color: AppColors.overlayDark,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GText(
                      isWin ? l10n.winTitle : l10n.gameOverTitle,
                      style: GTextStyle.title,
                      textAlign: TextAlign.center,
                    ),
                    GGap.h16,
                    GText(
                      isWin ? l10n.winMessage : l10n.gameOverMessage,
                      style: GTextStyle.body,
                      textAlign: TextAlign.center,
                    ),
                    GGap.h24,
                    GButton(
                      label: l10n.retryButton,
                      onPressed: onRetry,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
