import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:vector_math/vector_math.dart';

/// World-space dimensions and positions for the single-floor building.
///
/// All rooms share [roomSize] and connect through door openings of [doorWidth].
class BuildingLayout {
  BuildingLayout._();

  static const double roomSize = 8.0;
  static const double wallHeight = 3.0;
  static const double wallThickness = 0.2;
  static const double doorWidth = 1.5;
  static const double corridorSize = 10.0;

  /// Room center positions on the XZ plane (Y = 0).
  static final Map<RoomId, Vector3> roomCenters = {
    RoomId.library: Vector3(-24, 0, 0),
    RoomId.kitchen: Vector3(-12, 0, 0),
    RoomId.corridor: Vector3(0, 0, 0),
    RoomId.nursery: Vector3(12, 0, 0),
    RoomId.bathroom: Vector3(0, 0, -12),
    RoomId.storage: Vector3(0, 0, -24),
    RoomId.exitLobby: Vector3(12, 0, -24),
  };

  /// Player spawn position inside the corridor hub.
  static final Vector3 playerSpawn = Vector3(0, 0, 0);

  /// Axis-aligned bounds for room detection (min/max XZ).
  static Map<RoomId, Aabb2> get roomBounds {
    final bounds = <RoomId, Aabb2>{};
    for (final entry in roomCenters.entries) {
      final half = entry.key == RoomId.corridor
          ? corridorSize / 2
          : roomSize / 2;
      final c = entry.value;
      bounds[entry.key] = Aabb2.minMax(
        Vector2(c.x - half, c.z - half),
        Vector2(c.x + half, c.z + half),
      );
    }
    return bounds;
  }

  /// Detects which room the player is currently inside.
  static RoomId? roomAt(Vector3 position) {
    final p = Vector2(position.x, position.z);
    for (final entry in roomBounds.entries) {
      if (entry.value.containsVector2(p)) {
        return entry.key;
      }
    }
    return RoomId.corridor;
  }
}
