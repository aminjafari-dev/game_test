import 'package:game_test/core/audio/audio_manager.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/room_factory.dart';
import 'package:vector_math/vector_math.dart';

/// Exit lobby — locked exit door requiring both keys.
class ExitLobbyRoom {
  ExitLobbyRoom._();

  static final RoomConfig blueprint = RoomConfig(
    id: RoomId.exitLobby,
    center: BuildingLayout.roomCenters[RoomId.exitLobby]!,
    horror: const HorrorProfile(
      ambientSound: AudioPaths.ambientCorridor,
      flickerCount: 2,
      jumpScareChance: 0.01,
    ),
    doorDirections: {
      Vector3(-1, 0, 0): DoorId.storageToExitLobby,
      Vector3(0, 0, -1): DoorId.exitDoor,
    },
  );
}
