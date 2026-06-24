import 'package:game_test/core/audio/audio_manager.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/room_factory.dart';
import 'package:vector_math/vector_math.dart';

/// Nursery room — whispers ambient and monster spawn zone.
class NurseryRoom {
  NurseryRoom._();

  static final RoomConfig blueprint = RoomConfig(
    id: RoomId.nursery,
    center: BuildingLayout.roomCenters[RoomId.nursery]!,
    horror: const HorrorProfile(
      ambientSound: AudioPaths.ambientWhispers,
      flickerCount: 1,
      jumpScareChance: 0.025,
      wallDarkness: 0.14,
    ),
    doorDirections: {
      Vector3(-1, 0, 0): DoorId.corridorToNursery,
    },
  );
}
