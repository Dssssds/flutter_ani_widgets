import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

/// 首页的页码提示：“1 / 2” 加两颗圆点，放在标题区右下角，与大标题 “Game” 的基线对齐。
///
/// 直接绑定 PageController 的 0–1 分页进度：当前页的圆点随拖动拉长成胶囊，数字在过半时切换，
/// 松手吸附、取消拖动都跟着菜单同步，不使用独立的延时动画。减少动态效果时只在页面切换后跳变。
/// 仅作提示：不拦截触摸（翻页仍然靠拖动），也不进入读屏（菜单本身已经播报 “第 N 页，共 2 页”）。
class MenuPageIndicator extends StatelessWidget {
  const MenuPageIndicator({super.key, required this.progress, this.pageCount = 2, this.reduceMotion = false});

  /// 0..pageCount-1 的连续分页进度。
  final ValueListenable<double> progress;
  final int pageCount;
  final bool reduceMotion;

  static const Color _color = Color(0xFFFFF1CF);
  static const double _dotHeight = 6;
  static const double _dotWidth = 6;
  static const double _activeWidth = 22;
  static const double _dotGap = 5;
  static const double _textGap = 12;

  static const TextStyle _textStyle = TextStyle(
    fontFamily: PartyTheme.displayFamily,
    fontWeight: FontWeight.w400,
    fontSize: 24,
    height: 1,
    color: _color,
  );

  static TextPainter _measure(int pageCount) => TextPainter(
    text: TextSpan(text: '1 / $pageCount', style: _textStyle),
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
  )..layout();

  /// 组件的高度：就是一行文字的高度（行高 1）。
  static const double height = 24;

  /// 整个组件的宽度（文字 + 间距 + 所有圆点）。放得下与否由标题区据此判断。
  static double widthFor(int pageCount) {
    final painter = _measure(pageCount);
    final width = painter.width;
    painter.dispose();
    return width + _textGap + _activeWidth + (pageCount - 1) * _dotWidth + (pageCount - 1) * _dotGap;
  }

  /// 文字底边到基线的距离，用来把圆点“坐”在基线上，也用来让整个组件的基线与标题对齐。
  static double belowBaseline(int pageCount) {
    final painter = _measure(pageCount);
    final distance = painter.height - painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    painter.dispose();
    return distance;
  }

  @override
  Widget build(BuildContext context) {
    final inset = belowBaseline(pageCount);
    return IgnorePointer(
      child: ExcludeSemantics(
        child: ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (context, raw, _) {
            final value = (reduceMotion ? raw.roundToDouble() : raw).clamp(0.0, pageCount - 1.0);
            final current = math.min(pageCount - 1, math.max(0, raw.round()));
            return Row(
              key: const ValueKey('menu-page-indicator'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '${current + 1}'),
                      TextSpan(text: ' / $pageCount', style: TextStyle(color: _color.withValues(alpha: .5))),
                    ],
                  ),
                  style: _textStyle,
                  textScaler: TextScaler.noScaling,
                ),
                const SizedBox(width: _textGap),
                // 圆点坐在文字基线上。
                Padding(
                  padding: EdgeInsets.only(bottom: inset),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < pageCount; i++) ...[
                        if (i > 0) const SizedBox(width: _dotGap),
                        _Dot(closeness: 1 - (value - i).abs().clamp(0.0, 1.0)),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 一颗圆点：越接近当前页越长、越亮。
class _Dot extends StatelessWidget {
  const _Dot({required this.closeness});

  final double closeness;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MenuPageIndicator._dotWidth + (MenuPageIndicator._activeWidth - MenuPageIndicator._dotWidth) * closeness,
      height: MenuPageIndicator._dotHeight,
      decoration: BoxDecoration(
        color: MenuPageIndicator._color.withValues(alpha: .35 + .65 * closeness),
        borderRadius: BorderRadius.circular(MenuPageIndicator._dotHeight / 2),
      ),
    );
  }
}
