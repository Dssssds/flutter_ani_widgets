import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/dice/dice_theme.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

/// “一枚 / 两枚” 分段控件：深灰半透明胶囊，选中项有略亮的圆角底块。
class DiceCountSelector extends StatelessWidget {
  const DiceCountSelector({super.key, required this.count, required this.onChanged, this.animate = true});

  /// 当前选中的数量，1 或 2。
  final int count;
  final ValueChanged<int> onChanged;

  /// 减少动态效果时底块直接跳到新位置。
  final bool animate;

  static const double height = 44;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: DiceTheme.segmentTrack.withValues(alpha: .55), borderRadius: BorderRadius.circular(999)),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: animate ? const Duration(milliseconds: 180) : Duration.zero,
            curve: Curves.easeOutCubic,
            alignment: count == 1 ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: .5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(999)),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: _Segment(key: const ValueKey('dice-count-one'), dice: 1, label: '一枚骰子', selected: count == 1, onTap: () => onChanged(1))),
              Expanded(child: _Segment(key: const ValueKey('dice-count-two'), dice: 2, label: '两枚骰子', selected: count == 2, onTap: () => onChanged(2))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({super.key, required this.dice, required this.label, required this.selected, required this.onTap});

  final int dice;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? PartyTheme.chalk : DiceTheme.muted;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 单个或两个并排的小方块，对应骰子数量。
                for (var i = 0; i < dice; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(border: Border.all(color: color, width: 1.6), borderRadius: BorderRadius.circular(3.5)),
                  ),
                ],
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
