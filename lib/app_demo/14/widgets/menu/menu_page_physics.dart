import 'package:flutter/widgets.dart';

/// 保留原生分页阈值与取消拖动，放慢松手后的吸附而不拖慢手指跟随。
class MenuPagePhysics extends PageScrollPhysics {
  final Duration duration;

  const MenuPagePhysics({required this.duration, super.parent});

  @override
  MenuPagePhysics applyTo(ScrollPhysics? ancestor) => MenuPagePhysics(duration: duration, parent: buildParent(ancestor));

  @override
  SpringDescription get spring => SpringDescription.withDurationAndBounce(duration: duration, bounce: 0);

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // 高速甩动仍决定翻页方向，但不让过大初速度吞掉错峰过程。
    return super.createBallisticSimulation(position, velocity.clamp(-700.0, 700.0));
  }
}
