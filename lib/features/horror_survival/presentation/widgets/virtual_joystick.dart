import 'package:flutter/material.dart';
import 'package:game_test/core/input/input_state.dart';
import 'package:game_test/core/theme/app_theme.dart';

/// Virtual joystick for mobile movement control (bottom-left).
///
/// Drag the knob to move. Forward = push up, back = pull down.
class VirtualJoystick extends StatefulWidget {
  const VirtualJoystick({super.key, required this.inputState});

  final InputState inputState;

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _knobOffset = Offset.zero;
  static const double _baseSize = 130;
  static const double _knobSize = 54;
  static const double _maxRadius = 40;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      bottom: 16,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerUp,
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
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.joystickKnob, width: 2),
                  ),
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

  void _onPointerDown(PointerDownEvent event) {
    _updateKnob(event.localPosition);
  }

  void _onPointerMove(PointerMoveEvent event) {
    _updateKnob(event.localPosition);
  }

  void _onPointerUp(PointerEvent event) {
    setState(() => _knobOffset = Offset.zero);
    widget.inputState.clearJoystick();
  }

  void _updateKnob(Offset localPosition) {
    final center = Offset(_baseSize / 2, _baseSize / 2);
    var offset = localPosition - center;
    if (offset.distance > _maxRadius) {
      offset = Offset.fromDirection(offset.direction, _maxRadius);
    }
    setState(() => _knobOffset = offset);
    widget.inputState.setJoystickMovement(
      x: offset.dx / _maxRadius,
      z: -offset.dy / _maxRadius,
      active: true,
    );
  }
}
