import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/view_models/diary_controller.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_icon.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_pressable.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/journal/editor_toolbar.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/journal/paper_canvas.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/design_tokens.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key, required this.controller, required this.paperKey});

  final DiaryController controller;
  final GlobalKey paperKey;

  @override
  Widget build(BuildContext context) {
    final metrics = App16Metrics.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: metrics.navTotalHeight),
      child: Column(
        children: <Widget>[
          _JournalHeader(controller: controller),
          if (controller.saveError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 4, 23, 6),
              child: Text(controller.saveError, style: const TextStyle(fontSize: 13, height: 1.5, color: App16Colors.errorInk)),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(metrics.pagePadding, 0, metrics.pagePadding, 12),
              child: Column(children: <Widget>[_DateHeading(controller: controller), PaperCanvas(key: paperKey, controller: controller)]),
            ),
          ),
          EditorToolbar(controller: controller),
        ],
      ),
    );
  }
}

class _JournalHeader extends StatelessWidget {
  const _JournalHeader({required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    final metrics = App16Metrics.of(context);
    final canUndo = controller.history.isNotEmpty;
    final saveLabel =
        controller.saving
            ? '保存中'
            : controller.saved
            ? '已保存'
            : '保存';
    final savedTone = controller.saved && !controller.saving;

    return SizedBox(
      height: metrics.headerHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(23, metrics.short ? 6 : 8, 23, 8),
        child: Row(
          children: <Widget>[
            App16Pressable(
              onTap: controller.goToday,
              semanticLabel: '打开今天的手账',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Transform.rotate(
                    angle: -7 * 3.141592653589793 / 180,
                    child: const App16Icon(name: 'i-book', size: 28, color: App16Colors.berry),
                  ),
                  const SizedBox(width: 7),
                  const Text('拾页', style: App16Typography.brand),
                ],
              ),
            ),
            const Spacer(),
            Opacity(
              opacity: canUndo ? 1 : 0.35,
              child: App16Pressable(
                key: const ValueKey<String>('app16-undo'),
                onTap: canUndo ? controller.undo : null,
                semanticLabel: '撤销',
                child: const SizedBox(width: 44, height: 44, child: Center(child: App16Icon(name: 'i-undo', size: 20))),
              ),
            ),
            const SizedBox(width: 8),
            App16Pressable(
              key: const ValueKey<String>('app16-save'),
              onTap: controller.saving ? null : controller.saveEntry,
              semanticLabel: savedTone ? '已保存' : '保存这一页',
              child: Container(
                width: 92,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: savedTone ? App16Colors.selected : App16Colors.berry,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    App16Icon(name: 'i-check', size: 16, color: savedTone ? App16Colors.berry : Colors.white),
                    const SizedBox(width: 6),
                    Text(saveLabel, style: App16Typography.primaryButton.copyWith(color: savedTone ? App16Colors.berry : Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateHeading extends StatelessWidget {
  const _DateHeading({required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    final entry = controller.entry;
    final metrics = App16Metrics.of(context);
    final healed = entry.mood == '被治愈了';

    return SizedBox(
      height: metrics.dateHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
        child: Row(
          children: <Widget>[
            Text(entry.day.toString().padLeft(2, '0'), style: App16Typography.bigDay.copyWith(fontSize: metrics.narrow ? 46 : 50)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${entry.month} 月 · ${entry.weekday}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: App16Typography.dateLine,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${entry.year} 年 · 秋日手账',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: App16Typography.yearLine.copyWith(fontSize: metrics.narrow ? 11 : 13),
                  ),
                ],
              ),
            ),
            App16Pressable(
              key: const ValueKey<String>('app16-mood'),
              onTap: controller.toggleMood,
              semanticLabel: '切换心情，当前${entry.mood}',
              minSize: 54,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    App16Icon(name: healed ? 'i-heart' : 'i-sun', size: 23, color: App16Colors.muted),
                    const SizedBox(height: 5),
                    Text(entry.mood, style: const TextStyle(fontSize: 12, color: App16Colors.muted)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
