import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/room_factory.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/lighting_system.dart';
import 'package:flutter_scene/scene.dart';

/// Assembles The Mansfield Level 5 scene from [BuildingLayout.spaces].
class WorldBuilder {
  WorldBuilder({
    required this.roomFactory,
    required this.lightingSystem,
  });

  final RoomFactory roomFactory;
  final LightingSystem lightingSystem;

  /// Builds the world root node containing all apartments, corridors, and features.
  Node build() {
    final world = Node(name: 'world');

    for (final space in BuildingLayout.spaces) {
      world.add(roomFactory.buildRoom(BuildingLayout.toRoomConfig(space)));
    }

    return world;
  }
}
