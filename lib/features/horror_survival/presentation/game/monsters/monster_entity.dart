import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:game_test/core/constants/model_path.dart';
import 'package:vector_math/vector_math.dart';

/// Extra yaw (radians) added when turning the GLB toward the player.
///
/// Mixamo exports often face +Z while glTF viewers treat -Z as forward, so
/// `math.pi` is a common value. Tune if the monster runs sideways.
const double kMonsterFacingYawOffset = math.pi;

/// A roaming horror monster in the 3D scene.
///
/// Use with [MonsterSpawner] after [MonsterTemplate.load] has finished.
/// Example: `final m = MonsterSpawner.spawn(world, template, Vector3(9, 0, 2))`
class MonsterEntity {
  MonsterEntity({
    required this.node,
    required this.spawnPosition,
    required this.visualScale,
    required this.colliderRadius,
    required this.colliderCenterY,
    this.runClip,
    this.detectRadius = 12.0,
    this.attackRadius = 1.5,
    this.speed = 2.5,
    this.damage = 15,
  });

  final Node node;
  final Vector3 spawnPosition;
  final double visualScale;
  final double colliderRadius;
  final double colliderCenterY;
  final AnimationClip? runClip;
  final double detectRadius;
  final double attackRadius;
  final double speed;
  final double damage;
  double attackCooldown = 0;
  bool active = false;

  Vector3 get position => node.localTransform.getTranslation();

  /// Yaw in radians that makes the model's run cycle point at [worldTarget].
  ///
  /// Example: `final yaw = monster.facingYawToward(playerPosition);`
  double facingYawToward(Vector3 worldTarget) {
    final toTarget = worldTarget - position;
    if (toTarget.length2 < 1e-6) {
      return 0;
    }
    final flat = Vector3(toTarget.x, 0, toTarget.z).normalized();
    return math.atan2(flat.x, flat.z) + kMonsterFacingYawOffset;
  }

  /// Plays or stops the GLB run cycle while the monster chases the player.
  ///
  /// Example: `monster.setRunning(true)` when moving toward the player.
  void setRunning(bool running) {
    final clip = runClip;
    if (clip == null) return;

    if (running) {
      if (!clip.playing) {
        clip.play();
      }
      return;
    }

    clip.stop();
  }
}

/// Loaded monster GLB used to clone standing enemies into the world.
class MonsterTemplate {
  const MonsterTemplate({
    required this.root,
    required this.visualScale,
    required this.colliderRadius,
    required this.colliderCenterY,
    required this.runAnimationName,
  });

  final Node root;
  final double visualScale;
  final double colliderRadius;
  final double colliderCenterY;
  final String? runAnimationName;

  static const double _targetHeight = 1.8;
  static const double _defaultScale = 0.01;
  static const double _defaultColliderRadius = 0.6;
  static const double _defaultColliderCenterY = 0.9;

  static const List<String> _preferredRunNames = [
    'mixamo.com',
    'Running',
    'Run',
    'run',
    'Take 001',
  ];

  /// Loads [ModelPath.monster] once, grounds feet, and measures collider size.
  ///
  /// Example: `final template = await MonsterTemplate.load();`
  static Future<MonsterTemplate> load() async {
    final model = await Node.fromGlbAsset(ModelPath.monster);
    final bounds = model.combinedLocalBounds;

    final wrapper = Node(name: 'monster_template');
    var visualScale = _defaultScale;
    var colliderRadius = _defaultColliderRadius;
    var colliderCenterY = _defaultColliderCenterY;

    if (bounds != null) {
      model.localTransform = Matrix4.translation(Vector3(0, -bounds.min.y, 0));

      final height = bounds.max.y - bounds.min.y;
      final footprint = math.min(
        bounds.max.x - bounds.min.x,
        bounds.max.z - bounds.min.z,
      );

      visualScale = _targetHeight / height;
      colliderRadius = footprint * 0.25 * visualScale;
      colliderCenterY = (height * 0.5) * visualScale;
    }

    _useExactGlbColors(model);
    wrapper.add(model);

    final animatedNode = _findAnimatedNode(wrapper);
    final runAnimationName = animatedNode == null
        ? null
        : _resolveRunAnimationName(animatedNode);

    return MonsterTemplate(
      root: wrapper,
      visualScale: visualScale,
      colliderRadius: colliderRadius,
      colliderCenterY: colliderCenterY,
      runAnimationName: runAnimationName,
    );
  }

  /// Finds the subtree node that owns parsed GLB animations.
  static Node? _findAnimatedNode(Node root) {
    if (root.parsedAnimations.isNotEmpty) {
      return root;
    }
    for (final child in root.children) {
      final found = _findAnimatedNode(child);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  /// Picks the run clip name exported from Mixamo / Blender.
  static String? _resolveRunAnimationName(Node animatedNode) {
    for (final name in _preferredRunNames) {
      final animation = animatedNode.findAnimationByName(name);
      if (animation != null && animation.channels.isNotEmpty) {
        return name;
      }
    }

    for (final animation in animatedNode.parsedAnimations) {
      if (animation.channels.isNotEmpty) {
        return animation.name;
      }
    }
    return null;
  }

  /// Keeps embedded GLB textures/colors instead of scene PBR lighting.
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
}

/// Creates monster nodes in the scene from a shared [MonsterTemplate].
class MonsterSpawner {
  /// Clones the GLB model at [worldPosition] and binds the run animation clip.
  ///
  /// Example: `MonsterSpawner.spawn(worldNode, template, Vector3(9, 0, 2))`
  static MonsterEntity spawn(
    Node parent,
    MonsterTemplate template,
    Vector3 worldPosition,
  ) {
    final monsterNode = template.root.clone();
    monsterNode.name = 'monster';
    monsterNode.localTransform = Matrix4.compose(
      worldPosition,
      Quaternion.identity(),
      Vector3.all(template.visualScale),
    );

    final runClip = _createRunClip(monsterNode, template.runAnimationName);

    final collider = BasicCollider(
      shape: SphereShape(radius: template.colliderRadius),
      isTrigger: true,
    );
    monsterNode.addComponent(collider);
    parent.add(monsterNode);

    return MonsterEntity(
      node: monsterNode,
      spawnPosition: worldPosition.clone(),
      visualScale: template.visualScale,
      colliderRadius: template.colliderRadius,
      colliderCenterY: template.colliderCenterY,
      runClip: runClip,
    );
  }

  /// Instantiates a looping in-place run clip on the cloned animated model node.
  ///
  /// Mixamo run clips usually bake forward root motion into hip translation.
  /// That motion is stripped so [ChaseAI] owns world movement and loop restarts
  /// do not yank the mesh backward.
  static AnimationClip? _createRunClip(Node monsterRoot, String? animationName) {
    if (animationName == null) {
      return null;
    }

    final animatedNode = MonsterTemplate._findAnimatedNode(monsterRoot);
    final animation = animatedNode?.findAnimationByName(animationName);
    if (animatedNode == null || animation == null) {
      return null;
    }

    final inPlaceRun = _withoutRootMotion(animation);

    return animatedNode.createAnimationClip(inPlaceRun)
      ..loop = true
      ..playbackTimeScale = 1.0;
  }

  /// Drops translation tracks so only limb/body rotation drives the run cycle.
  static Animation _withoutRootMotion(Animation source) {
    final channels = source.channels
        .where(
          (channel) =>
              channel.bindTarget.property.toString() !=
              'AnimationProperty.translation',
        )
        .toList();

    return Animation(name: source.name, channels: channels);
  }
}
