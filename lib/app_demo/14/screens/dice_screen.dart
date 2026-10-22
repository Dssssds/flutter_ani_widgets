import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/dice_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/rules/dice_rules.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/feedback_service.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/random_source.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/dice_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/dice/dice_action_button.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/dice/dice_count_selector.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/dice/dice_motion.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/dice/dice_painter.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/dice/dice_stage_background.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/dice/dice_theme.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/game_scaffold.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

/// 掷骰子：选择 1 或 2 枚骰子，点击按钮（或骰子）掷出，落定后显示合计与分项。
class DiceScreen extends StatefulWidget {
  const DiceScreen({super.key, required this.settings, this.random, this.feedback, this.motionRandom});

  final SettingsViewModel settings;

  /// 点数的随机源，测试里注入固定序列。
  final IntRandomSource? random;
  final FeedbackService? feedback;

  /// 只影响翻滚轨迹和落点的视觉随机，不影响点数。
  final math.Random? motionRandom;

  @override
  State<DiceScreen> createState() => _DiceScreenState();
}

/// 一枚静止骰子：归一化中心和姿态。
typedef _Rest = ({Offset center, Rot3 rotation});

class _DiceScreenState extends State<DiceScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  /// 数量切换的中心约在屏高 17% 处，宽约屏宽 60%。
  static const _selectorCenter = .17;
  static const _selectorWidth = .6;

  /// 结果区从屏高 63% 开始。
  static const _resultTop = .63;

  late final _model = DiceViewModel(DiceRules(widget.random ?? DartIntRandomSource()));
  late final _feedback = widget.feedback ?? const PlatformFeedbackService();
  late final _motionRandom = widget.motionRandom ?? math.Random();
  late final _controller = AnimationController(vsync: this, animationBehavior: AnimationBehavior.preserve);

  DiceRound? _round;
  DiceMotionPlan? _plan;
  List<_Rest> _rest = _defaultRest(1);

  /// 最近一次落定的点数；切换数量后结果淡出期间还要用它渲染文字。
  List<int>? _lastValues;
  DiceStageLayout _layout = const DiceStageLayout(width: 390, screenHeight: 844, headerBottom: 103);
  bool _reduced = false;
  bool _active = true;
  bool _leaving = false;

  static List<_Rest> _defaultRest(int count) {
    final centers = DiceStageLayout.restCenters(count);
    final rotations = DiceStageLayout.restRotations(count);
    return [for (var i = 0; i < count; i++) (center: centers[i], rotation: rotations[i])];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _active = WidgetsBinding.instance.lifecycleState == null || WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_model.state.isBusy && !_reduced && MediaQuery.disableAnimationsOf(context)) _settle();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (!_active) _settle();
  }

  void _cancelForExit() {
    _leaving = true;
    _round = null;
    _plan = null;
    _controller.stop(canceled: true);
  }

  /// 后台或系统要求减少动态效果时：直接落定已经确定的结果，不重新抽取、不补震动。
  void _settle() {
    final round = _round;
    if (round == null || !_model.state.isBusy) return;
    _controller.stop(canceled: true);
    _complete(round, feedback: false);
  }

  /// 落定：骰子停在计划的落点和姿态上，按钮解锁与合计出现同时发生。
  void _complete(DiceRound round, {required bool feedback}) {
    final plan = _plan;
    if (plan != null) {
      _rest = [for (final die in plan.dice) (center: die.end, rotation: die.finalRotation)];
    }
    _lastValues = round.values;
    _round = null;
    _plan = null;
    _model.finish(round.id);
    if (feedback && widget.settings.state.hapticsEnabled) unawaited(_sendFeedback(round.id));
  }

  Future<void> _sendFeedback(int id) async {
    if (!mounted || !_active || _leaving || id != _model.state.roundId || !widget.settings.state.hapticsEnabled) return;
    try {
      await _feedback.reveal();
    } catch (_) {
      // 反馈不可用不影响回合结果。
    }
  }

  /// 点击按钮和点击骰子都走这里；翻滚中无效，也不排队。
  Future<void> _requestRoll() async {
    if (!_active || _leaving) return;
    final round = _model.requestRoll();
    if (round == null) return;
    final motion = MotionSpec.of(context, widget.settings.state);
    _reduced = motion.reduceMotion;
    _round = round;
    _plan = DiceMotionPlan.create(
      layout: _layout,
      starts: [for (final rest in _rest) rest.center],
      values: round.values,
      random: _motionRandom,
      reduceMotion: _reduced,
    );
    _controller.duration = motion.diceRound;
    try {
      await _controller.forward(from: 0).orCancel;
      if (!mounted || !_active || _round?.id != round.id) return;
      _complete(round, feedback: true);
    } on TickerCanceled {
      // 页面关闭或进入后台时，不再提交动画完成事件。
    }
  }

  /// 切换数量：清除旧结果，骰子立即换成待机姿态。
  void _selectCount(int count) {
    if (_model.setCount(count)) _rest = _defaultRest(count);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _round = null;
    _plan = null;
    _controller.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _cancelForExit();
      },
      child: ListenableBuilder(
        listenable: Listenable.merge([_model, widget.settings]),
        builder: (context, _) {
          final state = _model.state;
          final settings = widget.settings.state;
          final motion = MotionSpec.of(context, settings);
          final rolling = state.isBusy;
          final label = rolling ? '投掷中…' : (state.phase == DicePhase.result ? '再掷一次' : '掷一次');
          return GameScaffold(
            title: '掷骰子',
            background: const DiceStageBackground(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final headerBottom = MediaQuery.paddingOf(context).top + GameScaffold.headerHeight;
                _layout = DiceStageLayout(width: constraints.maxWidth, screenHeight: MediaQuery.sizeOf(context).height, headerBottom: headerBottom);
                return Column(
                  children: [
                    Expanded(child: _buildStage(_layout, state, motion)),
                    Padding(
                      padding: EdgeInsets.fromLTRB(22, 4, 22, MediaQuery.paddingOf(context).bottom + DiceActionButton.bottomGap),
                      child: DiceActionButton(onPressed: rolling ? null : _requestRoll, rolling: rolling, label: label, settings: settings),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStage(DiceStageLayout layout, DiceState state, MotionSpec motion) {
    final rolling = state.isBusy;
    final values = state.values ?? _lastValues;
    final selectorWidth = layout.width * _selectorWidth;
    final half = layout.side / 2;
    return Stack(
      // 骰子翻滚时会越过舞台边界，盖住标题栏，所以不能裁剪。
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        Positioned(
          top: layout.yFor(_selectorCenter) - DiceCountSelector.height / 2,
          left: (layout.width - selectorWidth) / 2,
          width: selectorWidth,
          child: _Fade(
            fadeKey: const ValueKey('dice-selector'),
            visible: !rolling,
            motion: motion,
            child: DiceCountSelector(count: state.count, onChanged: _selectCount, animate: !motion.reduceMotion),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final plan = _plan;
                    final visuals =
                        rolling && plan != null
                            ? [for (var i = 0; i < plan.dice.length; i++) plan.visualAt(i, _controller.value, layout)]
                            : [for (final rest in _rest) DiceMotionPlan.restVisual(rest.center, rest.rotation, layout)];
                    return CustomPaint(key: const ValueKey('dice-stage'), painter: DiceStagePainter(dice: visuals, side: layout.side));
                  },
                ),
              ),
            ),
          ),
        ),
        // 点击任一骰子也可以掷骰；翻滚中没有热区。
        if (!rolling)
          for (var i = 0; i < _rest.length; i++)
            Positioned(
              left: layout.toPx(_rest[i].center).dx - half * 1.1,
              top: layout.toPx(_rest[i].center).dy - half * 1.1,
              width: half * 2.2,
              height: half * 2.2,
              child: Semantics(
                key: ValueKey('dice-hit-$i'),
                button: true,
                label: '点击骰子掷骰',
                child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _requestRoll, child: const SizedBox.expand()),
              ),
            ),
        Positioned(
          top: layout.yFor(_resultTop),
          left: 0,
          right: 0,
          height: 150,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // 待机文字比结果淡入晚 100ms，避免新旧文字叠在一起。
              _Fade(
                fadeKey: const ValueKey('dice-idle'),
                visible: state.phase == DicePhase.idle,
                delayed: true,
                motion: motion,
                child: const _IdleBlock(),
              ),
              _Fade(
                fadeKey: const ValueKey('dice-result'),
                visible: state.phase == DicePhase.result,
                motion: motion,
                child: values == null ? const SizedBox.shrink() : _ResultBlock(values: values, announce: state.phase == DicePhase.result),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 淡入淡出：淡出快、淡入稍慢；[delayed] 让淡入晚 100ms 开始。隐藏时既不响应点击也不进入读屏。
class _Fade extends StatelessWidget {
  const _Fade({required this.fadeKey, required this.visible, required this.motion, required this.child, this.delayed = false});

  final Key fadeKey;
  final bool visible;
  final bool delayed;
  final MotionSpec motion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = visible && delayed && !motion.reduceMotion ? const Duration(milliseconds: 100) : Duration.zero;
    final duration = visible ? motion.diceFadeIn + delay : motion.diceFadeOut;
    // 带延迟时总时长 = 延迟 + 淡入，曲线只在后半段变化。
    final curve = delay == Duration.zero ? Curves.easeOut : Interval(delay.inMilliseconds / duration.inMilliseconds, 1, curve: Curves.easeOut);
    return AnimatedOpacity(
      key: fadeKey,
      opacity: visible ? 1 : 0,
      duration: duration,
      curve: curve,
      child: IgnorePointer(ignoring: !visible, child: ExcludeSemantics(excluding: !visible, child: child)),
    );
  }
}

/// 待机文案：小标签加一句标语。
class _IdleBlock extends StatelessWidget {
  const _IdleBlock();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('全凭运气', style: TextStyle(color: DiceTheme.muted, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 4)),
          SizedBox(height: 10),
          Text('手气如何？', style: TextStyle(color: PartyTheme.chalk, fontSize: 24, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// 结果：大号合计；两枚时下方给出分项，一枚只有点数本身。
class _ResultBlock extends StatelessWidget {
  const _ResultBlock({required this.values, required this.announce});

  final List<int> values;

  /// 只在真正落定后才向读屏播报。
  final bool announce;

  @override
  Widget build(BuildContext context) {
    final total = values.fold<int>(0, (sum, value) => sum + value);
    final two = values.length == 2;
    return Semantics(
      liveRegion: announce,
      label: two ? '本轮结果：合计 $total，分别是 ${values[0]} 和 ${values[1]}' : '本轮结果：$total',
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$total',
                key: const ValueKey('dice-total'),
                style: const TextStyle(color: PartyTheme.chalk, fontSize: 64, fontWeight: FontWeight.w800, height: 1.1),
              ),
              if (two)
                Text(
                  values.join(' + '),
                  key: const ValueKey('dice-breakdown'),
                  style: const TextStyle(color: DiceTheme.muted, fontSize: 22, fontWeight: FontWeight.w500),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
