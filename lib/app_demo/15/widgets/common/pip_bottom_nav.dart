import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/data/asset_manifest.dart';
import 'package:flutter_x_widgets/app_demo/15/models/root_tab.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_icon.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/motion/pip_motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/design_tokens.dart';

class PipBottomNav extends StatelessWidget {
  static const _itemWidth = 77.0;
  static const _itemHeight = 60.0;
  static const _itemRadius = 15.0;

  final RootTab activeTab;
  final ValueChanged<RootTab> onSelected;

  const PipBottomNav({super.key, required this.activeTab, required this.onSelected});

  static const _items = <_NavItem>[
    _NavItem(tab: RootTab.path, label: '学习', icon: 'book'),
    _NavItem(tab: RootTab.review, label: '复习', icon: 'review'),
    _NavItem(tab: RootTab.achievements, label: '成就', icon: 'trophy'),
    _NavItem(tab: RootTab.profile, label: '我的', icon: 'user'),
  ];

  @override
  Widget build(BuildContext context) {
    final motion = PipMotionSpec.of(context);
    final activeIndex = math.max(0, _items.indexWhere((item) => item.tab == activeTab));

    return ColoredBox(
      color: App15Theme.paper,
      child: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: App15Theme.line, width: 2))),
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        child: SizedBox(
          height: App15Design.navHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final slotWidth = constraints.maxWidth / _items.length;
                final itemWidth = math.min(_itemWidth, slotWidth);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedPositioned(
                      key: const ValueKey('root-nav-indicator'),
                      duration: motion.navTransition,
                      curve: Curves.easeOutCubic,
                      left: slotWidth * activeIndex + (slotWidth - itemWidth) / 2,
                      top: (constraints.maxHeight - _itemHeight) / 2,
                      width: itemWidth,
                      height: _itemHeight,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: App15Theme.navHighlight,
                          borderRadius: BorderRadius.all(Radius.circular(_itemRadius)),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (final item in _items)
                          Expanded(
                            child: Center(
                              child: _NavButton(
                                item: item,
                                active: item.tab == activeTab,
                                width: itemWidth,
                                onTap: () => onSelected(item.tab),
                              ),
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
      ),
    );
  }
}

class _NavItem {
  final RootTab tab;
  final String label;
  final String icon;

  const _NavItem({required this.tab, required this.label, required this.icon});
}

class _NavButton extends StatefulWidget {
  final _NavItem item;
  final bool active;
  final double width;
  final VoidCallback onTap;

  const _NavButton({required this.item, required this.active, required this.width, required this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final motion = PipMotionSpec.of(context);
    final active = widget.active;

    return Semantics(
      container: true,
      button: true,
      selected: active,
      label: widget.item.label,
      child: ExcludeSemantics(
        child: GestureDetector(
          key: ValueKey('root-nav-${widget.item.tab.name}'),
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: motion.buttonPress,
            width: widget.width,
            height: PipBottomNav._itemHeight,
            transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: active ? 1.03 : 1,
                  duration: motion.navIcon,
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: active ? 1 : 0.55,
                    duration: motion.navIcon,
                    curve: Curves.easeOut,
                    child: PipIcon(asset: PipAssets.icon(widget.item.icon), size: 26),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: motion.navIcon,
                  curve: Curves.easeOut,
                  style: App15Theme.captionStyle.copyWith(color: active ? App15Theme.ink : App15Theme.navInactive, fontSize: 12, height: 1),
                  child: Text(widget.item.label, maxLines: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
