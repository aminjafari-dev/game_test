import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Orbit camera for the Elements workshop 3D preview.
///
/// Drag to rotate around [target], scroll or pinch to zoom in and out.
/// Example: `OrbitCameraController().buildCamera()` in [SceneView.cameraBuilder].
class OrbitCameraController {
  OrbitCameraController({
    Vector3? target,
    double? yaw,
    double? pitch,
    double? distance,
  })  : target = target ?? Vector3(0, 0.25, 0),
        yaw = yaw ?? math.pi / 4,
        pitch = pitch ?? 0.33,
        distance = distance ?? 4.2;

  final Vector3 target;
  double yaw;
  double pitch;
  double distance;

  static const double minDistance = 1.5;
  static const double maxDistance = 12;
  static const double minPitch = 0.08;
  static const double maxPitch = math.pi / 2 - 0.08;
  static const double orbitSensitivity = 0.005;
  static const double scrollZoomSensitivity = 0.01;

  /// Rotates the camera around [target] from drag deltas in logical pixels.
  void orbit(double deltaX, double deltaY) {
    yaw += deltaX * orbitSensitivity;
    pitch = (pitch + deltaY * orbitSensitivity).clamp(minPitch, maxPitch);
  }

  /// Zooms from a mouse/trackpad scroll delta.
  void zoomFromScroll(double scrollDeltaY) {
    distance = (distance + scrollDeltaY * scrollZoomSensitivity)
        .clamp(minDistance, maxDistance);
  }

  /// Zooms from a pinch [scale] relative to the distance at gesture start.
  void zoomFromPinch(double startDistance, double scale) {
    distance =
        (startDistance / scale).clamp(minDistance, maxDistance);
  }

  /// Builds a [PerspectiveCamera] for the current orbit state.
  PerspectiveCamera buildCamera() {
    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);
    final offset = Vector3(
      distance * cosPitch * math.sin(yaw),
      distance * sinPitch,
      distance * cosPitch * math.cos(yaw),
    );

    return PerspectiveCamera(
      position: target + offset,
      target: target,
      up: Vector3(0, 1, 0),
      fovRadiansY: 55 * degrees2Radians,
      fovNear: 0.1,
      fovFar: 50,
    );
  }
}
