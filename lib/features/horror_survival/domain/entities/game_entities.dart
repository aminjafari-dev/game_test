/// Apartment size category matching The Mansfield Level 5 legend.
enum UnitType {
  studio,
  oneBedroom,
  twoBedroom,
  corridor,
  sunDeck,
  elevator,
  stairwell,
}

/// Identifies collectible keys hidden in apartment units.
enum KeyType {
  unit520,
  unit506,
}

/// Identifies doors connecting apartments to corridors and the exit elevator.
enum DoorId {
  doorUnit501,
  doorUnit502,
  doorUnit503,
  doorUnit504,
  doorUnit505,
  doorUnit506,
  doorUnit507,
  doorUnit508,
  doorUnit509,
  doorUnit510,
  doorUnit511,
  doorUnit512,
  doorUnit513,
  doorUnit514,
  doorUnit515,
  doorUnit516,
  doorUnit517,
  doorUnit518,
  doorUnit519,
  doorUnit520,
  doorUnit521,
  doorUnit522,
  doorUnit523,
  doorUnit524,
  doorUnit525,
  doorUnit526,
  doorUnit527,
  exitElevator,
}

/// Identifies every walkable space on The Mansfield 5th floor.
enum RoomId {
  unit501,
  unit502,
  unit503,
  unit504,
  unit505,
  unit506,
  unit507,
  unit508,
  unit509,
  unit510,
  unit511,
  unit512,
  unit513,
  unit514,
  unit515,
  unit516,
  unit517,
  unit518,
  unit519,
  unit520,
  unit521,
  unit522,
  unit523,
  unit524,
  unit525,
  unit526,
  unit527,
  corridorNorth,
  corridorDiagonal,
  corridorSouth,
  corridorWest,
  corridorJunction,
  sunDeck,
  elevatorTop,
  elevatorMid,
  elevatorBottom,
  stairTop,
  stairMid,
  stairBottom,
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
