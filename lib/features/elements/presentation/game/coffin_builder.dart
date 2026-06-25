import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:game_test/features/horror_survival/presentation/game/materials/horror_materials.dart';
import 'package:vector_math/vector_math.dart';

/// Procedural Halloween coffin prop with a hinged lid.
///
/// Builds a tapered coffin from [CuboidGeometry] blocks and exposes
/// [CoffinProp] for open/close animation. Use in the Elements workshop
/// preview or later in the horror game world.
///
/// Example:
/// ```dart
/// final coffin = CoffinBuilder.build();
/// scene.add(coffin.root);
/// coffin.setOpen(true);
/// coffin.tick(dt);
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
  static const double _openAngle = 1.13;

  /// Creates a fully assembled [CoffinProp] ready to add to a scene.
  static CoffinProp build() {
    final root = Node(name: 'coffin_root');
    final bodyGroup = Node(name: 'coffin_body');
    root.add(bodyGroup);

    _buildBody(bodyGroup);

    final hingeY = _bodyHeight + _lidThickness / 2;
    final hingePosition = Vector3(0, hingeY, -_halfLength);

    final hingeNode = Node(name: 'coffin_hinge');
    hingeNode.localTransform = Matrix4.translation(hingePosition);
    root.add(hingeNode);

    final lidOffset = Vector3(0, 0, _halfLength);
    final lidNode = _buildLid(lidOffset);
    hingeNode.add(lidNode);

    return CoffinProp(
      root: root,
      hingeNode: hingeNode,
      hingePosition: hingePosition,
      openAngle: _openAngle,
    );
  }

  static void _buildBody(Node bodyGroup) {
    final wood = HorrorMaterials.coffinWood();
    final metal = HorrorMaterials.coffinMetal();

    bodyGroup.add(
      Node(
        name: 'coffin_bottom',
        localTransform: Matrix4.translation(Vector3(0, _wallThickness / 2, 0)),
        mesh: Mesh(
          CuboidGeometry(Vector3(
            (_headHalfWidth + _footHalfWidth),
            _wallThickness,
            _length,
          )),
          wood,
        ),
      ),
    );

    _addWall(
      bodyGroup,
      name: 'head_wall',
      size: Vector3(_headHalfWidth * 2, _bodyHeight, _wallThickness),
      position: Vector3(0, _bodyHeight / 2 + _wallThickness, -_halfLength + _wallThickness / 2),
      material: wood,
    );
    _addWall(
      bodyGroup,
      name: 'foot_wall',
      size: Vector3(_footHalfWidth * 2, _bodyHeight, _wallThickness),
      position: Vector3(0, _bodyHeight / 2 + _wallThickness, _halfLength - _wallThickness / 2),
      material: wood,
    );

    _addWall(
      bodyGroup,
      name: 'left_head_wall',
      size: Vector3(_wallThickness, _bodyHeight, _halfLength),
      position: Vector3(
        -_headHalfWidth + _wallThickness / 2,
        _bodyHeight / 2 + _wallThickness,
        -_halfLength / 2,
      ),
      material: wood,
    );
    _addWall(
      bodyGroup,
      name: 'left_foot_wall',
      size: Vector3(_wallThickness, _bodyHeight, _halfLength),
      position: Vector3(
        -_footHalfWidth + _wallThickness / 2,
        _bodyHeight / 2 + _wallThickness,
        _halfLength / 2,
      ),
      material: wood,
    );
    _addWall(
      bodyGroup,
      name: 'right_head_wall',
      size: Vector3(_wallThickness, _bodyHeight, _halfLength),
      position: Vector3(
        _headHalfWidth - _wallThickness / 2,
        _bodyHeight / 2 + _wallThickness,
        -_halfLength / 2,
      ),
      material: wood,
    );
    _addWall(
      bodyGroup,
      name: 'right_foot_wall',
      size: Vector3(_wallThickness, _bodyHeight, _halfLength),
      position: Vector3(
        _footHalfWidth - _wallThickness / 2,
        _bodyHeight / 2 + _wallThickness,
        _halfLength / 2,
      ),
      material: wood,
    );

    _addHandle(bodyGroup, x: -_headHalfWidth - 0.02, material: metal);
    _addHandle(bodyGroup, x: _headHalfWidth + 0.02, material: metal);
  }

  static void _addWall(
    Node parent, {
    required String name,
    required Vector3 size,
    required Vector3 position,
    required UnlitMaterial material,
  }) {
    parent.add(
      Node(
        name: name,
        localTransform: Matrix4.translation(position),
        mesh: Mesh(CuboidGeometry(size), material),
      ),
    );
  }

  static void _addHandle(Node parent, {required double x, required UnlitMaterial material}) {
    parent.add(
      Node(
        name: x < 0 ? 'handle_left' : 'handle_right',
        localTransform: Matrix4.translation(Vector3(x, _bodyHeight / 2 + _wallThickness, 0)),
        mesh: Mesh(
          CuboidGeometry(Vector3(0.06, 0.08, 0.25)),
          material,
        ),
      ),
    );
  }

  static Node _buildLid(Vector3 localOffset) {
    final lidMaterial = HorrorMaterials.coffinLid();
    final metal = HorrorMaterials.coffinMetal();
    final lidGroup = Node(
      name: 'coffin_lid',
      localTransform: Matrix4.translation(localOffset),
    );

    final avgHalfWidth = (_headHalfWidth + _footHalfWidth) / 2;
    lidGroup.add(
      Node(
        name: 'lid_panel',
        mesh: Mesh(
          CuboidGeometry(Vector3(avgHalfWidth * 2, _lidThickness, _length)),
          lidMaterial,
        ),
      ),
    );

    lidGroup.add(
      Node(
        name: 'lid_cross_vertical',
        localTransform: Matrix4.translation(Vector3(0, _lidThickness / 2 + 0.01, 0)),
        mesh: Mesh(
          CuboidGeometry(Vector3(0.04, 0.02, _length * 0.7)),
          metal,
        ),
      ),
    );
    lidGroup.add(
      Node(
        name: 'lid_cross_horizontal',
        localTransform: Matrix4.translation(Vector3(0, _lidThickness / 2 + 0.01, 0)),
        mesh: Mesh(
          CuboidGeometry(Vector3(avgHalfWidth * 1.2, 0.02, 0.04)),
          metal,
        ),
      ),
    );

    return lidGroup;
  }
}

/// Runtime state for a [CoffinBuilder] prop — tracks lid angle and animates it.
class CoffinProp {
  CoffinProp({
    required this.root,
    required this.hingeNode,
    required this.hingePosition,
    required this.openAngle,
  });

  final Node root;
  final Node hingeNode;
  final Vector3 hingePosition;
  final double openAngle;

  static const double _animationSpeed = 3.5;
  static const double _angleEpsilon = 0.01;

  double _currentAngle = 0;
  double _targetAngle = 0;

  /// Whether the lid target state is open (may still be animating).
  bool get isOpen => _targetAngle > 0;

  /// Whether the lid has finished moving to its target angle.
  bool get isFullyOpen => (_currentAngle - openAngle).abs() < _angleEpsilon;
  bool get isFullyClosed => _currentAngle.abs() < _angleEpsilon;

  /// Sets the desired lid state; animation runs in [tick].
  void setOpen(bool open) {
    _targetAngle = open ? openAngle : 0;
  }

  /// Flips between open and closed target states.
  void toggle() => setOpen(!isOpen);

  /// Advances lid animation by [dt] seconds and updates the hinge transform.
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

    hingeNode.localTransform = Matrix4.translation(hingePosition)
      ..rotateX(_currentAngle);
  }
}
