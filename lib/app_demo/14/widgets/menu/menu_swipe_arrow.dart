import 'package:flutter/material.dart';

/// Decorative paging hint. Eyes stay upright when the arrow changes direction.
class MenuSwipeArrow extends StatelessWidget {
  const MenuSwipeArrow({super.key, required this.pageProgress, this.width = 72, this.reduceMotion = false});

  final double pageProgress;

  bool get pointsLeft => pageProgress < .5;
  final double width;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: Transform.scale(
        key: const ValueKey('menu-arrow-turn'),
        scaleX: reduceMotion || MediaQuery.disableAnimationsOf(context) ? (pointsLeft ? -1.0 : 1.0) : 2 * pageProgress.clamp(0.0, 1.0) - 1,
        child: SizedBox(width: width, height: width * .65, child: const CustomPaint(painter: _SwipeArrowPainter(false))),
      ),
    ),
  );
}

class _SwipeArrowPainter extends CustomPainter {
  const _SwipeArrowPainter(this.pointsLeft);

  final bool pointsLeft;

  @override
  void paint(Canvas canvas, Size size) {
    // Reflect only horizontal coordinates, never rotate the canvas or the eyes.
    Offset point(double x, double y) => Offset((pointsLeft ? 1 - x : x) * size.width, y * size.height);
    final paint =
        Paint()
          ..color = const Color(0xFFD9C3F3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * .17
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    final shaft =
        Path()
          ..moveTo(point(.13, .68).dx, point(.13, .68).dy)
          ..quadraticBezierTo(point(.42, .38).dx, point(.42, .38).dy, point(.84, .48).dx, point(.84, .48).dy);
    final head =
        Path()
          ..moveTo(point(.65, .20).dx, point(.65, .20).dy)
          ..lineTo(point(.85, .48).dx, point(.85, .48).dy)
          ..lineTo(point(.65, .78).dx, point(.65, .78).dy);
    canvas.drawPath(shaft, paint);
    canvas.drawPath(head, paint);
    final eyePaint = Paint()..color = const Color(0xFF211526);
    for (final x in [.36, .49]) {
      final center = point(x, .48);
      canvas.drawOval(Rect.fromCenter(center: center, width: size.width * .045, height: size.height * .12), eyePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SwipeArrowPainter oldDelegate) => pointsLeft != oldDelegate.pointsLeft;
}
