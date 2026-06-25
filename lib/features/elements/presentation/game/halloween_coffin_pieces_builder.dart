import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:game_test/features/elements/presentation/game/coffin_geometry.dart';
import 'package:game_test/features/elements/presentation/game/halloween_coffin_template_spec.dart';
import 'package:game_test/features/horror_survival/presentation/game/materials/horror_materials.dart';
import 'package:vector_math/vector_math.dart';

/// Flat cut-sheet preview for the cardboard Halloween coffin template.
class HalloweenCoffinCutSheet {
  HalloweenCoffinCutSheet({required this.root});

  final Node root;
}

/// Builds each Halloween coffin template piece separately and lays them flat
/// on the ground in a cut-sheet arrangement.
///
/// Phase 1 only — no assembly, hinges, or animation. Use beside the assembled
/// [CoffinBuilder] prop to compare shapes.
///
/// Example:
/// ```dart
/// final cutSheet = HalloweenCoffinPiecesBuilder.buildFlatCutSheet(
///   material: HorrorMaterials.coffinWood(),
/// );
/// world.add(cutSheet.root);
/// ```
class HalloweenCoffinPiecesBuilder {
  HalloweenCoffinPiecesBuilder._();

  /// Creates all flat pieces in a layout that mirrors the paper template.
  static HalloweenCoffinCutSheet buildFlatCutSheet({
    UnlitMaterial? material,
    UnlitMaterial? baseMaterial,
    Vector3? offset,
  }) {
    final wood = material ?? HorrorMaterials.coffinWood();
    final base = baseMaterial ?? HorrorMaterials.coffinBaseBlack();
    final root = Node(name: 'halloween_coffin_cut_sheet');

    final worldOffset =
        offset ?? Vector3(HalloweenCoffinTemplateSpec.cutSheetOffsetX, 0, 0);
    root.localTransform = Matrix4.translation(worldOffset);

    root.add(_buildLeftDoor(wood));
    root.add(_buildBase(base));
    root.add(_buildTopWall(wood));
    root.add(_buildTopLeftWall(wood));
    root.add(_buildTopRightWall(wood));
    root.add(_buildLeftSideWall(wood));
    root.add(_buildRightSideWall(wood));
    root.add(_buildBottomWall(wood));
    root.add(_buildRightDoor(wood));

    return HalloweenCoffinCutSheet(root: root);
  }

  /// Hexagonal coffin floor panel (pure black).
  static Node _buildBase(UnlitMaterial material) {
    return Node(
      name: 'piece_base',
      localTransform: _groundTransform(Vector2(0, 0)),
      mesh: CoffinGeometry.flatPolygonMesh(
        HalloweenCoffinTemplateSpec.baseVerticesIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.pieceThicknessWorld,
      ),
    );
  }

  /// Head wall strip (24" x 12").
  static Node _buildTopWall(UnlitMaterial material) {
    final centerZ =
        -HalloweenCoffinTemplateSpec.layoutGapIn -
        HalloweenCoffinTemplateSpec.wallDepthIn / 2;
    return Node(
      name: 'piece_top',
      localTransform: _groundTransform(Vector2(0, centerZ)),
      mesh: CoffinGeometry.flatRectangleMesh(
        HalloweenCoffinTemplateSpec.wallLengthIn[TemplatePiece.top]!,
        HalloweenCoffinTemplateSpec.wallDepthIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.pieceThicknessWorld,
      ),
    );
  }

  /// Upper-left shoulder wall strip (18" x 12").
  static Node _buildTopLeftWall(UnlitMaterial material) {
    final slantAngle = math.atan2(
      HalloweenCoffinTemplateSpec.shoulderYIn,
      -HalloweenCoffinTemplateSpec.upperSlantHorizontalIn,
    );
    final center = Vector2(
      -HalloweenCoffinTemplateSpec.shoulderHalfWidthIn -
          HalloweenCoffinTemplateSpec.layoutGapIn -
          HalloweenCoffinTemplateSpec.wallDepthIn / 2,
      HalloweenCoffinTemplateSpec.shoulderYIn / 2,
    );

    return Node(
      name: 'piece_top_left',
      localTransform: _groundTransform(center, angleY: slantAngle),
      mesh: CoffinGeometry.flatRectangleMesh(
        HalloweenCoffinTemplateSpec.wallLengthIn[TemplatePiece.topLeft]!,
        HalloweenCoffinTemplateSpec.wallDepthIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.pieceThicknessWorld,
      ),
    );
  }

