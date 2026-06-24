import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/materials/horror_materials.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/door_system.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/lighting_system.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Horror atmosphere profile applied when building a room.
class HorrorProfile {
  const HorrorProfile({
    this.ambientSound,
    this.flickerCount = 1,
    this.jumpScareChance = 0.015,
    this.keyType,
    this.keyLocalPosition,
  });

  final String? ambientSound;
  final int flickerCount;
  final double jumpScareChance;
  final KeyType? keyType;
  final Vector3? keyLocalPosition;
}

/// Configuration for building a single room node.
class RoomConfig {
  const RoomConfig({
    required this.id,
    required this.center,
    required this.horror,
    required this.unitType,
    this.width = BuildingLayout.roomSize,
    this.depth = BuildingLayout.roomSize,
    this.doorDirections = const {},
    this.openSides = const {},
  });

  final RoomId id;
  final Vector3 center;
  final HorrorProfile horror;
  final UnitType unitType;
  final double width;
  final double depth;
  final Map<Vector3, DoorId?> doorDirections;
  final Set<Vector3> openSides;
}

/// Builds procedural room geometry with horror elements.
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

    final isOutdoor = config.unitType == UnitType.path ||
        config.unitType == UnitType.lawn ||
        config.unitType == UnitType.poolDeck ||
        config.unitType == UnitType.terrace;

    _addFloor(roomNode, config.width, config.depth, config.unitType, raised: isOutdoor);

    if (!isOutdoor) {
      _addCeiling(roomNode, config.width, config.depth);
      _addWalls(roomNode, config);
    }

    if (!isOutdoor) {
      for (var i = 0; i < config.horror.flickerCount; i++) {
        final offset = Vector3(
          (i - config.horror.flickerCount / 2) * 2.0,
          BuildingLayout.wallHeight - 0.1,
          0,
        );
        lightingSystem.addFlickerLight(roomNode, offset);
      }
    }

    if (config.horror.keyType != null && config.horror.keyLocalPosition != null) {
      _addKeyPickup(roomNode, config.horror.keyType!, config.horror.keyLocalPosition!);
    }

    return roomNode;
  }

  void _addFloor(
    Node parent,
    double width,
    double depth,
    UnitType unitType, {
    bool raised = false,
  }) {
    final floor = Node(
      name: 'floor',
      localTransform: raised ? Matrix4.translation(Vector3(0, 0.02, 0)) : null,
      mesh: Mesh(
        PlaneGeometry(width: width, depth: depth),
        HorrorMaterials.unitFloor(unitType),
      ),
    );
    parent.add(floor);
  }

  void _addCeiling(Node parent, double width, double depth) {
    final ceiling = Node(
      name: 'ceiling',
      localTransform: Matrix4.translation(Vector3(0, BuildingLayout.wallHeight, 0))
        ..rotateX(3.14159),
      mesh: Mesh(
        PlaneGeometry(width: width, depth: depth),
        HorrorMaterials.wall(),
      ),
    );
    parent.add(ceiling);
  }

  void _addWalls(Node parent, RoomConfig config) {
    final halfW = config.width / 2;
    final halfD = config.depth / 2;
    final h = BuildingLayout.wallHeight;
    final t = BuildingLayout.wallThickness;

    final walls = <_WallSpec>[
      _WallSpec(
        pos: Vector3(0, h / 2, -halfD),
        scale: Vector3(config.width, h, t),
        direction: Vector3(0, 0, -1),
      ),
      _WallSpec(
        pos: Vector3(0, h / 2, halfD),
        scale: Vector3(config.width, h, t),
        direction: Vector3(0, 0, 1),
      ),
      _WallSpec(
        pos: Vector3(-halfW, h / 2, 0),
        scale: Vector3(t, h, config.depth),
        direction: Vector3(-1, 0, 0),
      ),
      _WallSpec(
        pos: Vector3(halfW, h / 2, 0),
        scale: Vector3(t, h, config.depth),
        direction: Vector3(1, 0, 0),
      ),
    ];

    for (final wall in walls) {
      if (config.openSides.contains(wall.direction)) {
        continue;
      }
      final doorId = config.doorDirections[wall.direction];
      if (doorId != null) {
        _addWallWithDoor(parent, wall, doorId, config);
      } else {
        _addSolidWall(parent, wall);
      }
    }
  }

  void _addSolidWall(Node parent, _WallSpec wall) {
    final wallNode = Node(
      name: 'wall',
      localTransform: Matrix4.translation(wall.pos),
      mesh: Mesh(
        CuboidGeometry(wall.scale),
        HorrorMaterials.wall(),
      ),
    );
    parent.add(wallNode);
    doorSystem.addWallCollider(wallNode, wall.pos, wall.scale);
  }

  void _addWallWithDoor(Node parent, _WallSpec wall, DoorId doorId, RoomConfig config) {
    final doorHalf = BuildingLayout.doorWidth / 2;
    final isZWall = wall.direction.z.abs() > 0.5;
    final totalLen = isZWall ? wall.scale.x : wall.scale.z;
    final segLen = (totalLen - BuildingLayout.doorWidth) / 2;

    if (segLen > 0.5) {
      if (isZWall) {
        _addWallSegment(parent, Vector3(-(doorHalf + segLen / 2), wall.pos.y, wall.pos.z),
            Vector3(segLen, wall.scale.y, wall.scale.z));
        _addWallSegment(parent, Vector3((doorHalf + segLen / 2), wall.pos.y, wall.pos.z),
            Vector3(segLen, wall.scale.y, wall.scale.z));
      } else {
        _addWallSegment(parent, Vector3(wall.pos.x, wall.pos.y, -(doorHalf + segLen / 2)),
            Vector3(wall.scale.x, wall.scale.y, segLen));
        _addWallSegment(parent, Vector3(wall.pos.x, wall.pos.y, (doorHalf + segLen / 2)),
            Vector3(wall.scale.x, wall.scale.y, segLen));
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
      isZWall: isZWall,
      wallDirection: wall.direction,
      locked: doorId == DoorId.exitElevator,
    );
  }

  void _addWallSegment(Node parent, Vector3 pos, Vector3 scale) {
    final seg = Node(
      localTransform: Matrix4.translation(pos),
      mesh: Mesh(
        CuboidGeometry(scale),
        HorrorMaterials.wall(),
      ),
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
