import 'dart:math' as math;

import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/materials/horror_materials.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/providers/game_provider.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Swinging wooden door panel attached to a hinge node.
class DoorLeaf {
  DoorLeaf({
    required this.hingeNode,
    required this.hingePosition,
    required this.openAngleY,
  });

  final Node hingeNode;
  final Vector3 hingePosition;
  final double openAngleY;
}

/// Door and interactable state in the 3D world.
///
/// A single logical door can span two room walls, so it may have multiple
/// interaction points, physics blockers, and visible panels that open together.
class DoorState {
  DoorState({
    required this.id,
    required this.worldPositions,
    required this.blockers,
    required this.leaves,
    this.isOpen = false,
    this.isLocked = false,
    this.requiredKeys = 0,
  });

  final DoorId id;
  final List<Vector3> worldPositions;
  final List<Node> blockers;
  final List<DoorLeaf> leaves;
  bool isOpen;
  bool isLocked;
  final int requiredKeys;
}

/// Key pickup interactable in the world.
class KeyPickup {
  KeyPickup({
    required this.keyType,
    required this.worldPosition,
    required this.node,
  });

  final KeyType keyType;
  final Vector3 worldPosition;
  final Node node;
  bool collected = false;
}

/// What the player can interact with when nearby.
enum NearbyInteractable {
  none,
  key,
  openDoor,
  unlockDoor,
  lockedDoor,
  escape,
}

/// Manages doors, wall colliders, and key pickups.
///
/// Example: `doorSystem.tryInteract(playerPosition, gameProvider)`
class DoorSystem {
  static const double _interactRadius = 2.5;

  final Map<DoorId, DoorState> _doors = {};
  final List<KeyPickup> _keys = [];

  void registerDoor({
    required DoorId doorId,
    required Node doorNode,
    required Vector3 worldPosition,
    required bool isZWall,
    required Vector3 wallDirection,
    bool locked = false,
  }) {
    final roomOrigin = doorNode.localTransform.getTranslation();
    final localPos = worldPosition - roomOrigin;

    final doorHalf = BuildingLayout.doorWidth / 2;
    const wallHalf = 0.1;
    final halfExtents = isZWall
        ? Vector3(doorHalf, 1.2, wallHalf)
        : Vector3(wallHalf, 1.2, doorHalf);

    final blocker = BasicCollider(
      shape: BoxShape(halfExtents: halfExtents),
      isTrigger: false,
    );
    final blockerNode = Node(
      name: 'door_blocker_$doorId',
      localTransform: Matrix4.translation(localPos),
    )..addComponent(blocker);
    doorNode.add(blockerNode);

    final leaf = _createDoorLeaf(
      doorId: doorId,
      localCenter: localPos,
      isZWall: isZWall,
      wallDirection: wallDirection,
      locked: locked,
    );
    doorNode.add(leaf.hingeNode);

    final existing = _doors[doorId];
    if (existing != null) {
      existing.worldPositions.add(worldPosition);
      existing.blockers.add(blockerNode);
      existing.leaves.add(leaf);
      return;
    }

    final isExit = doorId == DoorId.exitElevator;
    _doors[doorId] = DoorState(
      id: doorId,
      worldPositions: [worldPosition],
      blockers: [blockerNode],
      leaves: [leaf],
      isLocked: isExit,
      requiredKeys: isExit ? GameState.totalKeys : 0,
    );
  }

  DoorLeaf _createDoorLeaf({
    required DoorId doorId,
    required Vector3 localCenter,
    required bool isZWall,
    required Vector3 wallDirection,
    required bool locked,
  }) {
    final doorHalf = BuildingLayout.doorWidth / 2;
    final doorHeight = BuildingLayout.doorHeight;
    final doorThickness = BuildingLayout.doorThickness;

    final panelSize = isZWall
        ? Vector3(doorHalf * 2, doorHeight, doorThickness)
        : Vector3(doorThickness, doorHeight, doorHalf * 2);

    final visualCenter = Vector3(
      localCenter.x,
      doorHeight / 2,
      localCenter.z,
    );

    final hingePosition = _hingePosition(
      visualCenter,
      doorHalf,
      isZWall,
      wallDirection,
    );
    final panelOffset = _panelOffset(doorHalf, isZWall, wallDirection);
    final openAngleY = _openAngleY(wallDirection);

    final hingeNode = Node(name: 'door_hinge_${doorId.name}');
    hingeNode.localTransform = Matrix4.translation(hingePosition);

    final panelNode = Node(
      name: 'door_panel',
      localTransform: Matrix4.translation(panelOffset),
      mesh: Mesh(
        CuboidGeometry(panelSize),
        HorrorMaterials.doorWood(locked: locked),
      ),
    );
    hingeNode.add(panelNode);

    return DoorLeaf(
      hingeNode: hingeNode,
      hingePosition: hingePosition,
      openAngleY: openAngleY,
    );
  }

