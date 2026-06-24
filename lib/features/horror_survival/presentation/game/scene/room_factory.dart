import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/materials/horror_materials.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/door_system.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/lighting_system.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Horror atmosphere profile applied when building a room.
///
/// Configure per-room audio, flicker lights, jump scares, and key spawns.
/// Example: `HorrorProfile(ambientSound: AudioPaths.ambientDripping, flickerCount: 2)`
class HorrorProfile {
  const HorrorProfile({
    this.ambientSound,
    this.flickerCount = 1,
    this.jumpScareChance = 0.015,
    this.keyType,
    this.keyLocalPosition,
    this.wallBrightness = 0.95,
  });

  final String? ambientSound;
  final int flickerCount;
  final double jumpScareChance;
  final KeyType? keyType;
  final Vector3? keyLocalPosition;
  final double wallBrightness;
}

/// Configuration for building a single room node.
class RoomConfig {
  const RoomConfig({
    required this.id,
    required this.center,
    required this.horror,
    this.size = BuildingLayout.roomSize,
    this.doorDirections = const {},
  });

  final RoomId id;
  final Vector3 center;
  final HorrorProfile horror;
  final double size;
  /// Map of wall direction (+X, -X, +Z, -Z as unit vectors) to door presence.
  final Map<Vector3, DoorId?> doorDirections;
}

/// Builds procedural room geometry with horror elements.
///
/// ## How to extend rooms
/// 1. Add a [RoomConfig] in [BuildingLayout] or a dedicated room blueprint file.
/// 2. Set [HorrorProfile] fields: ambient sound, flicker count, jump scare rate, key spawn.
/// 3. Register the config in [WorldBuilder.buildAllRooms].
/// 4. Add localized room name to `app_en.arb` if shown in HUD.
/// 5. Optional: attach `.glb` props via `Node.fromGlbAsset` as child nodes.
class RoomFactory {
  RoomFactory({
    required this.lightingSystem,
    required this.doorSystem,
  });

  final LightingSystem lightingSystem;
  final DoorSystem doorSystem;

  /// Builds a complete room [Node] subtree at [config.center].
  Node buildRoom(RoomConfig config) {
    final roomNode = Node(name: 'room_${config.id.name}')
      ..localTransform = Matrix4.translation(config.center);

    _addFloor(roomNode, config.size);
    _addCeiling(roomNode, config.size);
    _addWalls(roomNode, config);

    for (var i = 0; i < config.horror.flickerCount; i++) {
      final offset = Vector3(
        (i - config.horror.flickerCount / 2) * 2.0,
        BuildingLayout.wallHeight - 0.1,
        0,
      );
      lightingSystem.addFlickerLight(roomNode, offset);
    }

    if (config.horror.keyType != null && config.horror.keyLocalPosition != null) {
      _addKeyPickup(roomNode, config.horror.keyType!, config.horror.keyLocalPosition!);
    }

    return roomNode;
  }

  void _addFloor(Node parent, double size) {
    final floor = Node(
      name: 'floor',
      mesh: Mesh(
        PlaneGeometry(width: size, depth: size),
        HorrorMaterials.floor(),
      ),
    );
    parent.add(floor);
  }

  void _addCeiling(Node parent, double size) {
    final ceiling = Node(
      name: 'ceiling',
      localTransform: Matrix4.translation(Vector3(0, BuildingLayout.wallHeight, 0))
        ..rotateX(3.14159),
      mesh: Mesh(
        PlaneGeometry(width: size, depth: size),
        HorrorMaterials.wall(brightness: 0.98),
      ),
    );
    parent.add(ceiling);
  }

