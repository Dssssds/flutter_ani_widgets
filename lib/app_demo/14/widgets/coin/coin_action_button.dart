import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';

/// 金色渐变主按钮：可点击 / 抛掷中两态，按下时缩到 97%。
///
/// 底层仍是一个 [FilledButton]，因此 onPressed 的启用语义和既有的调用方、
/// 测试保持一致；金色渐变和顶部高光边叠加在它上面。
/// 抛掷中整体变暗、不显示图标，文字由调用方传入，避免新旧文字叠在一起。
class CoinActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool busy;
  final String label;
  final SettingsState settings;

  const CoinActionButton({super.key, required this.onPressed, required this.busy, required this.label, required this.settings});

  /// 与底边的最小间距，配合 SafeArea 使用。
  static const double bottomGap = 24;

  /// 按钮高度。
  static const double height = 56;

  @override
  State<CoinActionButton> createState() => _CoinActionButtonState();
}

class _CoinActionButtonState extends State<CoinActionButton> {
  static const _ink = Color(0xFF1A1408);
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final motion = MotionSpec.of(context, widget.settings);
    // 抛掷中饱和度降到约一半并压暗，整体读起来是“不可点”。
    final colors = [for (final color in const [Color(0xFFFFF7A5), Color(0xFFE9C94A), Color(0xFFC9A02E)]) _dim(color, widget.busy)];

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
          // 按下时缩到 97%，松开后弹回。
          scale: _pressed ? .97 : 1,
          duration: _pressed ? motion.pressIn : motion.pressOut,
          curve: Curves.easeOut,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors, stops: const [0, .55, 1]),
              boxShadow: [BoxShadow(color: colors[1].withValues(alpha: .30), blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // 顶部 1 像素高光边。
                  Positioned(
                    top: 0,
                    left: 12,
                    right: 12,
                    child: Container(height: 1, color: Colors.white.withValues(alpha: widget.busy ? .25 : .55)),
                  ),
                  SizedBox(
                    height: CoinActionButton.height,
                    child: FilledButton(
                      key: const ValueKey('flip-button'),
                      onPressed: widget.onPressed,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        // 金色底上用深色叠层表示键盘焦点，与文字同色系。
                        overlayColor: _ink.withValues(alpha: .14),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        minimumSize: const Size.fromHeight(CoinActionButton.height),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!widget.busy) ...[const Icon(Icons.cached_rounded, size: 22, color: _ink), const SizedBox(width: 10)],
                          Flexible(
                            child: Text(
                              widget.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: widget.busy ? _ink.withValues(alpha: .7) : _ink, fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 抛掷中：保留明度、降低一半饱和度，再向黑色压暗三成。
  static Color _dim(Color color, bool busy) {
    if (!busy) return color;
    final hsl = HSLColor.fromColor(color);
    final muted = hsl.withSaturation((hsl.saturation * .5).clamp(0.0, 1.0)).toColor();
    return Color.lerp(muted, Colors.black, .3)!;
  }
}
