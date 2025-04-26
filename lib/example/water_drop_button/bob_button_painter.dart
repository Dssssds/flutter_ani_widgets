import 'dart:math' as math;

import 'package:flutter/material.dart';

class BlobButtonPainter extends CustomPainter {
  final double animationValue;
  final bool isMenuOpen;
  final Color color;
  final double elasticity;
  final List<Offset>? subButtonPositions;
  final double subButtonRadius;

  late final Paint _circlePaint;

  BlobButtonPainter({
    required this.animationValue,
    required this.isMenuOpen,
    this.color = const Color(0xFF4CAF50),
    this.elasticity = 0.3,
    this.subButtonPositions,
    this.subButtonRadius = 25,
  }) {
    _circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // 绘制主圆形
    canvas.drawCircle(
        center, radius * (1 - 0.1 * animationValue), _circlePaint);

    // 如果在动画中，添加连接效果
    if (subButtonPositions != null &&
        subButtonPositions!.isNotEmpty &&
        animationValue > 0) {
      _drawSplitEffects(canvas, center, radius);
    }
  }

  void _drawSplitEffects(Canvas canvas, Offset center, double radius) {
    if (subButtonPositions == null) return;

    for (final subButtonPos in subButtonPositions!) {
      final distance = (subButtonPos - center).distance;
      final direction = (subButtonPos - center) / distance;

      // 计算水滴分裂效果的参数
      final progress = animationValue;
      final splitDistance = distance * progress;
      final neckWidth = radius * 0.5 * (1 - progress); // 水滴颈部宽度

      // 计算主水滴和子水滴的大小
      final mainDropRadius = radius * (1 - 0.3 * progress);
      final subDropRadius = subButtonRadius * progress;

      // 计算水滴的位置
      final subDropCenter = center + direction * splitDistance;

      // 绘制水滴连接效果
      final path = Path();

      // 添加主水滴变形
      _addDeformedCircle(
          path, center, mainDropRadius, direction, progress * 0.3);

      // 如果还在连接阶段，绘制颈部
      if (progress < 0.8) {
        _addNeckConnection(
            path, center, subDropCenter, neckWidth, direction, progress);
      }

      // 添加子水滴变形
      _addDeformedCircle(
          path, subDropCenter, subDropRadius, -direction, progress * 0.3);

      // 绘制整个效果
      canvas.drawPath(
          path,
          Paint()
            // ignore: deprecated_member_use
            ..color = color.withOpacity(math.max(0, 1 - progress * 1.5))
            ..style = PaintingStyle.fill
            ..isAntiAlias = true);
    }
  }

  void _addDeformedCircle(Path path, Offset center, double radius,
      Offset direction, double deformation) {
    final deformationOffset = direction * (radius * deformation);

    path.addOval(Rect.fromCircle(
        center: center + deformationOffset,
        radius: radius * (1 - deformation * 0.5)));
  }

  void _addNeckConnection(Path path, Offset start, Offset end, double width,
      Offset direction, double progress) {
    final normal = Offset(-direction.dy, direction.dx);
    final controlPoint1 = start + direction * width * 2 + normal * width;
    final controlPoint2 = end - direction * width * 2 - normal * width;

    path.moveTo(start.dx + normal.dx * width, start.dy + normal.dy * width);
    path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        end.dx - normal.dx * width,
        end.dy - normal.dy * width);
    path.lineTo(end.dx + normal.dx * width, end.dy + normal.dy * width);
    path.cubicTo(
        controlPoint2.dx + normal.dx * width * 2,
        controlPoint2.dy + normal.dy * width * 2,
        controlPoint1.dx + normal.dx * width * 2,
        controlPoint1.dy + normal.dy * width * 2,
        start.dx - normal.dx * width,
        start.dy - normal.dy * width);
    path.close();
  }

  @override
  bool shouldRepaint(covariant BlobButtonPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isMenuOpen != isMenuOpen ||
        oldDelegate.color != color ||
        oldDelegate.elasticity != elasticity ||
        oldDelegate.subButtonPositions != subButtonPositions;
  }
}
