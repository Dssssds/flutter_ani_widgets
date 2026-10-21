import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/coin_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/rules/coin_rules.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/feedback_service.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/random_source.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/coin_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/animated_coin.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/coin_motion.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/game_scaffold.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/sheets/appearance_sheet.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/sheets/show_game_sheet.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

class CoinScreen extends StatefulWidget {
  final SettingsViewModel settings;
  final RandomSource? random;
  final FeedbackService? feedback;
  const CoinScreen({super.key, required this.settings, this.random, this.feedback});

  @override
  State<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends State<CoinScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final _model = CoinViewModel(CoinRules(widget.random ?? DartRandomSource()));
  late final _feedback = widget.feedback ?? const PlatformFeedbackService();
  late final _controller = AnimationController(vsync: this, animationBehavior: AnimationBehavior.preserve)..addListener(_tick);
  CoinRound? _round;
  int _settledHalfTurns = 0;
  bool _reduced = false;
  bool _sheetOpen = false;
  bool _active = true;
  bool _leaving = false;

  void _cancelForExit() {
    _leaving = true;
    _round = null;
    _controller.stop(canceled: true);
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
    _round = null;
    _settledHalfTurns = round.targetHalfTurns;
    _model.settle(round.id);
  }

  void _tick() {
    final round = _round;
    if (round == null || !_active || !mounted || _leaving || !(ModalRoute.of(context)?.isCurrent ?? true)) return;
    if (_controller.value >= CoinMotion.revealAt && _model.reveal(round.id)) {
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

  Future<void> _requestFlip() async {
    if (!_active || _leaving || _sheetOpen) return;
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

  Future<void> _showAppearance() async {
    if (_sheetOpen || _model.state.isBusy) return;
    _sheetOpen = true;
    try {
      await showGameSheet(context: context, settings: widget.settings, builder: (_) => AppearanceSheet(settings: widget.settings));
    } finally {
      if (mounted) _sheetOpen = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _round = null;
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
          final side = state.revealedSide;
          final result = side == null ? null : (side == CoinSide.heads ? '正面' : '反面');
          final accent = PartyTheme.coinColors(widget.settings.state.appearance)[1];
          return GameScaffold(
            title: 'Coin Toss',
            onAppearance: state.isBusy ? null : _showAppearance,
            child: LayoutBuilder(
              builder:
                  (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: (constraints.maxHeight - 40).clamp(0, double.infinity)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              const Text(
                                '让选择，简单一点。',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              const Text('轻点硬币，交给这一刻。', style: TextStyle(color: PartyTheme.muted)),
                              const SizedBox(height: 12),
                              Semantics(
                                key: const ValueKey('coin-trigger'),
                                button: true,
                                enabled: !state.isBusy,
                                label: state.isBusy ? '硬币抛掷中' : '点击硬币开始抛掷',
                                child: TextButton(
                                  onPressed: state.isBusy ? null : _requestFlip,
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: accent),
                                  child: RepaintBoundary(
                                    child: AnimatedBuilder(
                                      animation: _controller,
                                      builder:
                                          (context, _) => AnimatedCoin(
                                            progress: _round == null ? 1 : _controller.value,
                                            startHalfTurns: _round?.startHalfTurns ?? _settledHalfTurns,
                                            targetHalfTurns: _round?.targetHalfTurns ?? _settledHalfTurns,
                                            reduceMotion: _reduced,
                                            appearance: widget.settings.state.appearance,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Semantics(
                                liveRegion: result != null,
                                label: result == null ? (state.isBusy ? '抛掷中' : '等待抛掷') : '本轮结果：$result',
                                child: ExcludeSemantics(
                                  child: AnimatedBuilder(
                                    animation: _controller,
                                    builder:
                                        (context, _) => Opacity(
                                          opacity:
                                              result == null || state.phase == CoinPhase.result
                                                  ? 1
                                                  : CoinMotion.revealProgress(_controller.value),
                                          child: Text(
                                            result ?? (state.isBusy ? '抛掷中…' : '正面还是反面？'),
                                            key: const ValueKey('coin-result'),
                                            style: TextStyle(color: accent, fontSize: 24, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text('每次抛掷，正反面机会相同。', textAlign: TextAlign.center, style: TextStyle(color: PartyTheme.muted)),
                                const SizedBox(height: 20),
                                FilledButton(
                                  key: const ValueKey('flip-button'),
                                  onPressed: state.isBusy ? null : _requestFlip,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: accent,
                                    foregroundColor: PartyTheme.ink,
                                    minimumSize: const Size.fromHeight(56),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Text(state.isBusy ? '正在抛掷…' : (state.phase == CoinPhase.result ? '再抛一次' : '抛硬币')),
                                  ),
                                ),
                              ],
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
    );
  }
}
