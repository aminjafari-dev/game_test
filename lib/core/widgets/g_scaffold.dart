import 'package:flutter/material.dart';
import 'package:game_test/core/theme/app_theme.dart';

/// Project scaffold wrapper with horror theme defaults.
///
/// Use instead of [Scaffold] directly for consistent background and safe area.
/// Example: `GScaffold(body: Stack(children: [sceneView, hud]))`
class GScaffold extends StatelessWidget {
  const GScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
