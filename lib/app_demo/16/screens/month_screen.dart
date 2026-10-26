import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/rules/diary_rules.dart';
import 'package:flutter_x_widgets/app_demo/16/models/view_models/diary_controller.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_icon.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_pressable.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/month/calendar_grid.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/month/selected_entry_card.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/design_tokens.dart';

class MonthScreen extends StatelessWidget {
  const MonthScreen({super.key, required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    final metrics = App16Metrics.of(context);
    final count = controller.entryCountForMonth(
      controller.viewYear,
      controller.viewMonth,
    );
    return Column(
      children: <Widget>[
        _MonthHeader(controller: controller),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              22,
              0,
              22,
              metrics.navTotalHeight + 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _MonthHeading(controller: controller),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        const TextSpan(text: '写下了 '),
                        TextSpan(
                          text: '$count',
                          style: const TextStyle(
                            color: App16Colors.berry,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(text: ' 天'),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: App16Colors.muted,
                    ),
                  ),
                ),
                CalendarGrid(controller: controller),
                SelectedEntryCard(controller: controller),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    final metrics = App16Metrics.of(context);
    return SizedBox(
      height: metrics.headerHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(22, metrics.short ? 6 : 8, 22, 8),
        child: Row(
          children: <Widget>[
            const Expanded(
              child: Text('翻翻手账', style: App16Typography.screenTitle),
            ),
            Text(
              '拾页',
              style: App16Typography.hand(
                fontSize: 17,
                height: 1.2,
                color: App16Colors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthHeading extends StatelessWidget {
  const _MonthHeading({required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    final metrics = App16Metrics.of(context);
    final nextEnabled = controller.canGoNextMonth();
    return SizedBox(
      height: 98,
      child: Row(
        children: <Widget>[
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                controller.viewMonth.toString().padLeft(2, '0'),
                style: App16Typography.monthNumber.copyWith(
                  fontSize: metrics.narrow ? 62 : 72,
                ),
              ),
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${controller.viewYear} 年',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: App16Typography.yearLine,
                ),
                const SizedBox(height: 5),
                Text(
                  DiaryRules.monthLabel(controller.viewMonth),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: App16Colors.ink,
                  ),
                ),
              ],
            ),
          ),
          _ArrowButton(
            key: const ValueKey<String>('app16-prev-month'),
            iconRotated: true,
            label: '上个月',
            onTap: controller.previousMonth,
          ),
          const SizedBox(width: 2),
          Opacity(
            opacity: nextEnabled ? 1 : 0.35,
            child: _ArrowButton(
              key: const ValueKey<String>('app16-next-month'),
              iconRotated: false,
              label: '下个月',
              onTap: nextEnabled ? controller.nextMonth : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    super.key,
    required this.iconRotated,
    required this.label,
    required this.onTap,
  });

  final bool iconRotated;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return App16Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Transform.rotate(
            angle: iconRotated ? 180 * 3.141592653589793 / 180 : 0,
            child: const App16Icon(
              name: 'i-chevron',
              size: 18,
              color: App16Colors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
