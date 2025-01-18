import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimationPhoto extends StatefulWidget {
  final Widget coverChild;
  final Widget pageChild;
  final double? width;
  final double? height;
  final Duration animationDuration;
  final double maxOpenAngle;
  final double aspectRatio;
  final double expandedWidth;

  const AnimationPhoto({
    super.key,
    required this.coverChild,
    required this.pageChild,
    this.width,
    this.height,
    this.animationDuration = const Duration(milliseconds: 800),
    this.maxOpenAngle = 180,
    this.aspectRatio = 0.7,
    this.expandedWidth = 200,
  });

  @override
  State<AnimationPhoto> createState() => _AnimationPhotoState();
}

class _AnimationPhotoState extends State<AnimationPhoto>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _widthAnimation;
  bool _isOpen = false;

  Size _getBookDimensions(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final safeWidth = screenSize.width - padding.left - padding.right;
    final safeHeight = screenSize.height - padding.top - padding.bottom;

    final maxAllowedWidth = safeWidth / 1.6;
    final maxAllowedHeight = safeHeight * 0.8;

    if (widget.width != null && widget.height != null) {
      if (widget.width! <= maxAllowedWidth &&
          widget.height! <= maxAllowedHeight) {
        return Size(widget.width!, widget.height!);
      }
    }

    double width = maxAllowedWidth;
    double height = width / widget.aspectRatio;

    if (height > maxAllowedHeight) {
      height = maxAllowedHeight;
      width = height * widget.aspectRatio;
    }

    if (kDebugMode) {
      print('width: $width, height: $height');
    }
    return Size(width, height);
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linearToEaseOut,
    );

    _widthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleBook() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  // Helper method to ensure opacity is within valid range
  double _clampOpacity(double value) {
    return value.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final bookDimensions = _getBookDimensions(context);

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTap: _toggleBook,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final currentWidth = bookDimensions.width +
                    (widget.expandedWidth * _widthAnimation.value);

                return SizedBox(
                  width: currentWidth,
                  height: bookDimensions.height,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 背面页面
                      Positioned(
                        child: SizedBox(
                          width: currentWidth,
                          height: bookDimensions.height,
                          child: widget.pageChild,
                        ),
                      ),

                      // 封面
                      Positioned(
                        left: 0,
                        child: Transform(
                          alignment: Alignment.centerLeft,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(widget.maxOpenAngle *
                                _animation.value *
                                math.pi /
                                180),
                          child: Container(
                            width: bookDimensions.width,
                            height: bookDimensions.height,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(_clampOpacity(
                                      0.3 * (1 - _animation.value))),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: Offset(2 * (1 - _animation.value), 2),
                                ),
                                if (_animation.value > 0)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        _clampOpacity(0.2 * _animation.value)),
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                    offset: const Offset(-2, 0),
                                  ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: widget.coverChild,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<Color> initColors(int n) {
    List<Color> colors = [];
    for (int i = 0; i < n; i++) {
      colors.add(getRandomColor());
    }
    return colors;
  }

  Color getRandomColor() {
    math.Random random = math.Random();
    return Color.fromRGBO(
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
      1.0, // Opacity (1.0 is fully opaque)
    );
  }
}
