import 'package:game_test/features/horror_survival/presentation/game/materials/horror_materials.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// A roaming horror monster in the 3D scene.
class MonsterEntity {
  MonsterEntity({
    required this.node,
    required this.spawnPosition,
    this.detectRadius = 12.0,
    this.attackRadius = 1.5,
    this.speed = 2.5,
    this.damage = 15,
  });

  final Node node;
  final Vector3 spawnPosition;
  final double detectRadius;
  final double attackRadius;
  final double speed;
  final double damage;
  double attackCooldown = 0;
  bool active = false;

  Vector3 get position => node.localTransform.getTranslation();
}

/// Creates monster nodes in the scene.
class MonsterSpawner {
  static MonsterEntity spawn(Node parent, Vector3 worldPosition) {
    final monsterNode = Node(
      name: 'monster',
      localTransform: Matrix4.translation(worldPosition),
      mesh: Mesh(
        CuboidGeometry(Vector3(0.6, 1.8, 0.4)),
        HorrorMaterials.monster(),
      ),
    );
    final collider = BasicCollider(
      shape: SphereShape(radius: 0.6),
      isTrigger: true,
    );
    monsterNode.addComponent(collider);
    parent.add(monsterNode);

    return MonsterEntity(
      node: monsterNode,
      spawnPosition: worldPosition.clone(),
    );
  }
}
