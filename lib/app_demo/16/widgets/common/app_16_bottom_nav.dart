import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/app_screen.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_icon.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_pressable.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/motion/app_16_motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';

const _pillWidth = 49.0;
const _pillHeight = 32.0;
const _iconSize = 23.0;
const _labelGap = 3.0;
const _labelHeight = 15.0;

class App16BottomNav extends StatelessWidget {
  const App16BottomNav({
    super.key,
    required this.current,
    required this.height,
    required this.onSelect,
  });

  final AppScreen current;
  final double height;
  final ValueChanged<AppScreen> onSelect;

  static const _items = <_NavItem>[
    _NavItem(AppScreen.journal, '手账', 'i-book'),
    _NavItem(AppScreen.drawer, '素材', 'i-drawer'),
    _NavItem(AppScreen.month, '翻看', 'i-calendar'),
  ];

  @override
  Widget build(BuildContext context) {
    final duration = App16MotionSpec.motion(context, App16MotionSpec.tab);
    final activeIndex = math.max(
      0,
      _items.indexWhere((item) => item.screen == current),
    );
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const contentHeight = _pillHeight + _labelGap + _labelHeight;
    final verticalPadding = math.max(0.0, (height - contentHeight) / 2);

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: App16Colors.appBg,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x0F704458),
            offset: Offset(0, -6),
            blurRadius: 18,
          ),
        ],
      ),
      child: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  30,
                  verticalPadding,
                  30,
                  verticalPadding,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final slotWidth = constraints.maxWidth / _items.length;
                    final pillTop = math.max(
                      0.0,
                      (constraints.maxHeight - contentHeight) / 2,
                    );
                    return Stack(
                      children: <Widget>[
                        AnimatedPositioned(
                          key: const ValueKey<String>('app16-nav-indicator'),
                          duration: duration,
                          curve: App16MotionSpec.tabCurve,
                          left:
                              slotWidth * activeIndex +
                              (slotWidth - _pillWidth) / 2,
                          top: pillTop,
                          width: _pillWidth,
                          height: _pillHeight,
                          child: const _ActivePill(),
                        ),
                        Row(
                          children: <Widget>[
                            for (final item in _items)
                              Expanded(
                                child: _NavButton(
                                  item: item,
                                  active: item.screen == current,
                                  duration: duration,
                                  onTap: () => onSelect(item.screen),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 0.5,
                child: ColoredBox(color: App16Colors.line),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivePill extends StatelessWidget {
  const _ActivePill();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: App16Colors.berry,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x269D3C65),
            offset: Offset(0, 3),
            blurRadius: 9,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.duration,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = active ? const Color(0xFFFFFDF8) : App16Colors.muted;
    final labelColor = active ? App16Colors.berry : App16Colors.muted;
    return App16Pressable(
      onTap: onTap,
      semanticLabel: item.label,
      selected: active,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: _pillWidth,
            height: _pillHeight,
            child: Center(
              child: AnimatedScale(
                scale: active ? 1.08 : 1,
                duration: duration,
                curve: App16MotionSpec.tabCurve,
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: iconColor),
                  duration: duration,
                  curve: App16MotionSpec.tabCurve,
                  builder: (context, value, _) {
                    return App16Icon(
                      name: item.icon,
                      size: _iconSize,
                      color: value ?? iconColor,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: _labelGap),
          SizedBox(
            height: _labelHeight,
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: duration,
                curve: App16MotionSpec.tabCurve,
                style: App16Typography.navLabel.copyWith(
                  color: labelColor,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(item.label, maxLines: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.screen, this.label, this.icon);

  final AppScreen screen;
  final String label;
  final String icon;
}
