import 'package:flutter/foundation.dart';
import 'package:flutter_x_widgets/app_demo/14/models/coin_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/rules/coin_rules.dart';

/// 回合状态只在阶段切换时通知；动画逐帧变化由 View 负责。
class CoinViewModel extends ChangeNotifier {
  final CoinRules rules;
  CoinState _state = const CoinState();
  CoinSide? _pending;
  bool _disposed = false;

  CoinViewModel(this.rules);
  CoinState get state => _state;

  CoinRound? requestFlip(int settledHalfTurns) {
    if (_disposed || _state.isBusy) return null;
    final id = _state.roundId + 1;
    _state = CoinState(phase: CoinPhase.running, roundId: id);
    _pending = rules.draw();
    final round = CoinRound(
      id: id,
      startHalfTurns: settledHalfTurns,
      targetHalfTurns: CoinRules.targetHalfTurns(settledHalfTurns, _pending!),
    );
    notifyListeners();
    return round;
  }

  bool reveal(int id) {
    if (_disposed || id != _state.roundId || _state.phase != CoinPhase.running) return false;
    _state = CoinState(phase: CoinPhase.revealing, roundId: id, revealedSide: _pending);
    notifyListeners();
    return true;
  }

  bool finish(int id) {
    if (_disposed || id != _state.roundId || _state.phase != CoinPhase.revealing) return false;
    _state = CoinState(phase: CoinPhase.result, roundId: id, revealedSide: _pending);
    _pending = null;
    notifyListeners();
    return true;
  }

  /// 非活跃时直接结算，调用方不发送反馈。
  void settle(int id) {
    if (_disposed || id != _state.roundId || !_state.isBusy) return;
    _state = CoinState(phase: CoinPhase.result, roundId: id, revealedSide: _pending);
    _pending = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _pending = null;
    super.dispose();
  }
}
