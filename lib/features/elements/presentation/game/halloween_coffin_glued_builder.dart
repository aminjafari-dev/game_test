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
///   upright: true,
/// );
/// world.add(glued.root);
/// ```
class HalloweenCoffinGlued {
  HalloweenCoffinGlued({
    required this.root,
    required this.leftHingeNode,
    required this.rightHingeNode,
    required this.leftHingePosition,
    required this.rightHingePosition,
    required this.openAngle,
  });

  /// Scene-graph parent that contains every glued piece of the coffin.
  final Node root;
  final Node leftHingeNode;
  final Node rightHingeNode;
  final Vector3 leftHingePosition;
  final Vector3 rightHingePosition;
  final double openAngle;

  static const double _animationSpeed = 3.5;
  static const double _angleEpsilon = 0.01;

  double _currentAngle = 0;
  double _targetAngle = 0;

  bool get isOpen => _targetAngle > 0;
  bool get isFullyOpen => (_currentAngle - openAngle).abs() < _angleEpsilon;
  bool get isFullyClosed => _currentAngle.abs() < _angleEpsilon;

  void setOpen(bool open) {
    _targetAngle = open ? openAngle : 0;
  }

  void toggle() => setOpen(!isOpen);

  bool get isAnimating =>
      (_currentAngle - _targetAngle).abs() >= _angleEpsilon;

  bool containsNode(Node node) {
    Node? current = node;
    while (current != null) {
      if (current == root) return true;
      current = current.parent;
    }
    return false;
  }

  void tick(double dt) {
    if ((_currentAngle - _targetAngle).abs() < _angleEpsilon) {
      _currentAngle = _targetAngle;
    } else {
      final step = _animationSpeed * dt;
      if (_currentAngle < _targetAngle) {
        _currentAngle = math.min(_currentAngle + step, _targetAngle);
      } else {
        _currentAngle = math.max(_currentAngle - step, _targetAngle);
      }
    }

    leftHingeNode.localTransform = Matrix4.translation(leftHingePosition)
      ..rotateZ(_currentAngle);

    rightHingeNode.localTransform = Matrix4.translation(rightHingePosition)
      ..rotateZ(-_currentAngle);
  }
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
/// // Standing upright in the middle of the Elements workshop:
/// final glued = HalloweenCoffinGluedBuilder.build(
///   material: woodMaterial,
///   baseMaterial: HorrorMaterials.coffinBaseBlack(),
///   offset: Vector3.zero(),
///   upright: true,
/// );
/// world.add(glued.root);
/// ```
class HalloweenCoffinGluedBuilder {
  HalloweenCoffinGluedBuilder._();

  /// How far each lid half swings open (radians), matching [CoffinProp].
  static const double _openAngle = 2;

  /// Builds the assembled coffin from the shared template pieces.
  ///
  /// [material] paints the walls, base, and lid (defaults to coffin wood).
  /// [baseMaterial] paints only the hexagonal floor panel (defaults to black).
  /// [offset] positions the whole prop in world space (defaults to the origin so
  /// it sits in the middle of the Elements ground plane).
  /// [upright] when true, stands the coffin on its foot with the head pointing
  /// up — useful for a centerpiece preview instead of the burial pose.
  static HalloweenCoffinGlued build({
    UnlitMaterial? material,
    UnlitMaterial? baseMaterial,
    Vector3? offset,
    bool upright = false,
  }) {
    final wood = material ?? HorrorMaterials.coffinWood();
    final base = baseMaterial ?? HorrorMaterials.coffinBaseBlack();
    final root = Node(name: 'halloween_coffin_glued');

    // Place the prop at the requested world offset (middle of the area by
    // default). When [upright] is set, tip it onto its foot so the long axis
    // runs vertically instead of lying flat on the ground.
    final worldOffset = offset ?? Vector3.zero();
    root.localTransform = _rootTransform(
      offset: worldOffset,
      upright: upright,
    );

    // 1) The hexagonal floor sits flat on the ground, exactly like the cut-sheet
    //    base piece (same vertices, same thickness, same material).
    root.add(_buildBase(base));

    // 2) Each of the six wall strips folds up along its matching base edge. We
    //    walk the hexagon edges in order so every wall lands on the right side.
    final edges = _wallEdges();
    for (final edge in edges) {
      root.add(_buildStandingWall(edge, wood));
    }

    // 3) The two lid halves hinge on the outer head edges and swing open on tap,
    //    exactly like the procedural [CoffinProp] in the center of the scene.
    final scale = HalloweenCoffinTemplateSpec.inchesToWorld;
    final wallDepthWorld = HalloweenCoffinTemplateSpec.wallDepthIn * scale;
    final lidY = wallDepthWorld +
        HalloweenCoffinTemplateSpec.pieceHalfThicknessWorld;
    final headHalfWidthWorld =
        HalloweenCoffinTemplateSpec.topHalfWidthIn * scale;

    final leftHingePosition = Vector3(-headHalfWidthWorld, lidY, 0);
    final rightHingePosition = Vector3(headHalfWidthWorld, lidY, 0);

    final leftHingeNode = Node(name: 'glued_hinge_left');
    leftHingeNode.localTransform = Matrix4.translation(leftHingePosition);
    root.add(leftHingeNode);
    leftHingeNode.add(_buildLeftDoor(wood, headHalfWidthWorld));

    final rightHingeNode = Node(name: 'glued_hinge_right');
    rightHingeNode.localTransform = Matrix4.translation(rightHingePosition);
    root.add(rightHingeNode);
    rightHingeNode.add(_buildRightDoor(wood, headHalfWidthWorld));

    return HalloweenCoffinGlued(
      root: root,
      leftHingeNode: leftHingeNode,
      rightHingeNode: rightHingeNode,
      leftHingePosition: leftHingePosition,
      rightHingePosition: rightHingePosition,
      openAngle: _openAngle,
    );
  }

