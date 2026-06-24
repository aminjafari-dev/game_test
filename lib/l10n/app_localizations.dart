import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Application title shown in the app bar and launcher
  ///
  /// In en, this message translates to:
  /// **'Horror Survival'**
  String get appTitle;

  /// HUD label showing current player health
  ///
  /// In en, this message translates to:
  /// **'Health: {health}'**
  String healthLabel(int health);

  /// HUD label showing collected keys
  ///
  /// In en, this message translates to:
  /// **'Keys: {count}/{total}'**
  String keysLabel(int count, int total);

  /// Hint for interaction controls
  ///
  /// In en, this message translates to:
  /// **'Use the action button when standing next to a door or key'**
  String get interactHint;

  /// Generic interact button when nothing is nearby
  ///
  /// In en, this message translates to:
  /// **'Interact'**
  String get interactButton;

  /// Button label when near a key
  ///
  /// In en, this message translates to:
  /// **'Pick Up Key'**
  String get interactPickUpKey;

  /// Button label when near an unlocked door
  ///
  /// In en, this message translates to:
  /// **'Open Door'**
  String get interactOpenDoor;

  /// Button label when near exit door with all keys
  ///
  /// In en, this message translates to:
  /// **'Unlock Door'**
  String get interactUnlockDoor;

  /// Button label when near locked door without keys
  ///
  /// In en, this message translates to:
  /// **'Door Locked'**
  String get interactLockedDoor;

  /// Button label when near open exit door
  ///
  /// In en, this message translates to:
  /// **'Escape!'**
  String get interactEscape;

  /// Message when interact pressed with nothing in range
  ///
  /// In en, this message translates to:
  /// **'Nothing nearby — walk to a door or key'**
  String get interactNothingNearby;

  /// Feedback when a door is opened
  ///
  /// In en, this message translates to:
  /// **'Door opened'**
  String get interactDoorOpened;

  /// Feedback when exit door is unlocked
  ///
  /// In en, this message translates to:
  /// **'Door unlocked and opened'**
  String get interactDoorUnlocked;

  /// Title shown when player health reaches zero
  ///
  /// In en, this message translates to:
  /// **'You Did Not Survive'**
  String get gameOverTitle;

  /// Message shown on game over screen
  ///
  /// In en, this message translates to:
  /// **'The darkness claimed you. Try again.'**
  String get gameOverMessage;

  /// Title shown when player escapes the building
  ///
  /// In en, this message translates to:
  /// **'You Escaped!'**
  String get winTitle;

  /// Message shown on win screen
  ///
  /// In en, this message translates to:
  /// **'You reached the elevator and escaped The Mansfield.'**
  String get winMessage;

  /// Button to restart the game
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retryButton;

  /// Loading text while scene initializes
  ///
  /// In en, this message translates to:
  /// **'Entering The Mansfield...'**
  String get loadingScene;

  /// Name of the building shown in HUD or title
  ///
  /// In en, this message translates to:
  /// **'The Mansfield — Level 5'**
  String get buildingName;

  /// Address of The Mansfield building
  ///
  /// In en, this message translates to:
  /// **'5100 Wilshire Boulevard, Los Angeles'**
  String get buildingAddress;

  /// Name of a corridor space
  ///
  /// In en, this message translates to:
  /// **'Corridor'**
  String get roomCorridor;

  /// Name of the sun deck feature on level 5
  ///
  /// In en, this message translates to:
  /// **'5th Floor Sun Deck'**
  String get roomSunDeck;

  /// Name of an elevator shaft
  ///
  /// In en, this message translates to:
  /// **'Elevator'**
  String get roomElevator;

  /// Name of a stairwell
  ///
  /// In en, this message translates to:
  /// **'Stairwell'**
  String get roomStairwell;

  /// Label for an apartment unit number
  ///
  /// In en, this message translates to:
  /// **'Unit {number}'**
  String unitLabel(String number);

  /// Message when player tries locked door without keys
  ///
  /// In en, this message translates to:
  /// **'Door is locked. Find more keys.'**
  String get doorLocked;

  /// Snack bar when player collects a key
  ///
  /// In en, this message translates to:
  /// **'You found a key!'**
  String get keyCollected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
