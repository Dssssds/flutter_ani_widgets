import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/11/models/photo_editor_state.dart';

/// Color panel with new layout: Circular sliders for H/W/S/B and large Pill slider for Master
class ColorPanel extends StatelessWidget {
  final PhotoEditorState state;

  const ColorPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Sliders height/size
    const double circleSize = 75;
    const double masterWidth = 85;
    const double masterHeight = 165; // Matches approx 2 circles + gap

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        height: 180,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Column: H & W
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircularVerticalSlider(
                  label: 'H',
                  size: circleSize,
                  value: (state.filters.highlights + 1) / 2,
                  fillColors: const [Color(0xFF666666), Color(0xFF444444)],
                  onChanged: (val) {
                    state.updateHighlights(val * 2 - 1);
                    state.showIndicator(
                      'Highlights: ${(val * 2 - 1).toStringAsFixed(2)}',
                    );
                  },
                ),
                _CircularVerticalSlider(
                  label: 'W',
                  size: circleSize,
                  value: (state.filters.whites + 1) / 2,
                  fillColors: const [Color(0xFF888888), Color(0xFF666666)],
                  onChanged: (val) {
                    state.updateWhites(val * 2 - 1);
                    state.showIndicator(
                      'Whites: ${(val * 2 - 1).toStringAsFixed(2)}',
                    );
                  },
                ),
              ],
            ),

            // Center Column: Master (Brightness)
            _CenterPillSlider(
              width: masterWidth,
              height: masterHeight,
              value: state.filters.brightness - 0.5, // 0.5..1.5 -> 0..1
              onChanged: (val) {
                state.updateBrightness(val + 0.5);
                state.showIndicator(
                  'Brightness: ${((val + 0.5) * 100).round()}%',
                );
              },
            ),

            // Right Column: S & B
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircularVerticalSlider(
                  label: 'S',
                  size: circleSize,
                  value: (state.filters.shadows + 1) / 2,
                  fillColors: const [Color(0xFF2A2A35), Color(0xFF1E1E24)],
                  textColor: const Color(0xFFCCCCFF),
                  onChanged: (val) {
                    state.updateShadows(val * 2 - 1);
                    state.showIndicator(
                      'Shadows: ${(val * 2 - 1).toStringAsFixed(2)}',
                    );
                  },
                ),
                _CircularVerticalSlider(
                  label: 'B',
                  size: circleSize,
                  value: (state.filters.blacks + 1) / 2,
                  fillColors: const [
                    Color.fromARGB(255, 3, 3, 3),
                    Color(0xFF0F0F12),
                  ],
                  textColor: const Color(0xFFCCCCFF),
                  onChanged: (val) {
                    state.updateBlacks(val * 2 - 1);
                    state.showIndicator(
                      'Blacks: ${(val * 2 - 1).toStringAsFixed(2)}',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A circular slider that fills vertically
class _CircularVerticalSlider extends StatefulWidget {
  final String label;
  final double size;
  final double value; // 0.0 - 1.0
  final ValueChanged<double> onChanged;
  final List<Color> fillColors;
  final Color textColor;

  const _CircularVerticalSlider({
    required this.label,
    required this.size,
    required this.value,
    required this.onChanged,
    this.fillColors = const [Colors.grey, Colors.black],
    this.textColor = Colors.white,
  });

  @override
  State<_CircularVerticalSlider> createState() =>
      _CircularVerticalSliderState();
}

class _CircularVerticalSliderState extends State<_CircularVerticalSlider> {
  void _onPanUpdate(DragUpdateDetails details) {
    // Calculate new value based on vertical drag
    // Since it's small, we might want to allow dragging outside slightly?
    // For now, strict mapping within widget height (size) is okay.
    // The touch area is the circle square.
    final height = widget.size;
    final dy = details.localPosition.dy;
    final newValue = (1 - (dy / height)).clamp(0.0, 1.0);
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanDown:
          (d) => _onPanUpdate(
            DragUpdateDetails(
              globalPosition: d.globalPosition,
              localPosition: d.localPosition,
            ),
          ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF111111), // Dark BG
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: ClipOval(
          child: Stack(
            children: [
              // Fill
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: widget.size * widget.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: widget.fillColors,
                    ),
                  ),
                ),
              ),

              // Separator/Indicator Pill at the waterline
              Positioned(
                bottom: widget.size * widget.value - 3,
                left: widget.size * 0.35, // Centered approx
                right: widget.size * 0.35,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: const Color(0xFFFFB800), // Yellow accent
                      width: 2,
                    ),
                  ),
                ),
              ),

              // Label
              Center(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.8),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Large center pill slider with yellow border
class _CenterPillSlider extends StatefulWidget {
  final double width;
  final double height;
  final double value;
  final ValueChanged<double> onChanged;

  const _CenterPillSlider({
    required this.width,
    required this.height,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_CenterPillSlider> createState() => _CenterPillSliderState();
}

class _CenterPillSliderState extends State<_CenterPillSlider> {
  void _onPanUpdate(DragUpdateDetails details) {
    final dy = details.localPosition.dy;
    final newValue = (1 - (dy / widget.height)).clamp(0.0, 1.0);
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanDown:
          (d) => _onPanUpdate(
            DragUpdateDetails(
              globalPosition: d.globalPosition,
              localPosition: d.localPosition,
            ),
          ),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(widget.width / 2),
          border: Border.all(
            color: const Color(0xFFFFB800), // Yellow Accent Border
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.width / 2),
          child: Stack(
            children: [
              // Fill
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: widget.height * widget.value,
                child: Container(
                  color: const Color(0xFF666666), // Medium Gray Fill
                ),
              ),

              // Separator/Indicator Pill
              Positioned(
                bottom: widget.height * widget.value - 4,
                left: widget.width * 0.3,
                right: widget.width * 0.3,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFFFB800,
                    ).withOpacity(0.2), // Inner fill slightly
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: const Color(0xFFFFB800),
                      width: 2,
                    ),
                  ),
                ),
              ),

              // Icon
              const Center(
                child: Icon(
                  Icons.wb_sunny_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
