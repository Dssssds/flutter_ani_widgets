import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/coin_state.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

/// 硬币面只负责绘制图案；朝向、透视、阴影和厚度由舞台组合。
///
/// 正面是皇冠加「正面」，反面是五角星加「反面」，两面的图案必须明显不同。
/// 面的内容永远正向绘制：只做各向压缩，不做镜像或旋转，
/// 所以文字不会被翻转成镜像字。
class CoinPainter extends CustomPainter {
  final CoinSide side;

  const CoinPainter({this.side = CoinSide.heads});

  @override
  void paint(Canvas canvas, Size size) {
    const colors = PartyTheme.coinColors;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final face = Rect.fromCircle(center: center, radius: radius);

    // 金属底色：上浅下深，再叠一层斜向高光，读起来像一块抛光金属。
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors[0], colors[1], colors[2], colors[1]],
              stops: const [0, .34, .68, 1],
            ).createShader(face),
    );

    // 内侧压暗，让圆面有一点点凹陷的厚度感。
    canvas.drawCircle(
      center,
      radius * .97,
      Paint()
        ..shader =
            RadialGradient(
              center: const Alignment(-.3, -.45),
              radius: 1.15,
              colors: [Colors.white.withValues(alpha: .34), Colors.transparent, Colors.black.withValues(alpha: .22)],
              stops: const [0, .58, 1],
            ).createShader(face),
    );

    final rim =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = colors.last.withValues(alpha: .78);
    canvas.drawCircle(center, radius * .88, rim);

    // 刻度圈：长短交替，靠近外沿。
    for (var i = 0; i < 60; i++) {
      final angle = i * math.pi / 30;
      final long = i % 5 == 0;
      final outer = radius * .965;
      final inner = radius * (long ? .90 : .925);
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * inner,
        center + Offset(math.cos(angle), math.sin(angle)) * outer,
        Paint()
          ..color = colors.last.withValues(alpha: long ? .85 : .5)
          ..strokeWidth = long ? 2.4 : 1.4
          ..strokeCap = StrokeCap.round,
      );
    }

    // 图案与文字统一使用深色墨水，保证在金属面上有足够对比度。
    const ink = PartyTheme.coinInk;

    if (side == CoinSide.heads) {
      _drawCrown(canvas, center + Offset(0, -radius * .16), radius * .64, ink);
    } else {
      _drawStar(canvas, center + Offset(0, -radius * .15), radius * .29, ink);
    }

    // 字号按半径缩放，保证不同尺寸下比例一致。中文字形比拉丁字母宽，字号取大一些、字距也拉开。
    final painter = TextPainter(
      text: TextSpan(
        text: side == CoinSide.heads ? '正面' : '反面',
        style: TextStyle(
          fontFamily: PartyTheme.bodyFamily,
          fontSize: radius * .24,
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: radius * .1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, center + Offset(-painter.width / 2, radius * .28 - painter.height / 2));
    painter.dispose();
  }

  /// 三尖皇冠：左右两端和中央各一个尖，尖顶带小圆珠，底部有一条亮带。
  void _drawCrown(Canvas canvas, Offset center, double width, Color color) {
    final height = width * .72;
    final left = center.dx - width / 2;
    final right = center.dx + width / 2;
    final top = center.dy - height / 2;
    final bottom = center.dy + height / 2;
    final tips = [Offset(left, top + height * .2), Offset(center.dx, top), Offset(right, top + height * .2)];

    final body =
        Path()
          ..moveTo(left, bottom)
          ..lineTo(tips[0].dx, tips[0].dy)
          ..lineTo(left + width * .26, top + height * .58)
          ..lineTo(tips[1].dx, tips[1].dy)
          ..lineTo(right - width * .26, top + height * .58)
          ..lineTo(tips[2].dx, tips[2].dy)
          ..lineTo(right, bottom)
          ..close();
    final fill = Paint()..color = color;
    canvas.drawPath(body, fill);
    // 圆角：同色描边把转角磨圆。
    canvas.drawPath(
      body,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * .05
        ..strokeJoin = StrokeJoin.round,
    );
    for (final tip in tips) {
      canvas.drawCircle(tip + Offset(0, -height * .03), width * .065, fill);
    }
    // 底部亮带，让皇冠读起来有一圈金属箍。
    canvas.drawLine(
      Offset(left + width * .06, bottom - height * .2),
      Offset(right - width * .06, bottom - height * .2),
      Paint()
        ..color = PartyTheme.coinColors[0].withValues(alpha: .7)
        ..strokeWidth = height * .07
        ..strokeCap = StrokeCap.round,
    );
  }

  /// 规整的五角星，正顶点朝上。
  void _drawStar(Canvas canvas, Offset center, double outer, Color color) {
    final path = Path();
    const innerRatio = .382;
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outer : outer * innerRatio;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(CoinPainter oldDelegate) => oldDelegate.side != side;
}
