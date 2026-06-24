import 'package:game_test/core/audio/audio_manager.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/room_factory.dart';
import 'package:vector_math/vector_math.dart';

/// World-space dimensions and positions for the Minecraft modern villa map.
///
/// Layout matches the reference screenshot: a two-story white villa with
/// dark flat roof, L-shaped pool on the right, garden on the left, exterior
/// wooden stairs, second-floor terrace, and a large front lawn.
class BuildingLayout {
  BuildingLayout._();

  static const double wallHeight = 3.0;
  static const double wallThickness = 0.2;
  static const double doorWidth = 1.5;
  static const double doorHeight = 2.4;
  static const double doorThickness = 0.08;
  static const double roomSize = 7.0;

  /// Full grass field size rendered under the villa.
  static const double grassFieldSize = 80.0;

  static final Vector3 _n = Vector3(0, 0, -1);
  static final Vector3 _s = Vector3(0, 0, 1);
  static final Vector3 _e = Vector3(1, 0, 0);
  static final Vector3 _w = Vector3(-1, 0, 0);

  static final Set<Vector3> _open = {_n, _s, _e, _w};

  /// Player spawn on the front lawn, low-angle view toward the villa.
  static final Vector3 playerSpawn = Vector3(-2, 0, 16);

  /// Every walkable segment around and inside the villa.
  static final List<FloorSpace> spaces = [
    // ── Front lawn (main outdoor area) ─────────────────────────────────
    _area(RoomId.lawnFront, 0, 14, 30, 12, UnitType.lawn),

    // ── Wood path to exterior stairs ───────────────────────────────────
    _area(RoomId.pathToStairs, -6.5, 11, 3, 8, UnitType.path),

    // ── Garden plot (left) ─────────────────────────────────────────────
    _area(RoomId.garden, -8, 6, 6, 6, UnitType.lawn, key: KeyType.keyAlpha),

    // ── Pool deck (right) ──────────────────────────────────────────────
    _area(RoomId.poolDeck, 9, 2, 7, 12, UnitType.poolDeck),

    // ── Ground floor interior ──────────────────────────────────────────
    FloorSpace(
      id: RoomId.groundFloor,
      center: Vector3(0, 0, 0),
      width: 12,
      depth: 8,
      unitType: UnitType.path,
      openSides: _open,
      horror: HorrorProfile(
        ambientSound: AudioPaths.ambientCorridor,
        flickerCount: 0,
        jumpScareChance: 0.01,
      ),
    ),

    // ── Exterior stairs (walkable ramp) ────────────────────────────────
    _area(RoomId.exteriorStairs, -6.5, 5, 3, 8, UnitType.path),

    // ── Second floor terrace ───────────────────────────────────────────
    _area(RoomId.secondFloorTerrace, 0, 6.5, 14, 3, UnitType.terrace),

    // ── Second floor interior ────────────────────────────────────────────
    FloorSpace(
      id: RoomId.secondFloor,
      center: Vector3(0, 3, 0),
      width: 14,
      depth: 8,
      unitType: UnitType.path,
      openSides: _open,
      horror: HorrorProfile(
        ambientSound: AudioPaths.ambientWhispers,
        flickerCount: 1,
        jumpScareChance: 0.015,
        keyType: KeyType.keyBeta,
        keyLocalPosition: Vector3(3, 0, -2),
      ),
    ),

    // ── Left pergola balcony ───────────────────────────────────────────
    _area(RoomId.pergolaBalcony, -7.5, -2.5, 4, 4, UnitType.terrace),

    // ── Exit gate at the front entrance ────────────────────────────────
    FloorSpace(
      id: RoomId.frontEntrance,
      center: Vector3(0, 0, 4),
      width: 4,
      depth: 2,
      unitType: UnitType.exitZone,
      doors: {_s: DoorId.exitElevator},
      horror: HorrorProfile(
        ambientSound: AudioPaths.ambientWhispers,
        flickerCount: 0,
        jumpScareChance: 0.012,
      ),
    ),
  ];

  static FloorSpace _area(
    RoomId id,
    double cx,
    double cz,
    double width,
    double depth,
    UnitType type, {
    KeyType? key,
  }) {
    return FloorSpace(
      id: id,
      center: Vector3(cx, 0, cz),
      width: width,
      depth: depth,
      unitType: type,
      openSides: type == UnitType.path ? _open : const {},
      horror: HorrorProfile(
        ambientSound: AudioPaths.ambientCorridor,
        flickerCount: 0,
        jumpScareChance: 0.008,
        keyType: key,
        keyLocalPosition: key != null ? Vector3(0, 0, 0) : null,
      ),
    );
  }

  /// Axis-aligned bounds for room detection (min/max XZ).
  static Map<RoomId, Aabb2> get roomBounds {
    final bounds = <RoomId, Aabb2>{};
    for (final space in spaces) {
      bounds[space.id] = space.bounds;
    }
    return bounds;
  }

  /// Detects which area the player is currently on.
  static RoomId? roomAt(Vector3 position) {
    final p = Vector2(position.x, position.z);
    RoomId? lawnMatch;
    for (final space in spaces) {
      if (!space.bounds.containsVector2(p)) continue;
      if (space.unitType == UnitType.lawn ||
          space.unitType == UnitType.path ||
          space.unitType == UnitType.poolDeck ||
          space.unitType == UnitType.terrace) {
        lawnMatch ??= space.id;
        continue;
      }
      return space.id;
    }
    return lawnMatch;
  }

  /// Converts a [FloorSpace] into a [RoomConfig] for the room factory.
  static RoomConfig toRoomConfig(FloorSpace space) {
    return RoomConfig(
      id: space.id,
      center: space.center,
      width: space.width,
      depth: space.depth,
      unitType: space.unitType,
      horror: space.horror,
      doorDirections: space.doors,
      openSides: space.openSides,
    );
  }
}

/// A single walkable segment on the villa map.
class FloorSpace {
  const FloorSpace({
    required this.id,
    required this.center,
    required this.width,
    required this.depth,
    required this.unitType,
    this.doors = const {},
    this.openSides = const {},
    this.horror = const HorrorProfile(),
  });

  final RoomId id;
  final Vector3 center;
  final double width;
  final double depth;
  final UnitType unitType;
  final Map<Vector3, DoorId> doors;
  final Set<Vector3> openSides;
  final HorrorProfile horror;

  Aabb2 get bounds => Aabb2.minMax(
        Vector2(center.x - width / 2, center.z - depth / 2),
        Vector2(center.x + width / 2, center.z + depth / 2),
      );
}
