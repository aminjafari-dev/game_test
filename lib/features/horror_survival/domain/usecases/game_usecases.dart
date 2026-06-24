import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/domain/repositories/game_repository.dart';

/// Use case: apply damage to the player.
class TakeDamageUseCase {
  TakeDamageUseCase(this._repository);

  final GameRepository _repository;

  GameState call(int amount) => _repository.takeDamage(amount);
}

/// Use case: collect a key item.
class CollectKeyUseCase {
  CollectKeyUseCase(this._repository);

  final GameRepository _repository;

  GameState call(KeyType key) => _repository.collectKey(key);
}

/// Use case: check if a door can be unlocked.
class CanUnlockDoorUseCase {
  CanUnlockDoorUseCase(this._repository);

  final GameRepository _repository;

  bool call(DoorId doorId) => _repository.canUnlockDoor(doorId);
}

/// Use case: unlock a door after validation.
class UnlockDoorUseCase {
  UnlockDoorUseCase(this._repository);

  final GameRepository _repository;

  GameState? call(DoorId doorId) {
    if (!_repository.canUnlockDoor(doorId)) return null;
    return _repository.unlockDoor(doorId);
  }
}

/// Use case: player escapes the building.
class EscapeBuildingUseCase {
  EscapeBuildingUseCase(this._repository);

  final GameRepository _repository;

  GameState call() => _repository.escape();
}
