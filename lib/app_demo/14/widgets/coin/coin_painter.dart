import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/coin_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

/// 硬币面只负责绘制；朝向、阴影和厚度由舞台组合。
class CoinPainter extends CustomPainter {
  final CoinAppearance appearance;
  final CoinSide side;
  const CoinPainter(this.appearance, {this.side = CoinSide.heads});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = PartyTheme.coinColors(appearance);
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.45;
    final face = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors).createShader(face),
    );
    final rim =
        Paint()
          ..color = colors.last.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.88, rim);
    for (var i = 0; i < 60; i++) {
      final angle = i * math.pi / 30;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.93,
        center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.97,
        rim,
      );
    }
    void text(String value, double fontSize, double y) {
      final painter = TextPainter(
        text: TextSpan(text: value, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: colors.last)),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, center + Offset(-painter.width / 2, y - painter.height / 2));
      painter.dispose();
    }

    text(side == CoinSide.heads ? '✦' : '☾', radius * 0.65, -radius * 0.18);
    text(side == CoinSide.heads ? 'HEADS' : 'TAILS', radius * 0.20, radius * 0.35);
  }

  @override
  bool shouldRepaint(CoinPainter oldDelegate) => oldDelegate.appearance != appearance || oldDelegate.side != side;
}
