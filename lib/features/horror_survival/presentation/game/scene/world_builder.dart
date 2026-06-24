import 'package:game_test/features/horror_survival/presentation/game/materials/horror_materials.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/modern_house_builder.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/room_factory.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/tree_forest_builder.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/door_system.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/lighting_system.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Assembles the Minecraft modern villa scene from [BuildingLayout.spaces].
class WorldBuilder {
  WorldBuilder({
    required this.roomFactory,
    required this.lightingSystem,
    required this.doorSystem,
  });

  final RoomFactory roomFactory;
  final LightingSystem lightingSystem;
  final DoorSystem doorSystem;

  /// Builds the world root node with grass ground, villa, GLB forest, and floors.
  Future<Node> build() async {
    final world = Node(name: 'world');

    world.add(
      Node(
        name: 'grass_ground',
        localTransform: Matrix4.translation(Vector3(0, -0.01, 0)),
        mesh: Mesh(
          PlaneGeometry(
            width: BuildingLayout.grassFieldSize,
            depth: BuildingLayout.grassFieldSize,
          ),
          HorrorMaterials.grass(),
        ),
      ),
    );

    final houseBuilder = ModernHouseBuilder(doorSystem: doorSystem);
    world.add(houseBuilder.build());

    final treeTemplate = await TreeForestBuilder.loadTreeTemplate();
    TreeForestBuilder.build(world, treeTemplate);

    for (final space in BuildingLayout.spaces) {
      world.add(roomFactory.buildRoom(BuildingLayout.toRoomConfig(space)));
    }

    return world;
  }
}
