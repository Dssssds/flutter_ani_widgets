import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/11/models/photo_editor_state.dart';
import 'package:flutter_x_widgets/app_demo/11/utils/theme.dart';

/// Preview area displaying the image with applied filters
class PreviewArea extends StatefulWidget {
  final ImageProvider imageProvider;
  final PhotoEditorState state;

  const PreviewArea({
    super.key,
    required this.imageProvider,
    required this.state,
  });

  @override
  State<PreviewArea> createState() => _PreviewAreaState();
}

class _PreviewAreaState extends State<PreviewArea> {
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onStateChanged() {
    if (widget.state.indicatorText != null) {
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(milliseconds: 1500), () {
        widget.state.hideIndicator();
      });
    }
    setState(() {});
  }

  /// Build color matrix for filters
  ColorFilter _buildColorFilter(FilterState filters) {
    // 1. Gain (Contrast/Brightness/Highlights/Shadows)
    // - brightness: general multiplier (0.5 - 1.5)
    // - contrast: spreads values (0.5 - 2.0)
    // - highlights: boosts lighter areas (simulated via gain)
    // - shadows: boosts darker areas (simulated via inverse gain)

    double gain = filters.brightness;
    gain *= (1.0 + filters.highlights * 0.2); // +/- 20% gain from highlights
    gain *= (1.0 - filters.shadows * 0.2); // +/- 20% gain from shadows

    // Structure: -50..50 maps to +/- 50% extra gain
    // Simulates Clarity/Punchiness
    gain *= (1.0 + filters.structure * 0.01);

    double c = filters.contrast;
    double s = filters.saturate;

    // 2. Bias (Whites/Blacks)
    // - whites: adds to all channels (brighten)
    // - blacks: adds/subtracts from all channels (darken)
    // Note: Matrix values are usually normalized 0-1 or 0-255 depending on implementation.
    // In Flutter ColorFilter.matrix, the last column is absolute additive (0-255 range usually required roughly).
    // Let's assume +/- 30.0 offset for max effect.
    double bias = (filters.whites * 30.0) + (filters.blacks * 30.0);

    // Grayscale luminance weights
    const double lumR = 0.2126;
    const double lumG = 0.7152;
    const double lumB = 0.0722;

    // Saturation matrix elements
    final double sr = (1 - s) * lumR;
    final double sg = (1 - s) * lumG;
    final double sb = (1 - s) * lumB;

    // Combined transform:
    // [R']   [ (sr+s)*c*gain    sg*c*gain       sb*c*gain       0  bias ] [R]
    // [G'] = [ sr*c*gain        (sg+s)*c*gain   sb*c*gain       0  bias ] [G]
    // [B']   [ sr*c*gain        sg*c*gain       (sb+s)*c*gain   0  bias ] [B]
    // ...

    return ColorFilter.matrix(<double>[
      (sr + s) * c * gain,
      sg * c * gain,
      sb * c * gain,
      0,
      bias,
      sr * c * gain,
      (sg + s) * c * gain,
      sb * c * gain,
      0,
      bias,
      sr * c * gain,
      sg * c * gain,
      (sb + s) * c * gain,
      0,
      bias,
      0,
      0,
      0,
      1,
      0,
    ]);
  }

  String _getTranslatedText(String text) {
    String res = text;
    // Map of replacements
    final map = {
      'Contrast': '对比度',
      'Brightness': '亮度',
      'Master': '整体亮度',
      'Sat': '饱和度',
      'Sepia': '褐色',
      'Structure': '结构',
      'Dark': '暗角(黑)',
      'Light': '暗角(白)',
      'None': '无',
      'Reset All': '已重置',
      'H:': '高光:',
      'W:': '白色:',
      'S:': '阴影:',
      'B:': '黑色:',
    };

    map.forEach((key, value) {
      res = res.replaceAll(key, value);
    });
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final filters = widget.state.filters;
    final indicatorText = widget.state.indicatorText;

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [PhotoEditorTheme.bgPanelSolid, PhotoEditorTheme.bgMain],
          radius: 1.0,
        ),
      ),
      child: Stack(
        children: [
          // Image
          Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 50,
                    offset: const Offset(0, 30),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    ColorFiltered(
                      colorFilter: _buildColorFilter(filters),
                      child: Image(
                        image: widget.imageProvider,
                        fit: BoxFit.contain,
                      ),
                    ),
                    if (filters.vignette != 0)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.transparent,
                                  filters.vignette > 0
                                      ? Colors.black.withOpacity(
                                        filters.vignette.clamp(0.0, 1.0),
                                      )
                                      : Colors.white.withOpacity(
                                        filters.vignette.abs().clamp(0.0, 1.0),
                                      ),
                                ],
                                stops: const [0.3, 1.0],
                                radius: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Value Indicator
          if (indicatorText != null)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: indicatorText.isNotEmpty ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Text(
                          _getTranslatedText(indicatorText),
                          style: PhotoEditorTheme.indicatorStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
