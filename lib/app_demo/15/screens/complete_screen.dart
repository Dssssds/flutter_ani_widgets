import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/data/asset_manifest.dart';
import 'package:flutter_x_widgets/app_demo/15/models/lesson_result.dart';
import 'package:flutter_x_widgets/app_demo/15/models/root_tab.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/study_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/run_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/audio_service.dart';
import 'package:flutter_x_widgets/app_demo/15/models/view_models/pip_controller.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_bird.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_icon.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_primary_button.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/motion/pip_motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';

class CompleteScreen extends StatefulWidget {
  final PipController controller;
  final PipAudio audio;
  final LessonResult result;

  const CompleteScreen({super.key, required this.controller, required this.audio, required this.result});

  @override
  State<CompleteScreen> createState() => _CompleteScreenState();
}

class _CompleteScreenState extends State<CompleteScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.state.soundOn) {
      unawaited(widget.audio.playAsset(PipAssets.chime));
    }
  }

  @override
  void dispose() {
    unawaited(widget.audio.stop());
    super.dispose();
  }

  LessonResult get result => widget.result;

  ({String title, String subtitle}) get _copy {
    if (result.lessonId == 'challenge') {
      return (title: '整条街，都敢开口了！', subtitle: '咖啡和问路，一次打通。');
    }
    if (result.lessonId == 'directions') {
      return (title: '这条路，你走通了！', subtitle: '下次问路，别再只靠手势。');
    }
    if (result.mode == RunMode.review) {
      return (title: '又练了一遍，更顺了！', subtitle: '重复，是把句子变成本能的方式。');
    }
    return (title: '这杯英语，你拿下了！', subtitle: '下次点咖啡，试着用英语说说看。');
  }

  String get _ctaLabel {
    if (result.demo) return '返回学习路径';
    if (result.allDone && result.lessonId == 'challenge') return '查看单元成就';
    if (result.mode == RunMode.review) return '返回学习路径';
    return '收下奖励';
  }

  String get _footnote {
    if (result.demo) return '这是演示结算页，可以直接返回路径。';
    final goalSeconds = result.dailyGoal * 60;
    final remaining = math.max(0, ((goalSeconds - result.dailySeconds) / 60).ceil());
    return remaining > 0 ? '再学 $remaining 分钟，完成今日目标。' : '今日目标已完成，明天继续。';
  }

  void _finish() {
    unawaited(widget.audio.stop());
    Navigator.of(context).popUntil((route) => route.isFirst);
    widget.controller.setTab(result.allDone && result.lessonId == 'challenge' ? RootTab.achievements : RootTab.path);
  }

  @override
  Widget build(BuildContext context) {
    final copy = _copy;

    return Scaffold(
      key: const ValueKey('complete-screen'),
      backgroundColor: App15Theme.paper,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _CompleteHeader(eyebrow: result.eyebrow, title: result.title),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 13),
                    _Celebration(animate: !result.demo),
                    const SizedBox(height: 8),
                    Text(
                      copy.title,
                      key: const ValueKey('complete-title'),
                      textAlign: TextAlign.center,
                      style: App15Theme.finishTitleStyle,
                    ),
                    const SizedBox(height: 9),
                    Text(
                      copy.subtitle,
                      textAlign: TextAlign.center,
                      style: App15Theme.bodyStyle.copyWith(fontSize: 15, color: App15Theme.muted),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _RewardCard(result: result)),
                        const SizedBox(width: 13),
                        Expanded(child: _AccuracyCard(accuracy: result.accuracy)),
                      ],
                    ),
                    const SizedBox(height: 27),
                    _StreakCard(controller: widget.controller),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 25, 24, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PipPrimaryButton(
                    key: const ValueKey('complete-cta'),
                    label: _ctaLabel,
                    height: 58,
                    trailing: PipIcon(asset: PipAssets.icon('arrow'), size: 21),
                    onPressed: _finish,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _footnote,
                    key: const ValueKey('complete-footnote'),
                    textAlign: TextAlign.center,
                    style: App15Theme.captionStyle.copyWith(fontSize: 13, color: App15Theme.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompleteHeader extends StatelessWidget {
  final String eyebrow;
  final String title;

  const _CompleteHeader({required this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 0),
        child: Row(
          children: [
            Semantics(
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
            ),
            const Spacer(),
            Flexible(
              child: Text(
                '$eyebrow · $title',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: App15Theme.captionStyle.copyWith(fontSize: 13, color: App15Theme.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Celebration extends StatelessWidget {
  final bool animate;

  const _Celebration({required this.animate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 243,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 178,
              height: 178,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: App15Theme.paper,
                border: Border.all(color: App15Theme.yellow, width: 5),
              ),
            ),
            Positioned(
              bottom: 7,
              child: Container(
                width: 122,
                height: 15,
                decoration: BoxDecoration(color: App15Theme.ink.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
              ),
            ),
            _CelebrateBird(animate: animate),
            const Positioned(left: 16, top: 24, child: PipIcon(asset: 'assets/images/15/icons/spark.svg', size: 22)),
            const Positioned(right: 15, top: 82, child: PipIcon(asset: 'assets/images/15/icons/spark.svg', size: 17)),
            const Positioned(right: 50, top: 26, child: _Confetti(color: App15Theme.red, angle: 20)),
            const Positioned(left: 46, top: 86, child: _Confetti(color: App15Theme.mintDark, angle: -28)),
            const Positioned(left: 18, top: 158, child: _Confetti(color: App15Theme.yellowDark, angle: 35)),
            const Positioned(right: 22, top: 160, child: _Confetti(color: App15Theme.mintDark, angle: -15)),
            const Positioned(left: 62, top: 12, child: _Dot(color: App15Theme.red)),
          ],
        ),
      ),
    );
  }
}

class _CelebrateBird extends StatelessWidget {
  final bool animate;

  const _CelebrateBird({required this.animate});

  @override
  Widget build(BuildContext context) {
    const bird = PipBird(semanticsLabel: 'Pip 为你庆祝', asset: PipAssets.birdCelebrate, width: 198, height: 214, rotationDegrees: 0);
    final motion = PipMotionSpec.of(context);
    if (!animate || motion.reduceMotion) return bird;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: motion.celebrationPop,
      builder: (context, value, child) {
        final double degrees;
        final double scale;
        final double translateY;
        if (value < 0.45) {
          final k = value / 0.45;
          degrees = -6 - 6 * k;
          scale = 0.91 + 0.17 * k;
          translateY = 7 - 16 * k;
        } else {
          final k = (value - 0.45) / 0.55;
          degrees = -12 + 6 * k;
          scale = 1.08 - 0.08 * k;
          translateY = -9 + 9 * k;
        }
        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.rotate(angle: degrees * math.pi / 180, child: Transform.scale(scale: scale, child: child)),
        );
      },
      child: bird,
    );
  }
}

class _Confetti extends StatelessWidget {
  final Color color;
  final double angle;

  const _Confetti({required this.color, required this.angle});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle * math.pi / 180,
      child: Container(width: 7, height: 17, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class _RewardCard extends StatelessWidget {
  final LessonResult result;

  const _RewardCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final label = result.xpAwarded > 0 ? (result.lessonId == 'challenge' ? '挑战奖励' : '本课经验') : '复习成果';

    return _StatCard(
      label: label,
      child:
          result.xpAwarded > 0
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const PipIcon(asset: 'assets/images/15/icons/bolt.svg', size: 23),
                  const SizedBox(width: 9),
                  Text(
                    '+${result.xpAwarded}',
                    key: const ValueKey('complete-reward-xp'),
                    style: App15Theme.bodyStyle.copyWith(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -0.8, height: 1),
                  ),
                  const SizedBox(width: 3),
                  Text(' XP', style: App15Theme.captionStyle.copyWith(color: App15Theme.ink, fontSize: 12, fontWeight: FontWeight.w900)),
                ],
              )
              : Text('已巩固', style: App15Theme.bodyStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w900)),
    );
  }
}

class _AccuracyCard extends StatelessWidget {
  final int accuracy;

  const _AccuracyCard({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      label: '正确率',
      labelBackground: App15Theme.mint,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PipIcon(asset: 'assets/images/15/icons/target.svg', size: 23),
          const SizedBox(width: 9),
          Text(
            '$accuracy%',
            key: const ValueKey('complete-accuracy'),
            style: App15Theme.bodyStyle.copyWith(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -0.8, height: 1),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final Widget child;
  final Color labelBackground;

  const _StatCard({required this.label, required this.child, this.labelBackground = App15Theme.yellow});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: App15Theme.paper,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: App15Theme.ink, width: 2),
        boxShadow: const [BoxShadow(color: App15Theme.neutralShadow, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(color: labelBackground, border: const Border(bottom: BorderSide(color: App15Theme.ink, width: 2))),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: App15Theme.captionStyle.copyWith(color: App15Theme.ink, fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(height: 64, child: Center(child: child)),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final PipController controller;

  const _StreakCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final now = controller.now;
    final today = DateTime(now.year, now.month, now.day, 12);
    const names = ['日', '一', '二', '三', '四', '五', '六'];

    return Container(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 18),
      decoration: BoxDecoration(
        color: App15Theme.paper,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: App15Theme.ink, width: 2),
        boxShadow: const [BoxShadow(color: App15Theme.neutralShadow, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PipIcon(asset: 'assets/images/15/icons/flame.svg', size: 31, height: 36),
              const SizedBox(width: 8),
              Text(
                '连续学习 ${state.streak} 天！',
                key: const ValueKey('complete-streak-title'),
                style: App15Theme.bodyStyle.copyWith(fontSize: 23, fontWeight: FontWeight.w900, height: 1.3),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var offset = 6; offset >= 0; offset--)
                _DayCell(
                  label: offset == 0 ? '今天' : names[today.subtract(Duration(days: offset)).weekday % 7],
                  studied: state.studyDates.contains(StudyRules.dayKey(today.subtract(Duration(days: offset)))),
                  today: offset == 0,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String label;
  final bool studied;
  final bool today;

  const _DayCell({required this.label, required this.studied, required this.today});

  @override
  Widget build(BuildContext context) {
    final dashed = today && !studied;
    Widget disc = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: studied ? (today ? App15Theme.yellow : App15Theme.yellowPale) : App15Theme.paper,
        shape: BoxShape.circle,
        border: dashed ? null : Border.all(color: studied ? (today ? App15Theme.ink : App15Theme.yellowDark) : App15Theme.paper, width: 2),
        boxShadow: today && studied ? const [BoxShadow(color: App15Theme.ink, offset: Offset(0, 3))] : null,
      ),
      child: Center(
        child:
            studied
                ? const PipIcon(asset: 'assets/images/15/icons/check.svg', size: 15)
                : Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: dashed ? const Color(0xFFC9CCBD) : App15Theme.neutralBorder, shape: BoxShape.circle),
                ),
      ),
    );
    if (dashed) {
      disc = Stack(
        alignment: Alignment.center,
        children: [
          disc,
          const SizedBox(
            width: 30,
            height: 30,
            child: IgnorePointer(child: CustomPaint(painter: _DashedCirclePainter(color: Color(0xFFB9BCAA)))),
          ),
        ],
      );
    }
    if (today && studied) disc = Transform.rotate(angle: -7 * math.pi / 180, child: disc);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: App15Theme.captionStyle.copyWith(fontSize: 12, color: App15Theme.mutedLabel, height: 1)),
        const SizedBox(height: 6),
        disc,
      ],
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    final path = Path()..addOval(Rect.fromLTWH(1, 1, size.width - 2, size.height - 2));

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + 4 < metric.length ? distance + 4 : metric.length;
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + 4;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) => oldDelegate.color != color;
}
