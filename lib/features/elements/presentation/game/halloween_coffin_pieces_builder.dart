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

/// Fully assembled Halloween coffin built from the template cut-sheet pieces.
class HalloweenCoffinAssembly {
  HalloweenCoffinAssembly({required this.root});

  final Node root;
}

/// Builds each Halloween coffin template piece separately and lays them flat
/// on the ground in a cut-sheet arrangement, or folds them into a 3D prop.
///
/// Use [buildFlatCutSheet] beside [buildAssembled] and the legacy [CoffinBuilder]
/// prop to compare flat pieces vs glued-together geometry.
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

  /// Folds the same template pieces into a standing coffin beside the legacy prop.
  ///
  /// Does not move the flat cut sheet — this is a separate root node.
  ///
  /// Example:
  /// ```dart
  /// final assembly = HalloweenCoffinPiecesBuilder.buildAssembled(
  ///   material: HorrorMaterials.coffinTextured(texture),
  /// );
  /// world.add(assembly.root);
  /// ```
  static HalloweenCoffinAssembly buildAssembled({
    UnlitMaterial? material,
    UnlitMaterial? baseMaterial,
    Vector3? offset,
  }) {
    final wood = material ?? HorrorMaterials.coffinWood();
    final base = baseMaterial ?? HorrorMaterials.coffinBaseBlack();
    final root = Node(name: 'halloween_coffin_assembly');

    final scale = HalloweenCoffinTemplateSpec.inchesToWorld;
    final baseHeightWorld = HalloweenCoffinTemplateSpec.baseHeightIn * scale;
    final worldOffset =
        offset ??
        Vector3(
          HalloweenCoffinTemplateSpec.assembledOffsetX,
          0,
          -baseHeightWorld / 2,
        );
    root.localTransform = Matrix4.translation(worldOffset);

    root.add(_buildAssembledBase(base));
    root.add(_buildAssembledTopWall(wood));
    root.add(_buildAssembledTopLeftWall(wood));
    root.add(_buildAssembledTopRightWall(wood));
    root.add(_buildAssembledLeftSideWall(wood));
    root.add(_buildAssembledRightSideWall(wood));
    root.add(_buildAssembledBottomWall(wood));
    root.add(_buildAssembledLeftDoor(wood));
    root.add(_buildAssembledRightDoor(wood));

    return HalloweenCoffinAssembly(root: root);
  }

  /// Hexagonal floor panel lying flat inside the assembled walls.
  static Node _buildAssembledBase(UnlitMaterial material) {
    return Node(
      name: 'assembled_base',
      localTransform: Matrix4.translation(
        Vector3(0, HalloweenCoffinTemplateSpec.panelHalfThicknessWorld, 0),
      ),
      mesh: CoffinGeometry.flatPolygonMesh(
        HalloweenCoffinTemplateSpec.baseVerticesIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.panelThicknessWorld,
      ),
    );
  }

  /// Head wall — hinged on the top edge of the hex base.
  static Node _buildAssembledTopWall(UnlitMaterial material) {
    final verts = HalloweenCoffinTemplateSpec.baseVerticesIn;
    return Node(
      name: 'assembled_top',
      localTransform: _assembledWallTransform(
        edgeStartIn: verts[0],
        edgeEndIn: verts[1],
        lengthAlongX: true,
      ),
      mesh: CoffinGeometry.flatRectangleMesh(
        HalloweenCoffinTemplateSpec.wallLengthIn[TemplatePiece.top]!,
        HalloweenCoffinTemplateSpec.wallDepthIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.panelThicknessWorld,
      ),
    );
  }

  /// Upper-left shoulder wall — hinged on the left head slant edge.
  static Node _buildAssembledTopLeftWall(UnlitMaterial material) {
    final verts = HalloweenCoffinTemplateSpec.baseVerticesIn;
    return Node(
      name: 'assembled_top_left',
      localTransform: _assembledWallTransform(
        edgeStartIn: verts[5],
        edgeEndIn: verts[0],
        lengthAlongX: true,
      ),
      mesh: CoffinGeometry.flatRectangleMesh(
        HalloweenCoffinTemplateSpec.wallLengthIn[TemplatePiece.topLeft]!,
        HalloweenCoffinTemplateSpec.wallDepthIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.panelThicknessWorld,
      ),
    );
  }

  /// Upper-right shoulder wall — hinged on the right head slant edge.
  static Node _buildAssembledTopRightWall(UnlitMaterial material) {
    final verts = HalloweenCoffinTemplateSpec.baseVerticesIn;
    return Node(
      name: 'assembled_top_right',
      localTransform: _assembledWallTransform(
        edgeStartIn: verts[1],
        edgeEndIn: verts[2],
        lengthAlongX: true,
      ),
      mesh: CoffinGeometry.flatRectangleMesh(
        HalloweenCoffinTemplateSpec.wallLengthIn[TemplatePiece.topRight]!,
        HalloweenCoffinTemplateSpec.wallDepthIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.panelThicknessWorld,
      ),
    );
  }

  /// Long left side wall — hinged on the left taper edge.
  static Node _buildAssembledLeftSideWall(UnlitMaterial material) {
    final verts = HalloweenCoffinTemplateSpec.baseVerticesIn;
    return Node(
      name: 'assembled_left_side',
      localTransform: _assembledWallTransform(
        edgeStartIn: verts[4],
        edgeEndIn: verts[5],
        lengthAlongX: false,
      ),
      mesh: CoffinGeometry.flatRectangleMesh(
        HalloweenCoffinTemplateSpec.wallDepthIn,
        HalloweenCoffinTemplateSpec.wallLengthIn[TemplatePiece.leftSide]!,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.panelThicknessWorld,
      ),
    );
  }

  /// Long right side wall — hinged on the right taper edge.
  static Node _buildAssembledRightSideWall(UnlitMaterial material) {
    final verts = HalloweenCoffinTemplateSpec.baseVerticesIn;
    return Node(
      name: 'assembled_right_side',
      localTransform: _assembledWallTransform(
        edgeStartIn: verts[2],
        edgeEndIn: verts[3],
        lengthAlongX: false,
      ),
      mesh: CoffinGeometry.flatRectangleMesh(
        HalloweenCoffinTemplateSpec.wallDepthIn,
        HalloweenCoffinTemplateSpec.wallLengthIn[TemplatePiece.rightSide]!,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.panelThicknessWorld,
      ),
    );
  }

  /// Foot wall — hinged on the bottom edge of the hex base.
  static Node _buildAssembledBottomWall(UnlitMaterial material) {
    final verts = HalloweenCoffinTemplateSpec.baseVerticesIn;
    return Node(
      name: 'assembled_bottom',
      localTransform: _assembledWallTransform(
        edgeStartIn: verts[3],
        edgeEndIn: verts[4],
        lengthAlongX: true,
      ),
      mesh: CoffinGeometry.flatRectangleMesh(
        HalloweenCoffinTemplateSpec.wallLengthIn[TemplatePiece.bottom]!,
        HalloweenCoffinTemplateSpec.wallDepthIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.panelThicknessWorld,
      ),
    );
  }

  /// Left lid half resting on top of the standing walls.
  static Node _buildAssembledLeftDoor(UnlitMaterial material) {
    final wallTopY =
        HalloweenCoffinTemplateSpec.wallDepthIn *
        HalloweenCoffinTemplateSpec.inchesToWorld;
    return Node(
      name: 'assembled_left_door',
      localTransform: Matrix4.translation(
        Vector3(
          0,
          wallTopY + HalloweenCoffinTemplateSpec.lidHalfThicknessWorld,
          0,
        ),
      ),
      mesh: CoffinGeometry.flatPolygonMesh(
        HalloweenCoffinTemplateSpec.leftDoorVerticesIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.lidThicknessWorld,
      ),
    );
  }

  /// Right lid half resting on top of the standing walls.
  static Node _buildAssembledRightDoor(UnlitMaterial material) {
    final wallTopY =
        HalloweenCoffinTemplateSpec.wallDepthIn *
        HalloweenCoffinTemplateSpec.inchesToWorld;
    return Node(
      name: 'assembled_right_door',
      localTransform: Matrix4.translation(
        Vector3(
          0,
          wallTopY + HalloweenCoffinTemplateSpec.lidHalfThicknessWorld,
          0,
        ),
      ),
      mesh: CoffinGeometry.flatPolygonMesh(
        HalloweenCoffinTemplateSpec.rightDoorVerticesIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.lidThicknessWorld,
      ),
    );
  }

  /// Stands a flat wall strip upright along a hex-base perimeter edge.
  ///
  /// [lengthAlongX] is true when the strip's long edge runs along local X in the
  /// flat mesh (head, foot, shoulders); false for long sides (59" along local Z).
  static Matrix4 _assembledWallTransform({
    required Vector2 edgeStartIn,
    required Vector2 edgeEndIn,
    required bool lengthAlongX,
  }) {
    final scale = HalloweenCoffinTemplateSpec.inchesToWorld;
    final wallDepthWorld = HalloweenCoffinTemplateSpec.wallDepthIn * scale;
    final halfThick = HalloweenCoffinTemplateSpec.panelHalfThicknessWorld;
    final interiorIn = Vector2(0, HalloweenCoffinTemplateSpec.baseHeightIn / 2);

    final startWorld = Vector3(edgeStartIn.x * scale, 0, edgeStartIn.y * scale);
    final endWorld = Vector3(edgeEndIn.x * scale, 0, edgeEndIn.y * scale);
    final edgeWorld = endWorld - startWorld;
    final edgeLength = edgeWorld.length;
    if (edgeLength == 0) {
      return Matrix4.identity();
    }

    final edgeDir = edgeWorld / edgeLength;
    var outward = Vector3(-edgeDir.z, 0, edgeDir.x);
    final midWorld = (startWorld + endWorld) * 0.5;
    final interiorWorld = Vector3(
      interiorIn.x * scale,
      0,
      interiorIn.y * scale,
    );
    final toInterior = interiorWorld - midWorld;
    if (outward.dot(toInterior) > 0) {
      outward = -outward;
    }

    final edgeAngle = math.atan2(edgeDir.z, edgeDir.x);

    final transform = Matrix4.identity();
    transform.translateByVector3(midWorld + outward * halfThick);
    transform.rotateY(edgeAngle);
    if (lengthAlongX) {
      // Head, foot, and shoulder strips: 12" depth along local Z folds upward.
      transform.rotateX(-math.pi / 2);
      transform.translateByVector3(
        Vector3(0, wallDepthWorld / 2, -wallDepthWorld / 2),
      );
    } else {
      // Long side strips: 59" runs horizontally along the edge; 12" depth folds up.
      transform.translateByVector3(
        Vector3(wallDepthWorld / 2, halfThick, 0),
      );
      transform.rotateZ(math.pi / 2);
    }

    return transform;
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
        thicknessWorld: HalloweenCoffinTemplateSpec.panelThicknessWorld,
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
        thicknessWorld: HalloweenCoffinTemplateSpec.panelThicknessWorld,
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
        thicknessWorld: HalloweenCoffinTemplateSpec.panelThicknessWorld,
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
        thicknessWorld: HalloweenCoffinTemplateSpec.panelThicknessWorld,
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
        thicknessWorld: HalloweenCoffinTemplateSpec.panelThicknessWorld,
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
        thicknessWorld: HalloweenCoffinTemplateSpec.panelThicknessWorld,
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
        thicknessWorld: HalloweenCoffinTemplateSpec.panelThicknessWorld,
      ),
    );
  }

  /// Left lid half — full height split at the vertical center seam.
  static Node _buildLeftDoor(UnlitMaterial material) {
    return Node(
      name: 'piece_left_door',
      localTransform: _groundTransform(
        HalloweenCoffinTemplateSpec.leftDoorAnchorIn,
        halfThicknessWorld: HalloweenCoffinTemplateSpec.lidHalfThicknessWorld,
      ),
      mesh: CoffinGeometry.flatPolygonMesh(
        HalloweenCoffinTemplateSpec.leftDoorVerticesIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.lidThicknessWorld,
      ),
    );
  }

  /// Right lid half — full height split at the vertical center seam.
  static Node _buildRightDoor(UnlitMaterial material) {
    return Node(
      name: 'piece_right_door',
      localTransform: _groundTransform(
        HalloweenCoffinTemplateSpec.rightDoorAnchorIn,
        halfThicknessWorld: HalloweenCoffinTemplateSpec.lidHalfThicknessWorld,
      ),
      mesh: CoffinGeometry.flatPolygonMesh(
        HalloweenCoffinTemplateSpec.rightDoorVerticesIn,
        material,
        unitToWorld: HalloweenCoffinTemplateSpec.inchesToWorld,
        thicknessWorld: HalloweenCoffinTemplateSpec.lidThicknessWorld,
      ),
    );
  }

  /// Places a piece on the ground at a template-space anchor.
  static Matrix4 _groundTransform(
    Vector2 templateIn, {
    double angleY = 0,
    double? halfThicknessWorld,
  }) {
    final world = HalloweenCoffinTemplateSpec.templateInToWorld(
      templateIn,
      yWorld:
          halfThicknessWorld ??
          HalloweenCoffinTemplateSpec.panelHalfThicknessWorld,
    );
    final transform = Matrix4.translation(world);
    if (angleY != 0) {
      transform.rotateY(angleY);
    }
    return transform;
  }
}
