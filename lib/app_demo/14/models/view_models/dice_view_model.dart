import 'package:flutter/foundation.dart';
import 'package:flutter_x_widgets/app_demo/14/models/dice_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/rules/dice_rules.dart';

/// 回合状态只在阶段切换时通知；动画逐帧变化由 View 负责。
class DiceViewModel extends ChangeNotifier {
  final DiceRules rules;
  DiceState _state = const DiceState();
  List<int>? _pending;
  bool _disposed = false;

  DiceViewModel(this.rules);
  DiceState get state => _state;

  /// 切换骰子数量：清除旧结果，回到待机。翻滚中无效；选择当前已选项也无变化。
  bool setCount(int count) {
    if (_disposed || _state.isBusy || count == _state.count) return false;
    if (count < DiceRules.minCount || count > DiceRules.maxCount) return false;
    _state = DiceState(roundId: _state.roundId, count: count);
    notifyListeners();
    return true;
  }

  /// 开始一次掷骰：先锁定，再抽取点数；点数只存在于内部和返回的指令里。
  DiceRound? requestRoll() {
    if (_disposed || _state.isBusy) return null;
    final id = _state.roundId + 1;
    final values = rules.roll(_state.count);
    _pending = values;
    _state = DiceState(phase: DicePhase.rolling, roundId: id, count: _state.count);
    notifyListeners();
    return DiceRound(id: id, count: _state.count, values: values);
  }

  /// 落定：仅在 ID 匹配且本轮翻滚中时公开结果。后台直接结算也走这里。
  bool finish(int id) {
    if (_disposed || id != _state.roundId || _state.phase != DicePhase.rolling) return false;
    _state = DiceState(phase: DicePhase.result, roundId: id, count: _state.count, values: _pending);
    _pending = null;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    _pending = null;
    super.dispose();
  }
}
