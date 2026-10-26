import 'package:flutter/material.dart';

class TicketClipper extends CustomClipper<Path> {
  const TicketClipper({this.teeth = 16, this.depth = 3.5});

  final int teeth;
  final double depth;

  @override
  Path getClip(Size size) {
    final path = Path();
    final step = size.width / teeth;
    path.moveTo(0, depth);
    for (var index = 0; index < teeth; index++) {
      path.lineTo((index + 0.5) * step, 0);
      path.lineTo((index + 1) * step, depth);
    }
    path.lineTo(size.width, size.height - depth);
    for (var index = teeth - 1; index >= 0; index--) {
      path.lineTo((index + 0.5) * step, size.height);
      path.lineTo(index * step, size.height - depth);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant TicketClipper oldClipper) =>
      oldClipper.teeth != teeth || oldClipper.depth != depth;
}
