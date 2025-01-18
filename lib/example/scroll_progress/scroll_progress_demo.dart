import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/scroll_progress/design/widget_theme.dart';
import 'package:flutter_x_widgets/example/scroll_progress/scroll_progress.dart';

class ScrollProgressDemo extends StatefulWidget {
  const ScrollProgressDemo({super.key});

  @override
  State<ScrollProgressDemo> createState() => _ScrollProgressBasicState();
}

class _ScrollProgressBasicState extends State<ScrollProgressDemo> {
  ScrollProgressStyle _currentStyle = ScrollProgressStyle.default_;
  double _progress = 0.0;

  void _updateProgress(double progress) {
    setState(() {
      _progress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ScrollProgressBasic(
            style: _currentStyle,
            onProgressChanged: _updateProgress,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '进度条样式',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(_progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StyleButton(
                          title: '默认',
                          isSelected:
                              _currentStyle == ScrollProgressStyle.default_,
                          onTap: () => setState(() {
                            _currentStyle = ScrollProgressStyle.default_;
                          }),
                        ),
                        const SizedBox(width: 8),
                        _StyleButton(
                          title: '渐变',
                          isSelected:
                              _currentStyle == ScrollProgressStyle.gradient,
                          onTap: () => setState(() {
                            _currentStyle = ScrollProgressStyle.gradient;
                          }),
                        ),
                        const SizedBox(width: 8),
                        _StyleButton(
                          title: '加粗',
                          isSelected:
                              _currentStyle == ScrollProgressStyle.thick,
                          onTap: () => setState(() {
                            _currentStyle = ScrollProgressStyle.thick;
                          }),
                        ),
                        const SizedBox(width: 8),
                        _StyleButton(
                          title: '细条',
                          isSelected: _currentStyle == ScrollProgressStyle.slim,
                          onTap: () => setState(() {
                            _currentStyle = ScrollProgressStyle.slim;
                          }),
                        ),
                        const SizedBox(width: 8),
                        _StyleButton(
                          title: '多色',
                          isSelected:
                              _currentStyle == ScrollProgressStyle.shimmer,
                          onTap: () => setState(() {
                            _currentStyle = ScrollProgressStyle.shimmer;
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : isDarkMode
                    ? Colors.grey[800]
                    : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : isDarkMode
                      ? Colors.white
                      : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class GridPatternPainter extends CustomPainter {
  final bool isDarkMode;

  GridPatternPainter({required this.isDarkMode});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.getPatternColor(isDarkMode)
      ..strokeWidth = 1;

    const spacing = 20.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
