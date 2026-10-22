import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/dice/dice_motion.dart';

/// 带倒角的象牙白立方体骰子：6 个内缩的面 + 12 条棱面 + 8 个角面，按法线做光照着色。
///
/// 立方体是真正的凸多面体，所以只要剔除背面就不需要再排序。点数画在各个面所在的平面上，
/// 随面一起透视变形。整个舞台由一个画笔绘制，方便统一决定叠放顺序和投影。
class DiceStagePainter extends CustomPainter {
  const DiceStagePainter({required this.dice, required this.side});

  final List<DiceVisual> dice;

  /// 骰子边长（像素）。
  final double side;

  /// 倒角占半边长的比例。
  static const double _bevel = .14;

  /// 相机到立方体中心的距离，单位是半边长；越小透视越明显。
  static const double _camera = 6;

  static const Vec3 _light = (x: -.35, y: .55, z: .75);
  static const Color _ivoryLight = Color(0xFFFFFAF2);
  static const Color _ivoryDark = Color(0xFFB9AD9C);
  static const Color _pipLight = Color(0xFF3A3532);
  static const Color _pipDark = Color(0xFF1E1B19);

  @override
  void paint(Canvas canvas, Size size) {
    // 先画所有投影，再按抛起高度从低到高画骰子：飞得高的盖在上面。
    for (final die in dice) {
      _paintShadow(canvas, die);
    }
    final order = [...dice]..sort((a, b) => a.lift.compareTo(b.lift));
    for (final die in order) {
      if (die.opacity < 1) {
        canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: die.opacity.clamp(0.0, 1.0)));
        _paintDie(canvas, die);
        canvas.restore();
      } else {
        _paintDie(canvas, die);
      }
    }
  }

  void _paintShadow(Canvas canvas, DiceVisual die) {
    final height = die.lift.clamp(0.0, 1.0);
    final width = side * die.scale * (1.08 - .38 * height);
    final rect = Rect.fromCenter(center: die.floor + Offset(0, side * .56), width: width, height: side * .2 * (1 - .3 * height));
    canvas.drawOval(
      rect,
      Paint()
        ..color = Colors.black.withValues(alpha: .42 * (1 - .65 * height) * die.opacity.clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, side * .07),
    );
  }

  void _paintDie(Canvas canvas, DiceVisual die) {
    final half = side / 2 * die.scale;
    const inset = 1 - _bevel;

    Vec3 rotate(Vec3 p) => die.rotation.apply(p);
    Offset project(Vec3 p) {
      final factor = _camera / (_camera - p.z);
      return Offset(die.center.dx + p.x * half * factor, die.center.dy - p.y * half * factor);
    }

    // 面片的朝向：法线与“面心指向相机”的向量夹角为锐角才可见。
    bool facing(Vec3 normal, Vec3 center) =>
        V3.dot(normal, (x: -center.x, y: -center.y, z: _camera - center.z)) > 0;

    double shade(Vec3 normal) {
      final d = V3.dot(normal, V3.normalize(_light)) * .5 + .5;
      return .35 + .65 * math.pow(d.clamp(0.0, 1.0), 1.2).toDouble();
    }

    /// 画一个面片；返回它是否可见以及着色，供点数使用。
    double? facet(List<Vec3> corners, Vec3 localNormal, Vec3 localCenter) {
      final normal = rotate(V3.normalize(localNormal));
      if (!facing(normal, rotate(localCenter))) return null;
      final level = shade(normal);
      final color = Color.lerp(_ivoryDark, _ivoryLight, level)!;
      final path = Path()..addPolygon([for (final c in corners) project(rotate(c))], true);
      canvas.drawPath(path, Paint()..color = color);
      // 同色细描边盖住相邻面片之间的抗锯齿缝隙。
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8
          ..strokeJoin = StrokeJoin.round,
      );
      return level;
    }

    // 棱面：连接相邻两个面各自内缩后的边。
    for (var i = 0; i < DiceFaces.all.length; i++) {
      for (var j = i + 1; j < DiceFaces.all.length; j++) {
        final a = DiceFaces.all[i].normal;
        final b = DiceFaces.all[j].normal;
        if (V3.dot(a, b).abs() > .5) continue; // 相对的两个面不相邻
        final t = V3.cross(a, b);
        facet(
          [
            V3.add(V3.add(a, V3.scale(b, inset)), V3.scale(t, inset)),
            V3.add(V3.add(a, V3.scale(b, inset)), V3.scale(t, -inset)),
            V3.add(V3.add(b, V3.scale(a, inset)), V3.scale(t, -inset)),
            V3.add(V3.add(b, V3.scale(a, inset)), V3.scale(t, inset)),
          ],
          V3.add(a, b),
          V3.scale(V3.add(a, b), (1 + inset) / 2),
        );
      }
    }

    // 角面：每个顶点处三个面各取最靠近该顶点的内缩角，连成一个三角形。
    for (final sx in const [-1.0, 1.0]) {
      for (final sy in const [-1.0, 1.0]) {
        for (final sz in const [-1.0, 1.0]) {
          final corners = <Vec3>[
            (x: sx, y: sy * inset, z: sz * inset),
            (x: sx * inset, y: sy, z: sz * inset),
            (x: sx * inset, y: sy * inset, z: sz),
          ];
          facet(
            corners,
            (x: sx, y: sy, z: sz),
            (x: sx * (1 + 2 * inset) / 3, y: sy * (1 + 2 * inset) / 3, z: sz * (1 + 2 * inset) / 3),
          );
        }
      }
    }

    // 六个面和面上的点数。
    for (final face in DiceFaces.all) {
      Vec3 at(double u, double v) => V3.add(V3.add(face.normal, V3.scale(face.right, u)), V3.scale(face.up, v));
      final level = facet([at(-inset, -inset), at(inset, -inset), at(inset, inset), at(-inset, inset)], face.normal, face.normal);
      if (level == null) continue;
      final pipColor = Color.lerp(_pipDark, _pipLight, level)!;
      // 点数略高于面（0.002），避免与面片重叠闪烁。
      Vec3 raised(double u, double v) => V3.add(at(u, v), V3.scale(face.normal, .002));
      for (final pip in DiceFaces.pips(face.value)) {
        final cu = pip.dx * 1.25 * inset;
        final cv = pip.dy * 1.25 * inset;
        const radius = .16;
        // 圆用 14 边形近似，随面一起透视变形。
        final points = <Offset>[
          for (var k = 0; k < 14; k++)
            project(rotate(raised(cu + math.cos(k / 14 * 2 * math.pi) * radius, cv + math.sin(k / 14 * 2 * math.pi) * radius))),
        ];
        canvas.drawPath(Path()..addPolygon(points, true), Paint()..color = pipColor);
      }
    }
  }

  @override
  bool shouldRepaint(DiceStagePainter oldDelegate) => true;
}
