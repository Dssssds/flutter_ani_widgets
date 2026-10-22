enum DicePhase { idle, rolling, result }

/// 只公开已经落定的点数，不暴露待揭晓值。
class DiceState {
  final DicePhase phase;
  final int roundId;

  /// 当前选择的骰子数量，1 或 2。
  final int count;

  /// 落定后的各枚点数；待机和翻滚中为空。
  final List<int>? values;

  const DiceState({this.phase = DicePhase.idle, this.roundId = 0, this.count = 1, this.values});

  bool get isBusy => phase == DicePhase.rolling;

  /// 合计只由最终点数计算。
  int? get total => values?.fold<int>(0, (sum, value) => sum + value);
}

/// 只供动画消费的落点指令：点数在点击瞬间就已确定，动画必须落在这些点数上。
class DiceRound {
  final int id;
  final int count;
  final List<int> values;

  const DiceRound({required this.id, required this.count, required this.values});
}
