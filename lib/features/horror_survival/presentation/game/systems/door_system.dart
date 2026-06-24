import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/providers/game_provider.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Door and interactable state in the 3D world.
class DoorState {
  DoorState({
    required this.id,
    required this.worldPosition,
    required this.doorNode,
    this.isOpen = false,
    this.isLocked = false,
    this.requiredKeys = 0,
  });

  final DoorId id;
  final Vector3 worldPosition;
  final Node doorNode;
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
  final List<DoorState> _doors = [];
  final List<KeyPickup> _keys = [];
  final Map<DoorId, Node> _blockingNodes = {};

  void registerDoor({
    required DoorId doorId,
    required Node doorNode,
    required Vector3 worldPosition,
    required Vector3 rotationAxis,
    bool locked = false,
  }) {
    final isExit = doorId == DoorId.exitDoor;
    _doors.add(DoorState(
      id: doorId,
      worldPosition: worldPosition,
      doorNode: doorNode,
      isLocked: isExit,
      requiredKeys: isExit ? GameState.totalKeys : 0,
    ));

    final blocker = BasicCollider(
      shape: BoxShape(halfExtents: Vector3(0.75, 1.2, 0.1)),
      isTrigger: false,
    );
    final blockerNode = Node(
      name: 'door_blocker_$doorId',
      localTransform: Matrix4.translation(worldPosition),
    )..addComponent(blocker);
    doorNode.add(blockerNode);
    _blockingNodes[doorId] = blockerNode;
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

  /// Returns what the player can interact with at [playerPos], without acting.
  NearbyInteractable peekInteract(Vector3 playerPos, GameProvider game) {
    for (final key in _keys) {
      if (key.collected) continue;
      if (key.worldPosition.distanceTo(playerPos) < 1.5) {
        return NearbyInteractable.key;
      }
    }

    for (final door in _doors) {
      if (door.worldPosition.distanceTo(playerPos) > 2.0) continue;
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

  /// Attempts interaction near player position within [interactRadius].
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

    for (final door in _doors) {
      if (door.worldPosition.distanceTo(playerPos) > 2.0) continue;
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
    final blocker = _blockingNodes[door.id];
    if (blocker != null) {
      blocker.parent?.remove(blocker);
      _blockingNodes.remove(door.id);
    }
  }

  List<DoorState> get doors => List.unmodifiable(_doors);
  List<KeyPickup> get keys => List.unmodifiable(_keys);
}
