import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:game_test/core/theme/app_theme.dart';
import 'package:game_test/features/horror_survival/presentation/pages/horror_game_page.dart';
import 'package:game_test/features/horror_survival/presentation/providers/game_provider.dart';
import 'package:game_test/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const HorrorSurvivalApp());
}

/// Root application widget for the horror survival game.
class HorrorSurvivalApp extends StatelessWidget {
  const HorrorSurvivalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'Horror Survival',
        theme: AppTheme.darkTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HorrorGamePage(),
      ),
    );
  }
}
