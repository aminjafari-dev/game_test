import 'package:flutter/foundation.dart';

/// Unified input state for desktop WASD and mobile joystick.
///
/// Updated each frame by [HorrorGamePage] from keyboard and touch.
/// Example: `if (inputState.moveForward) controller.moveForward(dt)`
class InputState extends ChangeNotifier {
  double _moveX = 0;
  double _moveZ = 0;
  double _lookDeltaX = 0;
  double _lookDeltaY = 0;
  bool _interactPressed = false;
  bool _interactHeld = false;

  /// Strafe axis: -1 left, +1 right.
  double get moveX => _moveX;

  /// Forward axis: -1 backward, +1 forward.
  double get moveZ => _moveZ;

  /// Horizontal look delta accumulated this frame (radians).
  double get lookDeltaX => _lookDeltaX;

  /// Vertical look delta accumulated this frame (radians).
  double get lookDeltaY => _lookDeltaY;

  /// True for one frame when interact was pressed.
  bool get interactPressed => _interactPressed;

  /// True while interact is held.
  bool get interactHeld => _interactHeld;

  /// Sets movement from joystick or WASD. Values should be in [-1, 1].
  void setMovement({required double x, required double z}) {
    _moveX = x.clamp(-1.0, 1.0);
    _moveZ = z.clamp(-1.0, 1.0);
  }

  /// Adds look rotation delta for this frame.
  void addLookDelta({required double dx, required double dy}) {
    _lookDeltaX += dx;
    _lookDeltaY += dy;
  }

  /// Marks interact as pressed this frame.
  void pressInteract() {
    _interactPressed = true;
    _interactHeld = true;
  }

  /// Releases interact hold.
  void releaseInteract() {
    _interactHeld = false;
  }

  /// Clears per-frame deltas. Call at end of each game tick.
  void endFrame() {
    _lookDeltaX = 0;
    _lookDeltaY = 0;
    _interactPressed = false;
  }
}
