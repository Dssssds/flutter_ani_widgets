import 'package:flutter/material.dart';

enum MenuBandEdge { straight, rising, falling }

/// 斜切只改变背景下沿，内容始终水平；深度不占用额外行高。
class MenuBandClipper extends CustomClipper<Path> {
  final MenuBandEdge edge;
  final double depth;

  const MenuBandClipper({required this.edge, this.depth = 14});

  @override
  Path getClip(Size size) {
    final cut = depth.clamp(0.0, size.height / 4);
    final left = size.height - (edge == MenuBandEdge.falling ? cut : 0);
    final right = size.height - (edge == MenuBandEdge.rising ? cut : 0);
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, right)
      ..lineTo(0, left)
      ..close();
  }

  @override
  bool shouldReclip(MenuBandClipper oldClipper) => edge != oldClipper.edge || depth != oldClipper.depth;
}
