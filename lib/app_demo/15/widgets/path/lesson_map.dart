import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_x_widgets/app_demo/15/data/asset_manifest.dart';
import 'package:flutter_x_widgets/app_demo/15/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/lesson_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_icon.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/motion/pip_motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/design_tokens.dart';

enum LessonNodeVisual { completed, locked, current }

class LessonMap extends StatelessWidget {
  final Map<String, bool> completedLessons;
  final String? currentLessonId;
  final Set<String> resumableNodeIds;
  final bool allDone;
  final void Function(String nodeId, LessonNodeVisual visual) onNodeTap;

  const LessonMap({
    super.key,
    required this.completedLessons,
    required this.currentLessonId,
    required this.resumableNodeIds,
    required this.allDone,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    final donePath =
        completedLessons['challenge'] == true
            ? App15Design.afterChallengeTrailPath
            : completedLessons['directions'] == true
            ? App15Design.afterDirectionsTrailPath
            : App15Design.afterCoffeeTrailPath;

    final currentToken = currentLessonId == null ? null : App15Design.mapNodes[currentLessonId];

    return Semantics(
      container: true,
      label: '学习关卡路线',
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: App15Design.mapDesignWidth,
            height: App15Design.mapDesignHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: SvgPicture.string(_trailSvg(App15Design.baseTrailPath, App15Theme.trailBase), fit: BoxFit.fill),
                  ),
                ),
                Positioned.fill(child: IgnorePointer(child: SvgPicture.string(_trailSvg(donePath, App15Theme.mint), fit: BoxFit.fill))),
                if (currentToken != null)
                  Positioned(
                    left: currentToken.left - 11,
                    top: currentToken.top - 11,
                    width: App15Design.currentNodeWidth + 22,
                    height: App15Design.currentNodeHeight + 22,
                    child: const IgnorePointer(child: CustomPaint(painter: _DashedOvalPainter(color: App15Theme.yellowDark))),
                  ),
                ..._nodeWidgets('greeting'),
                ..._nodeWidgets('menu'),
                ..._nodeWidgets('coffee'),
                _bird(allDone),
                ..._nodeWidgets('directions'),
                ..._nodeWidgets('challenge'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _nodeWidgets(String nodeId) {
    final token = App15Design.mapNodes[nodeId];
    if (token == null) return const [];
    final visual = _visualFor(nodeId);
    final current = visual == LessonNodeVisual.current;
    final width = current ? App15Design.currentNodeWidth : App15Design.nodeWidth;
    final height = current ? App15Design.currentNodeHeight : App15Design.nodeHeight;
    final resumable = current && resumableNodeIds.contains(nodeId);

    return [
      Positioned(
        left: token.left,
        top: token.top,
        width: width,
        height: height,
        child: _MapNode(
          key: ValueKey('path-node-$nodeId'),
          label: token.label,
          visual: visual,
          resumable: resumable,
          width: width,
          height: height,
          onTap: () => onNodeTap(nodeId, visual),
        ),
      ),
      Positioned(
        left: token.labelLeft,
        top: token.labelTop,
        child: IgnorePointer(
          child: Text(
            token.label,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontFamily: App15Theme.fontFamily,
              fontFamilyFallback: App15Theme.fontFamilyFallback,
              fontSize: 14,
              fontWeight: current ? FontWeight.w900 : FontWeight.w800,
              height: 1,
              color: current ? App15Theme.ink : App15Theme.mutedLabel,
            ),
          ),
        ),
      ),
    ];
  }

  LessonNodeVisual _visualFor(String nodeId) {
    if (PipSeed.reviewOnlyNodeIds.contains(nodeId)) return LessonNodeVisual.completed;
    if (!LessonRules.isUnlocked(nodeId, completedLessons)) return LessonNodeVisual.locked;
    if (completedLessons[nodeId] == true) return LessonNodeVisual.completed;
    if (currentLessonId == nodeId) return LessonNodeVisual.current;
    return LessonNodeVisual.completed;
  }

  Widget _bird(bool celebrate) {
    return Positioned(
      left: App15Design.bird.left,
      top: App15Design.bird.top,
      width: App15Design.bird.width,
      height: App15Design.bird.height,
      child: Semantics(
        image: true,
        label: celebrate ? 'Pip 为你庆祝' : 'Pip 在路线旁等你',
        child: ExcludeSemantics(
          child: Transform.rotate(
            angle: App15Design.bird.rotationDegrees * math.pi / 180,
            child: SvgPicture.asset(
              celebrate ? PipAssets.birdCelebrate : PipAssets.birdWave,
              width: App15Design.bird.width,
              height: App15Design.bird.height,
            ),
          ),
        ),
      ),
    );
  }

  String _trailSvg(String path, Color color) {
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 350 425" preserveAspectRatio="none">'
        '<path d="$path" fill="none" stroke="${_hex(color)}" stroke-width="14" stroke-linecap="round"/>'
        '</svg>';
  }

  static String _hex(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0')}';
  }
}

class _MapNode extends StatefulWidget {
  final String label;
  final LessonNodeVisual visual;
  final bool resumable;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _MapNode({
    super.key,
    required this.label,
    required this.visual,
    required this.resumable,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  State<_MapNode> createState() => _MapNodeState();
}

class _MapNodeState extends State<_MapNode> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final motion = PipMotionSpec.of(context);
    final (background, border, shadow, icon) = switch (widget.visual) {
      LessonNodeVisual.completed => (App15Theme.mint, App15Theme.mintDark, App15Theme.mintDark, PipAssets.icon('check')),
      LessonNodeVisual.locked => (App15Theme.lockedSurface, App15Theme.lockedBorder, App15Theme.lockedBorder, PipAssets.icon('lock')),
      LessonNodeVisual.current => (App15Theme.yellow, App15Theme.ink, App15Theme.ink, PipAssets.icon('play')),
    };
    final iconColor = switch (widget.visual) {
      LessonNodeVisual.locked => App15Theme.lockedIcon,
      _ => App15Theme.ink,
    };
    final aria = switch (widget.visual) {
      LessonNodeVisual.completed => '已完成：${widget.label}，复习',
      LessonNodeVisual.locked => '未解锁：${widget.label}',
      LessonNodeVisual.current => '${widget.resumable ? '继续' : '开始'}：${widget.label}',
    };

    return Semantics(
      container: true,
      button: true,
      label: aria,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: motion.buttonPress,
            transform: Matrix4.translationValues(0, _pressed ? 5 : 0, 0),
            decoration: BoxDecoration(
              color: background,
              border: Border.all(color: border, width: App15Design.nodeBorderWidth),
              borderRadius: BorderRadius.all(Radius.elliptical(widget.width / 2, widget.height / 2)),
              boxShadow: [BoxShadow(color: shadow, offset: Offset(0, _pressed ? 2 : 6))],
            ),
            child: Center(child: PipIcon(asset: icon, size: 29, color: iconColor)),
          ),
        ),
      ),
    );
  }
}

class _DashedOvalPainter extends CustomPainter {
  final Color color;

  const _DashedOvalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    final path = Path()..addOval(Rect.fromLTWH(1, 1, size.width - 2, size.height - 2));

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + 5 < metric.length ? distance + 5 : metric.length;
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + 5;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedOvalPainter oldDelegate) => oldDelegate.color != color;
}
