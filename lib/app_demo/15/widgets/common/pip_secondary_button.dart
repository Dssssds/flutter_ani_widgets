import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/motion/pip_motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/design_tokens.dart';

class PipSecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final double height;
  final bool expand;

  const PipSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.trailing,
    this.height = 54,
    this.expand = true,
  });

  @override
  State<PipSecondaryButton> createState() => _PipSecondaryButtonState();
}

class _PipSecondaryButtonState extends State<PipSecondaryButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final motion = PipMotionSpec.of(context);
    final enabled = widget.onPressed != null;

    final button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: motion.buttonPress,
        height: widget.height,
        transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: enabled ? App15Theme.paper : App15Theme.disabledSurface,
          borderRadius: BorderRadius.circular(App15Design.buttonRadius),
          border: Border.all(color: enabled ? App15Theme.ink : App15Theme.lockedBorder, width: 2),
          boxShadow: [BoxShadow(color: App15Theme.neutralBorder, offset: Offset(0, _pressed ? 1 : 4))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 7)],
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: App15Theme.buttonStyle.copyWith(fontSize: 16, color: enabled ? App15Theme.ink : App15Theme.disabledText),
              ),
            ),
            if (widget.trailing != null) ...[const SizedBox(width: 7), widget.trailing!],
          ],
        ),
      ),
    );

    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: widget.label,
      child: ExcludeSemantics(child: widget.expand ? SizedBox(width: double.infinity, child: button) : button),
    );
  }
}
