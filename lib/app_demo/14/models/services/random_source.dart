import 'dart:math';

/// 可替换随机源，便于固定正反面验收。
abstract class RandomSource {
  bool nextBool();
}

class DartRandomSource implements RandomSource {
  final Random _random;
  DartRandomSource([Random? random]) : _random = random ?? Random();

  @override
  bool nextBool() => _random.nextBool();
}

/// 骰子需要整数随机；与 [RandomSource] 分开，不影响抛硬币的注入点。
abstract class IntRandomSource {
  /// 返回 [0, max) 内的整数。
  int nextInt(int max);
}

class DartIntRandomSource implements IntRandomSource {
  final Random _random;
  DartIntRandomSource([Random? random]) : _random = random ?? Random();

  @override
  int nextInt(int max) => _random.nextInt(max);
}
