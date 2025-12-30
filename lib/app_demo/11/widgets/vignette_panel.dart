import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/11/models/photo_editor_state.dart';
import 'package:flutter_x_widgets/app_demo/11/utils/theme.dart';

class VignettePanel extends StatefulWidget {
  final PhotoEditorState state;

  const VignettePanel({super.key, required this.state});

  @override
  State<VignettePanel> createState() => _VignettePanelState();
}

class _VignettePanelState extends State<VignettePanel> {
  // Vignette value: -1.0 (Light) to 1.0 (Dark)

  void _onPanUpdate(DragUpdateDetails details, double width) {
    // Current value
    final currentVal = widget.state.filters.vignette;

    // Sensitivity
    final delta =
        details.delta.dx /
        (width * 0.5); // Dragging half width = full range 0..1

    // Update
    final newValue = (currentVal + delta).clamp(-1.0, 1.0);

    if (newValue != currentVal) {
      widget.state.updateVignette(newValue);

      String label = 'None';
      if (newValue > 0.05) label = 'Dark: ${(newValue * 100).round()}';
      if (newValue < -0.05) label = 'Light: ${(newValue.abs() * 100).round()}';

      widget.state.showIndicator(label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.9;
    final value = widget.state.filters.vignette;

    return Center(
      child: Container(
        width: width,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: PhotoEditorTheme.softShadow,
        ),
        child: GestureDetector(
          onPanUpdate: (d) => _onPanUpdate(d, width),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Concentric Rectangles Background
                CustomPaint(
                  size: Size(width, 140),
                  painter: _ConcentricRectsPainter(),
                ),

                // Cursor
                // Position is mapped from value -1..1 to range -width/2 .. width/2
                Transform.translate(
                  offset: Offset(value * (width / 2 - 20), 0),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFFB800), // Yellow
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB800).withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConcentricRectsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    // Match screenshot: very tight spacing, about 6-8 layers
    const int count = 7;

    // Base dimensions to fill the container nicely
    final baseW = size.width * 0.95;
    final baseH = size.height * 0.85;

    for (int i = 0; i < count; i++) {
      // Calculate size with tight spacing
      // Each layer is only slightly smaller than the previous
      final spacing = i * 3.0; // Very tight 8px spacing between layers

      final w = baseW - spacing * 2;
      final h = baseH - spacing * 2;

      if (w <= 0 || h <= 0) continue;

      final rect = Rect.fromCenter(center: center, width: w, height: h);
      // Match screenshot's generous corner radius
      final radius = 16.0 - (i * 1.0).clamp(0, 8);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

      // Color gradient: outer layers more visible, inner layers fade
      // Match screenshot's blue-grey tone
      final opacity = (0.6 - i * 0.08).clamp(0.1, 0.6);
      paint.color = const Color(0xFF7B8BA8).withOpacity(opacity);

      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