  /// Builds the root-node transform for [offset] and optional upright pose.
  ///
  /// Lying pose (default): only translate by [offset] so the hexagonal base
  /// rests on the ground. Upright pose: rotate +90° around X so the foot edge
  /// becomes the contact with the ground and the head points skyward, then
  /// lift by the coffin length so the foot sits at y = 0 instead of sinking
  /// underground.
  ///
  /// Example — centerpiece standing in the Elements workshop:
  /// ```dart
  /// _rootTransform(offset: Vector3.zero(), upright: true);
  /// ```
  static Matrix4 _rootTransform({
    required Vector3 offset,
    required bool upright,
  }) {
    if (!upright) {
      return Matrix4.translation(offset);
    }

    // Template length along local Z becomes world height after rotateX(π/2).
    final lengthWorld = HalloweenCoffinTemplateSpec.baseHeightIn *
        HalloweenCoffinTemplateSpec.inchesToWorld;

    // rotateX(π/2) maps local (x, y, z) → (x, −z, y). The foot at z = length
    // would land at y = −length, so we lift by lengthWorld first via the
    // translation that multiplies after the rotation.
    return Matrix4.translation(offset + Vector3(0, lengthWorld, 0))
      ..rotateX(math.pi / 2);
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

  /// Builds the left lid half, offset from its hinge so the outer head edge
  /// sits on the hinge pivot (same layout trick as [CoffinBuilder._buildLeftLid]).
  static Node _buildLeftDoor(UnlitMaterial material, double headHalfWidthWorld) {
    final scale = HalloweenCoffinTemplateSpec.inchesToWorld;
    final thicknessWorld = HalloweenCoffinTemplateSpec.pieceThicknessWorld;

    return Node(
      name: 'glued_left_door',
      // Shift the mesh so x = -headHalfWidth (outer edge) aligns with the hinge.
      localTransform: Matrix4.translation(Vector3(headHalfWidthWorld, 0, 0)),
      mesh: CoffinGeometry.flatPolygonMesh(
        HalloweenCoffinTemplateSpec.leftDoorVerticesIn,
        material,
        unitToWorld: scale,
        thicknessWorld: thicknessWorld,
      ),
    );
  }

  /// Builds the right lid half, mirrored from [_buildLeftDoor].
  static Node _buildRightDoor(
    UnlitMaterial material,
    double headHalfWidthWorld,
  ) {
    final scale = HalloweenCoffinTemplateSpec.inchesToWorld;
    final thicknessWorld = HalloweenCoffinTemplateSpec.pieceThicknessWorld;

    return Node(
      name: 'glued_right_door',
      localTransform: Matrix4.translation(Vector3(-headHalfWidthWorld, 0, 0)),
      mesh: CoffinGeometry.flatPolygonMesh(
        HalloweenCoffinTemplateSpec.rightDoorVerticesIn,
        material,
        unitToWorld: scale,
        thicknessWorld: thicknessWorld,
      ),
    );
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
