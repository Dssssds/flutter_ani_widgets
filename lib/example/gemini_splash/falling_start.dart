import 'dart:math' as math;

import 'package:flutter/material.dart';

class FallingStarWidget extends StatefulWidget {
  final double startY;
  final Color primaryColor;
  final double size;
  final double maxStretch;

  const FallingStarWidget({
    super.key,
    required this.startY,
    required this.primaryColor,
    this.size = 30,
    this.maxStretch = 5.0,
  });

  @override
  State<FallingStarWidget> createState() => _FallingStarWidgetState();
}

class _FallingStarWidgetState extends State<FallingStarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _stretchAnimation;
  late Animation<double> _explosionProgress;
  late Animation<double> _particleSpread;
  late List<Particle> _particles;
  double? _screenWidth;
  double? _screenHeight;

  final int particleCount = 12;

  @override
  void initState() {
    super.initState();
    _initializeParticles();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _setupAnimations();
    _controller.forward();
  }

  void _initializeParticles() {
    _particles = List.generate(particleCount, (index) {
      final angle = (index * 2 * math.pi) / particleCount;
      return Particle(angle: angle);
    });
  }

  void _setupAnimations() {
    if (_screenHeight == null) return;

    final endY = _screenHeight! - MediaQuery.of(context).padding.bottom;

    // 增加动画持续时间以获得更好的效果可见性
    _controller.duration = const Duration(milliseconds: 3500);

    _positionAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.startY, end: endY - 100)
            .chain(CurveTween(curve: Curves.easeInQuart)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: endY - 100, end: endY - 50)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    // 增加模糊值以获得更多发光效果
    _blurAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 25.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 25.0, end: 35.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    // 增加发光强度
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 1.0),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.5),
        weight: 30,
      ),
    ]).animate(_controller);

    // 其余动画保持不变
    _stretchAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: widget.maxStretch),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.maxStretch, end: 1.0),
        weight: 30,
      ),
    ]).animate(_controller);

    _explosionProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
    );

    _particleSpread = Tween<double>(
      begin: 0.0,
      end: 1.2, // 增加扩散范围
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_screenWidth == null || _screenHeight == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _screenWidth! / 2 - widget.size / 2,
          top: _positionAnimation.value,
          child: SizedBox(
            width: widget.size * (1 + _explosionProgress.value * 3),
            height: widget.size * (1 + _explosionProgress.value * 3),
            child: CustomPaint(
              painter: EnhancedStarPainter(
                primaryColor: widget.primaryColor,
                blur: _blurAnimation.value,
                stretchFactor: _stretchAnimation.value,
                explosionProgress: _explosionProgress.value,
                particles: _particles,
                particleSpread: _particleSpread.value,
                glowIntensity: _glowAnimation.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class Particle {
  final double angle;
  final double speed;
  final double size;

  Particle({
    required this.angle,
    this.speed = 1.0,
    this.size = 1.0,
  });
}

class EnhancedStarPainter extends CustomPainter {
  final Color primaryColor;
  final double blur;
  final double stretchFactor;
  final double explosionProgress;
  final List<Particle> particles;
  final double particleSpread;
  final double glowIntensity;

  EnhancedStarPainter({
    required this.primaryColor,
    required this.blur,
    required this.stretchFactor,
    required this.explosionProgress,
    required this.particles,
    required this.particleSpread,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final starPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    // 增强基础发光效果
    final glowPaint = Paint()
      ..color = primaryColor.withOpacity(glowIntensity * 0.7) // 增加不透明度
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur * 3); // 增加模糊效果

    if (explosionProgress > 0) {
      // 绘制底部屏幕发光效果
      final screenGlowRect = Rect.fromLTWH(
          -size.width,
          size.height * 0.5,
          size.width * 3, // 加宽以确保完全覆盖
          size.height);

      final screenGlowGradient = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.0,
        colors: [
          primaryColor.withOpacity(0.4 * explosionProgress),
          primaryColor.withOpacity(0.1 * explosionProgress),
          primaryColor.withOpacity(0),
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      canvas.drawRect(screenGlowRect,
          Paint()..shader = screenGlowGradient.createShader(screenGlowRect));

      // 增强爆炸效果
      final radius = size.width / 2 * (1 + explosionProgress * 2.5); // 增加半径
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Usage
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          FallingStarWidget(
            startY: 100,
            primaryColor: Colors.blue,
            size: 30,
          ),
        ],
      ),
    );
  }
}
