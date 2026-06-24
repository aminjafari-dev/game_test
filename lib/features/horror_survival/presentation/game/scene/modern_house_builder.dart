import 'package:flutter_scene/scene.dart';
import 'package:game_test/features/horror_survival/presentation/game/materials/horror_materials.dart';
import 'package:game_test/features/horror_survival/presentation/game/systems/door_system.dart';
import 'package:vector_math/vector_math.dart';

/// Builds the Minecraft-style modern villa from the reference screenshot.
///
/// Produces blocky geometry: white walls, dark flat roof, oak trim, L-shaped
/// pool, garden plot, exterior stairs, pergola, and terrace planters.
/// Forest trees are placed separately by [TreeForestBuilder].
class ModernHouseBuilder {
  ModernHouseBuilder({required this.doorSystem});

  final DoorSystem doorSystem;

  static const double block = 1.0;
  static const double floorH = 3.0;
  static const double roofH = 0.5;

  /// Root node containing the entire villa structure.
  Node build() {
    final house = Node(name: 'modern_villa');

    _buildGroundFloorWalls(house);
    _buildSecondFloor(house);
    _buildRoof(house);
    _buildPool(house);
    _buildGarden(house);
    _buildExteriorStairs(house);
    _buildPergola(house);
    _buildTerracePlanters(house);

    return house;
  }

  void _buildGroundFloorWalls(Node parent) {
    // Back wall (z = -4).
    _wallRow(parent, -8, 4, -4, 17, floorH, HorrorMaterials.whiteConcrete());
    // Left wall (x = -8).
    _wallRow(parent, -8, 4, -4, 9, floorH, HorrorMaterials.whiteConcrete(), axisZ: true);
    // Right wall (x = 8), partial — pool side open.
    for (var z = -4.0; z <= 0; z += block) {
      _addBlock(parent, Vector3(8.5, floorH / 2, z + 0.5), HorrorMaterials.whiteConcrete());
    }
    // Front wall with entrance gap at center.
    for (var x = -8.0; x <= 8; x += block) {
      if (x > -2 && x < 2) continue;
      _addBlock(parent, Vector3(x + 0.5, floorH / 2, 4.5), HorrorMaterials.whiteConcrete());
    }

    // Interior floor slab (white).
    _addBlock(
      parent,
      Vector3(0, 0.05, 0),
      HorrorMaterials.whiteConcrete(),
      size: Vector3(15, 0.1, 7),
      collider: false,
    );

    // Ground-floor windows.
    for (var x = -6.0; x <= 6; x += 3) {
      _addBlock(parent, Vector3(x, 1.5, 4.35), HorrorMaterials.glass(), collider: false);
      _addBlock(parent, Vector3(x, 1.5, -3.85), HorrorMaterials.glass(), collider: false);
    }

    // Oak trim at base of front facade.
    for (var x = -8.0; x <= 8; x += block) {
      _addBlock(parent, Vector3(x + 0.5, 0.5, 4.6), HorrorMaterials.oakWood(), collider: false);
    }
  }

  void _buildSecondFloor(Node parent) {
    final y = floorH;

    // Perimeter walls.
    _wallRow(parent, -9, 4.5, -5, 19, floorH, HorrorMaterials.whiteConcrete(), baseY: y);
    _wallRow(parent, -9, 4.5, 5, 19, floorH, HorrorMaterials.whiteConcrete(), baseY: y);
    _wallRow(parent, -9, 4.5, -5, 11, floorH, HorrorMaterials.whiteConcrete(), axisZ: true, baseY: y);
    _wallRow(parent, 9, 4.5, -5, 11, floorH, HorrorMaterials.whiteConcrete(), axisZ: true, baseY: y);

    // Second floor slab.
    _addBlock(
      parent,
      Vector3(0, y + 0.05, 0),
      HorrorMaterials.whiteConcrete(),
      size: Vector3(17, 0.1, 9),
      collider: false,
    );

    // Front terrace extending toward camera.
    _addBlock(
      parent,
      Vector3(0, y + 0.15, 6.5),
      HorrorMaterials.oakWood(),
      size: Vector3(14, 0.3, 3),
      collider: false,
    );

    // Terrace railing.
    for (var x = -7.0; x <= 7; x += block) {
      _addBlock(parent, Vector3(x + 0.5, y + 1.2, 7.8), HorrorMaterials.oakWood(), collider: false);
    }
    for (var z = 5.0; z <= 7; z += block) {
      _addBlock(parent, Vector3(-7.5, y + 1.2, z + 0.5), HorrorMaterials.oakWood(), collider: false);
      _addBlock(parent, Vector3(7.5, y + 1.2, z + 0.5), HorrorMaterials.oakWood(), collider: false);
    }

    // Second-floor windows.
    for (var x = -6.0; x <= 6; x += 3) {
      for (var wy = 1.0; wy <= 2.0; wy += 1) {
        _addBlock(parent, Vector3(x, y + wy, 5.35), HorrorMaterials.glass(), collider: false);
        _addBlock(parent, Vector3(x, y + wy, -5.35), HorrorMaterials.glass(), collider: false);
      }
    }

    // Oak window sill trim.
    for (var x = -7.0; x <= 7; x += block) {
      _addBlock(parent, Vector3(x + 0.5, y + 0.5, 5.5), HorrorMaterials.oakWood(), collider: false);
    }
  }

  void _buildRoof(Node parent) {
    final y = floorH * 2;
    _addBlock(
      parent,
      Vector3(0, y + roofH / 2, 0),
      HorrorMaterials.darkRoof(),
      size: Vector3(20, roofH, 12),
    );
    // Wood pergola roof section on the left.
    _addBlock(
      parent,
      Vector3(-8, y + roofH / 2, -4),
      HorrorMaterials.oakWood(),
      size: Vector3(4, roofH, 4),
      collider: false,
    );
  }

