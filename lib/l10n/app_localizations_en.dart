// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Horror Survival';

  @override
  String healthLabel(int health) {
    return 'Health: $health';
  }

  @override
  String keysLabel(int count, int total) {
    return 'Keys: $count/$total';
  }

  @override
  String get interactHint =>
      'Use the action button when standing next to a door or key';

  @override
  String get interactButton => 'Interact';

  @override
  String get interactPickUpKey => 'Pick Up Key';

  @override
  String get interactOpenDoor => 'Open Door';

  @override
  String get interactUnlockDoor => 'Unlock Door';

  @override
  String get interactLockedDoor => 'Door Locked';

  @override
  String get interactEscape => 'Escape!';

  @override
  String get interactNothingNearby => 'Nothing nearby — walk to a door or key';

  @override
  String get interactDoorOpened => 'Door opened';

  @override
  String get interactDoorUnlocked => 'Door unlocked and opened';

  @override
  String get gameOverTitle => 'You Did Not Survive';

  @override
  String get gameOverMessage => 'The darkness claimed you. Try again.';

  @override
  String get winTitle => 'You Escaped!';

  @override
  String get winMessage =>
      'You reached the elevator and escaped The Mansfield.';

  @override
  String get retryButton => 'Try Again';

  @override
  String get loadingScene => 'Entering The Mansfield...';

  @override
  String get buildingName => 'The Mansfield — Level 5';

  @override
  String get buildingAddress => '5100 Wilshire Boulevard, Los Angeles';

  @override
  String get roomCorridor => 'Corridor';

  @override
  String get roomSunDeck => '5th Floor Sun Deck';

  @override
  String get roomElevator => 'Elevator';

  @override
  String get roomStairwell => 'Stairwell';

  @override
  String unitLabel(String number) {
    return 'Unit $number';
  }

  @override
  String get doorLocked => 'Door is locked. Find more keys.';

  @override
  String get keyCollected => 'You found a key!';
}
