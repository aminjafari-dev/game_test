import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/providers/game_provider.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Door and interactable state in the 3D world.
///
/// A single logical door can span two room walls, so it may have multiple
/// interaction points and physics blockers that all open together.
class DoorState {
  DoorState({
    required this.id,
    required this.worldPositions,
    required this.blockers,
    this.isOpen = false,
    this.isLocked = false,
    this.requiredKeys = 0,
  });

  final DoorId id;
  final List<Vector3> worldPositions;
  final List<Node> blockers;
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
    bool locked = false,
  }) {
    final roomOrigin = doorNode.localTransform.getTranslation();
    final localPos = worldPosition - roomOrigin;

    final doorHalf = BuildingLayout.doorWidth / 2;
    const wallHalf = 0.1;
    // Align the thin axis with the wall normal so the blocker sits in the doorway.
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

    final existing = _doors[doorId];
    if (existing != null) {
      existing.worldPositions.add(worldPosition);
      existing.blockers.add(blockerNode);
      return;
    }

    final isExit = doorId == DoorId.exitDoor;
    _doors[doorId] = DoorState(
      id: doorId,
      worldPositions: [worldPosition],
      blockers: [blockerNode],
      isLocked: isExit,
      requiredKeys: isExit ? GameState.totalKeys : 0,
    );
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

  /// Horizontal distance from player feet to a door interaction point.
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

  /// Returns what the player can interact with at [playerPos], without acting.
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
        if (door.id == DoorId.exitDoor) {
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

  /// Attempts interaction near player position within [_interactRadius].
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
        if (door.id == DoorId.exitDoor) {
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
    for (final blocker in door.blockers) {
      blocker.parent?.remove(blocker);
    }
    door.blockers.clear();
  }

  List<DoorState> get doors => List.unmodifiable(_doors.values);
  List<KeyPickup> get keys => List.unmodifiable(_keys);
}
