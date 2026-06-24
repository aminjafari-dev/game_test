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
  String get interactHint => 'Tap INTERACT or press E near doors and items';

  @override
  String get interactButton => 'INTERACT';

  @override
  String get gameOverTitle => 'You Did Not Survive';

  @override
  String get gameOverMessage => 'The darkness claimed you. Try again.';

  @override
  String get winTitle => 'You Escaped!';

  @override
  String get winMessage => 'You unlocked the exit and fled into the night.';

  @override
  String get retryButton => 'Try Again';

  @override
  String get loadingScene => 'Entering the building...';

  @override
  String get roomLibrary => 'Library';

  @override
  String get roomKitchen => 'Kitchen';

  @override
  String get roomCorridor => 'Corridor';

  @override
  String get roomNursery => 'Nursery';

  @override
  String get roomBathroom => 'Bathroom';

  @override
  String get roomStorage => 'Storage';

  @override
  String get roomExitLobby => 'Exit Lobby';

  @override
  String get doorLocked => 'Door is locked. Find more keys.';

  @override
  String get keyCollected => 'You found a key!';
}
