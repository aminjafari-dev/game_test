import 'package:audioplayers/audioplayers.dart';

/// Audio asset path registry for horror game sounds.
class AudioPaths {
  AudioPaths._();

  static const String ambientCorridor = 'audio/ambient/corridor_wind.wav';
  static const String ambientDripping = 'audio/ambient/dripping_water.wav';
  static const String ambientWhispers = 'audio/ambient/whispers.wav';
  static const String ambientCreaking = 'audio/ambient/creaking.wav';
  static const String scareScream = 'audio/scares/scream.wav';
  static const String sfxDoorCreak = 'audio/sfx/door_creak.wav';
  static const String sfxMonsterGrowl = 'audio/sfx/monster_growl.wav';
  static const String sfxKeyPickup = 'audio/sfx/key_pickup.wav';
}

/// Manages ambient loops and one-shot sound effects for the horror game.
///
/// Example:
/// ```dart
/// await audioManager.init();
/// audioManager.playAmbientLoop(AudioPaths.ambientCorridor);
/// audioManager.playOneShot(AudioPaths.scareScream);
/// ```
class AudioManager {
  AudioManager();

  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  String? _currentAmbient;
  bool _initialized = false;

  /// Prepares audio players. Call once before playing sounds.
  Future<void> init() async {
    if (_initialized) return;
    await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    _initialized = true;
  }

  /// Plays a looping ambient track, crossfading if a different track is active.
  Future<void> playAmbientLoop(String assetPath, {double volume = 0.5}) async {
    if (_currentAmbient == assetPath) return;
    _currentAmbient = assetPath;
    await _ambientPlayer.stop();
    await _ambientPlayer.setVolume(volume);
    await _ambientPlayer.play(AssetSource(assetPath));
  }

  /// Stops the current ambient loop.
  Future<void> stopAmbient() async {
    _currentAmbient = null;
    await _ambientPlayer.stop();
  }

  /// Plays a one-shot sound effect.
  Future<void> playOneShot(String assetPath, {double volume = 1.0}) async {
    await _sfxPlayer.stop();
    await _sfxPlayer.setVolume(volume);
    await _sfxPlayer.play(AssetSource(assetPath));
  }

  /// Releases audio resources.
  Future<void> dispose() async {
    await _ambientPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
