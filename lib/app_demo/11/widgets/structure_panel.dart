import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/11/models/photo_editor_state.dart';
import 'package:flutter_x_widgets/app_demo/11/utils/theme.dart';

/// Structure panel with rotatable arc dial (-50 to +50)
class StructurePanel extends StatefulWidget {
  final PhotoEditorState state;

  const StructurePanel({super.key, required this.state});

  @override
  State<StructurePanel> createState() => _StructurePanelState();
}

class _StructurePanelState extends State<StructurePanel> {
  double _lastX = 0;
  // Rotation is mapped visually: 1 unit value = 2 degrees rotation
  // Range -50..50 => -100deg..100deg

  @override
  void initState() {
    super.initState();
  }

  void _onPanStart(DragStartDetails details) {
    _lastX = details.localPosition.dx;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final dx = details.localPosition.dx - _lastX;
    _lastX = details.localPosition.dx;

    // Sensitivity: 1px drag = 0.2 unit change
    final delta = dx * 0.2;

    // Inverted logic for natural scrolling behavior:
    // Drag Left (dx < 0) -> Should bring right-side values (positives) into view -> Increase Value.
    // Drag Right (dx > 0) -> Should bring left-side values (negatives) into view -> Decrease Value.
    double newValue = widget.state.filters.structure - delta;

    newValue = newValue.clamp(-50.0, 50.0);

    if (newValue != widget.state.filters.structure) {
      widget.state.updateStructure(newValue);
      widget.state.showIndicator('Structure: ${newValue.round()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Current value from state
    final value = widget.state.filters.structure;
    // Map value to rotation angle (degrees)
    // value 0 = 0 deg (Center)
    // value -50 = -100 deg
    // value 50 = 100 deg
    final rotationAngle = value * 2.0;

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 180,
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Arc wheel (positioned to show top half)
              Positioned(
                top: 20,
                child: Transform.rotate(
                  angle:
                      -rotationAngle *
                      (math.pi / 180), // Negative to rotate dial against swipe?
                  // If I swipe Left (value decreases), I want the dial to rotate Clockwise?
                  // Usually: Swipe Left -> Content moves Left -> Rotate CCW.
                  // Let's stick to simple mapping: Angle = -Value * Scale.
                  // If Value is -50 (Left), Angle is +100?
                  // Let's visualize: 0 is Top. -50 is Left.
                  // If I want to see -50, I need to rotate -50 to the Top.
                  // So rotation should be +50's worth.
                  // Yes: visualRotation = -value * scale.
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF222222), Colors.transparent],
                        stops: [0.55, 0.65],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: CustomPaint(painter: _ArcTicksPainter()),
                  ),
                ),
              ),

              // Needle indicator (fixed position)
              Positioned(
                bottom: 0,
                child: Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        PhotoEditorTheme.accentSecondary,
                        PhotoEditorTheme.accentPrimary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: PhotoEditorTheme.accentSecondary.withOpacity(
                          0.5,
                        ),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
              ),

              // Mask for bottom fade effect
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        PhotoEditorTheme.bgPanel,
                        PhotoEditorTheme.bgPanel.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),

              // Current Value Display (Optional, big number in center?)
              // User asked for ticks adjustment.
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for arc ticks with Numbers
class _ArcTicksPainter extends CustomPainter {
  static const double radius = 180;

  // Ticks range covering -60 to +60 visually to ensure edges are visible
  // We want ticks for values -50, -40 ... 0 ... 50.
  // Value 1 = 2 degrees.

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw ticks relative to the Circle's coordinate system.
    // The Circle rotates, so these ticks are static relative to the Circle.
    // We map "Value X" to "Angle Y" on the circle.
    // Value 0 is at Angle 0 (Top, -90deg in standard math, but here we draw relative to center).

    // We iterate "values" from -60 to 60 to cover the dial surface.
    for (int v = -60; v <= 60; v += 1) {
      if (v % 2 != 0) continue; // Draw every 2 units

      // Position: Value * 2 degrees
      // 0 is Top.
      final angleRad = v * 2 * (math.pi / 180);

      final isMajor = v % 10 == 0;
      final isLabel = v % 25 == 0 && v.abs() <= 50; // -50, -25, 0, 25, 50

      final innerRadius = radius - (isMajor ? 25 : 15);
      const outerRadius = radius;

      // Coordinate rotation: 0 is Up (0, -r).
      // sin/cos logic:
      // x = r * sin(a)
      // y = r * -cos(a)
      final p1 = Offset(
        center.dx + innerRadius * math.sin(angleRad),
        center.dy - innerRadius * math.cos(angleRad),
      );
      final p2 = Offset(
        center.dx + outerRadius * math.sin(angleRad),
        center.dy - outerRadius * math.cos(angleRad),
      );

      final paint =
          Paint()
            ..color =
                isMajor ? const Color(0xFFDDDDDD) : const Color(0xFF666666)
            ..strokeWidth = isMajor ? 2 : 1
            ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, paint);

      // Draw Labels
      if (isLabel) {
        textPainter.text = TextSpan(
          text: v.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
            shadows: [Shadow(blurRadius: 2, color: Colors.black)],
          ),
        );
        textPainter.layout();

        // Position text slightly below the tick
        final textRadius = innerRadius - 15;
        final tp = Offset(
          center.dx + textRadius * math.sin(angleRad) - textPainter.width / 2,
          center.dy - textRadius * math.cos(angleRad) - textPainter.height / 2,
        );

        // Anti-rotate text so it stays upright?
        // No, usually numbers rotate with the dial.
        // But to make them readable, we might want to rotate the canvas locally.

        canvas.save();
        canvas.translate(
          center.dx + textRadius * math.sin(angleRad),
          center.dy - textRadius * math.cos(angleRad),
        );
        canvas.rotate(angleRad); // Text follows curve orientation
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
