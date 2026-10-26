import 'package:flutter/material.dart';

class TapePainter extends CustomPainter {
  const TapePainter(this.style);

  final String style;

  static Path tapePath(Size size) {
    final path =
        Path()
          ..moveTo(size.width * 0.03, 0)
          ..lineTo(size.width * 0.98, size.height * 0.04)
          ..lineTo(size.width * 0.96, size.height)
          ..lineTo(0, size.height * 0.95)
          ..close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = tapePath(size);
    canvas.drawShadow(path, const Color(0x1A5E4237), 1, false);
    canvas.save();
    canvas.clipPath(path);

    switch (style) {
      case 'rose':
        _paintRose(canvas, size);
        break;
      case 'check':
        _paintCheck(canvas, size);
        break;
      case 'caramel':
        canvas.drawRect(
          Offset.zero & size,
          Paint()..color = const Color(0xFFDBA86F),
        );
        break;
      case 'flower-tape':
        _paintDots(
          canvas,
          size,
          background: const Color(0xFFEBC3CD),
          dot: const Color(0xFFB96583),
          radius: 2,
          spacing: 13,
        );
        break;
      case 'dots':
        _paintDots(
          canvas,
          size,
          background: const Color(0xFFDACB9F),
          dot: const Color(0xFF997E55),
          radius: 1.4,
          spacing: 9,
        );
        break;
      default:
        canvas.drawRect(
          Offset.zero & size,
          Paint()..color = const Color(0xFFB4BFB0),
        );
    }

    canvas.restore();
  }

  void _paintRose(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFC989A4),
    );
    final paint = Paint()..color = const Color(0xFFECB8CA);
    for (double x = 0; x < size.width; x += 10) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 5, size.height), paint);
    }
  }

  void _paintCheck(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFDCE4E6),
    );
    final vertical = Paint()..color = const Color(0xFFA7B9CD);
    for (double x = 0; x < size.width; x += 16) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 8, size.height), vertical);
    }
    final horizontal = Paint()..color = const Color(0x669AACC0);
    for (double y = 0; y < size.height; y += 16) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 8), horizontal);
    }
  }

  void _paintDots(
    Canvas canvas,
    Size size, {
    required Color background,
    required Color dot,
    required double radius,
    required double spacing,
  }) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final paint = Paint()..color = dot;
    var row = 0;
    for (double y = spacing / 2; y < size.height; y += spacing) {
      final offset = row.isEven ? 0.0 : spacing / 2;
      for (double x = spacing / 2 + offset; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant TapePainter oldDelegate) =>
      oldDelegate.style != style;
}
