import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/dice/dice_theme.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

/// 酒红主按钮：可点击时带淡红光，翻滚中变成深灰、无图标、无红光。按下时缩到 97%。
///
/// 底层仍是一个 [FilledButton]，onPressed 的启用语义与抛硬币页的按钮一致。
class DiceActionButton extends StatefulWidget {
  const DiceActionButton({super.key, required this.onPressed, required this.rolling, required this.label, required this.settings});

  final VoidCallback? onPressed;
  final bool rolling;
  final String label;
  final SettingsState settings;

  /// 按钮高度与圆角。
  static const double height = 57;
  static const double radius = 16;

  /// 与底边的最小间距，配合 SafeArea 使用。
  static const double bottomGap = 24;

  @override
  State<DiceActionButton> createState() => _DiceActionButtonState();
}

class _DiceActionButtonState extends State<DiceActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final motion = MotionSpec.of(context, widget.settings);
    final rolling = widget.rolling;
    final foreground = rolling ? DiceTheme.disabledText : PartyTheme.chalk;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        child: AnimatedScale(
          scale: _pressed ? .97 : 1,
          duration: _pressed ? motion.pressIn : motion.pressOut,
          curve: Curves.easeOut,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DiceActionButton.radius),
              color: rolling ? DiceTheme.disabled : null,
              gradient:
                  rolling
                      ? null
                      : const LinearGradient(
                        colors: [DiceTheme.wineEdge, DiceTheme.wine, DiceTheme.wine, DiceTheme.wineEdge],
                        stops: [0, .3, .7, 1],
                      ),
              boxShadow: rolling ? null : [BoxShadow(color: DiceTheme.wineGlow.withValues(alpha: .35), blurRadius: 22, offset: const Offset(0, 8))],
            ),
            child: SizedBox(
              height: DiceActionButton.height,
              child: FilledButton(
                key: const ValueKey('roll-button'),
                onPressed: widget.onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  overlayColor: Colors.white.withValues(alpha: .12),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(DiceActionButton.radius))),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  minimumSize: const Size.fromHeight(DiceActionButton.height),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!rolling) ...[Icon(Icons.casino_rounded, size: 22, color: foreground), const SizedBox(width: 10)],
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: foreground, fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
