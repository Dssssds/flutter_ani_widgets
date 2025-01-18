//像气球一样旋转上浮的动画效果
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/text_reveal/text_reveal_widget.dart';

//像气球一样旋转上浮的动画效果
class SwirlFloatStrategy extends BaseAnimationStrategy {
  final double yOffset; // 垂直方向上的固定偏移量
  final double maxXDeviation; // 水平方向上的最大随机偏移量
  final double maxBlur; // 最大模糊程度
  final bool enableBlur; // 是否启用模糊效果
  final double curveIntensity; // 控制S形曲线的强度

  const SwirlFloatStrategy({
    this.yOffset = 50.0,
    this.maxXDeviation = 20.0,
    this.maxBlur = 8.0,
    this.enableBlur = true,
    this.curveIntensity = 0.5, // 0.5表示中等曲线强度
    super.synchronizeAnimation = false,
  });

  @override
  Widget buildAnimatedCharacter({
    required String character,
    required Animation<double> animation,
    TextStyle? style,
  }) {
    // 为每个字符生成随机值
    final random = Random();
    final xDeviation = (random.nextDouble() * 2 - 1) * maxXDeviation;

    final yDeviation =
        random.nextDouble() * yOffset.abs() * (yOffset >= 0 ? 1 : -1);

    return ValueListenableBuilder<double>(
      valueListenable: animation,
      builder: (context, value, _) {
        // 计算S形曲线上的位置
        final position = _calculateSCurvePosition(
            value, xDeviation, yDeviation, curveIntensity);

        // 根据动画值计算缩放比例
        final scale = value;

        Widget child = Text(character, style: style);

        if (enableBlur) {
          if (enableBlur) {
            const blurThreshold = 0.1;
            final blurProgress = value < blurThreshold
                ? maxBlur
                : maxBlur *
                    (1 - ((value - blurThreshold) / (1 - blurThreshold)));

            child = ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: blurProgress,
                sigmaY: blurProgress,
              ),
              child: child,
            );
          }
        }

        // 应用所有变换效果
        return Transform.translate(
          offset: position,
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: value,
              child: child,
            ),
          ),
        );
      },
    );
  }

  Offset _calculateSCurvePosition(
      double t, double targetX, double targetY, double intensity) {
    // 使用正弦波的组合来创建S形曲线
    // 这样可以创建一个从起点到终点的平滑S形路径

    // 如果t>1，则反转退出动画的进度
    final progress = t <= 1 ? 1 - t : t - 1;

    // 使用缓动计算Y轴位置
    final y = targetY * progress;

    // 使用正弦波计算X轴位置，实现S形曲线效果
    // 正弦波在中间位置被放大，在两端逐渐减小
    final xWave = sin(progress * pi * 2) * intensity;
    final xProgress = progress * (1 - progress) * 4; // 在0.5处达到峰值
    final x = targetX * progress + (xWave * xProgress * targetX);

    return Offset(x, y);
  }

  @override
  Animation<double> createAnimation({
    required AnimationController controller,
    required double startTime,
    required double endTime,
    required Curve curve,
  }) {
    // 使用自定义曲线与S形曲线计算相结合
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          startTime,
          endTime,
          curve: Curves.easeInOutCubic, // 平滑的加速和减速效果
        ),
      ),
    );
  }
}
