import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';

class PaperDotPainter extends CustomPainter {
  const PaperDotPainter();

  static const double spacing = 15;
  static const Offset origin = Offset(8, 9);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = App16Colors.dotGrid;
    for (double y = origin.dy; y < size.height; y += spacing) {
      for (double x = origin.dx; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 0.65, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PaperDotPainter oldDelegate) => false;
}
