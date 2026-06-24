import 'package:flutter/material.dart';
import 'package:game_test/core/input/input_state.dart';
import 'package:game_test/core/theme/app_theme.dart';

/// Virtual joystick for mobile movement control.
///
/// Updates [InputState] with moveX/moveZ values.
/// Example: place in bottom-left of game overlay stack.
class VirtualJoystick extends StatefulWidget {
  const VirtualJoystick({super.key, required this.inputState});

  final InputState inputState;

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _knobOffset = Offset.zero;
  static const double _baseSize = 120;
  static const double _knobSize = 50;
  static const double _maxRadius = 35;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      bottom: 24,
      child: GestureDetector(
        onPanStart: (_) {},
        onPanUpdate: _onPan,
        onPanEnd: (_) => _reset(),
        onPanCancel: _reset,
        child: SizedBox(
          width: _baseSize,
          height: _baseSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: _baseSize,
                height: _baseSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.joystickBase,
                ),
              ),
              Transform.translate(
                offset: _knobOffset,
                child: Container(
                  width: _knobSize,
                  height: _knobSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.joystickKnob,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPan(DragUpdateDetails details) {
    setState(() {
      _knobOffset += details.delta;
      if (_knobOffset.distance > _maxRadius) {
        _knobOffset = Offset.fromDirection(
          _knobOffset.direction,
          _maxRadius,
        );
      }
      widget.inputState.setMovement(
        x: _knobOffset.dx / _maxRadius,
        z: -_knobOffset.dy / _maxRadius,
      );
    });
  }

  void _reset() {
    setState(() {
      _knobOffset = Offset.zero;
      widget.inputState.setMovement(x: 0, z: 0);
    });
  }
}
