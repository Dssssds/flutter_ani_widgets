import 'package:flutter/material.dart';
import 'package:just_waveform/just_waveform.dart';

import 'retro_waveform_painter.dart';

class RetroDashboard extends StatelessWidget {
  final Waveform? waveform;
  final Duration currentPosition;
  final Duration totalDuration;

  const RetroDashboard({
    super.key,
    this.waveform,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 36),
      child: ClipPath(
        clipper: RetroScreenClipper(),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 点状背景
              Positioned.fill(
                child: CustomPaint(painter: DottedBackgroundPainter()),
              ),
              // 原始内容
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/live-alt.png',
                            width: 23,
                            height: 23,
                            color: const Color.fromARGB(255, 43, 192, 206),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "2",
                              style: TextStyle(
                                color: Color.fromARGB(255, 43, 192, 206),
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Image.asset(
                              'assets/images/radio-alt.png',
                              width: 20,
                              height: 18,
                              color: const Color.fromARGB(255, 43, 192, 206),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildWaveform(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "OTHERS",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          _buildReactionIcon(Icons.thumb_down),
                          _buildReactionIcon(Icons.sentiment_dissatisfied),
                          _buildReactionIcon(Icons.rocket_launch),
                          _buildReactionIcon(Icons.back_hand),
                          _buildReactionIcon(Icons.sentiment_satisfied),
                          _buildReactionIcon(Icons.favorite),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReactionIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Icon(icon, color: Colors.green[800], size: 18),
    );
  }

  Widget _buildWaveform() {
    if (waveform != null) {
      return Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomPaint(
          size: const Size(double.infinity, 80),
          painter: RetroWaveformPainter(
            waveform: waveform!,
            currentPosition: currentPosition,
            totalDuration: totalDuration,
            fixedWaveColor: const Color(0xFF3A3A3A),
            liveWaveColor: const Color(0xFFFFD200),
            seekLineColor: const Color(0xFFFFD200),
            strokeWidth: 3.0,
            pixelsPerStep: 4.0,
          ),
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Loading...',
          style: TextStyle(color: Colors.grey, fontSize: 18, letterSpacing: 2),
        ),
      );
    }
  }
}

/// 点状背景绘制器
class DottedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.15) // 浅白色
          ..style = PaintingStyle.fill;

    const dotRadius = 2.0; // 点的半径
    const spacing = 20.0; // 点之间的间距

    // 绘制均匀分布的点
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RetroScreenClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    const curveDepth = 12.0;
    const cornerRadius = 30.0;

    // 从左上角圆角开始
    path.moveTo(0, curveDepth + cornerRadius);

    // 左上角圆角
    path.quadraticBezierTo(0, curveDepth, cornerRadius, curveDepth);

    // 顶部椭圆曲线
    path.quadraticBezierTo(width * 0.5, 0, width - cornerRadius, curveDepth);

    // 右上角圆角
    path.quadraticBezierTo(width, curveDepth, width, curveDepth + cornerRadius);

    // 右侧直线
    path.lineTo(width, height - curveDepth - cornerRadius);

    // 右下角圆角
    path.quadraticBezierTo(
      width,
      height - curveDepth,
      width - cornerRadius,
      height - curveDepth,
    );

    // 底部椭圆曲线
    path.quadraticBezierTo(
      width * 0.5,
      height,
      cornerRadius,
      height - curveDepth,
    );

    // 左下角圆角
    path.quadraticBezierTo(
      0,
      height - curveDepth,
      0,
      height - curveDepth - cornerRadius,
    );

    // 左侧直线
    path.lineTo(0, curveDepth + cornerRadius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
