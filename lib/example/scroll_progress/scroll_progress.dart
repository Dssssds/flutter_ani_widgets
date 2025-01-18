import 'package:flutter/material.dart';

enum ScrollProgressStyle {
  default_, // 默认样式,纯色进度条
  gradient, // 渐变色进度条
  thick, // 加粗进度条,不同颜色
  slim, // 细线进度条,不同颜色
  shimmer, // 闪光效果进度条
}

class ScrollProgressBasic extends StatefulWidget {
  final ScrollProgressStyle style;
  final Function(double)? onProgressChanged;

  const ScrollProgressBasic({
    super.key,
    this.style = ScrollProgressStyle.default_,
    this.onProgressChanged,
  });

  @override
  State<ScrollProgressBasic> createState() => _ScrollProgressBasicState();
}

class _ScrollProgressBasicState extends State<ScrollProgressBasic> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollProgress() {
    if (_scrollController.position.maxScrollExtent > 0) {
      final progress = (_scrollController.offset /
              _scrollController.position.maxScrollExtent)
          .clamp(0.0, 1.0);
      setState(() {
        _scrollProgress = progress;
      });
      widget.onProgressChanged?.call(progress);
    }
  }

  Widget _buildProgressIndicator(bool isDarkMode) {
    switch (widget.style) {
      case ScrollProgressStyle.default_:
        return _buildDefaultIndicator(isDarkMode);
      case ScrollProgressStyle.gradient:
        return _buildGradientIndicator(isDarkMode);
      case ScrollProgressStyle.thick:
        return _buildThickIndicator(isDarkMode);
      case ScrollProgressStyle.slim:
        return _buildSlimIndicator(isDarkMode);
      case ScrollProgressStyle.shimmer:
        return _buildShimmerIndicator(isDarkMode);
    }
  }

  Widget _buildShimmerIndicator(bool isDarkMode) {
    return Stack(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color:
                isDarkMode ? const Color(0xFF111927) : const Color(0xFFE6F4FE),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(
          height: 6,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _scrollProgress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  colors: const [
                    Color(0xFF00FFF1),
                    Color(0xFFFF00AA),
                    Color(0xFF00FFF1),
                  ],
                  stops: const [
                    0.0,
                    0.5,
                    1.0,
                  ],
                  transform: GradientRotation(_scrollProgress * 6.28),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildDefaultIndicator(bool isDarkMode) {
    return Stack(
      children: [
        Container(
          height: 4,
          color: isDarkMode ? const Color(0xFF111927) : const Color(0xFFE6F4FE),
        ),
        SizedBox(
          height: 4,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _scrollProgress,
            child: Container(
              color: const Color(0xFF0090FF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientIndicator(bool isDarkMode) {
    return Stack(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color:
                isDarkMode ? const Color(0xFF111927) : const Color(0xFFE6F4FE),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(
          height: 6,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _scrollProgress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00C6FF),
                    Color(0xFF0072FF),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThickIndicator(bool isDarkMode) {
    return Stack(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color:
                isDarkMode ? const Color(0xFF111927) : const Color(0xFFE6F4FE),
          ),
        ),
        SizedBox(
          height: 8,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _scrollProgress,
            child: Container(
              color: Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlimIndicator(bool isDarkMode) {
    return Stack(
      children: [
        Container(
          height: 2,
          color: isDarkMode ? const Color(0xFF111927) : const Color(0xFFE6F4FE),
        ),
        SizedBox(
          height: 2,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _scrollProgress,
            child: Container(
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Scrollable content
        SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 32,
            ),
            child: Column(
              children: List.generate(
                50,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      '${index + 1} 这是第${index + 1}行',
                      style: TextStyle(
                        fontFamily: 'Monospace',
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Bottom gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 48,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  isDarkMode
                      ? Colors.black.withOpacity(0.9)
                      : Colors.white.withOpacity(0.9),
                  isDarkMode
                      ? Colors.black.withOpacity(0)
                      : Colors.white.withOpacity(0),
                ],
              ),
            ),
          ),
        ),

        // Progress indicator
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildProgressIndicator(isDarkMode),
        ),
      ],
    );
  }
}
