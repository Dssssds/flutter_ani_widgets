import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';

/// 有禁用语义的按压反馈，不影响子组件布局。
class PressScaleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final MotionSpec motion;
  final String label;
  final BorderRadius borderRadius;
  final double pressScale;

  const PressScaleButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.motion,
    required this.label,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.pressScale = 0.97,
  }) : assert(pressScale > 0 && pressScale <= 1);

  @override
  State<PressScaleButton> createState() => _PressScaleButtonState();
}

class _PressScaleButtonState extends State<PressScaleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: widget.label,
      child: AnimatedScale(
        scale: _pressed && !widget.motion.reduceMotion && widget.onPressed != null ? widget.pressScale : 1,
        duration: _pressed ? widget.motion.pressIn : widget.motion.pressOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: widget.borderRadius,
            onTap: widget.onPressed,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
