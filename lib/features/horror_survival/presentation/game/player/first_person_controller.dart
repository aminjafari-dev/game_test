import 'dart:math' as math;

import 'package:game_test/core/input/input_state.dart';
import 'package:game_test/features/horror_survival/presentation/game/scene/building_layout.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// First-person movement and camera controller.
///
/// Attach to [SceneView.cameraBuilder] and call [tick] each frame.
/// Example: `PerspectiveCamera` from `controller.buildCamera()`
class FirstPersonController {
  FirstPersonController({
    required this.physicsWorld,
    required this.inputState,
    Vector3? startPosition,
  }) : position = startPosition ?? BuildingLayout.playerSpawn.clone() {
    _playerNode = Node(name: 'player_body')
      ..localTransform = Matrix4.translation(position);
    final collider = BasicCollider(
      shape: SphereShape(radius: 0.45),
      isTrigger: true,
    );
    _playerNode.addComponent(BasicKinematicBody());
    _playerNode.addComponent(collider);
  }

  final BasicPhysicsWorld physicsWorld;
  final InputState inputState;

  late final Node _playerNode;
  Vector3 position;
  double yaw = 0;
  double pitch = 0;
  double _shakeTimer = 0;
  double _shakeIntensity = 0;

  static const double moveSpeed = 4.0;
  static const double lookSensitivity = 0.003;
  static const double eyeHeight = 1.7;
  static const double minPitch = -1.48;
  static const double maxPitch = 1.48;

  Node get playerNode => _playerNode;

  /// Applies a brief camera shake (e.g. jump scare).
  void applyCameraShake(double duration, {double intensity = 0.05}) {
    _shakeTimer = duration;
    _shakeIntensity = intensity;
  }

  /// Updates movement and look from input each frame.
  void tick(double dt) {
    yaw -= inputState.lookDeltaX * lookSensitivity;
    pitch = (pitch - inputState.lookDeltaY * lookSensitivity).clamp(minPitch, maxPitch);

    final forward = Vector3(math.sin(yaw), 0, math.cos(yaw));
    final right = Vector3(math.cos(yaw), 0, -math.sin(yaw));

    var moveDir = Vector3.zero();
    moveDir += forward * inputState.moveZ;
    moveDir += right * inputState.moveX;

    if (moveDir.length2 > 0.0001) {
      moveDir.normalize();
      _moveWithCollision(moveDir * moveSpeed * dt);
    }

    _playerNode.localTransform = Matrix4.translation(position);

    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
    }

    inputState.endFrame();
  }

  void _moveWithCollision(Vector3 delta) {
    var newPos = position.clone();

    if (delta.x.abs() > 0.001) {
      final xDelta = Vector3(delta.x, 0, 0);
      if (!_blocked(newPos, xDelta)) {
        newPos += xDelta;
      }
    }
    if (delta.z.abs() > 0.001) {
      final zDelta = Vector3(0, 0, delta.z);
      if (!_blocked(newPos, zDelta)) {
        newPos += zDelta;
      }
    }

    position = newPos;
  }

  bool _blocked(Vector3 from, Vector3 direction) {
    if (direction.length2 < 0.0001) return false;
    final pose = Matrix4.translation(from + Vector3(0, eyeHeight * 0.5, 0));
    final hit = physicsWorld.shapeCast(
      SphereShape(radius: 0.45),
      pose,
      direction.normalized(),
      direction.length,
      includeTriggers: false,
    );
    return hit != null;
  }

  /// Builds the first-person camera for the current frame.
  PerspectiveCamera buildCamera() {
    final shakeX = _shakeTimer > 0 ? (math.Random().nextDouble() - 0.5) * _shakeIntensity : 0.0;
    final shakeY = _shakeTimer > 0 ? (math.Random().nextDouble() - 0.5) * _shakeIntensity : 0.0;

    final cosPitch = math.cos(pitch);
    final forward = Vector3(
      math.sin(yaw) * cosPitch,
      math.sin(pitch),
      math.cos(yaw) * cosPitch,
    );

    final eyePos = position + Vector3(shakeX, eyeHeight + shakeY, 0);
    final target = eyePos + forward;

    return PerspectiveCamera(
      position: eyePos,
      target: target,
      up: Vector3(0, 1, 0),
      fovRadiansY: 75 * degrees2Radians,
      fovNear: 0.1,
      fovFar: 100,
    );
  }
}
