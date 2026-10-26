import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/motion/app_16_motion_spec.dart';

class App16Pressable extends StatefulWidget {
  const App16Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.selected,
    this.minSize = 44,
    this.borderRadius,
    this.focusNode,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool? selected;
  final double minSize;
  final BorderRadius? borderRadius;
  final FocusNode? focusNode;

  @override
  State<App16Pressable> createState() => _App16PressableState();
}

class _App16PressableState extends State<App16Pressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final content = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: widget.minSize,
        minHeight: widget.minSize,
      ),
      child: widget.child,
    );

    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: AnimatedScale(
        scale: _pressed && enabled && !reduceMotion ? 0.96 : 1,
        duration: reduceMotion ? Duration.zero : App16MotionSpec.press,
        curve: Curves.easeOut,
        child: InkWell(
          focusNode: widget.focusNode,
          onTap: widget.onTap,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          excludeFromSemantics: true,
          borderRadius: widget.borderRadius,
          overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: content,
        ),
      ),
    );
  }
}
