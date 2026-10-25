import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/data/asset_manifest.dart';
import 'package:flutter_x_widgets/app_demo/15/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/daily_goal_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/lesson_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/run_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/audio_service.dart';
import 'package:flutter_x_widgets/app_demo/15/models/view_models/pip_controller.dart';
import 'package:flutter_x_widgets/app_demo/15/screens/quiz_screen.dart';
import 'package:flutter_x_widgets/app_demo/15/screens/review_deck_screen.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_icon.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_primary_button.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_progress_bar.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_toast.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/path/lesson_map.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/design_tokens.dart';

class PathScreen extends StatelessWidget {
  final PipController controller;
  final PipAudio audio;

  const PathScreen({super.key, required this.controller, required this.audio});

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final currentLessonId = LessonRules.currentLessonId(state.completedLessons);
    final activeRun = currentLessonId == null ? state.run : controller.activeRunFor(currentLessonId);
    final resumableNodeIds = <String>{
      for (final lessonId in PipSeed.lessonOrder)
        if (controller.activeRunFor(lessonId) != null) lessonId,
    };
    final action = _resolveAction(currentLessonId, activeRun);

    return Column(
      key: const ValueKey('path-screen'),
      children: [
        _PathHeader(streak: state.streak, xp: state.xp, lives: state.lives),
        const _UnitBanner(),
        _DailyGoalRow(seconds: state.dailySeconds, goal: state.dailyGoal),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LessonMap(
              completedLessons: state.completedLessons,
              currentLessonId: currentLessonId,
              resumableNodeIds: resumableNodeIds,
              allDone: currentLessonId == null,
              onNodeTap: (nodeId, visual) => _handleNodeTap(context, nodeId, visual),
            ),
          ),
        ),
        _PathActionArea(
          ctaLabel: action.label,
          metaText: action.meta,
          allDone: action.allDone,
          onPressed: () => _startLesson(context, action.lessonId, action.mode),
        ),
      ],
    );
  }

  _PathAction _resolveAction(String? currentLessonId, RunState? activeRun) {
    if (currentLessonId == null) {
      if (activeRun != null) {
        final lesson = PipSeed.lessonsById[activeRun.lessonId];
        final label = activeRun.mode == RunMode.review ? '继续复习' : '继续这一课';
        return _PathAction(
          label: label,
          meta: '已完成 ${activeRun.answered} / ${lesson?.questions.length ?? 0} 题',
          allDone: false,
          lessonId: activeRun.lessonId,
          mode: activeRun.mode,
        );
      }
      return const _PathAction(label: '复习点单', meta: '本单元已通关 · 可随时复习', allDone: true, lessonId: 'coffee', mode: RunMode.review);
    }

    final lesson = PipSeed.lessonsById[currentLessonId]!;
    if (activeRun != null) {
      final label = activeRun.mode == RunMode.review ? '继续复习' : '继续这一课';
      return _PathAction(
        label: label,
        meta: '已完成 ${activeRun.answered} / ${lesson.questions.length} 题',
        allDone: false,
        lessonId: currentLessonId,
        mode: activeRun.mode,
      );
    }

    final label = switch (currentLessonId) {
      'coffee' => '开始这一课',
      'directions' => '学习问路',
      _ => '开始单元挑战',
    };
    return _PathAction(
      label: label,
      meta: '${lesson.questions.length} 道题 · ${lesson.estimated}',
      allDone: false,
      lessonId: currentLessonId,
      mode: RunMode.lesson,
    );
  }

  Future<void> _handleNodeTap(BuildContext context, String nodeId, LessonNodeVisual visual) async {
    if (visual == LessonNodeVisual.locked) {
      PipToast.show(context, _lockedMessage(nodeId));
      return;
    }

    if (PipSeed.reviewOnlyNodeIds.contains(nodeId)) {
      await audio.stop();
      if (!context.mounted) return;
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => ReviewDeckScreen(controller: controller, audio: audio, topicId: nodeId)));
      return;
    }

    await _startLesson(context, nodeId, visual == LessonNodeVisual.completed ? RunMode.review : RunMode.lesson);
  }

  Future<void> _startLesson(BuildContext context, String lessonId, RunMode mode) async {
    final status = controller.startLesson(lessonId, mode);
    if (!context.mounted) return;
    if (status == StartLessonStatus.locked) {
      PipToast.show(context, _lockedMessage(lessonId));
      return;
    }
    if (status != StartLessonStatus.started) return;

    await audio.stop();
    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => QuizScreen(controller: controller, audio: audio)));
  }

  String _lockedMessage(String lessonId) {
    return lessonId == 'directions' ? '先完成「点杯咖啡」，就能解锁「问个方向」。' : '先完成「问个方向」，就能解锁单元挑战。';
  }
}

class _PathAction {
  final String label;
  final String meta;
  final bool allDone;
  final String lessonId;
  final RunMode mode;

