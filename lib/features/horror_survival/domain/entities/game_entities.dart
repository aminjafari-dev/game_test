/// Surface type for map segments.
enum UnitType {
  /// Open outdoor dirt/wood path — no walls or ceiling.
  path,

  /// Walled exit zone at the front entrance.
  exitZone,

  /// Green grass lawn areas.
  lawn,

  /// White concrete pool deck.
  poolDeck,

  /// Second-floor wood terrace.
  terrace,
}

/// Identifies collectible keys hidden along the path loop.
enum KeyType {
  keyAlpha,
  keyBeta,
}

/// Identifies the exit gate at the bottom of the map.
enum DoorId {
  exitElevator,
}

/// Identifies every walkable segment on the modern villa map.
enum RoomId {
  lawnFront,
  pathToStairs,
  garden,
  poolDeck,
  groundFloor,
  exteriorStairs,
  secondFloorTerrace,
  secondFloor,
  pergolaBalcony,
  frontEntrance,
}

/// Current phase of the horror survival game.
enum GamePhase {
  playing,
  won,
  lost,
}

/// Types of jump scare events.
enum JumpScareType {
  ghost,
}

/// Player health and inventory state.
class PlayerStats {
  const PlayerStats({
    required this.health,
    required this.maxHealth,
    required this.collectedKeys,
  });

  final int health;
  final int maxHealth;
  final Set<KeyType> collectedKeys;

  PlayerStats copyWith({
    int? health,
    Set<KeyType>? collectedKeys,
  }) {
    return PlayerStats(
      health: health ?? this.health,
      maxHealth: maxHealth,
      collectedKeys: collectedKeys ?? this.collectedKeys,
    );
  }

  static const PlayerStats initial = PlayerStats(
    health: 100,
    maxHealth: 100,
    collectedKeys: {},
  );
}

/// Aggregate game state entity.
class GameState {
  const GameState({
    required this.playerStats,
    required this.phase,
    this.activeJumpScare,
    this.currentRoom,
  });

  final PlayerStats playerStats;
  final GamePhase phase;
  final JumpScareType? activeJumpScare;
  final RoomId? currentRoom;

  GameState copyWith({
    PlayerStats? playerStats,
    GamePhase? phase,
    JumpScareType? activeJumpScare,
    bool clearJumpScare = false,
    RoomId? currentRoom,
  }) {
    return GameState(
      playerStats: playerStats ?? this.playerStats,
      phase: phase ?? this.phase,
      activeJumpScare:
          clearJumpScare ? null : (activeJumpScare ?? this.activeJumpScare),
      currentRoom: currentRoom ?? this.currentRoom,
    );
  }

  static const GameState initial = GameState(
    playerStats: PlayerStats.initial,
    phase: GamePhase.playing,
  );

  int get keyCount => playerStats.collectedKeys.length;
  static const int totalKeys = 2;
}
