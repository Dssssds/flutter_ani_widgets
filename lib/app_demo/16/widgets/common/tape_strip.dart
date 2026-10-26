import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/tape_painter.dart';

class TapeStrip extends StatelessWidget {
  const TapeStrip({
    super.key,
    required this.style,
    required this.width,
    required this.height,
    this.rotation = 0,
    this.opacity = 0.86,
  });

  final String style;
  final double width;
  final double height;
  final double rotation;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * 3.141592653589793 / 180,
      child: Opacity(
        opacity: opacity,
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(painter: TapePainter(style)),
        ),
      ),
    );
  }
}