  const _PathAction({required this.label, required this.meta, required this.allDone, required this.lessonId, required this.mode});
}

class _PathHeader extends StatelessWidget {
  final int streak;
  final int xp;
  final int lives;

  const _PathHeader({required this.streak, required this.xp, required this.lives});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: App15Design.topBarHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 15, 25, 12),
        child: Row(
          children: [
            const _PipWordmark(),
            const Spacer(),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Resource(
                      key: const ValueKey('path-resource-streak'),
                      icon: 'flame',
                      value: '$streak',
                      unit: '天',
                      semanticsLabel: '连续学习 $streak 天',
                    ),
                    const SizedBox(width: 16),
                    _Resource(
                      key: const ValueKey('path-resource-xp'),
                      icon: 'bolt',
                      value: _formatNumber(xp),
                      unit: 'XP',
                      semanticsLabel: '$xp 经验值',
                    ),
                    const SizedBox(width: 16),
                    _Resource(key: const ValueKey('path-resource-lives'), icon: 'heart', value: '$lives', semanticsLabel: '剩余 $lives 颗生命'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < text.length; index++) {
      if (index > 0 && (text.length - index) % 3 == 0) buffer.write(',');
      buffer.write(text[index]);
    }
    return buffer.toString();
  }
}

class _PipWordmark extends StatelessWidget {
  const _PipWordmark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pip 英语学习',
      child: ExcludeSemantics(
        child: Transform.rotate(
          angle: -4 * math.pi / 180,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Text('pip', style: App15Theme.brandStyle),
              Positioned(
                right: -9,
                top: 3,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: App15Theme.yellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: App15Theme.ink, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Resource extends StatelessWidget {
  final String icon;
  final String value;
  final String? unit;
  final String semanticsLabel;

  const _Resource({super.key, required this.icon, required this.value, required this.semanticsLabel, this.unit});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PipIcon(asset: PipAssets.icon(icon), size: 21, height: 25),
            const SizedBox(width: 5),
            Text(value, style: App15Theme.bodyStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w900, height: 1)),
            if (unit != null) ...[
              const SizedBox(width: 2),
              Text(
                unit!,
                style: App15Theme.captionStyle.copyWith(color: App15Theme.ink, fontSize: 11, fontWeight: FontWeight.w900, height: 1),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UnitBanner extends StatelessWidget {
  const _UnitBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: App15Theme.yellow,
        border: Border(top: BorderSide(color: App15Theme.ink, width: 2), bottom: BorderSide(color: App15Theme.ink, width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(App15Design.unitBannerPaddingX, 16, App15Design.unitBannerPaddingX, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PipSeed.unitEyebrow,
                  style: App15Theme.captionStyle.copyWith(color: App15Theme.ink, fontSize: 13, letterSpacing: 0.2, height: 1.2),
                ),
                const SizedBox(height: 7),
                Text(
                  PipSeed.unitTitle,
                  key: const ValueKey('path-unit-title'),
                  style: App15Theme.pathTitleStyle.copyWith(fontSize: 24, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Transform.rotate(angle: -8 * math.pi / 180, child: PipIcon(asset: PipAssets.icon('cup'), size: 47, height: 48)),
        ],
      ),
    );
  }
}

class _DailyGoalRow extends StatelessWidget {
  final int seconds;
  final int goal;

  const _DailyGoalRow({required this.seconds, required this.goal});

  @override
  Widget build(BuildContext context) {
    final minutes = DailyGoalRules.displayMinutes(seconds, goal);
    final done = seconds >= goal * 60;
    final label = '$minutes / $goal 分钟${done ? ' · 已完成' : ''}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 17, 25, 9),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('今日目标', style: App15Theme.bodyStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w900, height: 1)),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    key: const ValueKey('path-today-minutes'),
                    maxLines: 1,
                    style: App15Theme.captionStyle.copyWith(fontSize: 13, height: 1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          PipProgressBar(
            key: const ValueKey('path-daily-progress'),
            width: 100,
            height: 11,
            fraction: seconds / (goal * 60),
            semanticsValue: '$minutes / $goal 分钟',
          ),
        ],
      ),
    );
  }
}

class _PathActionArea extends StatelessWidget {
  final String ctaLabel;
  final String metaText;
  final bool allDone;
  final VoidCallback onPressed;

  const _PathActionArea({required this.ctaLabel, required this.metaText, required this.allDone, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 11, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 24,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (allDone) ...[
                    const PipIcon(asset: 'assets/images/15/icons/trophy.svg', size: 16, color: App15Theme.mintDark),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    metaText,
                    key: const ValueKey('path-cta-meta'),
                    maxLines: 1,
                    style: App15Theme.captionStyle.copyWith(fontSize: 13, height: 1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          PipPrimaryButton(
            key: const ValueKey('path-cta'),
            label: ctaLabel,
            height: 53,
            trailing: PipIcon(asset: PipAssets.icon('arrow'), size: 21),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
