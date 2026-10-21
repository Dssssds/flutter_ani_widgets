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
