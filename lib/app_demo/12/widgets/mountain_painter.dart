import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/12/models/todo_model.dart';

/// 粒子模型，用于撤销动画尾迹和堆积微粒
class PhysicsParticle {
  double x, y;
  double vx, vy;
  double size;
  double life; // 1.0 -> 0.0
  final Color color;

  PhysicsParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.life,
    required this.color,
  });

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    vy += 100 * dt; // 微弱重力
    life -= dt * 1.5; // 寿命衰减
    if (life < 0) life = 0;
  }
}

/// 正在下落的物理字母状态
class PhysicsLetter {
  final String id;
  final String char;
  double x, y;
  double vx, vy;
  double angle;
  double angularVelocity;
  final double size;
  final Color color;
  bool isStatic;
  int settledFrames; // 连续休眠帧数
  double delay; // 延迟释放倒计时（秒）

  PhysicsLetter({
    required this.id,
    required this.char,
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
    this.angle = 0,
    this.angularVelocity = 0,
    required this.size,
    required this.color,
    this.isStatic = false,
    this.settledFrames = 0,
    this.delay = 0,
  });

  double get radius => size * 0.45;
}

/// 正在撤销返回列表的字母动画状态
class UndoAnimation {
  final String id; // 归属待办项的唯一 ID (即 batchId)
  final String char;
  final Offset start;
  final Offset target;
  final double size;
  final Color color;
  double progress; // 0.0 -> 1.0
  final Offset control; // 贝塞尔控制点

  UndoAnimation({
    required this.id,
    required this.char,
    required this.start,
    required this.target,
    required this.size,
    required this.color,
    required this.control,
    this.progress = 0.0,
  });
}

/// 火柴人攀登者状态
class ClimberState {
  double x = 100;
  double y = 0;
  double vx = 0;
  double walkPhase = 0;
  bool isClimbing = false;
  bool facingRight = true;
  double targetX = 100;
  bool patrollingRight = true; // 持续左右巡航的方向标志

  void update(double dt, List<double> heightmap, double width, double groundY) {
    if (heightmap.isEmpty) return;

    // 持续左右自动往复巡航目标逻辑
    if (patrollingRight) {
      targetX = width - 40.0;
      if (x >= width - 55.0) {
        patrollingRight = false;
      }
    } else {
      targetX = 40.0;
      if (x <= 55.0) {
        patrollingRight = true;
      }
    }

    // 水平移动：弹簧加速朝着目标前进
    double dx = targetX - x;
    vx += dx.sign * 80 * dt;
    facingRight = dx > 0;
    walkPhase += vx.abs() * dt * 0.15;

    // 速度限制和阻尼 (限制巡航最大速度以保证肢体动画协调自然)
    vx = vx.clamp(-75.0, 75.0);
    vx *= 0.95;
    x += vx * dt;
    x = x.clamp(30.0, width - 30.0); // 确保火柴人不会超出屏幕两侧隐藏

    // 重新启用高度图（山坡/地表）追踪吸附
    int mapX = x.round().clamp(0, heightmap.length - 1);
    double targetY = heightmap[mapX];

    // 为了防止重力物理与不规则碰撞体边缘突跳，进行平滑吸附插值
    if (y == 0) {
      y = targetY;
    } else {
      y = y + (targetY - y) * 0.25;
    }

    // 爬行判定：根据当前坡度判定是否在攀爬山体
    int nextMapX = (x + (facingRight ? 12 : -12)).round().clamp(0, heightmap.length - 1);
    double nextY = heightmap[nextMapX];
    isClimbing = (nextY - targetY).abs() > 8.0;
  }
}

/// 山景待办自定义画板
class MountainPainter extends CustomPainter {
  final List<PhysicsLetter> activeLetters;
  final List<SettledLetter> settledLetters;
  final List<UndoAnimation> activeUndos;
  final List<PhysicsParticle> particles;
  final ClimberState climber;
  final List<double> heightmap;
  final double groundY;

  MountainPainter({
    required this.activeLetters,
    required this.settledLetters,
    required this.activeUndos,
    required this.particles,
    required this.climber,
    required this.heightmap,
    required this.groundY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 绘制纯黑背景
    canvas.drawColor(Colors.black, BlendMode.srcOver);

    // 2. 绘制当天已固化的山体字母
    _paintSettledLetters(canvas);

    // 3. 绘制正在下落的物理字母
    _paintActiveLetters(canvas);

    // 4. 绘制撤销的字母及粒子尾迹
    _paintUndoAnimations(canvas);

    // 5. 绘制粒子
    _paintParticles(canvas);

    // 6. 绘制火柴人攀登者
    _paintClimber(canvas);
  }

  void _paintGroundGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E223D).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 地平线
    canvas.drawLine(Offset(0, groundY), Offset(size.width, groundY), paint);

