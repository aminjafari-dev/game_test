/// Central registry for all 3D model asset paths.
///
/// Reference paths from this class instead of hardcoding strings.
/// Example: `Node.fromGlbAsset(ModelPath.tree)`
class ModelPath {
  ModelPath._();

  static const String tree = 'assets/models/tree.glb';
}
