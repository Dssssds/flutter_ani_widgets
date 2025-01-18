import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/text_reveal/text_reveal_widget.dart';

class FlipUpStrategy extends BaseAnimationStrategy {
  final double rotationAngle; // 最大旋转角度（弧度）
  final double perspectiveValue; // 控制透视效果的强度

  const FlipUpStrategy({
    this.rotationAngle = -pi / 2, // 起始位置为平面（-90度）
    this.perspectiveValue = 0.003,
    super.synchronizeAnimation = false,
  });

  @override
  Widget buildAnimatedCharacter({
    required String character,
    required Animation<double> animation,
    TextStyle? style,
  }) {
    return ValueListenableBuilder<double>(
      valueListenable: animation,
      builder: (context, value, _) {
        // 计算当前旋转角度
        final double currentRotation = rotationAngle * (1 - value);

        // 创建包含透视效果和旋转的变换矩阵
        final transform = Matrix4.identity()
          ..setEntry(3, 2, perspectiveValue)
          ..rotateX(currentRotation);

        return Transform(
          transform: transform,
          alignment: Alignment.bottomCenter,
          child: Text(character, style: style),
        );
      },
    );
  }
}
