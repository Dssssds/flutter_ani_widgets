import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_x_widgets/example/text_reveal/text_reveal_widget.dart';

class FancySpringStrategy extends BaseAnimationStrategy {
  final double maxOffset;
  final double maxRotation;
  final double minScale;
  final bool enableRandomColors;
  final SpringDescription springDescription;
  final bool enableBlur;
  final double maxBlur;

  const FancySpringStrategy({
    this.maxOffset = 50.0,
    this.maxRotation = 45.0,
    this.minScale = 0.3,
    this.enableRandomColors = false,
    this.enableBlur = true,
    this.maxBlur = 14.0,
    SpringDescription? spring,
  })  : springDescription = spring ??
            const SpringDescription(
              mass: 0.8, // 质量
              stiffness: 300, // 刚度
              damping: 10, // 阻尼
            ),
        super(synchronizeAnimation: false);

  // 生成随机颜色
  Color _getRandomColor() {
    final random = math.Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  @override
  Widget buildAnimatedCharacter({
    required String character,
    required Animation<double> animation,
    TextStyle? style,
  }) {
    // 为每个字符生成随机值
    final random = math.Random();
    final initialY = (random.nextDouble() * 2 - 1) * maxOffset;
    final initialRotation = (random.nextDouble() * 2 - 1) * maxRotation;
    final initialColor = _getRandomColor();
    final targetColor = _getRandomColor();

    return ValueListenableBuilder<double>(
      valueListenable: animation,
      builder: (context, value, _) {
        // 创建弹簧曲线实现平滑动画
        final springCurve = SpringSimulation(
          springDescription,
          0, // 起始点
          1, // 终点
          0, // 初始速度
        );

        // 将弹簧物理应用到动画值
        final springValue = springCurve.x(value);

        // 在初始值和最终值之间进行插值
        final currentY = initialY * (1 - springValue);
        final currentRotation = initialRotation * (1 - springValue);
        final currentScale = minScale + (1 - minScale) * springValue;

        // 颜色插值
        final currentColor = Color.lerp(
          initialColor,
          targetColor,
          springValue,
        );

        Widget child = Text(
          character,
          style: style?.copyWith(
            color: enableRandomColors ? currentColor : style.color,
          ),
        );

        // 如果启用了模糊效果，添加模糊滤镜
        if (enableBlur) {
          final blurAmount = (1 - springValue) * maxBlur;
          child = ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurAmount,
              sigmaY: blurAmount,
            ),
            child: child,
          );
        }

        // 应用所有变换效果
        return Transform(
          transform: Matrix4.identity()
            ..translate(0.0, currentY)
            ..rotateZ(currentRotation * math.pi / 180)
            ..scale(currentScale),
          alignment: Alignment.center,
          child: Opacity(
            opacity: springValue.clamp(0.0, 1.0), // 将值限制在0.0到1.0之间
            child: child,
          ),
        );
      },
    );
  }

  @override
  Animation<double> createAnimation({
    required AnimationController controller,
    required double startTime,
    required double endTime,
    required Curve curve,
  }) {
    // 使用自定义曲线，将弹簧物理与缓动效果结合
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          startTime,
          endTime,
          curve: Curves.easeOutBack, // 添加轻微的回弹效果
        ),
      ),
    );
  }
}
