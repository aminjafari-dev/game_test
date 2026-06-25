/// Central registry for all image asset paths.
///
/// Reference paths from this class instead of hardcoding strings.
/// Example: `Image.asset(ImagePath.ghostOverlay)`
class ImagePath {
  ImagePath._();

  static const String ghostOverlay = 'assets/images/ghost_overlay.png';

  /// Wood plank texture with carved skull for the Halloween coffin prop.
  static const String halloweenCoffinWood =
      'assets/images/halloween coffin prop texture.png';
}
