import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_x_widgets/app_demo/15/data/asset_manifest.dart';
import 'package:flutter_x_widgets/app_demo/15/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/15/models/achievement.dart';
import 'package:flutter_x_widgets/app_demo/15/models/root_tab.dart';
import 'package:flutter_x_widgets/app_demo/15/models/run_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/achievement_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/audio_service.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/share_service.dart';
import 'package:flutter_x_widgets/app_demo/15/models/view_models/pip_controller.dart';
import 'package:flutter_x_widgets/app_demo/15/screens/quiz_screen.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_icon.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_primary_button.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_ring.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_screen_header.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_toast.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/motion/pip_motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/design_tokens.dart';

enum _AchievementAction { share, gotoLesson }

class AchievementsScreen extends StatelessWidget {
  final PipController controller;
  final PipAudio audio;
  final PipShare share;

  const AchievementsScreen({super.key, required this.controller, required this.audio, required this.share});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final earned = controller.earnedAchievementCount;
        final total = PipSeed.achievements.length;
        final percent = total == 0 ? 0 : (earned / total * 100).round();

        return Column(
          key: const ValueKey('achievements-screen'),
          children: [
            PipScreenHeader(title: '成就', onBack: () => controller.setTab(RootTab.path)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 25, 24, 24),
                child: Column(
                  children: [
                    _AchievementSummary(earned: earned, total: total, percent: percent),
                    const SizedBox(height: 12),
                    for (var index = 0; index < PipSeed.achievements.length; index++)
                      _AchievementRow(
                        definition: PipSeed.achievements[index],
                        progress: controller.achievementProgress(PipSeed.achievements[index]),
                        last: index == PipSeed.achievements.length - 1,
                        onTap: () => _open(context, PipSeed.achievements[index]),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _open(BuildContext context, AchievementDefinition definition) async {
    final progress = controller.achievementProgress(definition);
    final action = await showGeneralDialog<_AchievementAction>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '关闭',
      barrierColor: App15Theme.ink.withValues(alpha: 0.46),
      transitionDuration: PipMotionSpec.of(context).modalPop,
      pageBuilder: (context, _, _) => _AchievementDialog(definition: definition, progress: progress),
      transitionBuilder:
          (context, animation, _, child) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          ),
    );
    if (action == null || !context.mounted) return;

    if (action == _AchievementAction.share) {
      await _share(context, definition);
    } else {
      _goToLesson(context, definition);
    }
  }

  Future<void> _share(BuildContext context, AchievementDefinition definition) async {
    final text = AchievementRules.shareText(definition, controller.state);
    final shared = await share.shareText(text);
    if (shared || !context.mounted) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    PipToast.show(context, '分享文案已复制到剪贴板。');
  }

  void _goToLesson(BuildContext context, AchievementDefinition definition) {
    final lessonId = switch (definition.metric) {
      AchievementMetric.coffee => 'coffee',
      AchievementMetric.directions => 'directions',
      AchievementMetric.challenge => 'challenge',
      _ => null,
    };
    controller.setTab(RootTab.path);
    if (lessonId == null) return;

    final completed = controller.state.completedLessons[lessonId] ?? false;
    final status = controller.startLesson(lessonId, completed ? RunMode.review : RunMode.lesson);
    if (!context.mounted) return;
    if (status == StartLessonStatus.locked) {
      PipToast.show(context, lessonId == 'directions' ? '先完成「点杯咖啡」，就能解锁「问个方向」。' : '先完成「问个方向」，就能解锁单元挑战。');
      return;
    }
    if (status == StartLessonStatus.started) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => QuizScreen(controller: controller, audio: audio)));
    }
  }
}

class _AchievementSummary extends StatelessWidget {
  final int earned;
  final int total;
  final int percent;

