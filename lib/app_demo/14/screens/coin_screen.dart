import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/coin_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/rules/coin_rules.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/feedback_service.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/random_source.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/coin_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/animated_coin.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/coin_action_button.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/coin_body_painter.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/coin_motion.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/coin_stage_background.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/game_scaffold.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

class CoinScreen extends StatefulWidget {
  final SettingsViewModel settings;
  final RandomSource? random;
  final FeedbackService? feedback;
  const CoinScreen({super.key, required this.settings, this.random, this.feedback});

  @override
  State<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends State<CoinScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  /// 硬币静止时中心约在屏幕高度的 43% 处。
  static const _restingCenter = .43;

  /// 抛起的最大高度约为屏幕高度的 1/3。
  static const _apexRatio = .31;

  /// 点击热区比硬币轮廓外扩的距离。
  static const _hitPad = 8.0;

  late final _model = CoinViewModel(CoinRules(widget.random ?? DartRandomSource()));
  late final _feedback = widget.feedback ?? const PlatformFeedbackService();
  late final _controller = AnimationController(vsync: this, animationBehavior: AnimationBehavior.preserve)..addListener(_tick);

  /// 揭晓圆环的独立时间轴，不占用抛掷时间轴，所以按钮解锁后圆环仍可以继续扩散。
  late final _rings = AnimationController(vsync: this, animationBehavior: AnimationBehavior.preserve);
  CoinRound? _round;
  int _settledHalfTurns = 0;

  /// 上一轮已经揭晓的结果；新一轮开始时用它把旧结果淡出。
  CoinSide? _lastSide;

  /// 当前圆环属于哪一轮；与当前轮次不同说明它是上一轮残留的。
  int? _ringRoundId;
  bool _reduced = false;
  bool _coinPressed = false;
  bool _active = true;
  bool _leaving = false;

