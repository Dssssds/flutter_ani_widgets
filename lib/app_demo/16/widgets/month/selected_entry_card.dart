import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/diary_entry.dart';
import 'package:flutter_x_widgets/app_demo/16/models/view_models/diary_controller.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_icon.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_pressable.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/month/mini_page.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';

class SelectedEntryCard extends StatelessWidget {
  const SelectedEntryCard({super.key, required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    final entry = controller.selectedEntry;
    final date = formatShortDate(controller.viewMonth, controller.selectedDay);
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: App16Pressable(
        onTap:
            () => controller.openDate(
              controller.viewYear,
              controller.viewMonth,
              controller.selectedDay,
            ),
        semanticLabel: entry == null ? '写下这一天' : '打开$date的手账',
        minSize: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  date,
                  style: App16Typography.number(
                    fontSize: 19,
                    letterSpacing: 0.5,
                    color: App16Colors.berry,
                  ),
                ),
                const Spacer(),
                if (entry == null)
                  const Text(
                    '还没有写下这一天',
                    style: TextStyle(fontSize: 11, color: App16Colors.muted),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              constraints: const BoxConstraints(minHeight: 106),
              child:
                  entry == null
                      ? const _EmptySummary()
                      : _EntrySummary(entry: entry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntrySummary extends StatelessWidget {
  const _EntrySummary({required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        EntryThumbnail(entry: entry),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                entry.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: App16Colors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.note,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: App16Colors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        const App16Icon(name: 'i-chevron', size: 18, color: App16Colors.berry),
      ],
    );
  }
}

class _EmptySummary extends StatelessWidget {
  const _EmptySummary();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '给这一天留个位置',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: App16Colors.ink,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '一张照片，或者一句话。',
                style: TextStyle(fontSize: 13, color: App16Colors.muted),
              ),
              SizedBox(height: 8),
              Text(
                '写下这一天',
                style: TextStyle(fontSize: 12, color: App16Colors.berry),
              ),
            ],
          ),
        ),
        App16Icon(name: 'i-chevron', size: 18, color: App16Colors.berry),
      ],
    );
  }
}
