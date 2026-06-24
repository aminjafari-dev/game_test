import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';

/// Repository contract for horror survival game state.
abstract class GameRepository {
  GameState get state;

  /// Applies damage to the player. Returns updated state.
  GameState takeDamage(int amount);

  /// Collects a key if not already held.
  GameState collectKey(KeyType key);

  /// Attempts to unlock a door. Returns true if successful.
  bool canUnlockDoor(DoorId doorId);

  /// Marks a door as unlocked in persistent state.
  GameState unlockDoor(DoorId doorId);

  /// Triggers escape win condition.
  GameState escape();

  /// Shows a jump scare overlay.
  GameState showJumpScare(JumpScareType type);

  /// Clears active jump scare.
  GameState clearJumpScare();

  /// Updates current room for HUD/audio.
  GameState setCurrentRoom(RoomId roomId);

  /// Resets game to initial state.
  GameState reset();
}
