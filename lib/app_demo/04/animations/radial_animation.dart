import 'dart:math' as math;

import 'package:flutter/material.dart';

class RadialAnimation extends StatefulWidget {
  final Widget child;
  final bool isPlaying;

  const RadialAnimation({
    super.key,
    required this.child,
    this.isPlaying = false,
  });

  @override
  State<RadialAnimation> createState() => _RadialAnimationState();
}

// 射线属性类
class RadialLineProperties {
  final double angle;
  final double speed;
  final double maxLength;
  final Color color;
  final double startWidth;
  final double endWidth;
  final double offsetSpeed; // 添加偏移速度属性

  RadialLineProperties({
    required this.angle,
    required this.speed,
    required this.maxLength,
    required this.color,
    required this.startWidth,
    required this.endWidth,
    required this.offsetSpeed,
  });
}

class _RadialAnimationState extends State<RadialAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<RadialLineProperties> _lines = []; // 改为直接初始化为空列表
  final _random = math.Random();

  // 定义可用的颜色列表
  final List<Color> _colors = [
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    // 1. 先初始化控制器
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // 2. 初始化射线
    _initializeLines();

    // 3. 根据状态播放动画
    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  // 初始化射线
  void _initializeLines() {
    final lineCount = _random.nextInt(6) + 6; // 5-10条线
    _lines = List.generate(lineCount, (index) {
      return RadialLineProperties(
        // 随机生成射线的角度 (0 到 2π)
        angle: _random.nextDouble() * 2 * math.pi,
        // 射线的移动速度 (0.8-1.2之间的随机值)
        speed: 0.8 + _random.nextDouble() * 0.5,
        // 射线的最大长度 (50-300像素之间的随机值)
        maxLength: 50 + _random.nextDouble() * 450,
        // 从预定义的颜色列表中随机选择一个颜色
        color: _colors[_random.nextInt(_colors.length)],
        // 射线起始宽度(较细)
        startWidth: 0.2,
        // 射线结束宽度(较粗),形成锥形效果
        endWidth: 15.0,
        // 随机的偏移速度 (0.5-2.0之间)
        offsetSpeed: 0.5 + _random.nextDouble() * 1.5,
      );
    });
  }

  @override
  void didUpdateWidget(RadialAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _initializeLines();
        _controller.forward(from: 0);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: RadialPainter(
                  lines: _lines,
                  progress: _controller.value,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class RadialPainter extends CustomPainter {
  final List<RadialLineProperties> lines;
  final double progress;

  RadialPainter({
    required this.lines,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 设置固定的绘制区域大小
    const drawSize = Size(800, 800);

    // 计算绘制区域的偏移量，使其居中
    final offsetX = (size.width - drawSize.width) / 2;
    final offsetY = (size.height - drawSize.height) / 2;

    // 设置绘制区域
    final center = Offset(
      offsetX + drawSize.width / 2,
      offsetY + drawSize.height / 2,
    );

    // 计算基准长度（使用固定尺寸）
    final baseLength = math.sqrt(drawSize.width * drawSize.width +
            drawSize.height * drawSize.height) /
        4;

    for (var line in lines) {
      // 计算当前长度，使用固定尺寸作为基准
      final currentLength =
          baseLength * (line.maxLength / 350) * progress * line.speed;

      // 计算起点偏移（让线条从中心点向外移动，使用各自的偏移速度）
      final offsetDistance = 150.0 * progress * line.offsetSpeed;
      final startOffset = Offset(
        math.cos(line.angle) * offsetDistance,
        math.sin(line.angle) * offsetDistance,
      );

      // 计算实际的起点和终点
      final startPoint = Offset(
        center.dx + startOffset.dx,
        center.dy + startOffset.dy,
      );

      final endPoint = Offset(
        startPoint.dx + math.cos(line.angle) * currentLength,
        startPoint.dy + math.sin(line.angle) * currentLength,
      );

      // 计算当前宽度 - 使用 ease-in-out 效果让线条更平滑地从细到粗
      final currentWidth = line.startWidth +
          (line.endWidth - line.startWidth) * (1 - math.pow(1 - progress, 3));

      // 优化透明度曲线，使用 ease-out 效果
      final opacity = (1.0 - math.pow(progress, 2)) * 0.9;

      final paint = Paint()
        ..color = line.color.withOpacity(opacity)
        ..strokeWidth = currentWidth
        // 设置线条端点为圆形,让线条看起来更平滑
        ..strokeCap = StrokeCap.square
        // 设置绘制模式为描边,只绘制线条轮廓
        ..style = PaintingStyle.stroke;

      // 绘制线条（从偏移的起点到终点）
      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(RadialPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
