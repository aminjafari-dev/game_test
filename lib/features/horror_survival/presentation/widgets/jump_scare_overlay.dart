import 'package:flutter/material.dart';
import 'package:game_test/core/constants/image_path.dart';
import 'package:game_test/core/theme/app_theme.dart';
import 'package:game_test/features/horror_survival/presentation/providers/game_provider.dart';
import 'package:provider/provider.dart';

/// Full-screen ghost overlay shown during jump scares.
class JumpScareOverlay extends StatelessWidget {
  const JumpScareOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        if (game.activeJumpScare == null) return const SizedBox.shrink();
        return Positioned.fill(
          child: Container(
            color: AppColors.overlayDark,
            child: Center(
              child: Image.asset(
                ImagePath.ghostOverlay,
                width: 280,
                height: 280,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.visibility,
                  size: 200,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
