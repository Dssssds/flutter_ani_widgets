import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';

class SelectionBorderPainter extends CustomPainter {
  const SelectionBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(-4, -4, size.width + 8, size.height + 8);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    final path = Path()..addRRect(rrect);
    final paint =
        Paint()
          ..color = App16Colors.berry
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + 4).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += 7;
      }
    }

    final dot = Paint()..color = App16Colors.berry;
    for (final corner in <Offset>[
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ]) {
      canvas.drawCircle(corner, 1.6, dot);
    }
  }

  @override
  bool shouldRepaint(covariant SelectionBorderPainter oldDelegate) => false;
}