  void _buildPool(Node parent) {
    // L-shaped pool basin on the right.
    _addBlock(parent, Vector3(9, -0.6, 2), HorrorMaterials.whiteConcrete(), size: Vector3(6, 1.2, 8));
    _addBlock(parent, Vector3(11, -0.6, 8), HorrorMaterials.whiteConcrete(), size: Vector3(2, 1.2, 4));

    // Water.
    _addBlock(parent, Vector3(9, 0.0, 2), HorrorMaterials.poolWater(), size: Vector3(5.6, 0.15, 7.6), collider: false);
    _addBlock(parent, Vector3(11, 0.0, 8), HorrorMaterials.poolWater(), size: Vector3(1.6, 0.15, 3.6), collider: false);

    // White pool coping.
    for (var x = 5.5; x <= 12.5; x += block) {
      _addBlock(parent, Vector3(x, 0.1, -2.5), HorrorMaterials.whiteConcrete(), collider: false);
    }
    for (var z = -2.0; z <= 10; z += block) {
      _addBlock(parent, Vector3(5.5, 0.1, z + 0.5), HorrorMaterials.whiteConcrete(), collider: false);
      _addBlock(parent, Vector3(12.5, 0.1, z + 0.5), HorrorMaterials.whiteConcrete(), collider: false);
    }
  }

  void _buildGarden(Node parent) {
    const gx = -11.0;
    const gz = 3.0;
    const gw = 6.0;
    const gd = 6.0;

    for (var x = 0.0; x <= gw; x += block) {
      _addBlock(parent, Vector3(gx + x + 0.5, 0.5, gz - 0.5), HorrorMaterials.darkTrim());
      _addBlock(parent, Vector3(gx + x + 0.5, 0.5, gz + gd + 0.5), HorrorMaterials.darkTrim());
    }
    for (var z = 0.0; z <= gd; z += block) {
      _addBlock(parent, Vector3(gx - 0.5, 0.5, gz + z + 0.5), HorrorMaterials.darkTrim());
      _addBlock(parent, Vector3(gx + gw + 0.5, 0.5, gz + z + 0.5), HorrorMaterials.darkTrim());
    }

    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 5; col++) {
        _addBlock(
          parent,
          Vector3(gx + 1 + col * 1.1, 0.6, gz + 1 + row * 1.2),
          HorrorMaterials.crop(),
          collider: false,
        );
      }
    }
  }

  void _buildExteriorStairs(Node parent) {
    for (var step = 0; step < 8; step++) {
      final z = 8.0 - step * 0.8;
      final y = step * 0.375;
      _addBlock(
        parent,
        Vector3(-6.5, y + 0.2, z),
        HorrorMaterials.oakWood(),
        size: Vector3(2.5, 0.4, 0.8),
        collider: step == 0,
      );
      _addBlock(parent, Vector3(-8, y + 0.8, z), HorrorMaterials.whiteConcrete());
      _addBlock(parent, Vector3(-5, y + 0.8, z), HorrorMaterials.whiteConcrete());
    }

    for (var z = 9.0; z <= 14; z += block) {
      _addBlock(parent, Vector3(-6.5, 0.05, z), HorrorMaterials.oakWood(), collider: false);
    }
  }

  void _buildPergola(Node parent) {
    final y = floorH;
    const px = -9.0;
    const pz = -4.0;

    for (var x = 0.0; x <= 3; x += 1.5) {
      for (var z = 0.0; z <= 3; z += 1.5) {
        _addBlock(
          parent,
          Vector3(px + x, y + 1.5, pz + z),
          HorrorMaterials.oakWood(),
          size: Vector3(0.3, 3, 0.3),
          collider: false,
        );
      }
    }

    for (var x = 0.0; x <= 3; x += 0.6) {
      _addBlock(
        parent,
        Vector3(px + x, y + 3.2, pz + 1.5),
        HorrorMaterials.oakWood(),
        size: Vector3(0.3, 0.2, 3.5),
        collider: false,
      );
    }
  }

  void _buildTerracePlanters(Node parent) {
    final y = floorH + 0.3;
    for (var i = 0; i < 6; i++) {
      final x = -5.0 + i * 2.0;
      _addBlock(parent, Vector3(x, y + 0.3, 7.2), HorrorMaterials.whiteConcrete(), size: Vector3(0.6, 0.6, 0.6), collider: false);
      _addBlock(parent, Vector3(x, y + 0.8, 7.2), HorrorMaterials.plantPot(), size: Vector3(0.5, 0.5, 0.5), collider: false);
    }
  }

  void _wallRow(
    Node parent,
    double start,
    double center,
    double fixed,
    int count,
    double h,
    Material material, {
    bool axisZ = false,
    double baseY = 0,
  }) {
    for (var i = 0; i < count; i++) {
      final offset = start + i * block;
      final pos = axisZ
          ? Vector3(start + 0.5, baseY + h / 2, fixed + i * block + 0.5)
          : Vector3(offset + 0.5, baseY + h / 2, fixed + 0.5);
      _addBlock(parent, pos, material);
    }
  }

  void _addBlock(
    Node parent,
    Vector3 center,
    Material material, {
    Vector3? size,
    bool collider = true,
  }) {
    final blockSize = size ?? Vector3.all(1);
    final node = Node(
      localTransform: Matrix4.translation(center),
      mesh: Mesh(CuboidGeometry(blockSize), material),
    );
    parent.add(node);
    if (collider) {
      doorSystem.addWallCollider(node, center, blockSize);
    }
  }
}
