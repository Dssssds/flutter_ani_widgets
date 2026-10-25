import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';

class PipRing extends StatelessWidget {
  final double fraction;
  final double size;
  final double thickness;
  final Color progressColor;
  final Color trackColor;
  final Widget? child;

  const PipRing({
    super.key,
    required this.fraction,
    this.size = 55,
    this.thickness = 4.5,
    this.progressColor = App15Theme.ink,
    this.trackColor = const Color(0x66FFFEF8),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '完成进度',
      value: '${(fraction.clamp(0, 1) * 100).round()}%',
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(fraction: fraction.clamp(0, 1), thickness: thickness, progressColor: progressColor, trackColor: trackColor),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final double thickness;
  final Color progressColor;
  final Color trackColor;

  const _RingPainter({required this.fraction, required this.thickness, required this.progressColor, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(thickness / 2, thickness / 2, size.width - thickness, size.height - thickness);
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = trackColor);
    if (fraction > 0) {
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * fraction, false, paint..color = progressColor);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.thickness != thickness ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
