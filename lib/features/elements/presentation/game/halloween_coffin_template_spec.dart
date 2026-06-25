import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

/// Identifies each flat cardboard piece from the Halloween coffin cut sheet.
///
/// Use with [HalloweenCoffinPiecesBuilder] to build or inspect individual parts.
enum TemplatePiece {
  base,
  top,
  topLeft,
  topRight,
  leftSide,
  rightSide,
  bottom,
  leftDoor,
  rightDoor,
}

/// Dimensions and vertex math for the wikiHow coffin cardboard template.
///
/// All measurements are in **inches**, matching the reference diagram:
/// head 24", shoulders 18", long sides 59", foot 17", wall depth 12" (1 ft).
/// Coordinates use the origin at the center of the head (top) edge with Y
/// increasing downward, like the flat cut sheet.
///
/// Example:
/// ```dart
/// final base = HalloweenCoffinTemplateSpec.baseVerticesIn;
/// final scale = HalloweenCoffinTemplateSpec.inchesToWorld;
/// ```
class HalloweenCoffinTemplateSpec {
  HalloweenCoffinTemplateSpec._();

  // --- Edge lengths from the wikiHow template (inches) ---

  /// Head panel edge (top of the hexagon).
  static const double topEdgeIn = 24.0;

  /// Foot panel edge (bottom of the hexagon).
  static const double bottomEdgeIn = 17.0;

  /// Upper slanted shoulder edges (both sides).
  static const double upperSlantIn = 18.0;

  /// Long tapering side edges (both sides).
  static const double lowerSlantIn = 59.0;

  /// Depth of every wall strip when the coffin is assembled (1 foot).
  static const double wallDepthIn = 12.0;

  static const double topHalfWidthIn = topEdgeIn / 2;
  static const double bottomHalfWidthIn = bottomEdgeIn / 2;

  /// Half-width at the shoulder line — closes the 18" slant with the 24" head.
  static const double shoulderHalfWidthIn = 15.0;

  /// Horizontal run from a head corner to the shoulder on one side.
  static const double upperSlantHorizontalIn =
      shoulderHalfWidthIn - topHalfWidthIn;

  /// Horizontal run from a shoulder to the foot corner on one side.
  static const double lowerSlantHorizontalIn =
      shoulderHalfWidthIn - bottomHalfWidthIn;

  /// Y distance from the head edge to the shoulder line.
  static final double shoulderYIn = math.sqrt(
    upperSlantIn * upperSlantIn -
        upperSlantHorizontalIn * upperSlantHorizontalIn,
  );

  /// Y distance from the head edge to the foot edge along the center line.
  static final double baseHeightIn = shoulderYIn +
      math.sqrt(
        lowerSlantIn * lowerSlantIn -
            lowerSlantHorizontalIn * lowerSlantHorizontalIn,
      );

  /// Board thickness for flat preview pieces.
  ///
  /// Set to a real lumber thickness (3/4") so each extruded piece reads as a
  /// solid wooden plank rather than thin paper/cardboard. Increase this if the
  /// boards should look even chunkier.
  static const double pieceThicknessIn = 2;

  /// Gap between cut-sheet pieces in the flat layout preview.
  static const double layoutGapIn = 1.0;

  /// Default world offset so the cut sheet sits beside the assembled coffin.
  static const double cutSheetOffsetX = 4.0;

  /// Converts inches to world meters so the template height matches the
  /// assembled coffin length scale (~2 m).
  static final double inchesToWorld = 2.0 / baseHeightIn;

  /// Hexagon base vertices in template space (clockwise from top-left).
  static final List<Vector2> baseVerticesIn = [
    Vector2(-topHalfWidthIn, 0),
    Vector2(topHalfWidthIn, 0),
    Vector2(shoulderHalfWidthIn, shoulderYIn),
    Vector2(bottomHalfWidthIn, baseHeightIn),
    Vector2(-bottomHalfWidthIn, baseHeightIn),
    Vector2(-shoulderHalfWidthIn, shoulderYIn),
  ];

  /// Wall strip lengths keyed by [TemplatePiece].
  static const Map<TemplatePiece, double> wallLengthIn = {
    TemplatePiece.top: topEdgeIn,
    TemplatePiece.topLeft: upperSlantIn,
    TemplatePiece.topRight: upperSlantIn,
    TemplatePiece.leftSide: lowerSlantIn,
    TemplatePiece.rightSide: lowerSlantIn,
    TemplatePiece.bottom: bottomEdgeIn,
  };

  /// Horizontal distance from the cut-sheet center to each door seam.
  static double get doorSeamXIn =>
      shoulderHalfWidthIn + layoutGapIn + wallDepthIn + layoutGapIn;

  /// Left lid half — vertical split at the center seam (x = 0 in local space).
  static final List<Vector2> leftDoorVerticesIn = [
    Vector2(-topHalfWidthIn, 0),
    Vector2(0, 0),
    Vector2(0, baseHeightIn),
    Vector2(-bottomHalfWidthIn, baseHeightIn),
    Vector2(-shoulderHalfWidthIn, shoulderYIn),
  ];

  /// Right lid half — mirror of [leftDoorVerticesIn].
  static final List<Vector2> rightDoorVerticesIn = [
    Vector2(0, 0),
    Vector2(topHalfWidthIn, 0),
    Vector2(shoulderHalfWidthIn, shoulderYIn),
    Vector2(bottomHalfWidthIn, baseHeightIn),
    Vector2(0, baseHeightIn),
  ];

  /// Angle of the upper slant measured from horizontal (radians).
  static final double upperSlantAngleRad = math.atan2(
    shoulderYIn,
    upperSlantHorizontalIn,
  );

  /// Anchor for the left door — seam at x = 0 local faces the cut sheet.
  static Vector2 get leftDoorAnchorIn => Vector2(-doorSeamXIn, 0);

  /// Anchor for the right door — seam at x = 0 local faces the cut sheet.
  static Vector2 get rightDoorAnchorIn => Vector2(doorSeamXIn, 0);
  ///
  /// Template Y increases downward; world Z receives that axis so pieces lie
  /// flat on the ground with Y as thickness.
  static Vector3 templateInToWorld(Vector2 templateIn, {double yWorld = 0}) {
    return Vector3(
      templateIn.x * inchesToWorld,
      yWorld,
      templateIn.y * inchesToWorld,
    );
  }

  /// Half thickness of a flat piece in world units, used to rest it on the ground.
  static double get pieceHalfThicknessWorld =>
      pieceThicknessIn * inchesToWorld / 2;

  /// Full cardboard thickness of a flat piece in world meters.
  ///
  /// Use this for the `thicknessWorld` argument of [CoffinGeometry] mesh
  /// helpers so every piece extrudes by the same depth as the spec defines.
  static double get pieceThicknessWorld => pieceThicknessIn * inchesToWorld;
}
