import 'package:game_test/core/audio/audio_manager.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/room_factory.dart';
import 'package:vector_math/vector_math.dart';

/// Reference room blueprint — Library with full horror elements.
///
/// Demonstrates flickering lights, dripping ambient audio zone, jump scares,
/// and a hidden key. Other rooms follow this pattern via [RoomConfig].
class LibraryRoom {
  LibraryRoom._();

  static final RoomConfig blueprint = RoomConfig(
    id: RoomId.library,
    center: BuildingLayout.roomCenters[RoomId.library]!,
    horror: HorrorProfile(
      ambientSound: AudioPaths.ambientDripping,
      flickerCount: 2,
      jumpScareChance: 0.02,
      keyType: KeyType.library,
      keyLocalPosition: Vector3(2, 0, -2),
    ),
    doorDirections: {
      Vector3(1, 0, 0): DoorId.libraryToKitchen,
    },
  );
}
