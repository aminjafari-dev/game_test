import 'package:flutter/material.dart';
import 'package:game_test/core/theme/app_theme.dart';
import 'package:game_test/core/widgets/g_text.dart';
import 'package:game_test/features/elements/presentation/pages/elements_page.dart';
import 'package:game_test/features/horror_survival/presentation/pages/horror_game_page.dart';
import 'package:game_test/l10n/app_localizations.dart';

/// Root shell with top tabs for switching between the game and elements workshop.
///
/// Use as [MaterialApp.home] so players can jump between playing and authoring
/// props. Example: `home: const HomeShellPage()`
class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Material(
          color: AppColors.surface,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _ShellTab(
                    label: l10n.tabGame,
                    selected: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  const SizedBox(width: 8),
                  _ShellTab(
                    label: l10n.tabElements,
                    selected: _selectedIndex == 1,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: const [
              HorrorGamePage(),
              ElementsPage(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Single top tab chip used by [HomeShellPage].
class _ShellTab extends StatelessWidget {
  const _ShellTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: GText(
                label,
                style: selected ? GTextStyle.subtitle : GTextStyle.body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
