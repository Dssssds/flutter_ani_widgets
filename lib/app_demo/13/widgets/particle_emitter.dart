import 'package:flutter/material.dart';

class ChatParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double life; // 1.0 -> 0.0
  final Color color;

  ChatParticle({
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
    vy += 150 * dt; // 向下的重力加速度
    life -= dt * 1.6; // 寿命衰退率
    if (life < 0) life = 0;
  }
}

class ParticlePainter extends CustomPainter {
  final List<ChatParticle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var p in particles) {
      if (p.life <= 0) continue;
      paint.color = p.color.withOpacity(p.life);
      
      // 绘制粒子
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.life, paint);
      
      // 绘制微小的外圈发光
      final glowPaint = Paint()
        ..color = p.color.withOpacity(p.life * 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.life * 2.0, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
