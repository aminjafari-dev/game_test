import 'dart:math' as math;
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

  /// Builds a thin extruded polygon lying flat on the ground (XZ plane).
  ///
  /// [vertices] are 2D template coordinates where Y increases downward; they
  /// are mapped to world X/Z. [unitToWorld] converts template units to meters.
  /// [thicknessWorld] is the extrusion depth in meters (Y axis when flat).
  static Mesh flatPolygonMesh(
    List<Vector2> vertices,
    UnlitMaterial material, {
    required double unitToWorld,
    required double thicknessWorld,
  }) {
    return Mesh(
      _flatPolygonGeometry(
        vertices,
        unitToWorld: unitToWorld,
        thicknessWorld: thicknessWorld,
      ),
      material,
    );
  }

  /// Builds a thin axis-aligned rectangle lying flat on the ground.
  ///
  /// [length] runs along world X and [width] runs along world Z.
  static Mesh flatRectangleMesh(
    double length,
    double width,
    UnlitMaterial material, {
    required double unitToWorld,
    required double thicknessWorld,
  }) {
    final lengthWorld = length * unitToWorld;
    final widthWorld = width * unitToWorld;

    return Mesh(
      CuboidGeometry(Vector3(lengthWorld, thicknessWorld, widthWorld)),
      material,
    );
  }

  static MeshGeometry _flatPolygonGeometry(
    List<Vector2> vertices, {
    required double unitToWorld,
    required double thicknessWorld,
  }) {
    final vertexCount = vertices.length;
    if (vertexCount < 3) {
      throw ArgumentError('flatPolygonMesh requires at least 3 vertices.');
    }

    final halfThickness = thicknessWorld / 2;
    final positions = <double>[];
    final normals = <double>[];
    final texCoords = <double>[];
    final indices = <int>[];

    var minX = double.infinity;
    var maxX = -double.infinity;
    var minZ = double.infinity;
    var maxZ = -double.infinity;

    for (final vertex in vertices) {
      final x = vertex.x * unitToWorld;
      final z = vertex.y * unitToWorld;
      minX = minX < x ? minX : x;
      maxX = maxX > x ? maxX : x;
      minZ = minZ < z ? minZ : z;
      maxZ = maxZ > z ? maxZ : z;
    }

    final xSpan = maxX - minX;
    final zSpan = maxZ - minZ;

    double normalizeU(double x) => xSpan == 0 ? 0 : (x - minX) / xSpan;
    double normalizeV(double z) => zSpan == 0 ? 0 : (z - minZ) / zSpan;

    void addVertex(
      double x,
      double y,
      double z,
      double nx,
      double ny,
      double nz,
    ) {
      positions.addAll([x, y, z]);
      normals.addAll([nx, ny, nz]);
      texCoords.addAll([normalizeU(x), normalizeV(z)]);
    }

    // Top rim (+Y normal when viewed from above).
    for (var i = 0; i < vertexCount; i++) {
      final vertex = vertices[i];
      addVertex(
        vertex.x * unitToWorld,
        halfThickness,
        vertex.y * unitToWorld,
        0,
        1,
        0,
      );
    }

    // Bottom rim (-Y normal).
    for (var i = 0; i < vertexCount; i++) {
      final vertex = vertices[i];
      addVertex(
        vertex.x * unitToWorld,
        -halfThickness,
        vertex.y * unitToWorld,
        0,
        -1,
        0,
      );
    }

    // Top cap (+Y normal): template vertices are CW in XZ when viewed from above,
    // so reverse each fan triangle to make them CCW and visible from above.
    for (var i = 1; i < vertexCount - 1; i++) {
      indices.addAll([0, i + 1, i]);
    }

    final bottomRimStart = vertexCount;

    // Bottom cap (-Y normal): CW in XZ when viewed from above.
    for (var i = 1; i < vertexCount - 1; i++) {
      indices.addAll([
        bottomRimStart,
        bottomRimStart + i,
        bottomRimStart + i + 1,
      ]);
    }

    // Side quads reuse rim vertices so caps and walls are watertight.
    for (var i = 0; i < vertexCount; i++) {
      final next = (i + 1) % vertexCount;
      final topA = i;
      final topB = next;
      final bottomA = bottomRimStart + i;
      final bottomB = bottomRimStart + next;

      final current = vertices[i];
      final edgeNext = vertices[next];
      final edgeX = (edgeNext.x - current.x) * unitToWorld;
      final edgeZ = (edgeNext.y - current.y) * unitToWorld;
      final length = math.sqrt(edgeX * edgeX + edgeZ * edgeZ);
      if (length == 0) {
        continue;
      }

      // Outward normal for a CW boundary in template space (Y grows downward).
      final nx = -edgeZ / length;
      final nz = -edgeX / length;

      void setSideNormal(int index) {
        final base = index * 3;
        normals[base] = nx;
        normals[base + 1] = 0;
        normals[base + 2] = nz;
      }

      setSideNormal(topA);
      setSideNormal(topB);
      setSideNormal(bottomA);
      setSideNormal(bottomB);

      indices.addAll([topA, topB, bottomB, topA, bottomB, bottomA]);
    }

    return MeshGeometry.fromArrays(
      positions: Float32List.fromList(positions),
      normals: Float32List.fromList(normals),
      texCoords: Float32List.fromList(texCoords),
      indices: Uint32List.fromList(indices),
    );
  }
}
