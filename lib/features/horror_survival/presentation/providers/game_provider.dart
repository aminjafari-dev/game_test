import 'package:flutter/foundation.dart';
import 'package:game_test/features/horror_survival/data/repositories/game_repository_impl.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/domain/repositories/game_repository.dart';
import 'package:game_test/features/horror_survival/domain/usecases/game_usecases.dart';

/// Provider for horror survival game state and actions.
///
/// Inject into widget tree via [ChangeNotifierProvider].
/// Example: `context.read<GameProvider>().takeDamage(10)`
class GameProvider extends ChangeNotifier {
  GameProvider({GameRepository? repository})
    : _repository = repository ?? GameRepositoryImpl() {
    _takeDamage = TakeDamageUseCase(_repository);
    _collectKey = CollectKeyUseCase(_repository);
    _canUnlockDoor = CanUnlockDoorUseCase(_repository);
    _unlockDoor = UnlockDoorUseCase(_repository);
    _escape = EscapeBuildingUseCase(_repository);
  }

  final GameRepository _repository;
  late final TakeDamageUseCase _takeDamage;
  late final CollectKeyUseCase _collectKey;
  late final CanUnlockDoorUseCase _canUnlockDoor;
  late final UnlockDoorUseCase _unlockDoor;
  late final EscapeBuildingUseCase _escape;

  GameState get state => _repository.state;
  int get health => state.playerStats.health;
  Set<KeyType> get keys => state.playerStats.collectedKeys;
  GamePhase get phase => state.phase;
  JumpScareType? get activeJumpScare => state.activeJumpScare;
  RoomId? get currentRoom => state.currentRoom;

  void takeDamage(int amount) {
    _takeDamage(amount);
    notifyListeners();
  }

  void collectKey(KeyType key) {
    _collectKey(key);
    notifyListeners();
  }

  bool canUnlockDoor(DoorId doorId) => _canUnlockDoor(doorId);

  bool tryUnlockDoor(DoorId doorId) {
    final result = _unlockDoor(doorId);
    if (result != null) {
      notifyListeners();
      return true;
    }
    return false;
  }

  void escape() {
    _escape();
    notifyListeners();
  }

  void showJumpScare(JumpScareType type) {
    _repository.showJumpScare(type);
    notifyListeners();
  }

  void clearJumpScare() {
    _repository.clearJumpScare();
    notifyListeners();
  }

  void setCurrentRoom(RoomId roomId) {
    if (state.currentRoom == roomId) return;
    _repository.setCurrentRoom(roomId);
    notifyListeners();
  }

  void reset() {
    _repository.reset();
    notifyListeners();
  }
}
