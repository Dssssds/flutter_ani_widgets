import 'package:flutter_x_widgets/app_demo/14/models/services/random_source.dart';

/// 规则不依赖动画、Widget 或平台反馈。
class DiceRules {
  static const int minCount = 1;
  static const int maxCount = 2;
  static const int faces = 6;

  final IntRandomSource random;
  const DiceRules(this.random);

  /// 每枚骰子独立抽取 1–6，按“第一枚、第二枚”的顺序返回。
  List<int> roll(int count) {
    assert(count >= minCount && count <= maxCount, 'Unsupported dice count: $count');
    return List.unmodifiable([for (var i = 0; i < count; i++) random.nextInt(faces) + 1]);
  }
}
