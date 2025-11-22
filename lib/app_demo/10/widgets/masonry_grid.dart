import 'dart:ui';

import 'package:flutter/material.dart';

class MasonryGrid extends StatefulWidget {
  final List<Widget> children;
  final double spacing;
  final Duration staggerDuration;
  final Duration animationDuration;

  const MasonryGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.staggerDuration = const Duration(milliseconds: 50),
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<MasonryGrid> createState() => _MasonryGridState();
}

class _MasonryGridState extends State<MasonryGrid> {
  bool isAnimationReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Delay slightly to ensure layout is ready and create a nice entrance effect
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() => isAnimationReady = true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final leftColumn = <Widget>[];
    final rightColumn = <Widget>[];

    for (var i = 0; i < widget.children.length; i++) {
      final item = _MasonryGridItem(
        delay: Duration(
          milliseconds: i * widget.staggerDuration.inMilliseconds,
        ),
        duration: widget.animationDuration,
        isReadyToAnimation: isAnimationReady,
        child: widget.children[i],
      );

      if (i % 2 == 0) {
        leftColumn.add(item);
        leftColumn.add(SizedBox(height: widget.spacing));
      } else {
        rightColumn.add(item);
        rightColumn.add(SizedBox(height: widget.spacing));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Column(children: leftColumn)),
        SizedBox(width: widget.spacing),
        Expanded(child: Column(children: rightColumn)),
      ],
    );
  }
}

class _MasonryGridItem extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final bool isReadyToAnimation;

  const _MasonryGridItem({
    required this.child,
    required this.delay,
    required this.duration,
    required this.isReadyToAnimation,
  });

  @override
  State<_MasonryGridItem> createState() => _MasonryGridItemState();
}

class _MasonryGridItemState extends State<_MasonryGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _blurAnimation = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(_MasonryGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReadyToAnimation && !_hasAnimated) {
      _hasAnimated = true;
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If animation hasn't started, hide the widget
    if (!_hasAnimated && !widget.isReadyToAnimation) {
      return Opacity(opacity: 0, child: widget.child);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: _blurAnimation.value,
                sigmaY: _blurAnimation.value,
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
