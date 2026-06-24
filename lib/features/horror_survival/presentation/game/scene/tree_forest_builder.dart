import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:game_test/core/constants/model_path.dart';
import 'package:vector_math/vector_math.dart';

/// Loaded tree GLB plus trunk dimensions used for collision.
class TreeTemplate {
  const TreeTemplate({
    required this.root,
    required this.trunkRadius,
    required this.trunkHalfHeight,
  });

  final Node root;
  final double trunkRadius;
  final double trunkHalfHeight;
}

/// Places cloned instances of [ModelPath.tree] across the hillside forest.
///
/// Loads the GLB once, then clones it at many positions with varied scale
/// and rotation. Each tree gets an axis-aligned trunk collider so the
/// player cannot walk through it.
class TreeForestBuilder {
  TreeForestBuilder._();

  static const double _baseScale = 2.5;
  static const double _scaleJitter = 0.6;

  static const double _defaultTrunkRadius = 0.35;
  static const double _defaultTrunkHalfHeight = 1.2;

  /// Loads the tree GLB, grounds it, and measures trunk size for colliders.
  static Future<TreeTemplate> loadTreeTemplate() async {
    final model = await Node.fromGlbAsset(ModelPath.tree);
    final bounds = model.combinedLocalBounds;

    final wrapper = Node(name: 'tree_template');
    var trunkRadius = _defaultTrunkRadius;
    var trunkHalfHeight = _defaultTrunkHalfHeight;

    if (bounds != null) {
      model.localTransform = Matrix4.translation(Vector3(0, -bounds.min.y, 0));

      final height = bounds.max.y - bounds.min.y;
      final footprint = math.min(
        bounds.max.x - bounds.min.x,
        bounds.max.z - bounds.min.z,
      );
      trunkRadius = footprint * 0.12;
      trunkHalfHeight = height * 0.22;
    }

    _useExactGlbColors(model);

    wrapper.add(model);
    return TreeTemplate(
      root: wrapper,
      trunkRadius: trunkRadius,
      trunkHalfHeight: trunkHalfHeight,
    );
  }

  /// Converts GLB PBR materials to unlit so embedded colors/textures show as-is.
  static void _useExactGlbColors(Node node) {
    final mesh = node.mesh;
    if (mesh != null) {
      for (final primitive in mesh.primitives) {
        final material = primitive.material;
        if (material is PhysicallyBasedMaterial) {
          final unlit = UnlitMaterial();
          unlit.baseColorFactor = material.baseColorFactor;
          unlit.baseColorTexture = material.baseColorTexture;
          unlit.alphaMode = material.alphaMode;
          primitive.material = unlit;
        }
      }
    }

    for (final child in node.children) {
      _useExactGlbColors(child);
    }
  }

  /// Adds forest clones under [parent] using [template] as the source mesh.
  static void build(Node parent, TreeTemplate template) {
    final forestRoot = Node(name: 'forest');
    final random = math.Random(42);

    for (var x = -35.0; x <= 35; x += 4) {
      for (var z = -35.0; z <= -14; z += 4) {
        if (random.nextDouble() < 0.35) continue;

        final jitterX = (random.nextDouble() - 0.5) * 2;
        final jitterZ = (random.nextDouble() - 0.5) * 2;
        final tx = x + jitterX;
        final tz = z + jitterZ;
        final scale =
            _baseScale + (random.nextDouble() - 0.5) * _scaleJitter;
        final rotationY = random.nextDouble() * math.pi * 2;
        final rotation =
            Quaternion.axisAngle(Vector3(0, 1, 0), rotationY);

        final tree = template.root.clone();
        tree.localTransform = Matrix4.compose(
          Vector3(tx, 0.0, tz),
          rotation,
          Vector3.all(scale),
        );
        forestRoot.add(tree);

        // Collider is unscaled — bake scale into the box size. The basic
        // physics backend ignores non-uniform scale on transforms.
        final scaledRadius = template.trunkRadius * scale;
        final scaledHalfHeight = template.trunkHalfHeight * scale;
        final colliderNode = Node(
          name: 'tree_trunk_collider',
          localTransform: Matrix4.compose(
            Vector3(tx, scaledHalfHeight, tz),
            rotation,
            Vector3.all(1),
          ),
        )..addComponent(
            BasicCollider(
              shape: BoxShape(
                halfExtents: Vector3(
                  scaledRadius,
                  scaledHalfHeight,
                  scaledRadius,
                ),
              ),
            ),
          );
        forestRoot.add(colliderNode);
      }
    }

    parent.add(forestRoot);
  }
}
