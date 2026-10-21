import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 截图中的米色背景
    const backgroundColor = Color(0xFFF9F5F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.edit_note_rounded, // 类似截图中的编辑图标
              color: Colors.black,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 复古电视机插画
            SizedBox(
              width: 220,
              height: 180,
              child: CustomPaint(painter: RetroTVPainter()),
            ),
            SizedBox(height: 32),
            // 提示文字
            Text(
              'nothing to see here 👀',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF8D8C8A), // 深灰色
              ),
            ),
            SizedBox(height: 8),
            Text(
              'chat with friends and it will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFA8A6A3), // 浅灰色
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 100), // 稍微向上偏移一点视觉中心
          ],
        ),
      ),
    );
  }
}

/// 使用 CustomPainter 绘制复古电视机
class RetroTVPainter extends CustomPainter {
  const RetroTVPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final fillPaint =
        Paint()
          ..color = const Color(0xFFE0E0E0) // 电视机外壳的浅灰色
          ..style = PaintingStyle.fill;

    final screenFillPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 1. 绘制底部地面线 (Ground Line)
    // 在电视下方画一条横线
    canvas.drawLine(Offset(w * 0.1, h * 0.9), Offset(w * 0.9, h * 0.9), paint);

    // 2. 绘制天线 (Antenna)
    // V字形天线
    final antennaBase = Offset(w * 0.55, h * 0.25);
    canvas.drawLine(antennaBase, Offset(w * 0.45, h * 0.1), paint); // 左天线
    canvas.drawLine(antennaBase, Offset(w * 0.65, h * 0.05), paint); // 右天线

    // 3. 绘制电视机身 (Body)
    final bodyRect = Rect.fromLTWH(w * 0.2, h * 0.25, w * 0.6, h * 0.45);
    final bodyRRect = RRect.fromRectAndRadius(
      bodyRect,
      const Radius.circular(16),
    );

    // 先填充灰色背景
    canvas.drawRRect(bodyRRect, fillPaint);
    // 再画黑色描边
    canvas.drawRRect(bodyRRect, paint);

    // 4. 绘制电视脚 (Feet)
    // 左脚
    canvas.drawLine(
      Offset(w * 0.25, h * 0.7), // 机身底部
      Offset(w * 0.25, h * 0.78), // 接地
      Paint()
        ..color = Colors.black
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    // 右脚
    canvas.drawLine(
      Offset(w * 0.75, h * 0.7),
      Offset(w * 0.75, h * 0.78),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // 5. 绘制屏幕 (Screen)
    // 屏幕在机身左侧，留出右侧给旋钮
    final screenRect = Rect.fromLTWH(
      bodyRect.left + 12,
      bodyRect.top + 12,
      bodyRect.width * 0.65,
      bodyRect.height - 24,
    );
    final screenRRect = RRect.fromRectAndRadius(
      screenRect,
      const Radius.circular(12),
    );

    // 屏幕填充白色
    canvas.drawRRect(screenRRect, screenFillPaint);
    // 屏幕描边
    canvas.drawRRect(screenRRect, paint);

    // 6. 绘制心跳波形 (Heartbeat Wave)
    final path = Path();
    final sx = screenRect.left;
    final sy = screenRect.center.dy;
    final sw = screenRect.width;

    path.moveTo(sx + 10, sy);
    path.lineTo(sx + sw * 0.3, sy); // 平
    path.lineTo(sx + sw * 0.35, sy - 15); // 上
    path.lineTo(sx + sw * 0.45, sy + 25); // 下
    path.lineTo(sx + sw * 0.55, sy); // 回中
    path.lineTo(sx + sw - 10, sy); // 平

    canvas.drawPath(path, paint);

    // 7. 绘制控制旋钮和扬声器 (Controls & Speaker)
    final controlX = bodyRect.right - (bodyRect.width * 0.15);
    const knobRadius = 5.0;

    // 上旋钮
    canvas.drawCircle(Offset(controlX, bodyRect.top + 25), knobRadius, paint);
    // 下旋钮
    canvas.drawCircle(Offset(controlX, bodyRect.top + 45), knobRadius, paint);

    // 扬声器孔 (4个小方块/圆点)
    final speakerY = bodyRect.bottom - 30;
    const speakerSize = 3.0;
    final speakerPaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(controlX - 4, speakerY, speakerSize, speakerSize),
      speakerPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(controlX + 2, speakerY, speakerSize, speakerSize),
      speakerPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(controlX - 4, speakerY + 6, speakerSize, speakerSize),
      speakerPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(controlX + 2, speakerY + 6, speakerSize, speakerSize),
      speakerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
