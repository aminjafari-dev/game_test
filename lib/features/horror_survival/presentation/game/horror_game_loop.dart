import 'package:game_test/core/audio/audio_manager.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/monsters/chase_ai.dart';
import 'package:game_test/features/horror_survival/presentation/game/monsters/monster_entity.dart';
import 'package:game_test/features/horror_survival/presentation/game/player/first_person_controller.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/door_system.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/jump_scare_system.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/lighting_system.dart';
import 'package:game_test/features/horror_survival/presentation/providers/game_provider.dart';
import 'package:flutter_scene/scene.dart';

/// Orchestrates all per-frame game systems.
///
/// Wired to [SceneView.onTick]. Example: `gameLoop.tick(dt, totalTime)`
class HorrorGameLoop {
  HorrorGameLoop({
    required this.scene,
    required this.physicsWorld,
    required this.playerController,
    required this.doorSystem,
    required this.lightingSystem,
    required this.jumpScareSystem,
    required this.chaseAi,
    required this.gameProvider,
    required this.audioManager,
    required this.monsters,
  });

  final Scene scene;
  final BasicPhysicsWorld physicsWorld;
  final FirstPersonController playerController;
  final DoorSystem doorSystem;
  final LightingSystem lightingSystem;
  final JumpScareSystem jumpScareSystem;
  final ChaseAI chaseAi;
  final GameProvider gameProvider;
  final AudioManager audioManager;
  final List<MonsterEntity> monsters;

  RoomId? _lastRoom;
  String? _lastInteractResult;
  NearbyInteractable _nearbyInteract = NearbyInteractable.none;

  NearbyInteractable get nearbyInteract => _nearbyInteract;

  static final Map<RoomId, String> _roomAmbient = {
    RoomId.library: AudioPaths.ambientDripping,
    RoomId.kitchen: AudioPaths.ambientCreaking,
    RoomId.corridor: AudioPaths.ambientCorridor,
    RoomId.nursery: AudioPaths.ambientWhispers,
    RoomId.bathroom: AudioPaths.ambientDripping,
    RoomId.storage: AudioPaths.ambientCreaking,
    RoomId.exitLobby: AudioPaths.ambientCorridor,
  };

  /// Runs one frame of gameplay logic.
  void tick(double dt, double totalTime) {
    if (gameProvider.phase != GamePhase.playing) return;

    playerController.tick(dt);

    final playerPos = playerController.position;
    _nearbyInteract = doorSystem.peekInteract(playerPos, gameProvider);
    chaseAi.tick(dt, playerPos, gameProvider);
    lightingSystem.tick(dt, totalTime);
    jumpScareSystem.tick(dt, playerPos);

    final room = BuildingLayout.roomAt(playerPos);
    if (room != null && room != _lastRoom) {
      _lastRoom = room;
      gameProvider.setCurrentRoom(room);
      final ambient = _roomAmbient[room];
      if (ambient != null) {
        audioManager.playAmbientLoop(ambient, volume: 0.4);
      }
    }

    physicsWorld.step(dt);
  }

  /// Handles interact input from UI or keyboard.
  void handleInteract() {
    if (gameProvider.phase != GamePhase.playing) return;
    final result = doorSystem.tryInteract(playerController.position, gameProvider);
    if (result == 'key') {
      audioManager.playOneShot(AudioPaths.sfxKeyPickup);
    } else if (result == 'open' || result == 'unlock') {
      audioManager.playOneShot(AudioPaths.sfxDoorCreak);
    }
    _lastInteractResult = result;
  }

  String? get lastInteractResult => _lastInteractResult;
}
