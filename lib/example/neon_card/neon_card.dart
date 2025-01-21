import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 一个具有霓虹灯发光效果的卡片组件。
///
/// 该组件通过自定义绘制实现外发光效果，支持动态颜色渐变和强度调节。
/// 发光效果会随时间自动产生平滑的动画效果。
class NeonCard extends StatefulWidget {
  /// 卡片的内容组件
  final Widget child;

  /// 发光效果的强度，取值范围 0.0-1.0
  /// 值越大，发光效果越明显
  final double intensity;

  /// 发光效果的扩散范围
  /// 该值决定了光晕向外扩散的距离
  final double glowSpread;

  const NeonCard({
    super.key,
    required this.child,
    this.intensity = 0.3,
    this.glowSpread = 3.0,
  });

  @override
  NeonCardState createState() => NeonCardState();
}

class NeonCardState extends State<NeonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: GlowRectanglePainter(
            progress: _controller.value,
            intensity: widget.intensity,
            glowSpread: widget.glowSpread,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// 自定义画笔，用于实现霓虹灯发光效果
///
/// 通过组合径向渐变和线性渐变，实现动态变化的发光边框效果
class GlowRectanglePainter extends CustomPainter {
  /// 动画进度值，范围 0.0-1.0
  final double progress;

  /// 发光强度
  final double intensity;

  /// 发光扩散范围
  final double glowSpread;

  GlowRectanglePainter({
    required this.progress,
    this.intensity = 0.3,
    this.glowSpread = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    // 定义渐变使用的颜色
    const firstColor = Color(0xFFFF00AA);
    const secondColor = Color(0xFF00FFF1);
    const blurSigma = 50.0;

    // 绘制外发光效果
    final backgroundPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width / 2, size.height / 2),
        size.width * glowSpread,
        [
          Color.lerp(firstColor, secondColor, progress)!.withOpacity(intensity),
          Color.lerp(firstColor, secondColor, progress)!.withOpacity(0.0),
        ],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);
    canvas.drawRect(rect.inflate(size.width * glowSpread), backgroundPaint);

    // 绘制卡片的黑色背景
    final blackPaint = Paint()..color = Colors.black;
    canvas.drawRRect(rrect, blackPaint);

    // 绘制霓虹边框
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = LinearGradient(
        colors: [
          Color.lerp(firstColor, secondColor, progress)!,
          Color.lerp(secondColor, firstColor, progress)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    canvas.drawRRect(rrect, glowPaint);
  }

  @override
  bool shouldRepaint(GlowRectanglePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.intensity != intensity ||
      oldDelegate.glowSpread != glowSpread;
}