  void _addWalls(Node parent, RoomConfig config) {
    final half = config.size / 2;
    final h = BuildingLayout.wallHeight;
    final t = BuildingLayout.wallThickness;

    final walls = <_WallSpec>[
      _WallSpec(
        pos: Vector3(0, h / 2, -half),
        scale: Vector3(config.size, h, t),
        direction: Vector3(0, 0, -1),
      ),
      _WallSpec(
        pos: Vector3(0, h / 2, half),
        scale: Vector3(config.size, h, t),
        direction: Vector3(0, 0, 1),
      ),
      _WallSpec(
        pos: Vector3(-half, h / 2, 0),
        scale: Vector3(t, h, config.size),
        direction: Vector3(-1, 0, 0),
      ),
      _WallSpec(
        pos: Vector3(half, h / 2, 0),
        scale: Vector3(t, h, config.size),
        direction: Vector3(1, 0, 0),
      ),
    ];

    for (final wall in walls) {
      final doorId = config.doorDirections[wall.direction];
      if (doorId != null) {
        _addWallWithDoor(parent, wall, doorId, config);
      } else {
        _addSolidWall(parent, wall, config.horror.wallBrightness);
      }
    }
  }

  void _addSolidWall(Node parent, _WallSpec wall, double brightness) {
    final wallNode = Node(
      name: 'wall',
      localTransform: Matrix4.compose(wall.pos, Quaternion.identity(), wall.scale),
      mesh: Mesh(CuboidGeometry(Vector3(1, 1, 1)), HorrorMaterials.wall(brightness: brightness)),
    );
    parent.add(wallNode);
    doorSystem.addWallCollider(wallNode, wall.pos + parent.localTransform.getTranslation(), wall.scale);
  }

  void _addWallWithDoor(Node parent, _WallSpec wall, DoorId doorId, RoomConfig config) {
    final doorHalf = BuildingLayout.doorWidth / 2;
    final isZWall = wall.direction.z.abs() > 0.5;
    final totalLen = isZWall ? wall.scale.x : wall.scale.z;
    final segLen = (totalLen - BuildingLayout.doorWidth) / 2;

    if (segLen > 0.5) {
      if (isZWall) {
        _addWallSegment(parent, Vector3(-(doorHalf + segLen / 2), wall.pos.y, wall.pos.z),
            Vector3(segLen, wall.scale.y, wall.scale.z), config.horror.wallBrightness);
        _addWallSegment(parent, Vector3((doorHalf + segLen / 2), wall.pos.y, wall.pos.z),
            Vector3(segLen, wall.scale.y, wall.scale.z), config.horror.wallBrightness);
      } else {
        _addWallSegment(parent, Vector3(wall.pos.x, wall.pos.y, -(doorHalf + segLen / 2)),
            Vector3(wall.scale.x, wall.scale.y, segLen), config.horror.wallBrightness);
        _addWallSegment(parent, Vector3(wall.pos.x, wall.pos.y, (doorHalf + segLen / 2)),
            Vector3(wall.scale.x, wall.scale.y, segLen), config.horror.wallBrightness);
      }
    }

    final worldDoorPos = config.center + Vector3(
      isZWall ? 0.0 : wall.pos.x,
      1.0,
      isZWall ? wall.pos.z : 0.0,
    );
    doorSystem.registerDoor(
      doorId: doorId,
      doorNode: parent,
      worldPosition: worldDoorPos,
      rotationAxis: isZWall ? Vector3(0, 1, 0) : Vector3(0, 1, 0),
    );
  }

  void _addWallSegment(Node parent, Vector3 pos, Vector3 scale, double brightness) {
    final seg = Node(
      localTransform: Matrix4.compose(pos, Quaternion.identity(), scale),
      mesh: Mesh(CuboidGeometry(Vector3(1, 1, 1)), HorrorMaterials.wall(brightness: brightness)),
    );
    parent.add(seg);
    doorSystem.addWallCollider(seg, pos, scale);
  }

  void _addKeyPickup(Node parent, KeyType keyType, Vector3 localPos) {
    final keyNode = Node(
      name: 'key_$keyType',
      localTransform: Matrix4.translation(Vector3(localPos.x, 0.5, localPos.z)),
      mesh: Mesh(
        CuboidGeometry(Vector3(0.15, 0.05, 0.3)),
        HorrorMaterials.key(),
      ),
    );
    parent.add(keyNode);
    doorSystem.registerKeyPickup(keyType, keyNode, parent.localTransform.getTranslation() + localPos);
  }
}

class _WallSpec {
  _WallSpec({
    required this.pos,
    required this.scale,
    required this.direction,
  });

  final Vector3 pos;
  final Vector3 scale;
  final Vector3 direction;
}
