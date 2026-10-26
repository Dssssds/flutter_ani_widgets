import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/rules/diary_rules.dart';
import 'package:flutter_x_widgets/app_demo/16/models/view_models/diary_controller.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/month/mini_page.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/design_tokens.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({super.key, required this.controller});

  final DiaryController controller;

  static const _week = <String>['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    final metrics = App16Metrics.of(context);
    final year = controller.viewYear;
    final month = controller.viewMonth;
    final entries = controller.entriesForMonth(year, month);
    final leading = DiaryRules.leadingEmptyDays(year, month);
    final days = DiaryRules.daysInMonth(year, month);
    final cellHeight = metrics.narrow ? 66.0 : 59.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 13),
      decoration: BoxDecoration(
        color: App16Colors.paper,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x05704458),
            offset: Offset(0, 2),
            blurRadius: 5,
          ),
          BoxShadow(
            color: Color(0x05704458),
            offset: Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: _week
                .map(
                  (label) => Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: App16Colors.muted,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 9),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leading + days,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              mainAxisExtent: cellHeight,
            ),
            itemBuilder: (context, index) {
              final day = index - leading + 1;
              if (day < 1 || day > days) {
                return const SizedBox.shrink();
              }
              final future = controller.isFutureDay(day);
              final entry = entries[day];
              final selected = controller.selectedDay == day;
              final label =
                  future
                      ? '$month月$day日，还不能写'
                      : entry != null
                      ? '$month月$day日，有手账'
                      : '$month月$day日，还没有手账';
              return Semantics(
                key: ValueKey<String>('app16-day-$day'),
                button: !future,
                enabled: !future,
                selected: selected,
                label: label,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: future ? null : () => controller.selectDay(day),
                  child: Opacity(
                    opacity: future ? 0.35 : 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            selected
                                ? App16Colors.selected
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border:
                            selected
                                ? Border.all(color: const Color(0x3D9D3C65))
                                : null,
                      ),
                      child:
                          entry != null
                              ? Column(
                                children: <Widget>[
                                  const SizedBox(height: 3),
                                  Text('$day', style: _dayStyle(selected)),
                                  const SizedBox(height: 2),
                                  MiniPage(
                                    data: DiaryRules.deriveMiniPage(entry),
                                  ),
                                ],
                              )
                              : Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Text(
                                        '$day',
                                        style: _dayStyle(selected),
                                      ),
                                    ),
                                  ),
                                  if (!future)
                                    const Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 21,
                                      child: Center(
                                        child: SizedBox(
                                          width: 3,
                                          height: 3,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Color(0xFFD9CBD1),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  TextStyle _dayStyle(bool selected) {
    return TextStyle(
      fontSize: 13,
      height: 15 / 13,
      color: selected ? App16Colors.berry : App16Colors.muted,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
    );
  }
}
