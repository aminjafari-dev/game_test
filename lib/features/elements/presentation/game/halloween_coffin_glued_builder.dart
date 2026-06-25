import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:game_test/features/elements/presentation/game/coffin_geometry.dart';
import 'package:game_test/features/elements/presentation/game/halloween_coffin_template_spec.dart';
import 'package:game_test/features/horror_survival/presentation/game/materials/horror_materials.dart';
import 'package:vector_math/vector_math.dart';

/// Holds the assembled ("glued") Halloween coffin built from the flat template
/// pieces.
///
/// This is just a thin wrapper around the scene [Node] so callers can add the
/// whole prop to a world with a single line.
///
/// Example:
/// ```dart
/// final glued = HalloweenCoffinGluedBuilder.build(
///   material: HorrorMaterials.coffinWood(),
/// );
/// world.add(glued.root);
/// ```
class HalloweenCoffinGlued {
  HalloweenCoffinGlued({required this.root});

  /// Scene-graph parent that contains every glued piece of the coffin.
  final Node root;
}

/// Folds the exact same cut-sheet pieces from [HalloweenCoffinTemplateSpec] up
/// into a fully assembled coffin and glues them together.
///
/// Nothing about the flat cut sheet (built by `HalloweenCoffinPiecesBuilder`)
/// is changed or moved. We only *reuse the same dimensions and meshes* and place
/// them with new transforms so the walls stand up around the hexagonal base and
/// the two lid halves close on top — like folding the paper template into a box.
///
/// Piece-to-edge mapping (matches the spec exactly):
/// - base hexagon stays flat on the ground.
/// - head / foot / shoulder / side walls fold up 90° along each base edge.
/// - left + right doors lie flat on top of the walls to form the closed lid.
///
/// Example:
/// ```dart
/// final glued = HalloweenCoffinGluedBuilder.build(
///   material: woodMaterial,
///   baseMaterial: HorrorMaterials.coffinBaseBlack(),
///   offset: Vector3(4, 0, -3),
/// );
/// world.add(glued.root);
/// ```
class HalloweenCoffinGluedBuilder {
  HalloweenCoffinGluedBuilder._();

  /// Builds the assembled coffin from the shared template pieces.
  ///
  /// [material] paints the walls, base, and lid (defaults to coffin wood).
  /// [baseMaterial] paints only the hexagonal floor panel (defaults to black).
  /// [offset] positions the whole prop in world space so it can sit next to the
  /// flat cut sheet without overlapping it.
  static HalloweenCoffinGlued build({
    UnlitMaterial? material,
    UnlitMaterial? baseMaterial,
    Vector3? offset,
  }) {
    final wood = material ?? HorrorMaterials.coffinWood();
    final base = baseMaterial ?? HorrorMaterials.coffinBaseBlack();
    final root = Node(name: 'halloween_coffin_glued');

    // Park the assembled coffin beside the flat cut sheet by default so the two
    // versions can be compared side by side.
    final worldOffset = offset ??
        Vector3(HalloweenCoffinTemplateSpec.cutSheetOffsetX, 0, -3.0);
    root.localTransform = Matrix4.translation(worldOffset);

    // 1) The hexagonal floor sits flat on the ground, exactly like the cut-sheet
    //    base piece (same vertices, same thickness, same material).
    root.add(_buildBase(base));

    // 2) Each of the six wall strips folds up along its matching base edge. We
    //    walk the hexagon edges in order so every wall lands on the right side.
    final edges = _wallEdges();
    for (final edge in edges) {
      root.add(_buildStandingWall(edge, wood));
    }

    // 3) The two lid halves close on top of the walls to seal the coffin.
    root.add(_buildLid(wood));

    return HalloweenCoffinGlued(root: root);
  }

  /// Builds the flat hexagonal floor panel using the shared base vertices.
  ///
  /// We reuse `baseVerticesIn` and `flatPolygonMesh` verbatim so the glued
  /// coffin's footprint is identical to the cut-sheet base piece.
  static Node _buildBase(UnlitMaterial material) {
    return Node(
      name: 'glued_base',
      // Rest the panel on the ground with its thickness centered just above y=0.
      localTransform: Matrix4.translation(
        Vector3(0, HalloweenCoffinTemplateSpec.pieceHalfThicknessWorld, 0),
      ),
      mesh: CoffinGeometry.flatPolygonMesh(
        HalloweenCoffinTemplateSpec.baseVerticesIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.pieceThicknessWorld,
      ),
    );
  }

