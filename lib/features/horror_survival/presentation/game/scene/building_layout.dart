import 'package:game_test/core/audio/audio_manager.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/room_factory.dart';
import 'package:vector_math/vector_math.dart';

/// World-space dimensions and positions for The Mansfield Level 5 floor plan.
///
/// Layout mirrors the official floor plan: northwest wing, diagonal east wing,
/// southwest cluster, and bottom row with sun deck. All units 501–527 are placed
/// with sizes matching studio / 1-bedroom / 2-bedroom legend colors.
class BuildingLayout {
  BuildingLayout._();

  static const double wallHeight = 3.0;
  static const double wallThickness = 0.2;
  static const double doorWidth = 1.5;
  static const double doorHeight = 2.4;
  static const double doorThickness = 0.08;
  static const double roomSize = 7.0;

  static const double _studio = 7.0;
  static const double _oneBrW = 9.0;
  static const double _oneBrD = 7.0;
  static const double _twoBrW = 11.0;
  static const double _twoBrD = 9.0;
  static const double _corridorW = 3.5;
  static const double _service = 3.0;

  static final Vector3 _n = Vector3(0, 0, -1);
  static final Vector3 _s = Vector3(0, 0, 1);
  static final Vector3 _e = Vector3(1, 0, 0);
  static final Vector3 _w = Vector3(-1, 0, 0);

  /// Player spawn in the north corridor near the top elevators.
  static final Vector3 playerSpawn = Vector3(-8, 0, -32);

