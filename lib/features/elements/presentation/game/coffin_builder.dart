import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:game_test/features/elements/presentation/game/coffin_geometry.dart';
import 'package:game_test/features/horror_survival/presentation/game/materials/horror_materials.dart';
import 'package:vector_math/vector_math.dart';

/// Procedural Halloween coffin with fixed side walls and split upper lids.
///
/// The side walls stay fixed; only the left and right lid halves swing open
/// from the outer edges when toggled.
///
/// Example:
/// ```dart
/// final coffin = CoffinBuilder.build(
///   woodMaterial: HorrorMaterials.coffinTextured(texture),
///   texturedWood: true,
/// );
/// ```
class CoffinBuilder {
  CoffinBuilder._();

  static const double _length = 2.0;
  static const double _headHalfWidth = 0.36;
  static const double _footHalfWidth = 0.24;
  static const double _bodyHeight = 0.41;
  static const double _wallThickness = 0.04;
  static const double _lidThickness = 0.06;
  static const double _halfLength = _length / 2;
  static const double _openAngle = 1.35;

  /// Pulls the lid halves inward so they sit flush with the side wall panels.
  static const double _lidInwardInset = 0.06;

  /// Lowers the lid slightly so the top does not sit above the wall line.
  static const double _lidDownInset = 0.015;

  /// Creates a fully assembled [CoffinProp] ready to add to a scene.
  static CoffinProp build({
    UnlitMaterial? woodMaterial,
    UnlitMaterial? lidMaterial,
    UnlitMaterial? metalMaterial,
    bool texturedWood = false,
  }) {
    final wood = woodMaterial ?? HorrorMaterials.coffinWood();
    final lid = lidMaterial ?? wood;
    final metal = metalMaterial ?? HorrorMaterials.coffinMetal();

    final root = Node(name: 'coffin_root');
    final bodyGroup = Node(name: 'coffin_body');
    root.add(bodyGroup);

    _buildBody(bodyGroup, wood: wood, metal: metal, texturedWood: texturedWood);

    final doorCenterY = _bodyHeight / 2 + _wallThickness + _lidThickness / 2;
    final leftHingePosition = Vector3(-_headHalfWidth, doorCenterY, 0);
    final rightHingePosition = Vector3(_headHalfWidth, doorCenterY, 0);

    final leftHingeNode = Node(name: 'coffin_hinge_left');
    leftHingeNode.localTransform = Matrix4.translation(leftHingePosition);
    root.add(leftHingeNode);
    leftHingeNode.add(_buildLeftLid(
      lid: lid,
      metal: metal,
      texturedWood: texturedWood,
    ));

    final rightHingeNode = Node(name: 'coffin_hinge_right');
    rightHingeNode.localTransform = Matrix4.translation(rightHingePosition);
    root.add(rightHingeNode);
    rightHingeNode.add(_buildRightLid(
      lid: lid,
      metal: metal,
      texturedWood: texturedWood,
    ));

    return CoffinProp(
      root: root,
      leftHingeNode: leftHingeNode,
      rightHingeNode: rightHingeNode,
      leftHingePosition: leftHingePosition,
      rightHingePosition: rightHingePosition,
      openAngle: _openAngle,
    );
  }

  static void _buildBody(
    Node bodyGroup, {
    required UnlitMaterial wood,
    required UnlitMaterial metal,
    required bool texturedWood,
  }) {
    final wallCenterY = _bodyHeight / 2 + _wallThickness;

    bodyGroup.add(
      Node(
        name: 'coffin_bottom',
        localTransform: Matrix4.translation(Vector3(0, _wallThickness / 2, 0)),
        mesh: _cuboidMesh(
          Vector3(_headHalfWidth + _footHalfWidth, _wallThickness, _length),
          wood,
          texturedWood: texturedWood,
        ),
      ),
    );

    _addWall(
      bodyGroup,
      name: 'head_wall',
      size: Vector3(_headHalfWidth * 2, _bodyHeight, _wallThickness),
      position: Vector3(0, wallCenterY, -_halfLength + _wallThickness / 2),
      material: wood,
      texturedWood: texturedWood,
    );
    _addWall(
      bodyGroup,
      name: 'foot_wall',
      size: Vector3(_footHalfWidth * 2, _bodyHeight, _wallThickness),
      position: Vector3(0, wallCenterY, _halfLength - _wallThickness / 2),
      material: wood,
      texturedWood: texturedWood,
    );

    _addWall(
      bodyGroup,
      name: 'left_head_wall',
      size: Vector3(_wallThickness, _bodyHeight, _halfLength),
      position: Vector3(
        -_headHalfWidth / 2 - _wallThickness / 2,
        wallCenterY,
        -_halfLength / 2,
      ),
      material: wood,
      texturedWood: texturedWood,
    );
    _addWall(
      bodyGroup,
      name: 'left_foot_wall',
      size: Vector3(_wallThickness, _bodyHeight, _halfLength),
      position: Vector3(
        -_footHalfWidth / 2 - _wallThickness / 2,
        wallCenterY,
        _halfLength / 2,
      ),
      material: wood,
      texturedWood: texturedWood,
    );
    _addWall(
      bodyGroup,
      name: 'right_head_wall',
      size: Vector3(_wallThickness, _bodyHeight, _halfLength),
      position: Vector3(
        _headHalfWidth / 2 + _wallThickness / 2,
        wallCenterY,
        -_halfLength / 2,
      ),
      material: wood,
      texturedWood: texturedWood,
    );
    _addWall(
      bodyGroup,
      name: 'right_foot_wall',
      size: Vector3(_wallThickness, _bodyHeight, _halfLength),
      position: Vector3(
        _footHalfWidth / 2 + _wallThickness / 2,
        wallCenterY,
        _halfLength / 2,
      ),
      material: wood,
      texturedWood: texturedWood,
    );

    bodyGroup.add(
      Node(
        name: 'left_handle',
        localTransform: Matrix4.translation(
          Vector3(-_headHalfWidth - 0.02, wallCenterY, 0),
        ),
        mesh: Mesh(CuboidGeometry(Vector3(0.06, 0.08, 0.25)), metal),
      ),
    );
    bodyGroup.add(
      Node(
        name: 'right_handle',
        localTransform: Matrix4.translation(
          Vector3(_headHalfWidth + 0.02, wallCenterY, 0),
        ),
        mesh: Mesh(CuboidGeometry(Vector3(0.06, 0.08, 0.25)), metal),
      ),
    );
  }

