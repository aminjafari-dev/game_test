import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Factory for dark horror-themed PBR and unlit materials.
///
/// Call after [Scene.initializeStaticResources].
/// Example: `HorrorMaterials.wall()` for room walls.
class HorrorMaterials {
  HorrorMaterials._();

  /// Clean white wall material.
  static PhysicallyBasedMaterial wall({double brightness = 0.95}) {
    final material = PhysicallyBasedMaterial();
    material.baseColorFactor = Vector4(brightness, brightness, brightness, 1);
    material.metallicFactor = 0.0;
    material.roughnessFactor = 0.85;
    return material;
  }

  /// Light gray floor material.
  static PhysicallyBasedMaterial floor({double brightness = 0.88}) {
    final material = PhysicallyBasedMaterial();
    material.baseColorFactor = Vector4(brightness, brightness, brightness, 1);
    material.metallicFactor = 0.0;
    material.roughnessFactor = 0.9;
    return material;
  }

  /// Blood-stained accent material for horror props.
  static PhysicallyBasedMaterial bloodStain() {
    final material = PhysicallyBasedMaterial();
    material.baseColorFactor = Vector4(0.35, 0.05, 0.05, 1);
    material.metallicFactor = 0.0;
    material.roughnessFactor = 0.85;
    return material;
  }

  /// Emissive flickering ceiling light panel.
  static UnlitMaterial flickerLight({double intensity = 0.9}) {
    final material = UnlitMaterial();
    material.baseColorFactor = Vector4(intensity, intensity * 0.95, 0.7, 1);
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

  /// Monster body — dark red silhouette.
  static PhysicallyBasedMaterial monster() {
    final material = PhysicallyBasedMaterial();
    material.baseColorFactor = Vector4(0.15, 0.02, 0.02, 1);
    material.emissiveFactor = Vector4(0.3, 0.0, 0.0, 1);
    material.metallicFactor = 0.2;
    material.roughnessFactor = 0.8;
    return material;
  }

  /// Golden key pickup prop.
  static PhysicallyBasedMaterial key() {
    final material = PhysicallyBasedMaterial();
    material.baseColorFactor = Vector4(0.7, 0.55, 0.1, 1);
    material.emissiveFactor = Vector4(0.2, 0.15, 0.0, 1);
    material.metallicFactor = 0.9;
    material.roughnessFactor = 0.3;
    return material;
  }
}
