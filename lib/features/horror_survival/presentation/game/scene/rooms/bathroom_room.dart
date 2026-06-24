import 'package:game_test/core/audio/audio_manager.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/room_factory.dart';
import 'package:vector_math/vector_math.dart';

/// Bathroom room — dripping water and high jump scare rate.
class BathroomRoom {
  BathroomRoom._();

  static final RoomConfig blueprint = RoomConfig(
    id: RoomId.bathroom,
    center: BuildingLayout.roomCenters[RoomId.bathroom]!,
    horror: const HorrorProfile(
      ambientSound: AudioPaths.ambientDripping,
      flickerCount: 2,
      jumpScareChance: 0.018,
    ),
    doorDirections: {
      Vector3(0, 0, 1): DoorId.corridorToBathroom,
      Vector3(0, 0, -1): DoorId.bathroomToStorage,
    },
  );
}
