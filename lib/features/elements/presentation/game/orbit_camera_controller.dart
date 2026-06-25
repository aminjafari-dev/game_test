import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// Orbit camera for the Elements workshop 3D preview.
///
/// Drag to rotate around [target], scroll or pinch to zoom toward the pointer
/// or pinch focal point. Example: `OrbitCameraController().buildCamera()` in
/// [SceneView.cameraBuilder].
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

  /// Zooms from a mouse/trackpad scroll delta at [screenPoint].
  void zoomFromScrollAt(
    double scrollDeltaY,
    Offset screenPoint,
    Size viewSize,
  ) {
    final fromDistance = distance;
    final toDistance = (distance + scrollDeltaY * scrollZoomSensitivity)
        .clamp(minDistance, maxDistance);
    _dollyToward(
      screenPoint: screenPoint,
      viewSize: viewSize,
      fromDistance: fromDistance,
      toDistance: toDistance,
      fromTarget: target,
    );
  }

  /// Zooms from a pinch [scale] relative to the orbit state at gesture start.
  void zoomFromPinchAt({
    required double startDistance,
    required double scale,
    required Vector3 startTarget,
    required Offset focalPoint,
    required Size viewSize,
  }) {
    final toDistance = (startDistance / scale).clamp(minDistance, maxDistance);
    _dollyToward(
      screenPoint: focalPoint,
      viewSize: viewSize,
      fromDistance: startDistance,
      toDistance: toDistance,
      fromTarget: startTarget,
    );
  }

  /// Moves [target] while changing [distance] so [screenPoint] stays anchored.
  void _dollyToward({
    required Offset screenPoint,
    required Size viewSize,
    required double fromDistance,
    required double toDistance,
    required Vector3 fromTarget,
  }) {
    if ((fromDistance - toDistance).abs() < 1e-9) {
      return;
    }

    final camera = _buildCamera(
      orbitTarget: fromTarget,
      orbitDistance: fromDistance,
    );
    final ray = camera.screenPointToRay(screenPoint, viewSize);
    final anchor = _intersectRayWithViewPlane(
      ray: ray,
      planePoint: fromTarget,
      cameraPosition: camera.position,
    );

    if (anchor != null) {
      final blend = 1.0 - toDistance / fromDistance;
      target.setFrom(fromTarget + (anchor - fromTarget) * blend);
    } else {
      target.setFrom(fromTarget);
    }
    distance = toDistance;
  }

  /// Intersects [ray] with the plane through [planePoint] facing the camera.
  Vector3? _intersectRayWithViewPlane({
    required Ray ray,
    required Vector3 planePoint,
    required Vector3 cameraPosition,
  }) {
    final normal = planePoint - cameraPosition;
    final length = normal.length;
    if (length < 1e-8) {
      return null;
    }
    normal.scale(1 / length);

    final denom = ray.direction.dot(normal);
    if (denom.abs() < 1e-8) {
      return null;
    }

    final t = (planePoint - ray.origin).dot(normal) / denom;
    if (t < 0) {
      return null;
    }

    return ray.origin + ray.direction * t;
  }

  PerspectiveCamera _buildCamera({
    required Vector3 orbitTarget,
    required double orbitDistance,
  }) {
    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);
    final offset = Vector3(
      orbitDistance * cosPitch * math.sin(yaw),
      orbitDistance * sinPitch,
      orbitDistance * cosPitch * math.cos(yaw),
    );

    return PerspectiveCamera(
      position: orbitTarget + offset,
      target: orbitTarget,
      up: Vector3(0, 1, 0),
      fovRadiansY: 55 * degrees2Radians,
      fovNear: 0.1,
      fovFar: 50,
    );
  }

  /// Builds a [PerspectiveCamera] for the current orbit state.
  PerspectiveCamera buildCamera() {
    return _buildCamera(orbitTarget: target, orbitDistance: distance);
  }
}
