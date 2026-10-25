import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/15/models/root_tab.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/achievement_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/daily_goal_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/view_models/pip_controller.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_bird.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_icon.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_primary_button.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_screen_header.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_toast.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/motion/pip_motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';

class ProfileScreen extends StatelessWidget {
  final PipController controller;

  const ProfileScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        final minutes = DailyGoalRules.displayMinutes(state.dailySeconds, state.dailyGoal);

        return Column(
          key: const ValueKey('profile-screen'),
          children: [
            PipScreenHeader(title: '我的 Pip', onBack: () => controller.setTab(RootTab.path)),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const padding = EdgeInsets.fromLTRB(24, 25, 24, 24);
                  return SingleChildScrollView(
                    padding: padding,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - padding.vertical),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const PipBird(asset: 'assets/images/15/bird_wave.svg', width: 112, height: 112),
                            const SizedBox(height: 12),
                            Semantics(
                              header: true,
                              child: Text(
                                '小林的学习日常',
                                key: const ValueKey('profile-name'),
                                textAlign: TextAlign.center,
                                style: App15Theme.bodyStyle.copyWith(fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: -0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const _DetailRow(label: '正在学习', value: '英语 · 初级 A1'),
                            _DetailRow(
                              key: const ValueKey('profile-xp'),
                              label: '累计经验',
                              value: '${AchievementRules.formatNumber(state.xp)} XP',
                            ),
                            _DetailRow(key: const ValueKey('profile-streak'), label: '连续学习', value: '${state.streak} 天'),
                            _DetailRow(
                              key: const ValueKey('profile-lessons'),
                              label: '已完成关卡',
                              value: '${controller.completedLessonCount} / ${state.completedLessons.length}',
                            ),
                            _DetailRow(
                              key: const ValueKey('profile-mastered'),
                              label: '复习掌握',
                              value: '${controller.totalMastered} / ${controller.totalTermCount}',
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.only(top: 14),
                              decoration: const BoxDecoration(border: Border(top: BorderSide(color: App15Theme.line, width: 2))),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text('每天的目标', style: App15Theme.bodyStyle.copyWith(fontSize: 14, color: App15Theme.muted)),
                                      const Spacer(),
                                      Text(
                                        '$minutes / ${state.dailyGoal} 分钟',
                                        key: const ValueKey('profile-goal-text'),
                                        style: App15Theme.bodyStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      for (var index = 0; index < PipSeed.dailyGoalOptions.length; index++) ...[
                                        if (index > 0) const SizedBox(width: 8),
                                        Expanded(
                                          child: _GoalChip(
                                            key: ValueKey('profile-goal-${PipSeed.dailyGoalOptions[index]}'),
                                            minutes: PipSeed.dailyGoalOptions[index],
                                            active: state.dailyGoal == PipSeed.dailyGoalOptions[index],
                                            onPressed: () => _setGoal(context, PipSeed.dailyGoalOptions[index]),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text('改变目标后，今日进度会按新目标重新计算。', style: App15Theme.captionStyle.copyWith(fontSize: 11, height: 1.4)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Spacer(),
                            PipPrimaryButton(
                              key: const ValueKey('profile-back-to-path'),
                              label: '回去学一点',
                              trailing: const PipIcon(asset: 'assets/images/15/icons/arrow.svg', size: 20),
                              onPressed: () => controller.setTab(RootTab.path),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _setGoal(BuildContext context, int goal) async {
    await controller.setDailyGoal(goal);
    if (!context.mounted) return;
    PipToast.show(context, '每日目标已改为 $goal 分钟。');
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: App15Theme.line, width: 2))),
      child: Row(
        children: [
          Text(label, style: App15Theme.bodyStyle.copyWith(fontSize: 14, color: App15Theme.muted)),
          const Spacer(),
          Text(value, style: App15Theme.bodyStyle.copyWith(fontSize: 15, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _GoalChip extends StatefulWidget {
  final int minutes;
  final bool active;
  final VoidCallback onPressed;

  const _GoalChip({super.key, required this.minutes, required this.active, required this.onPressed});

  @override
  State<_GoalChip> createState() => _GoalChipState();
}

class _GoalChipState extends State<_GoalChip> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final motion = PipMotionSpec.of(context);
    final active = widget.active;
    final borderColor = active ? App15Theme.yellowDark : App15Theme.neutralBorder;

    return Semantics(
      button: true,
      selected: active,
      label: '${widget.minutes} 分钟',
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: motion.buttonPress,
            height: 40,
            transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
            decoration: BoxDecoration(
              color: active ? App15Theme.yellowSelected : App15Theme.paper,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [BoxShadow(color: borderColor, offset: Offset(0, _pressed ? 1 : 3))],
            ),
            child: Center(
              child: Text(
                '${widget.minutes} 分钟',
                style: App15Theme.captionStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: active ? App15Theme.ink : App15Theme.mutedLabel,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
