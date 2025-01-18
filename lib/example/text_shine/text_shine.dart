import 'dart:math' as math;

import 'package:flutter/material.dart';

class TextShiningDemo extends StatelessWidget {
  const TextShiningDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 39, 22, 231), // 深靛蓝色
              Color.fromARGB(255, 78, 185, 155), // 亮靛蓝色
              Color.fromARGB(255, 98, 141, 78), // 浅靛蓝色
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            const GridBackground(),
            const BackgroundShimmerEffect(), // 新增的动画背景
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 30, // 增加阴影高度
                    shadowColor: Colors.black26, // 更深的阴影颜色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32), // 增加圆角半径
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 56.0,
                        vertical: 48.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          // 添加渐变效果
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.95),
                            Colors.white.withOpacity(0.90),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const AnimatedIconContainer(), // 新增的动画图标容器
                          const SizedBox(height: 32),
                          ShimmerText(
                            text: "文字闪烁",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w800, // 更粗的字体
                                  letterSpacing: 0.5, // 增加字间距
                                ),
                            shimmerColors: const [
                              // 自定义闪烁颜色
                              Color(0xFF64748B),
                              Color(0xFF818CF8),
                              Color(0xFF64748B),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ShimmerText(
                            text: "今天明天昨天星期天 ✨",
                            shimmerWidth: 200, // 增加宽度
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: const Color(0xFF64748B),
                                  height: 1.5,
                                  letterSpacing: 0.3,
                                  fontSize: 18,
                                ),
                            shimmerColors: const [
                              // 自定义闪烁颜色
                              Color(0xFF64748B),
                              Color(0xFF818CF8),
                              Color(0xFF64748B),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedIconContainer extends StatefulWidget {
  const AnimatedIconContainer({super.key});

  @override
  State<AnimatedIconContainer> createState() => _AnimatedIconContainerState();
}

class _AnimatedIconContainerState extends State<AnimatedIconContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.2),
                    const Color(0xFF818CF8).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 48,
                color: Color(0xFF6366F1),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ShimmerText extends StatefulWidget {
  final String text;
  final double? shimmerWidth;
  final TextStyle? style;
  final List<Color> shimmerColors;

  const ShimmerText({
    super.key,
    required this.text,
    this.shimmerWidth = 100.0,
    this.style,
    this.shimmerColors = const [
      Color(0xFF1E293B),
      Color(0xFF818CF8),
      Color(0xFF1E293B),
    ],
  });

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500), // 更快的动画速度
      vsync: this,
    );
    _startAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() async {
    while (mounted) {
      await _controller.forward();
      await Future.delayed(const Duration(milliseconds: 200)); // 更短的暂停时间
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: widget.shimmerColors,
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(
                percent: _controller.value,
                width: widget.shimmerWidth ?? 100.0,
              ),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            widget.text,
            style: widget.style,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

class BackgroundShimmerEffect extends StatefulWidget {
  const BackgroundShimmerEffect({super.key});

  @override
  State<BackgroundShimmerEffect> createState() =>
      _BackgroundShimmerEffectState();
}

class _BackgroundShimmerEffectState extends State<BackgroundShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
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
          painter: ShimmerBackgroundPainter(
            animation: _controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class ShimmerBackgroundPainter extends CustomPainter {
  final double animation;

  ShimmerBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color.fromARGB(255, 141, 143, 229).withOpacity(0.8),
          const Color.fromARGB(255, 59, 72, 189).withOpacity(0.9),
          const Color.fromARGB(255, 137, 48, 103).withOpacity(0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(animation * 2 * math.pi),
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(ShimmerBackgroundPainter oldDelegate) =>
      oldDelegate.animation != animation;
}

// 原始的网格绘制器和其他支持类保持不变...

class GridBackground extends StatelessWidget {
  const GridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(),
      child: Container(),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.percent,
    required this.width,
  });

  final double percent;
  final double width;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (percent * 2.0 - 1.0),
      0.0,
      0.0,
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.07)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const gridSize = 32.0; // 稍小的网格尺寸
    final horizontalLines = (size.height / gridSize).ceil();
    final verticalLines = (size.width / gridSize).ceil();

    for (var i = 0; i <= horizontalLines; i++) {
      final y = i * gridSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (var i = 0; i <= verticalLines; i++) {
      final x = i * gridSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final random = math.Random(42);
    final dotPaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    for (var i = 0; i <= verticalLines; i++) {
      for (var j = 0; j <= horizontalLines; j++) {
        if (random.nextDouble() < 0.08) {
          // 稍少的点
          canvas.drawCircle(
            Offset(i * gridSize, j * gridSize),
            2.5, // 稍大的点
            dotPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
