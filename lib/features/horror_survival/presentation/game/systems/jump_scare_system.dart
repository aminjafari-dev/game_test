import 'dart:math' as math;

import 'package:game_test/core/audio/audio_manager.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/rooms/bathroom_room.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/rooms/exit_lobby_room.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/rooms/kitchen_room.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/rooms/library_room.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/rooms/nursery_room.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/rooms/storage_room.dart';
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
///
/// Example: zones registered automatically from room horror profiles.
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

  /// Registers jump scare zones from all room configs.
  void registerFromRooms() {
    final configs = [
      LibraryRoom.blueprint,
      KitchenRoom.blueprint,
      NurseryRoom.blueprint,
      BathroomRoom.blueprint,
      StorageRoom.blueprint,
      ExitLobbyRoom.blueprint,
    ];
    for (final config in configs) {
      _zones.add(JumpScareZone(
        roomId: config.id,
        chancePerSecond: config.horror.jumpScareChance,
      ));
    }
    _zones.add(JumpScareZone(
      roomId: RoomId.corridor,
      chancePerSecond: 0.008,
    ));
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
