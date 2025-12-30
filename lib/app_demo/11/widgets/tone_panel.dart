import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/11/models/photo_editor_state.dart';

/// Tone panel with gradient plus-grid and rounded star cursor
class TonePanel extends StatefulWidget {
  final PhotoEditorState state;

  const TonePanel({super.key, required this.state});

  @override
  State<TonePanel> createState() => _TonePanelState();
}

class _TonePanelState extends State<TonePanel> {
  Offset _crosshairPosition = const Offset(0.5, 0.5); // Normalized 0-1

  void _onPanStart(DragStartDetails details) {
    _updatePosition(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _updatePosition(details.localPosition);
  }

  void _updatePosition(Offset localPosition) {
    final box = context.findRenderObject() as RenderBox;
    final size = box.size;

    final normalizedX = (localPosition.dx / size.width).clamp(0.0, 1.0);
    final normalizedY = (localPosition.dy / size.height).clamp(0.0, 1.0);

    setState(() {
      _crosshairPosition = Offset(normalizedX, normalizedY);
    });

    // Update filters
    final saturation = normalizedX * 2; // 0-2
    final sepia = normalizedY; // 0-1

    widget.state.updateSaturate(saturation);
    widget.state.updateSepia(sepia);
    widget.state.showIndicator(
      'Sat: ${(saturation * 100).round()}%  Sepia: ${(sepia * 100).round()}%',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF111111), // Dark BG
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanDown:
              (d) => _onPanUpdate(
                DragUpdateDetails(
                  globalPosition: d.globalPosition,
                  localPosition: d.localPosition,
                ),
              ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Plus Grid Background
                Positioned.fill(
                  child: CustomPaint(painter: _PlusGridPainter()),
                ),

                // Rounded Star Cursor
                Positioned(
                  left:
                      _crosshairPosition.dx *
                          (MediaQuery.of(context).size.width * 0.9) -
                      24, // Size/2
                  top: _crosshairPosition.dy * 160 - 24,
                  child: const _RoundedStarCursor(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Painter for the gradient plus grid
class _PlusGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1.5;

    const double spacing = 20.0;
    final int cols = (size.width / spacing).ceil();
    final int rows = (size.height / spacing).ceil();

    // Define gradient colors
    // Left: Cool (Blue/Purple/Cyan)
    // Right: Warm (Yellow/Green)
    const List<Color> colors = [
      Color(0xFF6F86D6), // Cool Blue
      Color(0xFF48C6EF), // Cyan
      Color(0xFF76E2B3), // Greenish
      Color(0xFFF9D423), // Yellow
    ];

    for (int col = 0; col < cols; col++) {
      for (int row = 0; row < rows; row++) {
        final double x = col * spacing + spacing / 2;
        final double y = row * spacing + spacing / 2;

        if (x > size.width || y > size.height) continue;

        // Determine color based on X position (Mainly) and slight Y variation
        final double t = (x / size.width).clamp(0.0, 1.0);

        // Simple linear interpolation between multiple colors
        final Color color = _getGradientColor(t, colors);

        paint.color = color.withOpacity(0.8);

        // Draw Plus sign
        const double r = 2.0; // Radius/Size of plus arm
        canvas.drawLine(Offset(x - r, y), Offset(x + r, y), paint);
        canvas.drawLine(Offset(x, y - r), Offset(x, y + r), paint);
      }
    }
  }

  Color _getGradientColor(double t, List<Color> colors) {
    if (t <= 0) return colors.first;
    if (t >= 1) return colors.last;

    final double step = 1.0 / (colors.length - 1);
    final int index = (t / step).floor();
    final double localT = (t - (index * step)) / step;

    return Color.lerp(colors[index], colors[index + 1], localT)!;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Rounded 4-point star cursor
class _RoundedStarCursor extends StatelessWidget {
  const _RoundedStarCursor();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: CustomPaint(painter: _StarCursorPainter()),
    );
  }
}

class _StarCursorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint =
        Paint()
          ..color = const Color(0xFFFFB800) // Yellow Accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Draw a rounded 4-point star shape
    // Effectively a super-ellipse or just 4 quadratic curves
    const double r = 16.0; // Arm length
    const double innerR = 4.0; // Inner curve radius

    // Top
    path.moveTo(center.dx, center.dy - r);
    // Top-Right Curve
    path.quadraticBezierTo(
      center.dx + innerR,
      center.dy - innerR,
      center.dx + r,
      center.dy,
    );
    // Bottom-Right Curve
    path.quadraticBezierTo(
      center.dx + innerR,
      center.dy + innerR,
      center.dx,
      center.dy + r,
    );
    // Bottom-Left Curve
    path.quadraticBezierTo(
      center.dx - innerR,
      center.dy + innerR,
      center.dx - r,
      center.dy,
    );
    // Top-Left Curve
    path.quadraticBezierTo(
      center.dx - innerR,
      center.dy - innerR,
      center.dx,
      center.dy - r,
    );

    path.close();

    // Glow Effect
    canvas.drawShadow(path, const Color(0xFFFFB800), 8, true);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
