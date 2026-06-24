import 'package:flutter/material.dart';
import 'package:game_test/core/widgets/g_button.dart';
import 'package:game_test/core/widgets/g_text.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/door_system.dart';
import 'package:game_test/l10n/app_localizations.dart';

/// Context-aware interact button that shows what will happen when pressed.
///
/// Label changes based on [nearbyInteract]: pick up key, open door, escape, etc.
class InteractButton extends StatelessWidget {
  const InteractButton({
    super.key,
    required this.nearbyInteract,
    required this.onPressed,
  });

  final NearbyInteractable nearbyInteract;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = _labelFor(l10n, nearbyInteract);
    final canAct = nearbyInteract != NearbyInteractable.none;

    return GButton(
      label: label,
      onPressed: canAct ? onPressed : () => onPressed(),
    );
  }

  String _labelFor(AppLocalizations l10n, NearbyInteractable target) {
    return switch (target) {
      NearbyInteractable.key => l10n.interactPickUpKey,
      NearbyInteractable.openDoor => l10n.interactOpenDoor,
      NearbyInteractable.unlockDoor => l10n.interactUnlockDoor,
      NearbyInteractable.lockedDoor => l10n.interactLockedDoor,
      NearbyInteractable.escape => l10n.interactEscape,
      NearbyInteractable.none => l10n.interactButton,
    };
  }
}

/// Shows feedback after the player presses interact.
void showInteractFeedback(BuildContext context, String? result) {
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context);
  final message = switch (result) {
    'key' => l10n.keyCollected,
    'open' => l10n.interactDoorOpened,
    'unlock' => l10n.interactDoorUnlocked,
    'locked' => l10n.doorLocked,
    'escape' => l10n.winTitle,
    _ => l10n.interactNothingNearby,
  };
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: GText(message, style: GTextStyle.body),
      duration: const Duration(seconds: 2),
    ),
  );
}
