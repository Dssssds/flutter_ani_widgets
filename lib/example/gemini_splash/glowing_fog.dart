import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class MysticalWaves extends StatefulWidget {
  final double height;
  final Duration animationDuration;
  final Duration waveDuration;
  final List<Color>? waveColors;

  const MysticalWaves({
    super.key,
    this.height = 200.0,
    this.animationDuration = const Duration(seconds: 2),
    this.waveDuration = const Duration(seconds: 3),
    this.waveColors,
  });

  @override
  State<MysticalWaves> createState() => MysticalWavesState();
}

class MysticalWavesState extends State<MysticalWaves>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _visibilityController;

  List<Color> get _waveColors =>
      widget.waveColors ??
      [
        const Color(0xFFFFD700).withOpacity(0.5), // 璀璨金色
        const Color(0xFFFFA500).withOpacity(0.4), // 发光橙色
        const Color(0xFFFFE4B5).withOpacity(0.3), // 柔和鹿皮色
      ];

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: widget.waveDuration,
    )..repeat();

    _visibilityController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _visibilityController.dispose();
    super.dispose();
  }

  Future<void> startAnimation() async {
    await _visibilityController.forward();
  }

  Future<void> stopAnimation() async {
    await _visibilityController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveController, _visibilityController]),
      builder: (context, child) {
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 35 * _visibilityController.value,
              sigmaY: 35 * _visibilityController.value,
            ),
            child: Container(
              height: widget.height * _visibilityController.value,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Stack(
                children: List.generate(
                  _waveColors.length,
                  (index) => CustomPaint(
                    size: Size.infinite,
                    painter: _WavePainter(
                      waveColor: _waveColors[index],
                      animation: _waveController,
                      waveOffset: index * 0.4,
                      amplitude: 25 - (index * 5),
                      frequency: 1.5 + (index * 0.5),
                      blur: 30 * _visibilityController.value,
                      opacity: 0.5 * _visibilityController.value,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color waveColor;
  final Animation<double> animation;
  final double waveOffset;
  final double amplitude;
  final double frequency;
  final double blur;
  final double opacity;

  _WavePainter({
    required this.waveColor,
    required this.animation,
    this.waveOffset = 0.0,
    this.amplitude = 20.0,
    this.frequency = 1.5,
    this.blur = 30.0,
    this.opacity = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor.withOpacity(opacity)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(0, height);

    for (double x = 0; x <= width; x++) {
      final relativeX = x / width;
      final normalizedX = (relativeX * frequency * 2 * math.pi) +
          (animation.value * 2 * math.pi) +
          waveOffset;

      final y = height - (math.sin(normalizedX) * amplitude) - (height * 0.2);
      path.lineTo(x, y);
    }

    path.lineTo(width, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 使用示例：
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  MyScreenState createState() => MyScreenState();
}

class MyScreenState extends State<MyScreen> {
  final GlobalKey<MysticalWavesState> _wavesKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 这里是你的主要内容

          // 底部的神秘波浪效果
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MysticalWaves(
              key: _wavesKey,
              height: 200,
              animationDuration: const Duration(seconds: 2),
              waveDuration: const Duration(seconds: 3),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => _wavesKey.currentState?.startAnimation(),
            child: const Icon(Icons.play_arrow),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () => _wavesKey.currentState?.stopAnimation(),
            child: const Icon(Icons.stop),
          ),
        ],
      ),
    );
  }
}
