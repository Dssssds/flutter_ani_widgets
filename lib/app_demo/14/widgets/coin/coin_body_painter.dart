import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/coin_state.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/coin_painter.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

/// 硬币的几何常量；舞台布局和绘制共用同一套数值。
abstract final class CoinShape {
  /// 硬币的标准直径（逻辑像素）。绘制始终用这个尺寸，缩放交给外层 Transform。
  static const double diameter = 216;

  /// 硬币的标准半径。
  static const double radius = diameter / 2;

  /// 硬币厚度，只在侧向时可见。
  static const double thickness = 24;

  /// 相机到硬币的距离。距离越近，近大远小越明显。
  static const double camera = 170;

  /// 近面可能达到的最大透视放大倍数。
  ///
  /// 深度最大为半厚 `thickness / 2`，据此算出放大系数并向上取整。
  /// 绘制时用它反推基准半径，保证放大后的硬币仍然落在分配的方框内。
  static const double maxPerspective = 1.08;

  static double scale(double depth) => camera / (camera - depth);
}

/// 硬币本体：圆柱的侧面剪影 + 正反两面的透视。
///
/// 硬币是一个绕横轴旋转的圆柱，θ 为旋转角：
///
/// - 正面圆心位于 `y = -half·sin θ`、`z = +half·cos θ`；
/// - 反面圆心位于 `y = +half·sin θ`、`z = -half·cos θ`。
///
/// 两个面的深度一正一负，于是近面放大、远面缩小，形成近大远小的透视。
/// 圆柱的剪影由「远面圆盘 + 中间连接带 + 近面圆盘」组成。正对用户时两个面
/// 的屏幕位置重合，连接带高度为零，看不到厚度；侧过来时连接带展开成一条
/// 有厚度的边，因此厚度只在侧向出现。
///
/// 面的内容始终正向可读：只做各向压缩，不做镜像或旋转，
/// 所以面上的文字永远是正着的，字形不会被翻转。
class CoinBodyPainter extends CustomPainter {
  /// 硬币的正面（角度为 0 时朝向用户的那一面）。
  final CoinSide side;

  /// 当前旋转角，允许超出 [0, 2π)。
  final double angle;

  const CoinBodyPainter({required this.side, required this.angle});

  /// 硬币的另一面。
  CoinSide get _opposite => side == CoinSide.heads ? CoinSide.tails : CoinSide.heads;

  /// 当前朝向用户的那一面。
  CoinSide get visibleSide => math.cos(angle) >= 0 ? side : _opposite;

