import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_swipe_arrow.dart';

/// A bounded, responsive title above the game menu.
///
/// The headline replays a staggered character entrance on every visit, driven by
/// the same [visits] counter the menu rows use.
class MenuHeader extends StatefulWidget {
  const MenuHeader({super.key, required this.pageProgress, this.onExit, this.reduceMotion = false, this.visits});

  final double pageProgress;
  final VoidCallback? onExit;
  final bool reduceMotion;

  /// Increments replay the staggered entrance from its first frame.
  final ValueListenable<int>? visits;

  static const _cream = Color(0xFFFFF1CF);

  @override
  State<MenuHeader> createState() => _MenuHeaderState();
}

class _MenuHeaderState extends State<MenuHeader> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: TitleEntrance.duration,
    animationBehavior: AnimationBehavior.preserve,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.visits?.addListener(_replay);
    _replay();
  }

  @override
  void didUpdateWidget(MenuHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visits != widget.visits) {
      oldWidget.visits?.removeListener(_replay);
      widget.visits?.addListener(_replay);
    }
  }

  /// A hidden ticker must not keep driving glyphs nobody can see.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _enter.isAnimating) _enter.stop();
  }

  void _replay() {
    if (!mounted) return;
    if (widget.reduceMotion) {
      _enter.value = 1;
      return;
    }
    _enter.forward(from: 0);
  }

  @override
  void dispose() {
    widget.visits?.removeListener(_replay);
    WidgetsBinding.instance.removeObserver(this);
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxHeight < 170;
      final back = IconButton(
        tooltip: '返回案例列表',
        onPressed: widget.onExit,
        color: MenuHeader._cream,
        disabledColor: MenuHeader._cream.withValues(alpha: .38),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
        icon: const Icon(Icons.arrow_back_rounded, size: 26),
      );
      final title = FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.bottomLeft,
        child: AnimatedBuilder(
          animation: _enter,
          builder: (context, _) => _StaggeredHeadline(
            text: compact ? 'Pick a Game' : 'Pick a\nGame',
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w700,
              color: MenuHeader._cream,
              fontSize: 140,
              height: .92,
              letterSpacing: -5,
            ),
            maxLines: compact ? 1 : 2,
            progress: _enter.value,
            reduceMotion: widget.reduceMotion,
          ),
        ),
      );
      if (compact) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              back,
              const SizedBox(width: 8),
              Expanded(child: title),
              const SizedBox(width: 12),
              MenuSwipeArrow(pageProgress: widget.pageProgress, width: 48, reduceMotion: widget.reduceMotion),
            ],
          ),
        );
      }
      final arrowWidth = (constraints.maxWidth * .2).clamp(64.0, 80.0);
      return Stack(
        children: [
          Positioned(top: 0, left: 12, child: back),
          Positioned(top: 54, left: 24, right: arrowWidth + 32, bottom: 12, child: title),
          Positioned(
            right: 20,
            bottom: 4,
            child: MenuSwipeArrow(pageProgress: widget.pageProgress, width: arrowWidth, reduceMotion: widget.reduceMotion),
          ),
        ],
      );
    },
  );
}

/// One shared timeline so the header and its tests agree on every duration.
///
/// Both title variants animate the same nine glyphs, so `step * 8 + perCharacter`
/// lands exactly on [duration] and the last letter arrives with the timeline.
abstract final class TitleEntrance {
  static const Duration duration = Duration(milliseconds: 720);
  static const Duration perCharacter = Duration(milliseconds: 320);
  static const Duration step = Duration(milliseconds: 50);

  /// Travel distance each glyph rises through, in logical pixels. Deliberately
  /// smaller than the 12px of breathing room the layout leaves under the title,
  /// so a descending glyph can never reach the menu rows below.
  static const double lift = 10;

  static const double _overshoot = .08;

  /// Local 0..1 progress of the character at [index] on the shared timeline.
  static double characterProgress(double progress, int index) {
    final elapsed = progress.clamp(0.0, 1.0) * duration.inMilliseconds;
    return ((elapsed - index * step.inMilliseconds) / perCharacter.inMilliseconds).clamp(0.0, 1.0);
  }

  /// How far the character at [index] still sits below its resting baseline.
  /// Rises on a smoothstep and overshoots by 8% before settling, the same shape
  /// `MenuMotion.enterOffset` gives the menu rows.
  static double offset(double progress, int index) {
    final local = characterProgress(progress, index);
    if (local <= 0) return lift;
    if (local >= 1) return 0;
    if (local <= .75) {
      final t = local / .75;
      return lift * (1 - t * t * (3 - 2 * t));
    }
    final t = (local - .75) / .25;
    final remaining = 1 - t;
    return -lift * _overshoot * (1 - remaining * remaining * remaining);
  }

  /// Glyph opacity ramps in over the first 30% of its own timeline, then holds,
  /// so a letter is readable for most of its rise instead of only at the top.
  static double opacity(double progress, int index) => (characterProgress(progress, index) / .3).clamp(0.0, 1.0);
}