    // 网格透视斜线
    int divisions = 16;
    for (int i = 0; i <= divisions; i++) {
      double pct = i / divisions;
      double topX = size.width * pct;
      double bottomX = size.width * 0.5 + (topX - size.width * 0.5) * 1.5;
      canvas.drawLine(Offset(topX, groundY), Offset(bottomX, size.height), paint);
    }

    // 渐近线
    double y = groundY;
    double dy = 8.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      dy *= 1.35; // 远近拉伸
      y += dy;
    }
  }

  void _paintSettledLetters(Canvas canvas) {
    for (var letter in settledLetters) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: letter.char,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: letter.size,
            fontFamily: 'NeumaticGothic-Black',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 4,
              )
            ],
          ),
        ),
      )..layout();

      canvas.save();
      canvas.translate(letter.x, letter.y);
      canvas.rotate(letter.angle);

      // 渐进放大：在屏幕底部区域内线性放大 1.0 -> 1.25，增强近大远小纵深
      double scale = 1.0;
      double scaleThresholdY = groundY - 150.0;
      if (letter.y > scaleThresholdY) {
        double pct = ((letter.y - scaleThresholdY) / 150.0).clamp(0.0, 1.0);
        scale = 1.0 + 0.25 * pct;
      }
      canvas.scale(scale);

      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  void _paintActiveLetters(Canvas canvas) {
    for (var letter in activeLetters) {
      if (letter.delay > 0) continue; // 尚未释放

      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: letter.char,
          style: TextStyle(
            color: letter.color,
            fontSize: letter.size,
            fontFamily: 'NeumaticGothic-Black',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: letter.color.withOpacity(0.6),
                blurRadius: 8,
              )
            ],
          ),
        ),
      )..layout();

      canvas.save();
      canvas.translate(letter.x, letter.y);
      canvas.rotate(letter.angle);

      // 渐进放大：在屏幕底部区域内线性放大 1.0 -> 1.25，增强近大远小纵深
      double scale = 1.0;
      double scaleThresholdY = groundY - 150.0;
      if (letter.y > scaleThresholdY) {
        double pct = ((letter.y - scaleThresholdY) / 150.0).clamp(0.0, 1.0);
        scale = 1.0 + 0.25 * pct;
      }
      canvas.scale(scale);

      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  void _paintUndoAnimations(Canvas canvas) {
    if (activeUndos.isEmpty) return;

    // 1. 按 id 分组正在飞行的字母，绘制同批次字母之间的发光连接折线
    final Map<String, List<UndoAnimation>> groups = {};
    for (var undo in activeUndos) {
      groups.putIfAbsent(undo.id, () => []).add(undo);
    }

    for (var entry in groups.entries) {
      final list = entry.value;
      if (list.length < 2) continue;

      // 按照飞行折线实时点计算出连接路径
      final List<Offset> points = [];
      double avgProgress = 0.0;
      for (var undo in list) {
        double t = undo.progress;
        double mt = 1 - t;
        double px = mt * mt * undo.start.dx + 2 * mt * t * undo.control.dx + t * t * undo.target.dx;
        double py = mt * mt * undo.start.dy + 2 * mt * t * undo.control.dy + t * t * undo.target.dy;
        points.add(Offset(px, py));
        avgProgress += t;
      }
      avgProgress /= list.length;

      // 飞越后半段 (0.5 -> 1.0) 连接线线性淡出
      double lineOpacity = 1.0;
      if (avgProgress > 0.5) {
        lineOpacity = ((1.0 - avgProgress) / 0.5).clamp(0.0, 1.0);
      }

      if (lineOpacity > 0.01) {
        final path = Path();
        path.moveTo(points[0].dx, points[0].dy);
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }

        // 外层霓虹发光层
        final glowPaint = Paint()
          ..color = const Color(0xFF5030EF).withOpacity(0.45 * lineOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, glowPaint);

        // 内层白炽核心层
        final corePaint = Paint()
          ..color = Colors.white.withOpacity(0.9 * lineOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, corePaint);
      }
    }

    // 2. 绘制每个飞行的字符
    for (var undo in activeUndos) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: undo.char,
          style: TextStyle(
            color: undo.color,
            fontSize: undo.size,
            fontFamily: 'NeumaticGothic-Black',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: undo.color.withOpacity(0.8), blurRadius: 10),
            ],
          ),
        ),
      )..layout();

      // 二阶贝塞尔求当前点
      double t = undo.progress;
      double mt = 1 - t;
      double x = mt * mt * undo.start.dx + 2 * mt * t * undo.control.dx + t * t * undo.target.dx;
      double y = mt * mt * undo.start.dy + 2 * mt * t * undo.control.dy + t * t * undo.target.dy;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * math.pi * 4); // 飞回时自旋
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  void _paintParticles(Canvas canvas) {
    for (var p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.life)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.life, paint);
    }
  }

  void _paintClimber(Canvas canvas) {
    final bodyPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final hatPaint = Paint()
      ..color = const Color(0xFF00FF66)
      ..style = PaintingStyle.fill;

    // 骨架参考尺寸
    const double headRadius = 7.0;
    const double bodyLength = 16.0;
    const double limbLength = 12.0;

    // 极点定位
    double limbDir = climber.facingRight ? 1.0 : -1.0;
    double headX = climber.x;
    double headY = climber.y - bodyLength - headRadius * 2;
    double hipX = climber.x;
    double hipY = climber.y - limbLength;

    // 火柴人头部
    canvas.drawCircle(Offset(headX, headY), headRadius, bodyPaint);
    
    // 荧光帽
    final hatPath = Path()
      ..moveTo(headX - headRadius * 0.8, headY - headRadius * 0.6)
      ..lineTo(headX, headY - headRadius * 1.5)
      ..lineTo(headX + headRadius * 0.8, headY - headRadius * 0.6)
      ..close();
    canvas.drawPath(hatPath, hatPaint);

    // 身体躯干
    canvas.drawLine(Offset(headX, headY + headRadius), Offset(hipX, hipY), bodyPaint);

    double phase = climber.walkPhase;

    if (climber.isClimbing) {
      // 1. 爬行姿态：手向上攀附，腿部弯曲跨步
      double armAngle1 = -math.pi / 3 + math.sin(phase) * 0.4;
      double armAngle2 = -math.pi / 3 - math.sin(phase) * 0.4;

      // 绘制左臂、右臂 (向上举起)
      _drawLimb(canvas, headX, headY + headRadius, armAngle1, limbLength, limbDir, bodyPaint);
      _drawLimb(canvas, headX, headY + headRadius, armAngle2, limbLength, -limbDir, bodyPaint);

      // 绘制腿部 (大幅跨步贴地)
      double legAngle1 = math.pi / 4 + math.sin(phase) * 0.3;
      double legAngle2 = math.pi / 4 - math.sin(phase) * 0.3;
      _drawLimb(canvas, hipX, hipY, legAngle1, limbLength, limbDir, bodyPaint);
      _drawLimb(canvas, hipX, hipY, legAngle2, limbLength, -limbDir, bodyPaint);
    } else {
      // 2. 行走/站立姿态：双臂摆动，双腿行走
      double armAngle1 = math.pi / 4 + math.sin(phase) * 0.5;
      double armAngle2 = math.pi / 4 - math.sin(phase) * 0.5;

      // 双臂摆动
      _drawLimb(canvas, headX, headY + headRadius, armAngle1, limbLength, -limbDir, bodyPaint);
      _drawLimb(canvas, headX, headY + headRadius, armAngle2, limbLength, limbDir, bodyPaint);

      // 双腿行走
      double legAngle1 = math.pi / 6 + math.sin(phase) * 0.4;
      double legAngle2 = math.pi / 6 - math.sin(phase) * 0.4;
      _drawLimb(canvas, hipX, hipY, legAngle1, limbLength, limbDir, bodyPaint);
      _drawLimb(canvas, hipX, hipY, legAngle2, limbLength, -limbDir, bodyPaint);
    }
  }

  void _drawLimb(Canvas canvas, double startX, double startY, double angle, double length, double scaleX, Paint paint) {
    // scaleX控制镜像朝向
    double jointX = startX + math.sin(angle) * length * 0.6 * scaleX;
    double jointY = startY + math.cos(angle) * length * 0.6;
    
    // 关节稍微弯曲
    double endX = jointX + math.sin(angle + 0.3) * length * 0.5 * scaleX;
    double endY = jointY + math.cos(angle + 0.3) * length * 0.5;

    canvas.drawLine(Offset(startX, startY), Offset(jointX, jointY), paint);
    canvas.drawLine(Offset(jointX, jointY), Offset(endX, endY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