  /// Builds one wall strip standing vertically along a hexagon edge.
  ///
  /// The wall mesh is the *same* rectangle the cut sheet uses
  /// (`flatRectangleMesh(edgeLength, wallDepth, thickness)`), but instead of
  /// lying flat we rotate it so the wall-depth dimension points straight up and
  /// the length dimension follows the base edge — i.e. we fold it up 90°.
  static Node _buildStandingWall(_WallEdge edge, UnlitMaterial material) {
    final scale = HalloweenCoffinTemplateSpec.inchesToWorld;

    // Convert the two edge endpoints from template inches to world XZ. Template
    // Y maps to world Z (same convention as templateInToWorld).
    final worldA = Vector3(edge.start.x * scale, 0, edge.start.y * scale);
    final worldB = Vector3(edge.end.x * scale, 0, edge.end.y * scale);

    final delta = worldB - worldA;
    final length = delta.length;

    // Degenerate edges (zero length) would break normalization; skip them by
    // returning an empty, harmless node.
    if (length == 0) {
      return Node(name: 'glued_${edge.name}_empty');
    }

    final wallDepthWorld = HalloweenCoffinTemplateSpec.wallDepthIn * scale;
    final thicknessWorld = HalloweenCoffinTemplateSpec.pieceThicknessWorld;
    final wallLengthIn = HalloweenCoffinTemplateSpec.wallLengthIn[edge.piece]!;

    // Local mesh axes before rotation: X = edge length, Y = thickness,
    // Z = wall depth (height). This matches the cut-sheet rectangle exactly.
    final mesh = CoffinGeometry.flatRectangleMesh(
      wallLengthIn,
      HalloweenCoffinTemplateSpec.wallDepthIn,
      material,
      unitToWorld: scale,
      thicknessWorld: thicknessWorld,
    );

    // Build an orthonormal basis that folds the flat rectangle upright:
    // - local X follows the edge direction (horizontal),
    // - local Z (wall depth) becomes world up (+Y),
    // - local Y (thickness) becomes the horizontal edge normal.
    final dir = delta.normalized();
    final xAxis = Vector4(dir.x, 0, dir.z, 0);
    // Horizontal normal = up × edgeDir, keeping the basis right-handed.
    final yAxis = Vector4(dir.z, 0, -dir.x, 0);
    final zAxis = Vector4(0, 1, 0, 0);

    // Place the wall at the edge midpoint, lifted so it rests on the ground and
    // reaches the full wall-depth height.
    final mid = (worldA + worldB) * 0.5;
    final translation = Vector4(mid.x, wallDepthWorld / 2, mid.z, 1);

    final transform = Matrix4.identity()
      ..setColumn(0, xAxis)
      ..setColumn(1, yAxis)
      ..setColumn(2, zAxis)
      ..setColumn(3, translation);

    return Node(
      name: 'glued_${edge.name}',
      localTransform: transform,
      mesh: mesh,
    );
  }

  /// Builds the closed lid from the two door halves resting on the walls.
  ///
  /// Both door polygons are already expressed in base-hexagon coordinates, so
  /// laying them flat at wall-top height reconstructs the full hexagon lid with
  /// the seam running down the center — exactly the split-lid shape we cut.
  static Node _buildLid(UnlitMaterial material) {
    final scale = HalloweenCoffinTemplateSpec.inchesToWorld;
    final wallDepthWorld = HalloweenCoffinTemplateSpec.wallDepthIn * scale;
    final thicknessWorld = HalloweenCoffinTemplateSpec.pieceThicknessWorld;

    // Sit the lid on top of the walls; its thickness is centered, so add half
    // the thickness to keep it resting flush on the wall rim.
    final lidY = wallDepthWorld +
        HalloweenCoffinTemplateSpec.pieceHalfThicknessWorld;

    final lid = Node(
      name: 'glued_lid',
      localTransform: Matrix4.translation(Vector3(0, lidY, 0)),
    );

    lid.add(
      Node(
        name: 'glued_left_door',
        mesh: CoffinGeometry.flatPolygonMesh(
          HalloweenCoffinTemplateSpec.leftDoorVerticesIn,
          material,
          unitToWorld: scale,
          thicknessWorld: thicknessWorld,
        ),
      ),
    );

    lid.add(
      Node(
        name: 'glued_right_door',
        mesh: CoffinGeometry.flatPolygonMesh(
          HalloweenCoffinTemplateSpec.rightDoorVerticesIn,
          material,
          unitToWorld: scale,
          thicknessWorld: thicknessWorld,
        ),
      ),
    );

    return lid;
  }

  /// Returns the six hexagon edges paired with the wall piece that folds up on
  /// each one. The order matches `baseVerticesIn` so every wall lands on the
  /// correct side (head, shoulders, long sides, foot).
  static List<_WallEdge> _wallEdges() {
    final v = HalloweenCoffinTemplateSpec.baseVerticesIn;
    return [
      _WallEdge('top', v[0], v[1], TemplatePiece.top),
      _WallEdge('top_right', v[1], v[2], TemplatePiece.topRight),
      _WallEdge('right_side', v[2], v[3], TemplatePiece.rightSide),
      _WallEdge('bottom', v[3], v[4], TemplatePiece.bottom),
      _WallEdge('left_side', v[4], v[5], TemplatePiece.leftSide),
      _WallEdge('top_left', v[5], v[0], TemplatePiece.topLeft),
    ];
  }
}

/// Internal description of one hexagon edge and the wall piece glued onto it.
///
/// [start] and [end] are template-space (inches) endpoints; [piece] picks the
/// matching wall length from the shared spec so the glued wall is identical to
/// the flat cut-sheet wall.
class _WallEdge {
  _WallEdge(this.name, this.start, this.end, this.piece);

  final String name;
  final Vector2 start;
  final Vector2 end;
  final TemplatePiece piece;

  /// Geometric length of the edge in inches (handy for debugging seams).
  double get lengthIn => math.sqrt(
        math.pow(end.x - start.x, 2) + math.pow(end.y - start.y, 2),
      ).toDouble();
}
