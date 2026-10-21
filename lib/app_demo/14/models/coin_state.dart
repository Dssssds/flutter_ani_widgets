enum CoinSide { heads, tails }

enum CoinPhase { idle, running, revealing, result }

/// 只公开已经揭晓的结果，不暴露待揭晓值。
class CoinState {
  final CoinPhase phase;
  final int roundId;
  final CoinSide? revealedSide;

  const CoinState({this.phase = CoinPhase.idle, this.roundId = 0, this.revealedSide});

  bool get isBusy => phase == CoinPhase.running || phase == CoinPhase.revealing;
}

/// 只供动画消费的落点指令，不用于结果文案。
class CoinRound {
  final int id;
  final int startHalfTurns;
  final int targetHalfTurns;

  const CoinRound({required this.id, required this.startHalfTurns, required this.targetHalfTurns});
}
