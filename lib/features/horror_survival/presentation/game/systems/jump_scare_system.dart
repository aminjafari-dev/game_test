import 'dart:math' as math;

import 'package:game_test/core/audio/audio_manager.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/providers/game_provider.dart';
import 'package:game_test/features/horror_survival/presentation/game/player/first_person_controller.dart';
import 'package:vibration/vibration.dart';
import 'package:vector_math/vector_math.dart';

/// Jump scare zone tied to a room.
class JumpScareZone {
  JumpScareZone({required this.roomId, required this.chancePerSecond});

  final RoomId roomId;
  final double chancePerSecond;
  double cooldown = 0;
}

/// Triggers randomized jump scares when player enters horror zones.
class JumpScareSystem {
  JumpScareSystem({
    required this.gameProvider,
    required this.audioManager,
    required this.playerController,
  });

  final GameProvider gameProvider;
  final AudioManager audioManager;
  final FirstPersonController playerController;
  final List<JumpScareZone> _zones = [];
  final math.Random _random = math.Random();
  double _scareDisplayTimer = 0;

  /// Registers jump scare zones from Mansfield floor plan spaces.
  void registerFromRooms() {
    for (final space in BuildingLayout.spaces) {
      if (space.horror.jumpScareChance <= 0) continue;
      _zones.add(JumpScareZone(
        roomId: space.id,
        chancePerSecond: space.horror.jumpScareChance,
      ));
    }
  }

  /// Evaluates jump scare probability each frame.
  void tick(double dt, Vector3 playerPos) {
    if (_scareDisplayTimer > 0) {
      _scareDisplayTimer -= dt;
      if (_scareDisplayTimer <= 0) {
        gameProvider.clearJumpScare();
      }
      return;
    }

    if (gameProvider.phase != GamePhase.playing) return;

    final room = BuildingLayout.roomAt(playerPos);
    if (room == null) return;

    for (final zone in _zones) {
      if (zone.roomId != room) continue;
      if (zone.cooldown > 0) {
        zone.cooldown -= dt;
        continue;
      }
      if (_random.nextDouble() < zone.chancePerSecond * dt) {
        _triggerScare();
        zone.cooldown = 8.0 + _random.nextDouble() * 12;
        break;
      }
    }
  }

  Future<void> _triggerScare() async {
    gameProvider.showJumpScare(JumpScareType.ghost);
    gameProvider.takeDamage(5);
    playerController.applyCameraShake(0.3);
    _scareDisplayTimer = 0.8;
    await audioManager.playOneShot(AudioPaths.scareScream, volume: 0.8);
    if (await Vibration.hasVibrator() == true) {
      await Vibration.vibrate(duration: 200);
    }
  }
}
