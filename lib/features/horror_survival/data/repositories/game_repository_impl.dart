import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/domain/repositories/game_repository.dart';

/// In-memory implementation of [GameRepository].
class GameRepositoryImpl implements GameRepository {
  GameState _state = GameState.initial;
  final Set<DoorId> _unlockedDoors = {};

  @override
  GameState get state => _state;

  @override
  GameState takeDamage(int amount) {
    if (_state.phase != GamePhase.playing) return _state;
    final newHealth = (_state.playerStats.health - amount).clamp(0, 100);
    final newStats = _state.playerStats.copyWith(health: newHealth);
    final phase = newHealth <= 0 ? GamePhase.lost : GamePhase.playing;
    _state = _state.copyWith(playerStats: newStats, phase: phase);
    return _state;
  }

  @override
  GameState collectKey(KeyType key) {
    if (_state.phase != GamePhase.playing) return _state;
    final keys = Set<KeyType>.from(_state.playerStats.collectedKeys)..add(key);
    _state = _state.copyWith(
      playerStats: _state.playerStats.copyWith(collectedKeys: keys),
    );
    return _state;
  }

  @override
  bool canUnlockDoor(DoorId doorId) {
    if (doorId == DoorId.exitDoor) {
      return _state.playerStats.collectedKeys.length >= GameState.totalKeys;
    }
    return true;
  }

  @override
  GameState unlockDoor(DoorId doorId) {
    _unlockedDoors.add(doorId);
    return _state;
  }

  @override
  GameState escape() {
    if (_state.phase != GamePhase.playing) return _state;
    _state = _state.copyWith(phase: GamePhase.won);
    return _state;
  }

  @override
  GameState showJumpScare(JumpScareType type) {
    _state = _state.copyWith(activeJumpScare: type);
    return _state;
  }

  @override
  GameState clearJumpScare() {
    _state = _state.copyWith(clearJumpScare: true);
    return _state;
  }

  @override
  GameState setCurrentRoom(RoomId roomId) {
    _state = _state.copyWith(currentRoom: roomId);
    return _state;
  }

  @override
  GameState reset() {
    _unlockedDoors.clear();
    _state = GameState.initial;
    return _state;
  }

  bool isDoorUnlocked(DoorId doorId) => _unlockedDoors.contains(doorId);
}
