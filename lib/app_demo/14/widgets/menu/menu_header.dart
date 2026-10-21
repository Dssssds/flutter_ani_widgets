import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_swipe_arrow.dart';

/// A bounded, responsive title above the game menu.
class MenuHeader extends StatelessWidget {
  const MenuHeader({super.key, required this.pageProgress, this.onExit, this.reduceMotion = false});

  final double pageProgress;
  final VoidCallback? onExit;
  final bool reduceMotion;

  static const _cream = Color(0xFFFFF1CF);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxHeight < 170;
      final back = IconButton(
        tooltip: '返回案例列表',
        onPressed: onExit,
        color: _cream,
        disabledColor: _cream.withValues(alpha: .38),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
        icon: const Icon(Icons.arrow_back_rounded, size: 26),
      );
      final title = FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.bottomLeft,
        child: Text(
          compact ? 'Pick a Game' : 'Pick a\nGame',
          semanticsLabel: 'Pick a Game',
          maxLines: compact ? 1 : 2,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            color: _cream,
            fontSize: 140,
            height: .92,
            letterSpacing: -5,
          ),
        ),
      );
      if (compact) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              back,
              const SizedBox(width: 8),
              Expanded(child: title),
              const SizedBox(width: 12),
              MenuSwipeArrow(pageProgress: pageProgress, width: 48, reduceMotion: reduceMotion),
            ],
          ),
        );
      }
      final arrowWidth = (constraints.maxWidth * .2).clamp(64.0, 80.0);
      return Stack(
        children: [
          Positioned(top: 0, left: 12, child: back),
          Positioned(top: 54, left: 24, right: arrowWidth + 32, bottom: 12, child: title),
          Positioned(
            right: 20,
            bottom: 4,
            child: MenuSwipeArrow(pageProgress: pageProgress, width: arrowWidth, reduceMotion: reduceMotion),
          ),
        ],
      );
    },
  );
}
