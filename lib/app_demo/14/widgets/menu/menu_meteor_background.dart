import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A decorative, bounded header background. Route visibility and app-specific
/// reduced motion are supplied by the parent through [enabled].
class MenuMeteorBackground extends StatefulWidget {
  const MenuMeteorBackground({
    super.key,
    this.enabled = true,
    this.interval = const Duration(seconds: 2),
    this.duration = const Duration(milliseconds: 1000),
  }) : assert(interval > Duration.zero),
       assert(duration > Duration.zero);

  final bool enabled;

  /// Quiet time before the first meteor and after each completed meteor.
  final Duration interval;
  final Duration duration;

  @override
  State<MenuMeteorBackground> createState() => _MenuMeteorBackgroundState();
}

class _MenuMeteorBackgroundState extends State<MenuMeteorBackground> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  Timer? _timer;
  AppLifecycleState? _lifecycle;
  bool _disableAnimations = false;
  bool _tickerEnabled = false;
  bool _allowed = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = WidgetsBinding.instance.lifecycleState;
    _controller = AnimationController(vsync: this, duration: widget.duration)..addStatusListener(_onStatus);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    _tickerEnabled = TickerMode.valuesOf(context).enabled;
    _synchronize();
  }

  @override
  void didUpdateWidget(covariant MenuMeteorBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    _synchronize();
    if (_allowed && (oldWidget.interval != widget.interval || oldWidget.duration != widget.duration)) {
      _stop();
      _schedule();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    _synchronize();
  }

  void _synchronize() {
    final allowed =
        widget.enabled && !_disableAnimations && _tickerEnabled && (_lifecycle ?? AppLifecycleState.resumed) == AppLifecycleState.resumed;
    if (_allowed == allowed) return;
    _allowed = allowed;
    if (allowed) {
      _schedule();
    } else {
      _stop();
    }
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _controller.stop();
    _controller.reset();
  }

  void _schedule() {
    if (!_allowed || _timer != null) return;
    _timer = Timer(widget.interval, () {
      _timer = null;
      if (_allowed) _controller.forward(from: 0);
    });
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _schedule();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: RepaintBoundary(
        child: ClipRect(child: SizedBox.expand(child: CustomPaint(painter: MenuMeteorPainter(animation: _controller.view)))),
      ),
    ),
  );
}

/// Paint-only animation; public to allow deterministic fixed-phase rendering.
/// All positions are normalized to the header constraints, without randomness.
class MenuMeteorPainter extends CustomPainter {
  MenuMeteorPainter({required this.animation}) : super(repaint: animation);

  final Animation<double> animation;

  static const _lavender = Color(0xFFD9C3F3);
  static const _cream = Color(0xFFFFF1CF);
  static const _stars = <Offset>[
    Offset(.09, .18),
    Offset(.26, .43),
    Offset(.39, .12),
    Offset(.57, .31),
    Offset(.72, .13),
    Offset(.85, .57),
    Offset(.95, .28),
    Offset(.04, .54),
    Offset(.12, .76),
    Offset(.18, .09),
    Offset(.21, .61),
    Offset(.29, .85),
    Offset(.33, .24),
    Offset(.36, .67),
    Offset(.43, .48),
    Offset(.47, .91),
    Offset(.51, .07),
    Offset(.54, .71),
    Offset(.62, .18),
    Offset(.65, .53),
    Offset(.68, .85),
    Offset(.74, .39),
    Offset(.78, .69),
    Offset(.82, .06),
    Offset(.88, .34),
    Offset(.91, .81),
    Offset(.97, .65),
    Offset(.08, .93),
  ];
  static const _start = Offset(.96, -.08);
  static const _end = Offset(.12, .88);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || !size.width.isFinite || !size.height.isFinite) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final starPaint = Paint()..color = _cream.withValues(alpha: .12);
    for (final star in _stars) {
      canvas.drawCircle(Offset(star.dx * size.width, star.dy * size.height), .8, starPaint);
    }
    final phase = animation.value.clamp(0.0, 1.0);
    if (phase > 0 && phase < 1) {
      final position = Offset.lerp(_start, _end, phase)!;
      final head = Offset(position.dx * size.width, position.dy * size.height);
      final tail = head + Offset((_start.dx - _end.dx) * size.width * .19, (_start.dy - _end.dy) * size.height * .19);
      final opacity = math.sin(math.pi * phase) * .32;
      final meteorPaint =
          Paint()
            ..strokeWidth = 1.2
            ..strokeCap = StrokeCap.round
            ..shader = LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [_lavender.withValues(alpha: 0), _lavender.withValues(alpha: opacity * .55), _cream.withValues(alpha: opacity)],
              stops: const [0, .65, 1],
            ).createShader(Rect.fromPoints(tail, head));
      canvas.drawLine(tail, head, meteorPaint);
      canvas.drawCircle(head, 1, Paint()..color = _cream.withValues(alpha: opacity * .5));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MenuMeteorPainter oldDelegate) => oldDelegate.animation != animation;
}
