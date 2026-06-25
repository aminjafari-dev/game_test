import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:game_test/core/theme/app_theme.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:vector_math/vector_math.dart';

/// Factory for block materials used in the modern villa scene.
///
/// Uses [UnlitMaterial] so [AppColors] appear exactly as defined — no lighting
/// brightening or darkening. Call after [Scene.initializeStaticResources].
/// Example: `HorrorMaterials.whiteConcrete()` for house walls.
class HorrorMaterials {
  HorrorMaterials._();

  static Vector4 _color(Color c) => Vector4(c.r, c.g, c.b, c.a);

  /// Builds an unlit material that outputs the exact [color] from [AppColors].
  static UnlitMaterial _unlit(
    Color color, {
    AlphaMode alphaMode = AlphaMode.opaque,
  }) {
    final material = UnlitMaterial();
    material.baseColorFactor = _color(color);
    material.alphaMode = alphaMode;
    return material;
  }

  /// Smooth white concrete / quartz wall blocks.
  static UnlitMaterial whiteConcrete() => _unlit(AppColors.mcWhite);

  /// Dark gray flat roof slabs.
  static UnlitMaterial darkRoof() => _unlit(AppColors.mcDarkGray);

  /// Light oak wood planks for stairs, pergola, and trim.
  static UnlitMaterial oakWood() => _unlit(AppColors.mcOakWood);

  /// Glass window panes.
  static UnlitMaterial glass() =>
      _unlit(AppColors.mcGlass, alphaMode: AlphaMode.blend);

  /// Swimming pool water.
  static UnlitMaterial poolWater() =>
      _unlit(AppColors.mcPoolWater, alphaMode: AlphaMode.blend);

  /// Crop rows in the garden plot.
  static UnlitMaterial crop() => _unlit(AppColors.mcCrop);

  /// Dark gray garden border blocks.
  static UnlitMaterial darkTrim() => _unlit(AppColors.mcDarkGray);

  /// Oak tree trunk.
  static UnlitMaterial treeTrunk() => _unlit(AppColors.mcTreeTrunk);

  /// Oak tree leaf canopy.
  static UnlitMaterial treeLeaves() => _unlit(AppColors.mcTreeLeaves);

  /// Potted plant foliage on the terrace.
  static UnlitMaterial plantPot() => _unlit(AppColors.mcCrop);

  /// Large grass field under the villa.
  static UnlitMaterial grass() => _unlit(AppColors.mcGrass);

  /// Floor color based on map segment type.
  static UnlitMaterial unitFloor(UnitType type) {
    final color = switch (type) {
      UnitType.path => AppColors.mcOakWood,
      UnitType.exitZone => AppColors.mcWhite,
      UnitType.lawn => AppColors.mcGrass,
      UnitType.poolDeck => AppColors.mcWhite,
      UnitType.terrace => AppColors.mcOakWood,
    };
    return _unlit(color);
  }

  /// Interior ceiling panels.
  static UnlitMaterial wall() => whiteConcrete();

  /// Interior floors.
  static UnlitMaterial floor() => whiteConcrete();

  /// Emissive flickering ceiling light panel.
  static UnlitMaterial flickerLight({double intensity = 0.9}) {
    final material = UnlitMaterial();
    material.baseColorFactor = Vector4(intensity, intensity * 0.95, 0.7, 1);
    return material;
  }

  /// Monster body — dark red silhouette.
  static UnlitMaterial monster() {
    final material = UnlitMaterial();
    material.baseColorFactor = Vector4(0.15, 0.02, 0.02, 1);
    return material;
  }

  /// Golden key pickup prop.
  static UnlitMaterial key() {
    final material = UnlitMaterial();
    material.baseColorFactor = Vector4(0.7, 0.55, 0.1, 1);
    return material;
  }

  /// Semi-transparent mist plane.
  static UnlitMaterial mist({double alpha = 0.15}) {
    final material = UnlitMaterial();
    material.alphaMode = AlphaMode.blend;
    material.baseColorFactor = Vector4(0.6, 0.65, 0.7, alpha);
    return material;
  }

  /// Small dust particle sphere.
  static UnlitMaterial dust({double alpha = 0.25}) {
    final material = UnlitMaterial();
    material.alphaMode = AlphaMode.blend;
    material.baseColorFactor = Vector4(0.8, 0.75, 0.7, alpha);
    return material;
  }

  /// Wooden door panel.
  static UnlitMaterial doorWood({bool locked = false}) {
    if (locked) {
      final material = UnlitMaterial();
      material.baseColorFactor = Vector4(0.24, 0.16, 0.08, 1);
      return material;
    }
    return _unlit(AppColors.mcOakWood);
  }

  /// Coffin body panels — dark aged wood.
  static UnlitMaterial coffinWood() => _unlit(AppColors.coffinWoodDark);

  /// Coffin lid — slightly lighter wood tone.
  static UnlitMaterial coffinLid() => _unlit(AppColors.coffinWoodLight);

  /// Coffin handles and decorative metal trim.
  static UnlitMaterial coffinMetal() => _unlit(AppColors.coffinMetal);
}