  @override
  void paint(Canvas canvas, Size size) {
    const colors = PartyTheme.coinColors;
    final center = size.center(Offset.zero);
    // 透视会把近面放大，所以基准半径要按最大放大系数反推，
    // 保证放大后的硬币仍然完整落在分配的方框内，不被裁掉。
    final radius = math.min(size.width, size.height) / 2 / CoinShape.maxPerspective;
    // 硬币面按标准尺寸绘制，再整体缩放到当前半径。
    final unit = radius / CoinShape.radius;

    final theta = angle;
    final cosine = math.cos(theta);
    final sine = math.sin(theta);
    // 正面在屏幕上的高度占比：正对时为 1，侧过来时趋于 0。
    final squash = cosine.abs();

    const half = CoinShape.thickness / 2;
    // 两个面沿视线的深度：cos 为正时正面离相机更近。
    final frontScale = CoinShape.scale(half * cosine);
    final backScale = CoinShape.scale(-half * cosine);
    // 圆心的竖直间距；正对时为零，侧过来时达到整个厚度。
    final frontDy = half * sine * frontScale;
    final backDy = -half * sine * backScale;

    final frontIsNear = cosine >= 0;
    final nearRect = _faceRect(center, radius, frontIsNear ? frontDy : backDy, frontIsNear ? frontScale : backScale, squash);
    final farRect = _faceRect(center, radius, frontIsNear ? backDy : frontDy, frontIsNear ? backScale : frontScale, squash);

    // 侧面金属渐变：上下亮、中间暗，读起来是一段圆柱壁。
    final shell = Rect.fromCenter(center: center, width: radius * 2.4, height: radius * 2.4);
    final shellPaint =
        Paint()
          ..shader =
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors[1], colors[2], colors[2], colors[1]],
                stops: const [0, .3, .7, 1],
              ).createShader(shell);

    // 远面圆盘：多半被近面盖住，露出的是圆柱远端的边缘。
    canvas.drawOval(farRect, shellPaint);
    // 连接带：近面与远面之间露出的那圈厚度。
    canvas.drawPath(
      Path()
        ..moveTo(nearRect.left, nearRect.center.dy)
        ..lineTo(farRect.left, farRect.center.dy)
        ..lineTo(farRect.right, farRect.center.dy)
        ..lineTo(nearRect.right, nearRect.center.dy)
        ..close(),
      shellPaint,
    );
    // 近面圆盘。
    canvas.drawOval(nearRect, shellPaint);

    if (squash <= .02) return;
    _paintFace(canvas, nearRect, frontIsNear ? frontScale : backScale, squash, visibleSide, unit: unit);
  }

  /// 面的投影椭圆：横向按透视系数放大，纵向再乘以 cos 的绝对值。
  Rect _faceRect(Offset center, double radius, double dy, double scale, double squash) {
    return Rect.fromCenter(
      center: Offset(center.dx, center.dy + dy),
      width: radius * 2 * scale,
      height: radius * 2 * squash * scale,
    );
  }

  /// 把面画在透视后的椭圆里。
  ///
  /// 只做各向压缩，不做镜像或旋转，所以文字始终正向可读。
  void _paintFace(
    Canvas canvas,
    Rect rect,
    double nearScale,
    double squash,
    CoinSide face, {
    required double unit,
  }) {
    // 面接近侧视时淡出，避免留下细窄的锯齿。
    final opacity = ((squash - .02) / .22).clamp(0.0, 1.0);
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.scale(nearScale * unit, nearScale * unit * squash);
    if (opacity < 1) {
      canvas.saveLayer(
        Rect.fromCircle(center: Offset.zero, radius: CoinShape.radius),
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
    }
    // 此处坐标原点在硬币中心，而 CoinPainter 以左上角为原点绘制整张面，先平移半径对齐。
    canvas.translate(-CoinShape.radius, -CoinShape.radius);
    CoinPainter(side: face).paint(canvas, const Size.square(CoinShape.diameter));
    if (opacity < 1) canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CoinBodyPainter oldDelegate) => oldDelegate.side != side || oldDelegate.angle != angle;
}

/// 硬币外圈的多层柔光：内层亮黄、外层金色，强度随抛起高度变化。
class CoinGlowPainter extends CustomPainter {
  final List<Color> colors;
  final double strength;

  /// 硬币在屏幕上的半径。
  final double radius;

  /// 光晕中心的屏幕坐标。
  final Offset center;

  const CoinGlowPainter({
    required this.colors,
    required this.strength,
    required this.radius,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (strength <= 0) return;
    void halo(double factor, Color color, double alpha, double blur) {
      canvas.drawCircle(
        center,
        radius * factor,
        Paint()
          ..color = color.withValues(alpha: (alpha * strength).clamp(0.0, 1))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
      );
    }

    // 外层金色柔光铺底，内层亮黄收紧在硬币周围。
    halo(1.5, colors[1], .10, radius * .22);
    halo(1.22, colors[1], .12, radius * .14);
    halo(1.06, colors[0], .35, radius * .10);
  }

  @override
  bool shouldRepaint(CoinGlowPainter oldDelegate) =>
      oldDelegate.strength != strength || oldDelegate.colors != colors || oldDelegate.radius != radius;
}

/// 揭晓圆环：三圈细金线由硬币外沿向外扩散并逐渐变淡。
///
/// [progress] 是 0..1 的扩散进度；三圈错开起步，外圈稍后出发。
/// [opacity] 用来在下一轮开始时把还没散尽的圆环整体淡出。
class CoinRingsPainter extends CustomPainter {
  final double progress;
  final double opacity;
  final Color color;

  /// 硬币在屏幕上的半径。
  final double radius;

  /// 圆环中心的屏幕坐标。
  final Offset center;

  const CoinRingsPainter({
    required this.progress,
    required this.opacity,
    required this.color,
    required this.radius,
    required this.center,
  });

  static const int ringCount = 3;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    for (var i = 0; i < ringCount; i++) {
      // 每圈占用整段进度的 70%，起点依次后移。
      final t = ((progress - i * .15) / .7).clamp(0.0, 1.0);
      if (t <= 0 || t >= 1) continue;
      final eased = Curves.easeOutCubic.transform(t);
      canvas.drawCircle(
        center,
        radius * (1.04 + eased * (.7 + i * .12)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = color.withValues(alpha: (1 - t) * .7 * opacity),
      );
    }
  }

  @override
  bool shouldRepaint(CoinRingsPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.opacity != opacity || oldDelegate.radius != radius;
}