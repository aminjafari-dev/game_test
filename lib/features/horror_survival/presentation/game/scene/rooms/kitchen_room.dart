import 'package:game_test/core/audio/audio_manager.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/room_factory.dart';
import 'package:vector_math/vector_math.dart';

/// Kitchen room — creaking floorboards and moderate jump scare chance.
class KitchenRoom {
  KitchenRoom._();

  static final RoomConfig blueprint = RoomConfig(
    id: RoomId.kitchen,
    center: BuildingLayout.roomCenters[RoomId.kitchen]!,
    horror: const HorrorProfile(
      ambientSound: AudioPaths.ambientCreaking,
      flickerCount: 1,
      jumpScareChance: 0.012,
    ),
    doorDirections: {
      Vector3(-1, 0, 0): DoorId.libraryToKitchen,
      Vector3(1, 0, 0): DoorId.kitchenToCorridor,
    },
  );
}
