import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/11/models/photo_editor_state.dart';
import 'package:flutter_x_widgets/app_demo/11/utils/theme.dart';

/// Enhancer panel with horizontal slider wave control
class EnhancerPanel extends StatefulWidget {
  final PhotoEditorState state;

  const EnhancerPanel({super.key, required this.state});

  @override
  State<EnhancerPanel> createState() => _EnhancerPanelState();
}

class _EnhancerPanelState extends State<EnhancerPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  double _sliderX = 0.5; // Normalized slider position (0.0 - 1.0)

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialize slider position based on current contrast
    _sliderX = (widget.state.filters.contrast / 2.0).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _updateSliderPosition(Offset localPosition, double containerWidth) {
    setState(() {
      _sliderX = (localPosition.dx / containerWidth).clamp(0.0, 1.0);
    });

    // Update contrast (0.0 - 2.0)
    final contrast = _sliderX * 2.0;
    widget.state.updateContrast(contrast);
    widget.state.showIndicator(
      'Contrast: ${(contrast * 100).round()}%',
    );
  }

  @override
  Widget build(BuildContext context) {
    final containerWidth = MediaQuery.of(context).size.width * 0.9;

    return Center(
      child: Container(
        width: containerWidth,
        height: 140,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF111111), Color(0xFF1A1A1A)],
          ),
          borderRadius: BorderRadius.circular(PhotoEditorTheme.radiusCard),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: GestureDetector(
          onPanDown: (details) => _updateSliderPosition(
            details.localPosition,
            containerWidth,
          ),
          onPanUpdate: (details) => _updateSliderPosition(
            details.localPosition,
            containerWidth,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(PhotoEditorTheme.radiusCard),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                final phase = _animController.value * math.pi * 2;
                final sliderPixelX = _sliderX * containerWidth;

                return Stack(
                  children: [
                    // Left wave (gold/orange - adjusted)
                    CustomPaint(
                      painter: _LeftWavePainter(
                        phase: phase,
                        amplitude: _sliderX * 50, // 0 - 50px
                        sliderX: sliderPixelX,
                      ),
                      size: Size(containerWidth, 140),
                    ),

                    // Right wave (gray - preview)
                    CustomPaint(
                      painter: _RightWavePainter(
                        phase: phase,
                        amplitude: 30, // Fixed preview amplitude
                        sliderX: sliderPixelX,
                      ),
                      size: Size(containerWidth, 140),
                    ),

                    // Slider indicator
                    Positioned(
                      left: sliderPixelX - 3,
                      top: 40,
                      child: _SliderIndicator(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Left wave painter (gold/orange - dynamic amplitude)
class _LeftWavePainter extends CustomPainter {
  final double phase;
  final double amplitude;
  final double sliderX;

  _LeftWavePainter({
    required this.phase,
    required this.amplitude,
    required this.sliderX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sliderX <= 0) return;

    final midY = size.height / 2;
    const layers = 2;

    for (int l = 0; l < layers; l++) {
      final path = Path();
      final opacity = 1.0 - (l * 0.4);
      final offsetPhase = l * 1.5;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = l == 0
            ? PhotoEditorTheme.accentPrimary.withOpacity(opacity)
            : PhotoEditorTheme.accentSecondary.withOpacity(opacity * 0.7);

      for (int x = 0; x <= sliderX.toInt(); x++) {
        final y = midY +
            math.sin(x * 0.05 + phase + offsetPhase) *
                amplitude.clamp(0, 50);

        if (x == 0) {
          path.moveTo(x.toDouble(), y);
        } else {
          path.lineTo(x.toDouble(), y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LeftWavePainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.sliderX != sliderX;
  }
}

/// Right wave painter (gray - fixed amplitude preview)
class _RightWavePainter extends CustomPainter {
  final double phase;
  final double amplitude;
  final double sliderX;

  _RightWavePainter({
    required this.phase,
    required this.amplitude,
    required this.sliderX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sliderX >= size.width) return;

    final midY = size.height / 2;
    const layers = 3;

    for (int l = 0; l < layers; l++) {
      final path = Path();
      final opacity = 0.3 - (l * 0.1);
      final offsetPhase = l * 1.5;

      final grayShade = 100 + (l * 30);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = Color.fromRGBO(grayShade, grayShade, grayShade, opacity);

      for (int x = sliderX.toInt(); x <= size.width.toInt(); x++) {
        final y =
            midY + math.sin(x * 0.05 + phase + offsetPhase) * amplitude;

        if (x == sliderX.toInt()) {
          path.moveTo(x.toDouble(), y);
        } else {
          path.lineTo(x.toDouble(), y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RightWavePainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.sliderX != sliderX;
  }
}

/// Vertical slider indicator
class _SliderIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFAAAAAA),
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(-1, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
    );
  }
}