  Vector3 _hingePosition(
    Vector3 center,
    double doorHalf,
    bool isZWall,
    Vector3 wallDirection,
  ) {
    if (isZWall) {
      final hingeOnPositiveX = wallDirection.z > 0;
      return Vector3(
        center.x + (hingeOnPositiveX ? doorHalf : -doorHalf),
        center.y,
        center.z,
      );
    }
    final hingeOnPositiveZ = wallDirection.x > 0;
    return Vector3(
      center.x,
      center.y,
      center.z + (hingeOnPositiveZ ? doorHalf : -doorHalf),
    );
  }

  Vector3 _panelOffset(double doorHalf, bool isZWall, Vector3 wallDirection) {
    if (isZWall) {
      final offsetX = wallDirection.z > 0 ? -doorHalf : doorHalf;
      return Vector3(offsetX, 0, 0);
    }
    final offsetZ = wallDirection.x > 0 ? -doorHalf : doorHalf;
    return Vector3(0, 0, offsetZ);
  }

  double _openAngleY(Vector3 wallDirection) {
    if (wallDirection.x > 0.5) return -math.pi / 2;
    if (wallDirection.x < -0.5) return math.pi / 2;
    if (wallDirection.z > 0.5) return math.pi / 2;
    return -math.pi / 2;
  }

  void addWallCollider(Node wallNode, Vector3 localPos, Vector3 scale) {
    final half = scale * 0.5;
    final collider = BasicCollider(
      shape: BoxShape(halfExtents: Vector3(half.x, half.y, half.z)),
    );
    wallNode.addComponent(collider);
  }

  void registerKeyPickup(KeyType keyType, Node keyNode, Vector3 worldPosition) {
    final trigger = BasicCollider(
      shape: SphereShape(radius: 0.5),
      isTrigger: true,
    );
    keyNode.addComponent(trigger);
    _keys.add(KeyPickup(
      keyType: keyType,
      worldPosition: worldPosition,
      node: keyNode,
    ));
  }

  bool _isNearDoor(Vector3 playerPos, DoorState door) {
    final radiusSq = _interactRadius * _interactRadius;
    for (final doorPos in door.worldPositions) {
      final dx = playerPos.x - doorPos.x;
      final dz = playerPos.z - doorPos.z;
      if (dx * dx + dz * dz <= radiusSq) {
        return true;
      }
    }
    return false;
  }

  NearbyInteractable peekInteract(Vector3 playerPos, GameProvider game) {
    for (final key in _keys) {
      if (key.collected) continue;
      if (key.worldPosition.distanceTo(playerPos) < 1.5) {
        return NearbyInteractable.key;
      }
    }

    for (final door in _doors.values) {
      if (!_isNearDoor(playerPos, door)) continue;
      if (door.isOpen) {
        if (door.id == DoorId.exitElevator) {
          return NearbyInteractable.escape;
        }
        continue;
      }
      if (door.isLocked) {
        return game.canUnlockDoor(door.id)
            ? NearbyInteractable.unlockDoor
            : NearbyInteractable.lockedDoor;
      }
      return NearbyInteractable.openDoor;
    }
    return NearbyInteractable.none;
  }

  String? tryInteract(Vector3 playerPos, GameProvider game) {
    for (final key in _keys) {
      if (key.collected) continue;
      if (key.worldPosition.distanceTo(playerPos) < 1.5) {
        key.collected = true;
        key.node.visible = false;
        game.collectKey(key.keyType);
        return 'key';
      }
    }

    for (final door in _doors.values) {
      if (!_isNearDoor(playerPos, door)) continue;
      if (door.isOpen) {
        if (door.id == DoorId.exitElevator) {
          game.escape();
          return 'escape';
        }
        continue;
      }

      if (door.isLocked) {
        if (game.canUnlockDoor(door.id)) {
          game.tryUnlockDoor(door.id);
          door.isLocked = false;
          _openDoor(door);
          return 'unlock';
        }
        return 'locked';
      }

      _openDoor(door);
      return 'open';
    }
    return null;
  }

  void _openDoor(DoorState door) {
    door.isOpen = true;
    for (final leaf in door.leaves) {
      leaf.hingeNode.localTransform = Matrix4.translation(leaf.hingePosition)
        ..rotateY(leaf.openAngleY);
    }
    for (final blocker in door.blockers) {
      blocker.parent?.remove(blocker);
    }
    door.blockers.clear();
  }

  List<DoorState> get doors => List.unmodifiable(_doors.values);
  List<KeyPickup> get keys => List.unmodifiable(_keys);
}
