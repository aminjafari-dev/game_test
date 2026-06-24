import 'dart:math' as math;

import 'package:game_test/features/horror_survival/presentation/game/materials/horror_materials.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Tracks a flickering emissive light panel in a room.
class FlickerLight {
  FlickerLight({required this.node, required this.material});

  final Node node;
  final UnlitMaterial material;
  double phase = 0;
  double frequency = 3.0 + math.Random().nextDouble() * 4;
}

/// Dust particle with slow drift for atmospheric effect.
class DustParticle {
  DustParticle({required this.node, required this.velocity});

  final Node node;
  final Vector3 velocity;
}

/// Manages flickering lights, mist planes, and dust particles.
///
/// Call [tick] each frame from the game loop.
/// Example: `lightingSystem.addFlickerLight(roomNode, Vector3(0, 2.9, 0))`
class LightingSystem {
  final List<FlickerLight> _flickerLights = [];
  final List<DustParticle> _dust = [];
  final math.Random _random = math.Random();

  /// Adds an emissive ceiling panel that flickers over time.
  void addFlickerLight(Node parent, Vector3 localPosition) {
    final material = HorrorMaterials.flickerLight();
    final lightNode = Node(
      name: 'flicker_light',
      localTransform: Matrix4.translation(localPosition),
      mesh: Mesh(
        CuboidGeometry(Vector3(0.8, 0.05, 0.8)),
        material,
      ),
    );
    parent.add(lightNode);
    _flickerLights.add(FlickerLight(node: lightNode, material: material));
  }

  /// Adds a horizontal mist plane at knee height.
  void addMist(Node parent, Vector3 center, double extent) {
    final mist = Node(
      name: 'mist',
      localTransform: Matrix4.translation(Vector3(center.x, 0.6, center.z)),
      mesh: Mesh(
        PlaneGeometry(width: extent, depth: extent, segmentsX: 4, segmentsZ: 4),
        HorrorMaterials.mist(alpha: 0.12),
      ),
    );
    parent.add(mist);
  }

  /// Spawns floating dust spheres across the building.
  void addDustParticles(Node parent, int count) {
    for (var i = 0; i < count; i++) {
      final pos = Vector3(
        (_random.nextDouble() - 0.5) * 50,
        0.5 + _random.nextDouble() * 2,
        (_random.nextDouble() - 0.5) * 50,
      );
      final node = Node(
        name: 'dust_$i',
        localTransform: Matrix4.translation(pos),
        mesh: Mesh(
          SphereGeometry(radius: 0.03),
          HorrorMaterials.dust(),
        ),
      );
      parent.add(node);
      _dust.add(DustParticle(
        node: node,
        velocity: Vector3(
          (_random.nextDouble() - 0.5) * 0.2,
          (_random.nextDouble() - 0.5) * 0.05,
          (_random.nextDouble() - 0.5) * 0.2,
        ),
      ));
    }
  }

  /// Updates flicker intensity and particle drift each frame.
  void tick(double dt, double totalTime) {
    for (final light in _flickerLights) {
      light.phase += dt;
      final flicker = 0.5 + 0.5 * math.sin(totalTime * light.frequency);
      final jitter = 0.85 + _random.nextDouble() * 0.15;
      final intensity = (flicker * jitter).clamp(0.05, 1.0);
      light.material.baseColorFactor = Vector4(intensity, intensity * 0.95, 0.7, 1);
    }

    for (final dust in _dust) {
      final pos = dust.node.localTransform.getTranslation() + dust.velocity * dt;
      if (pos.y < 0.3 || pos.y > 2.8) {
        dust.velocity.y *= -1;
      }
      dust.node.localTransform = Matrix4.translation(pos);
    }
  }
}
