import 'package:flutter_x_widgets/app_demo/14/models/coin_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/random_source.dart';

/// 规则不依赖动画、Widget 或平台反馈。
class CoinRules {
  final RandomSource random;
  const CoinRules(this.random);

  CoinSide draw() => random.nextBool() ? CoinSide.heads : CoinSide.tails;

  static int targetHalfTurns(int start, CoinSide side) {
    final target = start + 6;
    final parity = side == CoinSide.heads ? 0 : 1;
    return target.isEven == (parity == 0) ? target : target + 1;
  }
}
