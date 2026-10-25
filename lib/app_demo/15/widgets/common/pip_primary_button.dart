import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/motion/pip_motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/design_tokens.dart';

class PipPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final double height;
  final bool expand;

  const PipPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.trailing,
    this.height = 58,
    this.expand = true,
  });

  @override
  State<PipPrimaryButton> createState() => _PipPrimaryButtonState();
}

class _PipPrimaryButtonState extends State<PipPrimaryButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final motion = PipMotionSpec.of(context);
    final offset = _pressed ? 4.0 : 0.0;
    final decoration = BoxDecoration(
      color: _enabled ? App15Theme.yellow : App15Theme.disabledSurface,
      borderRadius: BorderRadius.circular(App15Design.buttonRadius),
      border: Border.all(color: _enabled ? App15Theme.ink : App15Theme.lockedBorder, width: 2),
      boxShadow:
          _enabled
              ? (_pressed ? const [BoxShadow(color: App15Theme.ink, offset: Offset(0, 2))] : App15Design.buttonShadow)
              : App15Design.neutralButtonShadow,
    );

    final button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _enabled ? (_) => _setPressed(true) : null,
      onTapUp: _enabled ? (_) => _setPressed(false) : null,
      onTapCancel: _enabled ? () => _setPressed(false) : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: motion.buttonPress,
        height: widget.height,
        transform: Matrix4.translationValues(0, offset, 0),
        decoration: decoration,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 10)],
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: App15Theme.buttonStyle.copyWith(color: _enabled ? App15Theme.ink : App15Theme.disabledText),
              ),
            ),
            if (widget.trailing != null) ...[const SizedBox(width: 10), widget.trailing!],
          ],
        ),
      ),
    );

    return Semantics(
      container: true,
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: ExcludeSemantics(child: widget.expand ? SizedBox(width: double.infinity, child: button) : button),
    );
  }
}