  static Node _buildLeftLid({
    required UnlitMaterial lid,
    required UnlitMaterial metal,
    required bool texturedWood,
  }) {
    final lidGroup = Node(name: 'coffin_lid_left');

    final lidHalfWidth = (_headHalfWidth + _footHalfWidth) / 2;
    final lidCenterX = lidHalfWidth / 2 + _lidInwardInset;
    final lidCenterY = _lidThickness / 2 - _lidDownInset;
    lidGroup.add(
      Node(
        name: 'left_lid_half',
        localTransform: Matrix4.translation(Vector3(lidCenterX, lidCenterY, 0)),
        mesh: texturedWood
            ? CoffinGeometry.cuboidMesh(
                Vector3(lidHalfWidth, _lidThickness, _length),
                lid,
                uMin: 0,
                uMax: 0.5,
                uvFaceIndex: CoffinGeometry.topFaceIndex,
              )
            : Mesh(CuboidGeometry(Vector3(lidHalfWidth, _lidThickness, _length)), lid),
      ),
    );

    lidGroup.add(
      Node(
        name: 'left_cross_vertical',
        localTransform: Matrix4.translation(
          Vector3(lidCenterX * 0.92, lidCenterY + 0.01, 0),
        ),
        mesh: Mesh(CuboidGeometry(Vector3(0.03, 0.02, _length * 0.65)), metal),
      ),
    );

    return lidGroup;
  }

  static Node _buildRightLid({
    required UnlitMaterial lid,
    required UnlitMaterial metal,
    required bool texturedWood,
  }) {
    final lidGroup = Node(name: 'coffin_lid_right');

    final lidHalfWidth = (_headHalfWidth + _footHalfWidth) / 2;
    final lidCenterX = -lidHalfWidth / 2 - _lidInwardInset;
    final lidCenterY = _lidThickness / 2 - _lidDownInset;
    lidGroup.add(
      Node(
        name: 'right_lid_half',
        localTransform: Matrix4.translation(Vector3(lidCenterX, lidCenterY, 0)),
        mesh: texturedWood
            ? CoffinGeometry.cuboidMesh(
                Vector3(lidHalfWidth, _lidThickness, _length),
                lid,
                uMin: 0.5,
                uMax: 1,
                uvFaceIndex: CoffinGeometry.topFaceIndex,
              )
            : Mesh(CuboidGeometry(Vector3(lidHalfWidth, _lidThickness, _length)), lid),
      ),
    );

    lidGroup.add(
      Node(
        name: 'right_cross_vertical',
        localTransform: Matrix4.translation(
          Vector3(lidCenterX * 0.92, lidCenterY + 0.01, 0),
        ),
        mesh: Mesh(CuboidGeometry(Vector3(0.03, 0.02, _length * 0.65)), metal),
      ),
    );

    return lidGroup;
  }

  static Mesh _cuboidMesh(
    Vector3 size,
    UnlitMaterial material, {
    required bool texturedWood,
  }) {
    if (texturedWood) {
      return CoffinGeometry.cuboidMesh(size, material);
    }
    return Mesh(CuboidGeometry(size), material);
  }

  static void _addWall(
    Node parent, {
    required String name,
    required Vector3 size,
    required Vector3 position,
    required UnlitMaterial material,
    required bool texturedWood,
  }) {
    parent.add(
      Node(
        name: name,
        localTransform: Matrix4.translation(position),
        mesh: _cuboidMesh(size, material, texturedWood: texturedWood),
      ),
    );
  }
}

/// Runtime state for a [CoffinBuilder] prop — animates both upper lids together.
class CoffinProp {
  CoffinProp({
    required this.root,
    required this.leftHingeNode,
    required this.rightHingeNode,
    required this.leftHingePosition,
    required this.rightHingePosition,
    required this.openAngle,
  });

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
