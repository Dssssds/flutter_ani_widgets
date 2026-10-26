import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/rules/diary_rules.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/journal/selection_border_painter.dart';

class DraggableStamp extends StatefulWidget {
  const DraggableStamp({
    super.key,
    required this.position,
    required this.paperSize,
    required this.itemSize,
    required this.onFirstMove,
    required this.onMoved,
    required this.child,
    this.onPress,
    this.selected = false,
    this.rotation = 0,
  });

  /// Normalized origin (0..1) of the unrotated item inside the paper.
  final Offset position;
  final Size paperSize;
  final Size itemSize;
  final VoidCallback onFirstMove;
  final void Function(double x, double y) onMoved;
  final VoidCallback? onPress;
  final bool selected;
  final double rotation;
  final Widget child;

  @override
  State<DraggableStamp> createState() => _DraggableStampState();
}

class _DraggableStampState extends State<DraggableStamp> {
  Offset _origin = Offset.zero;
  Offset _delta = Offset.zero;
  bool _snapshotted = false;

  void _handleStart() {
    _origin = widget.position;
    _delta = Offset.zero;
    _snapshotted = false;
    widget.onPress?.call();
  }

  void _handleUpdate(DragUpdateDetails details) {
    _delta += details.delta;
    if (!_snapshotted && _delta.distance > 2) {
      _snapshotted = true;
      widget.onFirstMove();
    }
    if (!_snapshotted) {
      return;
    }
    final x = DiaryRules.clampPosition(
      origin: _origin.dx,
      deltaPx: _delta.dx,
      paperExtent: widget.paperSize.width,
      itemExtent: widget.itemSize.width,
    );
    final y = DiaryRules.clampPosition(
      origin: _origin.dy,
      deltaPx: _delta.dy,
      paperExtent: widget.paperSize.height,
      itemExtent: widget.itemSize.height,
    );
    widget.onMoved(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: widget.onPress == null ? null : (_) => widget.onPress!(),
      onPanStart: (_) => _handleStart(),
      onPanUpdate: _handleUpdate,
      onPanEnd: (_) => _delta = Offset.zero,
      onPanCancel: () => _delta = Offset.zero,
      child: Transform.rotate(
        angle: widget.rotation * 3.141592653589793 / 180,
        child: CustomPaint(
          foregroundPainter:
              widget.selected ? const SelectionBorderPainter() : null,
          child: widget.child,
        ),
      ),
    );
  }
}
