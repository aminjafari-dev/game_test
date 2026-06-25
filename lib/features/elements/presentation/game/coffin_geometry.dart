import 'dart:typed_data';

import 'package:flutter_scene/scene.dart';
// ignore: implementation_imports
import 'package:flutter_scene/src/geometry/primitives.dart' show buildCuboidArrays;
import 'package:vector_math/vector_math.dart';

/// Cuboid mesh helpers for the textured Halloween coffin prop.
///
/// Scales UV coordinates so the skull texture can span the split doors.
class CoffinGeometry {
  CoffinGeometry._();

  static const int _topFaceIndex = 4;

  /// Builds a cuboid [Mesh] with optional per-face UV scaling.
  static Mesh cuboidMesh(
    Vector3 extents,
    UnlitMaterial material, {
    double uMin = 0,
    double uMax = 1,
    double vMin = 0,
    double vMax = 1,
    int? uvFaceIndex,
  }) {
    return Mesh(
      _cuboidGeometry(
        extents,
        uMin: uMin,
        uMax: uMax,
        vMin: vMin,
        vMax: vMax,
        uvFaceIndex: uvFaceIndex,
      ),
      material,
    );
  }

  static MeshGeometry _cuboidGeometry(
    Vector3 extents, {
    double uMin = 0,
    double uMax = 1,
    double vMin = 0,
    double vMax = 1,
    int? uvFaceIndex,
  }) {
    final arrays = buildCuboidArrays(extents);
    final texCoords = Float32List.fromList(arrays.texCoords!);

    if (uvFaceIndex != null) {
      _scaleFaceUv(texCoords, uvFaceIndex, uMin, uMax, vMin, vMax);
    } else {
      for (var face = 0; face < 6; face++) {
        _scaleFaceUv(texCoords, face, uMin, uMax, vMin, vMax);
      }
    }

    return MeshGeometry.fromArrays(
      positions: arrays.positions,
      normals: arrays.normals,
      texCoords: texCoords,
      indices: arrays.indices,
    );
  }

  static void _scaleFaceUv(
    Float32List texCoords,
    int faceIndex,
    double uMin,
    double uMax,
    double vMin,
    double vMax,
  ) {
    final base = faceIndex * 8;
    for (var i = 0; i < 4; i++) {
      final index = base + i * 2;
      final u = texCoords[index];
      final v = texCoords[index + 1];
      texCoords[index] = uMin + u * (uMax - uMin);
      texCoords[index + 1] = vMin + v * (vMax - vMin);
    }
  }

  /// Face index for the top (+Y) surface — used to map half the skull texture.
  static int get topFaceIndex => _topFaceIndex;
}
