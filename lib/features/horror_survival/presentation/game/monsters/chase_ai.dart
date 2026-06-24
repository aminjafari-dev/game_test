import 'package:game_test/core/audio/audio_manager.dart';
import 'package:game_test/features/horror_survival/domain/entities/game_entities.dart';
import 'package:game_test/features/horror_survival/presentation/game/monsters/monster_entity.dart';
import 'package:game_test/features/horror_survival/presentation/providers/game_provider.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vibration/vibration.dart';
import 'package:vector_math/vector_math.dart';

/// Simple chase AI — monsters pursue the player when in range.
///
/// Example: `chaseAi.tick(dt, playerPosition, gameProvider)`
class ChaseAI {
  ChaseAI({
    required this.physicsWorld,
    required this.audioManager,
    required this.monsters,
  });

  final BasicPhysicsWorld physicsWorld;
  final AudioManager audioManager;
  final List<MonsterEntity> monsters;
  double _spawnTimer = 30.0;
  bool _spawned = false;

  /// Delays monster activation for the first [spawnDelay] seconds.
  void tick(double dt, Vector3 playerPos, GameProvider game) {
    if (!_spawned) {
      _spawnTimer -= dt;
      if (_spawnTimer <= 0) {
        for (final m in monsters) {
          m.active = true;
        }
        _spawned = true;
      }
      return;
    }

    if (game.phase != GamePhase.playing) return;

    for (final monster in monsters) {
      if (!monster.active) continue;

      if (monster.attackCooldown > 0) {
        monster.attackCooldown -= dt;
      }

      final toPlayer = playerPos - monster.position;
      final dist = toPlayer.length;

      if (dist < monster.attackRadius && monster.attackCooldown <= 0) {
        game.takeDamage(monster.damage.round());
        monster.attackCooldown = 2.0;
        audioManager.playOneShot(AudioPaths.sfxMonsterGrowl, volume: 0.7);
        Vibration.vibrate(duration: 100);
        continue;
      }

      if (dist < monster.detectRadius && dist > 0.5) {
        final dir = toPlayer.normalized();
        final move = dir * monster.speed * dt;
        final newPos = monster.position + Vector3(move.x, 0, move.z);

        final pose = Matrix4.translation(newPos + Vector3(0, 0.9, 0));
        final blocked = physicsWorld.shapeCast(
          SphereShape(radius: 0.5),
          pose,
          dir,
          move.length + 0.1,
          includeTriggers: false,
        );

        if (blocked == null) {
          monster.node.localTransform = Matrix4.translation(newPos);
        } else {
          final slideDir = Vector3(-dir.z, 0, dir.x);
          final slidePos = monster.position + slideDir * monster.speed * dt * 0.5;
          monster.node.localTransform = Matrix4.translation(slidePos);
        }
      }
    }
  }
}