  void _cancelForExit() {
    _leaving = true;
    _round = null;
    _controller.stop(canceled: true);
    _rings.stop(canceled: true);
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
    if (_model.state.isBusy && !_reduced && MediaQuery.disableAnimationsOf(context)) {
      _settle();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (!_active) _settle();
  }

  void _settle() {
    final round = _round;
    if (round == null || !_model.state.isBusy) return;
    _controller.stop(canceled: true);
    _rings.stop(canceled: true);
    _rings.value = 0;
    _ringRoundId = null;
    _round = null;
    _settledHalfTurns = round.targetHalfTurns;
    _model.settle(round.id);
    _lastSide = _model.state.revealedSide;
  }

  void _tick() {
    final round = _round;
    if (round == null || !_active || !mounted || _leaving || !(ModalRoute.of(context)?.isCurrent ?? true)) return;
    if (_controller.value >= CoinMotion.revealAt && _model.reveal(round.id)) {
      _lastSide = _model.state.revealedSide;
      if (!_reduced) {
        _ringRoundId = round.id;
        _rings.duration = MotionSpec.of(context, widget.settings.state).coinRing;
        _rings.forward(from: 0);
      }
      if (_active && mounted && widget.settings.state.hapticsEnabled) unawaited(_sendFeedback(round.id));
    }
  }

  Future<void> _sendFeedback(int id) async {
    if (!mounted ||
        !_active ||
        _leaving ||
        !(ModalRoute.of(context)?.isCurrent ?? true) ||
        id != _model.state.roundId ||
        !widget.settings.state.hapticsEnabled) {
      return;
    }
    try {
      await _feedback.reveal();
    } catch (_) {
      // 反馈不可用不影响回合结果。
    }
  }

  /// 点击硬币和点击按钮都走这里，一轮只产生一次结果。
  Future<void> _requestFlip() async {
    if (!_active || _leaving) return;
    final round = _model.requestFlip(_settledHalfTurns);
    if (round == null) return;
    final motion = MotionSpec.of(context, widget.settings.state);
    _round = round;
    _reduced = motion.reduceMotion;
    _controller.duration = motion.coinRound;
    try {
      await _controller.forward(from: 0).orCancel;
      if (!mounted || !_active || _round?.id != round.id) return;
      _settledHalfTurns = round.targetHalfTurns;
      _model.finish(round.id);
    } on TickerCanceled {
      // 页面关闭或进入后台时，不再提交动画完成事件。
    }
  }

  void _setCoinPressed(bool value) {
    if (_coinPressed == value || !mounted) return;
    setState(() => _coinPressed = value);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _round = null;
    _controller.dispose();
    _rings.dispose();
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
          final busy = state.isBusy;
          final label = busy ? '抛掷中…' : (state.roundId == 0 ? '抛一次' : '再抛一次');
          return GameScaffold(
            title: '抛硬币',
            background: const CoinStageBackground(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screen = MediaQuery.sizeOf(context);
                final headerBottom = MediaQuery.paddingOf(context).top + GameScaffold.headerHeight;
                final diameter = (constraints.maxWidth * .58).clamp(150.0, 300.0);
                final radius = diameter / 2;
                // 热区外扩的 8pt 也算在舞台槽内，所以槽顶比硬币上沿高 8。
                final slotTop = math.max(0.0, screen.height * _restingCenter - headerBottom - radius - _hitPad);
                final restingCenter = headerBottom + slotTop + _hitPad + radius;
                // 抛到最高点时硬币上沿接近屏幕顶部，与标题栏重叠。
                final apex = math.max(1.0, math.min(screen.height * _apexRatio, restingCenter - radius * CoinShape.maxPerspective));
                final stageWidth = AnimatedCoin.stageWidthFor(diameter);
                final stageHeight = AnimatedCoin.stageHeightFor(diameter, apex);
                final hit = diameter + _hitPad * 2;
                return Column(
                  children: [
                    Expanded(
                      // 抛起时硬币会越过舞台上沿盖住标题栏，所以不能裁剪。
                      child: SingleChildScrollView(
                        clipBehavior: Clip.none,
                        child: Column(
                          children: [
                            SizedBox(height: slotTop),
                            SizedBox(
                              width: stageWidth,
                              height: diameter + _hitPad + AnimatedCoin.shadowBand,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: _hitPad - apex,
                                    child: RepaintBoundary(
                                      child: AnimatedBuilder(
                                        animation: Listenable.merge([_controller, _rings]),
                                        builder: (context, _) {
                                          final progress = _round == null ? 1.0 : _controller.value;
                                          final ringStale = _ringRoundId != null && _ringRoundId != _round?.id;
                                          final ringActive = _ringRoundId != null && _rings.value > 0 && _rings.value < 1;
                                          final motion = MotionSpec.of(context, settings);
                                          return AnimatedScale(
                                            // 按下时硬币缩到约 96%，松开后随抛起弹回。
                                            scale: _coinPressed ? .96 : 1,
                                            duration: _coinPressed ? motion.pressIn : motion.pressOut,
                                            curve: Curves.easeOut,
                                            alignment: Alignment(0, (apex + diameter / 2) / stageHeight * 2 - 1),
                                            child: AnimatedCoin(
                                              progress: progress,
                                              startHalfTurns: _round?.startHalfTurns ?? _settledHalfTurns,
                                              targetHalfTurns: _round?.targetHalfTurns ?? _settledHalfTurns,
                                              reduceMotion: _reduced,
                                              diameter: diameter,
                                              apex: apex,
                                              ringProgress: ringActive ? _rings.value : null,
                                              // 上一轮的圆环还没散尽时，随文字切换一起淡出。
                                              ringOpacity: ringStale ? 1 - CoinMotion.textOut(progress) : 1,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: (stageWidth - hit) / 2,
                                    top: 0,
                                    width: hit,
                                    height: hit,
                                    child: Semantics(
                                      key: const ValueKey('coin-trigger'),
                                      button: true,
                                      enabled: !busy,
                                      label: '点击硬币开始抛掷',
                                      // 热区以硬币轮廓为准；光晕和圆环不响应点击。
                                      child: ClipOval(
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTapDown: busy ? null : (_) => _setCoinPressed(true),
                                          onTapUp: busy ? null : (_) => _setCoinPressed(false),
                                          onTapCancel: busy ? null : () => _setCoinPressed(false),
                                          onTap: busy ? null : _requestFlip,
                                          child: const SizedBox.expand(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            _ResultArea(side: state.revealedSide, lastSide: _lastSide, busy: busy, settled: state.phase == CoinPhase.result, controller: _controller),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    // 底部操作区：不参与滚动，按钮不会被裁掉或缩小。
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 4, 20, MediaQuery.paddingOf(context).bottom + CoinActionButton.bottomGap),
                      child: CoinActionButton(onPressed: busy ? null : _requestFlip, busy: busy, label: label, settings: settings),
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
}

/// 硬币下方的结果区。
///
/// - 首次进入：什么都不显示。
/// - 抛掷中：灰色 “抛掷中…”；若上一轮有结果，旧结果先淡出，“抛掷中…” 晚 100ms 淡入。
/// - 揭晓：“抛掷中…” 淡出，金色小标签与结果大字晚 100ms 淡入并轻微上移。
///
/// 只有真正揭晓后才暴露读屏播报，动画过程中不朗读。
class _ResultArea extends StatelessWidget {
  final CoinSide? side;
  final CoinSide? lastSide;
  final bool busy;
  final bool settled;
  final Animation<double> controller;

  const _ResultArea({required this.side, required this.lastSide, required this.busy, required this.settled, required this.controller});

  static String _name(CoinSide side) => side == CoinSide.heads ? '正面' : '反面';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final p = controller.value;
        final CoinSide? shown;
        final double resultOpacity;
        final double flippingOpacity;
        if (side != null) {
          shown = side;
          resultOpacity = settled ? 1 : CoinMotion.resultIn(p);
          flippingOpacity = settled ? 0 : 1 - CoinMotion.flippingOut(p);
        } else if (busy) {
          shown = lastSide;
          resultOpacity = lastSide == null ? 0 : 1 - CoinMotion.textOut(p);
          flippingOpacity = CoinMotion.flippingIn(p);
        } else {
          shown = null;
          resultOpacity = 0;
          flippingOpacity = 0;
        }
        final rise = side != null && !settled ? 12 * (1 - CoinMotion.resultIn(p)) : 0.0;
        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 96),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (flippingOpacity > 0)
                Opacity(
                  opacity: flippingOpacity,
                  child: const Text(
                    '抛掷中…',
                    key: ValueKey('coin-flipping'),
                    style: TextStyle(color: PartyTheme.muted, fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                ),
              if (shown != null && resultOpacity > 0)
                Semantics(
                  liveRegion: side != null,
                  label: side == null ? null : '本轮结果：${_name(side!)}',
                  child: ExcludeSemantics(
                    child: Opacity(
                      opacity: resultOpacity,
                      child: Transform.translate(
                        offset: Offset(0, rise),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '硬币说',
                              style: TextStyle(color: PartyTheme.coinColors[1], fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 4),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _name(shown),
                              key: const ValueKey('coin-result'),
                              style: const TextStyle(color: PartyTheme.chalk, fontSize: 40, fontWeight: FontWeight.w800, height: 1.15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