  /// Every walkable space on the floor.
  static final List<FloorSpace> spaces = [
    // ── Northwest top row (units 520–517) ──────────────────────────────
    _unit(
      RoomId.unit520,
      UnitType.oneBedroom,
      Vector3(-45, 0, -38),
      _oneBrW,
      _oneBrD,
      {_s: DoorId.doorUnit520},
      key: KeyType.unit520,
    ),
    _unit(
      RoomId.unit519,
      UnitType.oneBedroom,
      Vector3(-33, 0, -38),
      _oneBrW,
      _oneBrD,
      {_s: DoorId.doorUnit519},
    ),
    _unit(
      RoomId.unit518,
      UnitType.studio,
      Vector3(-22, 0, -38),
      _studio,
      _studio,
      {_s: DoorId.doorUnit518},
    ),
    _unit(
      RoomId.unit517,
      UnitType.oneBedroom,
      Vector3(-10, 0, -38),
      _oneBrW,
      _oneBrD,
      {_s: DoorId.doorUnit517},
    ),

    // ── Northwest second row (521–524) ─────────────────────────────────
    _unit(
      RoomId.unit521,
      UnitType.twoBedroom,
      Vector3(-45, 0, -26),
      _twoBrW,
      _twoBrD,
      {_n: DoorId.doorUnit521},
    ),
    _unit(
      RoomId.unit522,
      UnitType.studio,
      Vector3(-28, 0, -26),
      _studio,
      _studio,
      {_n: DoorId.doorUnit522},
    ),
    _unit(
      RoomId.unit523,
      UnitType.studio,
      Vector3(-19, 0, -26),
      _studio,
      _studio,
      {_n: DoorId.doorUnit523},
    ),
    _unit(
      RoomId.unit524,
      UnitType.oneBedroom,
      Vector3(-8, 0, -26),
      _oneBrW,
      _oneBrD,
      {_n: DoorId.doorUnit524},
    ),

    // ── Inner west cluster (525–527) ─────────────────────────────────
    _unit(
      RoomId.unit525,
      UnitType.studio,
      Vector3(-18, 0, -6),
      _studio,
      _studio,
      {_e: DoorId.doorUnit525},
    ),
    _unit(
      RoomId.unit526,
      UnitType.studio,
      Vector3(-18, 0, 2),
      _studio,
      _studio,
      {_e: DoorId.doorUnit526},
    ),
    _unit(
      RoomId.unit527,
      UnitType.studio,
      Vector3(-18, 0, 10),
      _studio,
      _studio,
      {_e: DoorId.doorUnit527},
    ),

    // ── East diagonal wing (516, 515, 514, 501–505) ───────────────────
    _unit(
      RoomId.unit516,
      UnitType.twoBedroom,
      Vector3(30, 0, -38),
      _twoBrW,
      _twoBrD,
      {_w: DoorId.doorUnit516},
    ),
    _unit(
      RoomId.unit515,
      UnitType.twoBedroom,
      Vector3(30, 0, -26),
      _twoBrW,
      _twoBrD,
      {_w: DoorId.doorUnit515},
    ),
    _unit(
      RoomId.unit514,
      UnitType.oneBedroom,
      Vector3(30, 0, -14),
      _oneBrW,
      _oneBrD,
      {_w: DoorId.doorUnit514},
    ),
    _unit(
      RoomId.unit501,
      UnitType.oneBedroom,
      Vector3(30, 0, -2),
      _oneBrW,
      _oneBrD,
      {_w: DoorId.doorUnit501},
    ),
    _unit(
      RoomId.unit502,
      UnitType.studio,
      Vector3(30, 0, 10),
      _studio,
      _studio,
      {_w: DoorId.doorUnit502},
    ),
    _unit(
      RoomId.unit503,
      UnitType.studio,
      Vector3(30, 0, 18),
      _studio,
      _studio,
      {_w: DoorId.doorUnit503},
    ),
    _unit(
      RoomId.unit504,
      UnitType.studio,
      Vector3(30, 0, 26),
      _studio,
      _studio,
      {_w: DoorId.doorUnit504},
    ),
    _unit(
      RoomId.unit505,
      UnitType.twoBedroom,
      Vector3(30, 0, 36),
      _twoBrW,
      _twoBrD,
      {_w: DoorId.doorUnit505},
    ),

    // ── South row (509–513 above corridor, 508/507/506 below) ──────────
    _unit(
      RoomId.unit509,
      UnitType.studio,
      Vector3(-30, 0, 14),
      _studio,
      _studio,
      {_s: DoorId.doorUnit509},
    ),
    _unit(
      RoomId.unit510,
      UnitType.studio,
      Vector3(-20, 0, 14),
      _studio,
      _studio,
      {_s: DoorId.doorUnit510},
    ),
    _unit(
      RoomId.unit511,
      UnitType.studio,
      Vector3(-10, 0, 14),
      _studio,
      _studio,
      {_s: DoorId.doorUnit511},
    ),
    _unit(
      RoomId.unit512,
      UnitType.studio,
      Vector3(0, 0, 14),
      _studio,
      _studio,
      {_s: DoorId.doorUnit512},
    ),
    _unit(
      RoomId.unit513,
      UnitType.studio,
      Vector3(10, 0, 14),
      _studio,
      _studio,
      {_s: DoorId.doorUnit513},
    ),
    _unit(
      RoomId.unit508,
      UnitType.studio,
      Vector3(-32, 0, 24),
      _studio,
      _studio,
      {_n: DoorId.doorUnit508},
    ),
    _unit(
      RoomId.unit507,
      UnitType.studio,
      Vector3(-22, 0, 24),
      _studio,
      _studio,
      {_n: DoorId.doorUnit507},
    ),
    _unit(
      RoomId.unit506,
      UnitType.studio,
      Vector3(-12, 0, 30),
      _studio,
      _studio,
      {_n: DoorId.doorUnit506},
      key: KeyType.unit506,
    ),

    // ── Corridors (white paths on the plan) ──────────────────────────
    FloorSpace(
      id: RoomId.corridorNorth,
      center: Vector3(-8, 0, -32),
      width: 72,
      depth: _corridorW,
      unitType: UnitType.corridor,
      horror: const HorrorProfile(
        ambientSound: AudioPaths.ambientCorridor,
        flickerCount: 4,
        jumpScareChance: 0.006,
      ),
      openSides: {_n, _s, _e, _w},
    ),
    FloorSpace(
      id: RoomId.corridorDiagonal,
      center: Vector3(18, 0, 0),
      width: _corridorW,
      depth: 78,
      unitType: UnitType.corridor,
      horror: const HorrorProfile(
        ambientSound: AudioPaths.ambientCorridor,
        flickerCount: 3,
        jumpScareChance: 0.008,
      ),
      openSides: {_n, _s, _e, _w},
    ),
    FloorSpace(
      id: RoomId.corridorSouth,
      center: Vector3(-10, 0, 18),
      width: 58,
      depth: _corridorW,
      unitType: UnitType.corridor,
      horror: const HorrorProfile(
        ambientSound: AudioPaths.ambientCorridor,
        flickerCount: 3,
        jumpScareChance: 0.006,
      ),
      openSides: {_n, _s, _e, _w},
    ),
    FloorSpace(
      id: RoomId.corridorWest,
      center: Vector3(-12, 0, 2),
      width: _corridorW,
      depth: 24,
      unitType: UnitType.corridor,
      horror: const HorrorProfile(
        ambientSound: AudioPaths.ambientCorridor,
        flickerCount: 2,
        jumpScareChance: 0.005,
      ),
      openSides: {_n, _s, _e, _w},
    ),
    FloorSpace(
      id: RoomId.corridorJunction,
      center: Vector3(-2, 0, -10),
      width: 6,
      depth: 6,
      unitType: UnitType.corridor,
      horror: const HorrorProfile(
        ambientSound: AudioPaths.ambientCorridor,
        flickerCount: 2,
        jumpScareChance: 0.007,
      ),
      openSides: {_n, _s, _e, _w},
    ),

    // ── Sun deck (feature 2 on the plan) ───────────────────────────────
    FloorSpace(
      id: RoomId.sunDeck,
      center: Vector3(-42, 0, 32),
      width: 16,
      depth: 12,
      unitType: UnitType.sunDeck,
      horror: const HorrorProfile(
        flickerCount: 0,
        jumpScareChance: 0.003,
        wallBrightness: 0.75,
      ),
      openSides: {_n, _e},
    ),

    // ── Elevators (feature 1 on the plan) ──────────────────────────────
    FloorSpace(
      id: RoomId.elevatorTop,
      center: Vector3(2, 0, -38),
      width: _service,
      depth: _service,
      unitType: UnitType.elevator,
      horror: const HorrorProfile(flickerCount: 1, jumpScareChance: 0.01),
      openSides: {_s},
    ),
    FloorSpace(
      id: RoomId.elevatorMid,
      center: Vector3(22, 0, -8),
      width: _service,
      depth: _service,
      unitType: UnitType.elevator,
      horror: const HorrorProfile(flickerCount: 1, jumpScareChance: 0.01),
      openSides: {_w},
    ),
    FloorSpace(
      id: RoomId.elevatorBottom,
      center: Vector3(2, 0, 30),
      width: _service,
      depth: _service,
      unitType: UnitType.elevator,
      horror: const HorrorProfile(flickerCount: 1, jumpScareChance: 0.012),
      openSides: {_n},
      doors: {_s: DoorId.exitElevator},
    ),

    // ── Stairwells ─────────────────────────────────────────────────────
    FloorSpace(
      id: RoomId.stairTop,
      center: Vector3(6, 0, -38),
      width: _service,
      depth: _service,
      unitType: UnitType.stairwell,
      horror: const HorrorProfile(flickerCount: 0, jumpScareChance: 0.008),
      openSides: {_s},
    ),
    FloorSpace(
      id: RoomId.stairMid,
      center: Vector3(22, 0, -2),
      width: _service,
      depth: _service,
      unitType: UnitType.stairwell,
      horror: const HorrorProfile(flickerCount: 0, jumpScareChance: 0.008),
      openSides: {_w},
    ),
    FloorSpace(
      id: RoomId.stairBottom,
      center: Vector3(-32, 0, 30),
      width: _service,
      depth: _service,
      unitType: UnitType.stairwell,
      horror: const HorrorProfile(flickerCount: 0, jumpScareChance: 0.008),
      openSides: {_n},
    ),
  ];

  static FloorSpace _unit(
    RoomId id,
    UnitType type,
    Vector3 center,
    double width,
    double depth,
    Map<Vector3, DoorId> doors, {
    KeyType? key,
  }) {
    return FloorSpace(
      id: id,
      center: center,
      width: width,
      depth: depth,
      unitType: type,
      doors: doors,
      horror: HorrorProfile(
        ambientSound: type == UnitType.twoBedroom
            ? AudioPaths.ambientWhispers
            : AudioPaths.ambientCreaking,
        flickerCount: type == UnitType.studio ? 1 : 2,
        jumpScareChance: type == UnitType.twoBedroom ? 0.018 : 0.012,
        keyType: key,
        keyLocalPosition: key != null ? Vector3(1.5, 0, -1.5) : null,
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

  /// Detects which space the player is currently inside.
  static RoomId? roomAt(Vector3 position) {
    final p = Vector2(position.x, position.z);
    RoomId? corridorMatch;
    for (final space in spaces) {
      if (!space.bounds.containsVector2(p)) continue;
      if (space.unitType == UnitType.corridor) {
        corridorMatch ??= space.id;
        continue;
      }
      return space.id;
    }
    return corridorMatch;
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

/// A single space on The Mansfield floor plan.
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
