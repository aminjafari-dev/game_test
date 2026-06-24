import 'package:flutter/material.dart';
import 'package:game_test/core/theme/app_theme.dart';
import 'package:game_test/core/widgets/g_gap.dart';
import 'package:game_test/core/widgets/g_text.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/door_system.dart';
import 'package:game_test/features/horror_survival/presentation/providers/game_provider.dart';
import 'package:game_test/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Heads-up display showing health, keys, and interaction hints.
class GameHud extends StatelessWidget {
  const GameHud({super.key, required this.nearbyInteract});

  final NearbyInteractable nearbyInteract;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        final healthFraction = game.health / 100.0;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GText(
                  l10n.healthLabel(game.health),
                  style: GTextStyle.subtitle,
                ),
                GGap.h8,
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: healthFraction,
                    minHeight: 8,
                    backgroundColor: AppColors.surface,
                    color: healthFraction > 0.3
                        ? AppColors.healthGreen
                        : AppColors.bloodRed,
                  ),
                ),
                GGap.h12,
                GText(
                  l10n.keysLabel(game.keys.length, GameState.totalKeys),
                  style: GTextStyle.body,
                ),
                const Spacer(),
                GText(
                  nearbyHintText(l10n, nearbyInteract),
                  style: GTextStyle.caption,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Localized hint describing what interact will do right now.
String nearbyHintText(AppLocalizations l10n, NearbyInteractable nearby) {
  return switch (nearby) {
    NearbyInteractable.key => l10n.interactPickUpKey,
    NearbyInteractable.openDoor => l10n.interactOpenDoor,
    NearbyInteractable.unlockDoor => l10n.interactUnlockDoor,
    NearbyInteractable.lockedDoor => l10n.interactLockedDoor,
    NearbyInteractable.escape => l10n.interactEscape,
    NearbyInteractable.none => l10n.interactHint,
  };
}
