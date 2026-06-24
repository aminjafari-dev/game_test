import 'package:game_test/core/audio/audio_manager.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/room_factory.dart';
import 'package:vector_math/vector_math.dart';

/// Storage room — contains the second key required for exit.
class StorageRoom {
  StorageRoom._();

  static final RoomConfig blueprint = RoomConfig(
    id: RoomId.storage,
    center: BuildingLayout.roomCenters[RoomId.storage]!,
    horror: HorrorProfile(
      ambientSound: AudioPaths.ambientCreaking,
      flickerCount: 1,
      jumpScareChance: 0.015,
      keyType: KeyType.storage,
      keyLocalPosition: Vector3(-2, 0, 1),
    ),
    doorDirections: {
      Vector3(0, 0, 1): DoorId.bathroomToStorage,
      Vector3(1, 0, 0): DoorId.storageToExitLobby,
    },
  );
}
