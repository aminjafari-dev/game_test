import 'package:game_test/core/audio/audio_manager.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/room_factory.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/rooms/bathroom_room.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/rooms/exit_lobby_room.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/rooms/kitchen_room.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/rooms/library_room.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/rooms/nursery_room.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/rooms/storage_room.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/lighting_system.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Assembles the full building scene graph from room blueprints.
class WorldBuilder {
  WorldBuilder({
    required this.roomFactory,
    required this.lightingSystem,
  });

  final RoomFactory roomFactory;
  final LightingSystem lightingSystem;

  /// Builds the world root node containing all rooms and atmosphere.
  Node build() {
    final world = Node(name: 'world');

    final configs = _allRoomConfigs();
    for (final config in configs) {
      world.add(roomFactory.buildRoom(config));
    }

    return world;
  }

  List<RoomConfig> _allRoomConfigs() {
    return [
      LibraryRoom.blueprint,
      KitchenRoom.blueprint,
      _corridorConfig(),
      NurseryRoom.blueprint,
      BathroomRoom.blueprint,
      StorageRoom.blueprint,
      ExitLobbyRoom.blueprint,
    ];
  }

  RoomConfig _corridorConfig() {
    return RoomConfig(
      id: RoomId.corridor,
      center: BuildingLayout.roomCenters[RoomId.corridor]!,
      size: BuildingLayout.corridorSize,
      horror: const HorrorProfile(
        ambientSound: AudioPaths.ambientCorridor,
        flickerCount: 3,
        jumpScareChance: 0.008,
      ),
      doorDirections: {
        Vector3(-1, 0, 0): DoorId.kitchenToCorridor,
        Vector3(1, 0, 0): DoorId.corridorToNursery,
        Vector3(0, 0, -1): DoorId.corridorToBathroom,
      },
    );
  }
}
