import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_icon.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/journal/ticket_clipper.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';

class WeatherTicket extends StatelessWidget {
  const WeatherTicket({super.key, this.width = 81, this.height = 159});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipPath(
        clipper: const TicketClipper(),
        child: Container(
          decoration: BoxDecoration(
            color: App16Colors.ticketBg,
            border: Border.all(color: App16Colors.ticketBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: width - 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    '午后收集',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2,
                      color: App16Colors.ticketInk,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const App16Icon(
                    name: 'i-sun',
                    size: 25,
                    color: App16Colors.ticketInk,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '23°',
                    style: App16Typography.number(
                      fontSize: 24,
                      letterSpacing: 0,
                      color: App16Colors.ticketInk,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 8,
                    width: width - 18,
                    child: const CustomPaint(painter: _DashedDividerPainter()),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '有风\n有阳光',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: App16Typography.handFamily,
                      fontFamilyFallback: App16Typography.handFallback,
                      fontSize: 14,
                      height: 1.5,
                      color: App16Colors.ticketInk,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  const _DashedDividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFB89271)
          ..strokeWidth = 1;
    const dash = 3.0;
    for (double x = 0; x < size.width; x += dash * 2) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset((x + dash).clamp(0, size.width), size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedDividerPainter oldDelegate) => false;
}