  const _AchievementSummary({required this.earned, required this.total, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('achievements-summary'),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: App15Theme.mint,
        borderRadius: BorderRadius.circular(App15Design.panelRadius),
        border: Border.all(color: App15Theme.ink, width: 2),
        boxShadow: const [BoxShadow(color: App15Theme.mintDark, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: App15Theme.paper,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: App15Theme.ink, width: 2),
            ),
            child: Center(child: PipIcon(asset: PipAssets.icon('trophy'), size: 25)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '已解锁 $earned / $total 枚徽章',
                  key: const ValueKey('achievements-earned'),
                  style: App15Theme.bodyStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w900, height: 1.25),
                ),
                const SizedBox(height: 4),
                Text('每一点进步都算数。', style: App15Theme.captionStyle.copyWith(fontSize: 12, color: App15Theme.ink)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          PipRing(
            fraction: total == 0 ? 0 : earned / total,
            size: 55,
            thickness: 4.5,
            trackColor: App15Theme.mintTrack,
            child: Container(
              width: 41,
              height: 41,
              decoration: const BoxDecoration(color: App15Theme.mint, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  '$percent%',
                  key: const ValueKey('achievements-percent'),
                  style: App15Theme.captionStyle.copyWith(fontSize: 11, color: App15Theme.ink, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  final AchievementDefinition definition;
  final AchievementProgress progress;
  final bool last;
  final VoidCallback onTap;

  const _AchievementRow({required this.definition, required this.progress, required this.last, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final earned = progress.earned;

    return Semantics(
      button: true,
      label: '${definition.title}，${definition.description}，${progress.text}，${earned ? '已获得' : '待解锁'}',
      child: ExcludeSemantics(
        child: GestureDetector(
          key: ValueKey('achievement-${definition.id}'),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
            decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: App15Theme.line, width: 2))),
            child: Row(
              children: [
                Opacity(
                  opacity: earned ? 1 : 0.65,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: earned ? App15Theme.yellowPale : App15Theme.lockedSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: earned ? App15Theme.ink : App15Theme.lockedBorder, width: 1.5),
                    ),
                    child: Center(child: PipIcon(asset: PipAssets.icon(definition.icon), size: 27, grayscale: !earned)),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        definition.title,
                        style: App15Theme.bodyStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          color: earned ? App15Theme.ink : App15Theme.muted,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(definition.description, style: App15Theme.captionStyle.copyWith(fontSize: 12, color: App15Theme.muted)),
                      const SizedBox(height: 2),
                      Text(progress.text, style: App15Theme.captionStyle.copyWith(fontSize: 10, color: const Color(0xFF8A8D7E))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: earned ? App15Theme.mint : App15Theme.lockedSurface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: earned ? App15Theme.ink : App15Theme.lockedBorder, width: 1.5),
                  ),
                  child: Text(
                    earned ? '已获得' : '待解锁',
                    style: App15Theme.captionStyle.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: earned ? App15Theme.ink : const Color(0xFF8C8F82),
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AchievementDialog extends StatelessWidget {
  final AchievementDefinition definition;
  final AchievementProgress progress;

  const _AchievementDialog({required this.definition, required this.progress});

  @override
  Widget build(BuildContext context) {
    final earned = progress.earned;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 330),
          child: Material(
            color: App15Theme.paper,
            borderRadius: BorderRadius.circular(App15Design.modalRadius),
            child: SingleChildScrollView(
              child: Container(
                key: const ValueKey('achievement-modal'),
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
                decoration: BoxDecoration(
                  color: App15Theme.paper,
                  borderRadius: BorderRadius.circular(App15Design.modalRadius),
                  border: Border.all(color: App15Theme.ink, width: 2),
                  boxShadow: const [BoxShadow(color: App15Theme.ink, offset: Offset(0, 8))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        color: earned ? App15Theme.yellow : App15Theme.lockedSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: earned ? App15Theme.ink : App15Theme.lockedBorder, width: 2),
                        boxShadow: [BoxShadow(color: earned ? App15Theme.yellowDark : App15Theme.lockedBorder, offset: const Offset(0, 4))],
                      ),
                      child: Center(child: PipIcon(asset: PipAssets.icon(definition.icon), size: 38, grayscale: !earned)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: earned ? App15Theme.mint : App15Theme.lockedSurface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        earned ? '已获得' : '未解锁',
                        style: App15Theme.captionStyle.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: earned ? App15Theme.ink : App15Theme.muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Semantics(
                      header: true,
                      child: Text(
                        definition.title,
                        textAlign: TextAlign.center,
                        style: App15Theme.bodyStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.6, height: 1.2),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      definition.description,
                      textAlign: TextAlign.center,
                      style: App15Theme.bodyStyle.copyWith(fontSize: 13, color: App15Theme.muted, height: 1.45),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBFBF4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: App15Theme.line, width: 1.5),
                      ),
                      child: Text(progress.text, style: App15Theme.captionStyle.copyWith(fontSize: 11, color: const Color(0xFF6F7365))),
                    ),
                    const SizedBox(height: 15),
                    PipPrimaryButton(
                      key: const ValueKey('achievement-modal-action'),
                      label: earned ? '分享成就' : '去完成这一步',
                      height: 52,
                      leading: PipIcon(asset: PipAssets.icon(earned ? 'share' : 'arrow'), size: 19),
                      onPressed: () => Navigator.of(context).pop(earned ? _AchievementAction.share : _AchievementAction.gotoLesson),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      key: const ValueKey('achievement-modal-close'),
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF777B6D),
                        side: const BorderSide(color: App15Theme.ink, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('关闭', style: App15Theme.captionStyle.copyWith(fontSize: 12, color: const Color(0xFF777B6D))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