  /// Upper-right shoulder wall strip (18" x 12").
  static Node _buildTopRightWall(UnlitMaterial material) {
    final slantAngle = math.atan2(
      HalloweenCoffinTemplateSpec.shoulderYIn,
      HalloweenCoffinTemplateSpec.upperSlantHorizontalIn,
    );
    final center = Vector2(
      HalloweenCoffinTemplateSpec.shoulderHalfWidthIn +
          HalloweenCoffinTemplateSpec.layoutGapIn +
          HalloweenCoffinTemplateSpec.wallDepthIn / 2,
      HalloweenCoffinTemplateSpec.shoulderYIn / 2,
    );

    return Node(
      name: 'piece_top_right',
      localTransform: _groundTransform(center, angleY: slantAngle),
      mesh: CoffinGeometry.flatRectangleMesh(
        HalloweenCoffinTemplateSpec.wallLengthIn[TemplatePiece.topRight]!,
        HalloweenCoffinTemplateSpec.wallDepthIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.pieceThicknessWorld,
      ),
    );
  }

  /// Long left side wall strip (59" x 12").
  static Node _buildLeftSideWall(UnlitMaterial material) {
    final center = Vector2(
      -HalloweenCoffinTemplateSpec.shoulderHalfWidthIn -
          HalloweenCoffinTemplateSpec.layoutGapIn -
          HalloweenCoffinTemplateSpec.wallDepthIn / 2,
      HalloweenCoffinTemplateSpec.shoulderYIn +
          HalloweenCoffinTemplateSpec.lowerSlantIn / 2,
    );

    return Node(
      name: 'piece_left_side',
      localTransform: _groundTransform(center),
      mesh: CoffinGeometry.flatRectangleMesh(
        HalloweenCoffinTemplateSpec.wallDepthIn,
        HalloweenCoffinTemplateSpec.wallLengthIn[TemplatePiece.leftSide]!,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.pieceThicknessWorld,
      ),
    );
  }

  /// Long right side wall strip (59" x 12").
  static Node _buildRightSideWall(UnlitMaterial material) {
    final center = Vector2(
      HalloweenCoffinTemplateSpec.shoulderHalfWidthIn +
          HalloweenCoffinTemplateSpec.layoutGapIn +
          HalloweenCoffinTemplateSpec.wallDepthIn / 2,
      HalloweenCoffinTemplateSpec.shoulderYIn +
          HalloweenCoffinTemplateSpec.lowerSlantIn / 2,
    );

    return Node(
      name: 'piece_right_side',
      localTransform: _groundTransform(center),
      mesh: CoffinGeometry.flatRectangleMesh(
        HalloweenCoffinTemplateSpec.wallDepthIn,
        HalloweenCoffinTemplateSpec.wallLengthIn[TemplatePiece.rightSide]!,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.pieceThicknessWorld,
      ),
    );
  }

  /// Foot wall strip (17" x 12").
  static Node _buildBottomWall(UnlitMaterial material) {
    final centerZ =
        HalloweenCoffinTemplateSpec.baseHeightIn +
        HalloweenCoffinTemplateSpec.layoutGapIn +
        HalloweenCoffinTemplateSpec.wallDepthIn / 2;

    return Node(
      name: 'piece_bottom',
      localTransform: _groundTransform(Vector2(0, centerZ)),
      mesh: CoffinGeometry.flatRectangleMesh(
        HalloweenCoffinTemplateSpec.wallLengthIn[TemplatePiece.bottom]!,
        HalloweenCoffinTemplateSpec.wallDepthIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.pieceThicknessWorld,
      ),
    );
  }

  /// Left lid half — full height split at the vertical center seam.
  static Node _buildLeftDoor(UnlitMaterial material) {
    return Node(
      name: 'piece_left_door',
      localTransform: _groundTransform(
        HalloweenCoffinTemplateSpec.leftDoorAnchorIn,
      ),
      mesh: CoffinGeometry.flatPolygonMesh(
        HalloweenCoffinTemplateSpec.leftDoorVerticesIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.pieceThicknessWorld,
      ),
    );
  }

  /// Right lid half — full height split at the vertical center seam.
  static Node _buildRightDoor(UnlitMaterial material) {
    return Node(
      name: 'piece_right_door',
      localTransform: _groundTransform(
        HalloweenCoffinTemplateSpec.rightDoorAnchorIn,
      ),
      mesh: CoffinGeometry.flatPolygonMesh(
        HalloweenCoffinTemplateSpec.rightDoorVerticesIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.pieceThicknessWorld,
      ),
    );
  }

  /// Places a piece on the ground at a template-space anchor.
  static Matrix4 _groundTransform(Vector2 templateIn, {double angleY = 0}) {
    final world = HalloweenCoffinTemplateSpec.templateInToWorld(
      templateIn,
      yWorld: HalloweenCoffinTemplateSpec.pieceHalfThicknessWorld,
    );
    final transform = Matrix4.translation(world);
    if (angleY != 0) {
      transform.rotateY(angleY);
    }
    return transform;
  }
}
