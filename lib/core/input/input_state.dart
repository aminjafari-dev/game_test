import 'package:flutter/foundation.dart';

/// Unified input state for desktop WASD and mobile joystick.
///
/// Keyboard and joystick are kept separate so keyboard polling does not
/// overwrite joystick values each frame.
class InputState extends ChangeNotifier {
  double _keyboardX = 0;
  double _keyboardZ = 0;
  double _joystickX = 0;
  double _joystickZ = 0;
  double _lookDeltaX = 0;
  double _lookDeltaY = 0;
  bool _interactPressed = false;
  bool _interactHeld = false;
  bool _joystickActive = false;

  /// Strafe axis: -1 left, +1 right.
  double get moveX {
    if (_keyboardX != 0) return _keyboardX;
    return _joystickX;
  }

  /// Forward axis: -1 backward, +1 forward.
  double get moveZ {
    if (_keyboardZ != 0) return _keyboardZ;
    return _joystickZ;
  }

  bool get joystickActive => _joystickActive;

  double get lookDeltaX => _lookDeltaX;
  double get lookDeltaY => _lookDeltaY;
  bool get interactPressed => _interactPressed;
  bool get interactHeld => _interactHeld;

  /// Sets movement from WASD keyboard. Call every frame while keys are held.
  void setKeyboardMovement({required double x, required double z}) {
    _keyboardX = x.clamp(-1.0, 1.0);
    _keyboardZ = z.clamp(-1.0, 1.0);
  }

  /// Sets movement from the on-screen joystick.
  void setJoystickMovement({required double x, required double z, bool active = true}) {
    _joystickX = x.clamp(-1.0, 1.0);
    _joystickZ = z.clamp(-1.0, 1.0);
    _joystickActive = active;
  }

  void clearJoystick() {
    _joystickX = 0;
    _joystickZ = 0;
    _joystickActive = false;
  }

  void addLookDelta({required double dx, required double dy}) {
    _lookDeltaX += dx;
    _lookDeltaY += dy;
  }

  void pressInteract() {
    _interactPressed = true;
    _interactHeld = true;
  }

  void releaseInteract() {
    _interactHeld = false;
  }

  /// Clears per-frame look deltas only. Movement is held until released.
  void endFrame() {
    _lookDeltaX = 0;
    _lookDeltaY = 0;
    _interactPressed = false;
  }
}
