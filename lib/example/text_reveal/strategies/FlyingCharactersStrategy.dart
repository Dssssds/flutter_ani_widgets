// 字符飞行动画策略
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/text_reveal/text_reveal_widget.dart';

class FlyingCharactersStrategy extends BaseAnimationStrategy {
  final double maxOffset;
  final bool randomDirection;
  final double angle;
  final bool enableBlur; // 是否启用模糊效果
  final double maxBlur; // 最大模糊程度

  const FlyingCharactersStrategy({
    this.maxOffset = 100.0,
    this.randomDirection = true,
    this.angle = pi / 2,
    this.enableBlur = false, // 默认关闭模糊效果
    this.maxBlur = 8.0, // 默认模糊程度
  }) : super();

  @override
  Widget buildAnimatedCharacter({
    required String character,
    required Animation<double> animation,
    TextStyle? style,
  }) {
    return ValueListenableBuilder<double>(
      valueListenable: animation,
      builder: (context, value, _) {
        final actualAngle =
            randomDirection ? (Random().nextDouble() * 2 * pi) : angle;
        final offset = maxOffset * (1 - value);

        Widget child = Text(character, style: style);

        // 如果启用了模糊效果，添加模糊滤镜
        if (enableBlur) {
          child = ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: (1 - value) * maxBlur,
              sigmaY: (1 - value) * maxBlur,
            ),
            child: child,
          );
        }

        // 应用位移和透明度效果
        return Transform.translate(
          offset: Offset(
            cos(actualAngle) * offset,
            sin(actualAngle) * offset,
          ),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }
}