/// Paints the headline glyph by glyph while it enters.
///
/// A transparent [Text] twin underneath owns layout, text scaling, wrapping and
/// the accessibility label, so this widget only decides how each glyph looks on
/// the current frame. Once the timeline settles the paragraph is painted in one
/// pass, so the resting render is identical to a plain [Text].
class _StaggeredHeadline extends StatefulWidget {
  const _StaggeredHeadline({
    required this.text,
    required this.style,
    required this.maxLines,
    required this.progress,
    required this.reduceMotion,
  });

  final String text;
  final TextStyle style;
  final int maxLines;
  final double progress;
  final bool reduceMotion;

  @override
  State<_StaggeredHeadline> createState() => _StaggeredHeadlineState();
}

class _StaggeredHeadlineState extends State<_StaggeredHeadline> {
  _HeadlineShaping? _shaping;

  @override
  void dispose() {
    _shaping?.dispose();
    _shaping = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    return CustomPaint(
      painter: _HeadlinePainter(
        shaping: _shaping ??= _HeadlineShaping.of(
          text: widget.text,
          style: style,
          maxLines: widget.maxLines,
          scaler: MediaQuery.textScalerOf(context),
          direction: Directionality.of(context),
        ),
        style: style,
        settled: widget.reduceMotion || widget.progress >= 1,
        progress: widget.progress,
      ),
      child: Text(
        widget.text,
        semanticsLabel: 'Pick a Game',
        maxLines: widget.maxLines,
        style: style.copyWith(color: style.color?.withValues(alpha: 0)),
      ),
    );
  }
}

/// Shaping results for one headline, resolved once and reused for every frame.
///
/// Caret origins and glyph widths depend only on the text, style and text
/// scale, so they are measured once instead of being reshaped on each of the
/// ~43 frames a single entrance takes.
class _HeadlineShaping {
  _HeadlineShaping._({
    required this.text,
    required this.style,
    required this.maxLines,
    required this.scaler,
    required this.direction,
    required this.ranks,
    required this.origins,
    required this.widths,
  });

  final String text;
  final TextStyle style;
  final int maxLines;
  final TextScaler scaler;
  final TextDirection direction;

  /// Character indices that animate; whitespace and `\n` never stagger.
  final List<int> ranks;
  final List<Offset> origins;
  final List<double> widths;

  bool get isEmpty => ranks.isEmpty;

  factory _HeadlineShaping.of({
    required String text,
    required TextStyle style,
    required int maxLines,
    required TextScaler scaler,
    required TextDirection direction,
  }) {
    final ranks = <int>[];
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == ' ' || char == '\n') continue;
      ranks.add(i);
    }
    final layout = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: maxLines,
    )..layout();
    final origins = <Offset>[];
    final widths = <double>[];
    try {
      for (final index in ranks) {
        final origin = layout.getOffsetForCaret(TextPosition(offset: index), Rect.zero);
        final next = layout.getOffsetForCaret(TextPosition(offset: index + 1), Rect.zero);
        origins.add(origin);
        widths.add((next.dx - origin.dx).abs());
      }
    } finally {
      layout.dispose();
    }
    return _HeadlineShaping._(
      text: text,
      style: style,
      maxLines: maxLines,
      scaler: scaler,
      direction: direction,
      ranks: ranks,
      origins: origins,
      widths: widths,
    );
  }

  /// Paints the character at sequence position [i] tinted to [color].
  void paintGlyph(Canvas canvas, int i, Color? color) {
    final painter = TextPainter(
      text: TextSpan(text: text[ranks[i]], style: style.copyWith(color: color)),
      textDirection: direction,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    try {
      painter.paint(canvas, Offset.zero);
    } finally {
      painter.dispose();
    }
  }

  /// Paints the whole headline in a single pass for the resting frame.
  void paintParagraph(Canvas canvas, double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);
    try {
      painter.paint(canvas, Offset.zero);
    } finally {
      painter.dispose();
    }
  }

  void dispose() {}
}

class _HeadlinePainter extends CustomPainter {
  _HeadlinePainter({
    required this.shaping,
    required this.style,
    required this.settled,
    required this.progress,
  });

  final _HeadlineShaping shaping;
  final TextStyle style;
  final bool settled;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (settled || shaping.isEmpty) {
      shaping.paintParagraph(canvas, size.width.isFinite ? size.width : double.infinity);
      return;
    }
    final base = style.color ?? const Color(0xFFFFFFFF);
    for (var i = 0; i < shaping.ranks.length; i++) {
      final origin = shaping.origins[i];
      canvas.save();
      canvas.translate(origin.dx, origin.dy + TitleEntrance.offset(progress, i));
      shaping.paintGlyph(canvas, i, base.withValues(alpha: TitleEntrance.opacity(progress, i)));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_HeadlinePainter old) => old.settled != settled || old.progress != progress || old.style != style;
}

