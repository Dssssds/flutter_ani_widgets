import 'dart:math' show pow, sqrt;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

class DotPattern extends StatefulWidget {
  /// 创建一个交互式点阵图案
  ///
  /// 该图案会用响应式的动画点阵填充其容器
  const DotPattern({super.key});

  @override
  State<DotPattern> createState() => _DotPatternState();
}

class _DotPatternState extends State<DotPattern>
    with SingleTickerProviderStateMixin {
  // 动画配置
  late final AnimationController _animationController;
  static const Duration _animationDuration = Duration(milliseconds: 300);

  // 触摸追踪
  Offset? _targetTouchLocation;
  Offset? _currentTouchLocation;
  DateTime _lastFeedbackTime = DateTime.now();

  // 网格配置
  static const int _columns = 15;
  static const int _rows = 30;
  static const double _dotSize = 6;
  static const double _maxEffectRadius = 100;

  // 物理效果配置
  static const double _dragAnimationSpeed = 0.6; // 控制点跟随触摸的速度
  static const double _springStiffness = 0.85; // 控制弹簧效果的强度

  @override
  void initState() {
    super.initState();
    _setupAnimationController();
  }

  /// 设置带有弹簧物理效果的动画控制器
  void _setupAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..addListener(_updateTouchLocation);
  }

  /// 使用弹簧物理效果更新触摸位置
  void _updateTouchLocation() {
    if (_targetTouchLocation == null || _currentTouchLocation == null) return;

    setState(() {
      final double progress = _animationController.value;
      // 使用二次缓动应用弹簧物理效果
      final springProgress = -pow(progress - 1, 2) * _springStiffness + 1;

      _currentTouchLocation = Offset.lerp(
        _currentTouchLocation,
        _targetTouchLocation,
        springProgress * _dragAnimationSpeed,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleTouch,
      onPanUpdate: _handleTouch,
      onPanEnd: (_) => _clearTouch(),
      child: Container(
        color: Colors.black,
        child: CustomPaint(
          painter: _DotsPainter(
            columns: _columns,
            rows: _rows,
            dotSize: _dotSize,
            touchLocation: _currentTouchLocation,
            maxEffectRadius: _maxEffectRadius,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  /// 处理触摸输入并触发触觉反馈
  void _handleTouch(dynamic details) {
    setState(() {
      _targetTouchLocation = details.localPosition;

      // 如果是首次触摸，初始化触摸位置
      if (_currentTouchLocation == null) {
        _currentTouchLocation = _targetTouchLocation;
        _animationController.value = 0;
      }

      // 对于拖动更新，从当前动画进度继续
      final startValue =
          details is DragUpdateDetails ? _animationController.value : 0.0;

      _animationController.forward(from: startValue);
    });

    _triggerHapticFeedback();
  }

  /// 提供带有频率限制的触觉反馈
  void _triggerHapticFeedback() {
    final now = DateTime.now();
    if (now.difference(_lastFeedbackTime).inMilliseconds > 100) {
      HapticFeedback.lightImpact();
      _lastFeedbackTime = now;
    }
  }

  /// 当交互结束时清除触摸状态
  void _clearTouch() {
    setState(() {
      _targetTouchLocation = null;
      _currentTouchLocation = null;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

/// 自定义绘制器，用于渲染带有交互效果的点阵网格
class _DotsPainter extends CustomPainter {
  final int columns;
  final int rows;
  final double dotSize;
  final Offset? touchLocation;
  final double maxEffectRadius;

  // 物理效果配置
  static const double _dentStrength = 20.0; // 控制触摸效果的深度

  const _DotsPainter({
    required this.columns,
    required this.rows,
    required this.dotSize,
    required this.touchLocation,
    required this.maxEffectRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cellWidth = size.width / (columns - 1);
    final cellHeight = size.height / (rows - 1);

    _drawDotGrid(canvas, paint, size, cellWidth, cellHeight);
  }

  /// 绘制交互式点阵网格
  void _drawDotGrid(Canvas canvas, Paint paint, Size size, double cellWidth,
      double cellHeight) {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final position = _calculateDotPosition(col, row, cellWidth, cellHeight);
        final adjustedPosition = _applyTouchEffect(position);

        canvas.drawCircle(
            adjustedPosition.center, adjustedPosition.size / 2, paint);
      }
    }
  }

  /// 计算点的基础位置
  Offset _calculateDotPosition(
      int col, int row, double cellWidth, double cellHeight) {
    return Offset(col * cellWidth, row * cellHeight);
  }

  /// 对点应用基于触摸的位移和缩放效果
  ({Offset center, double size}) _applyTouchEffect(Offset originalCenter) {
    double scale = 1.0;
    Offset displacement = Offset.zero;

    if (touchLocation != null) {
      final toTouch = touchLocation! - originalCenter;
      final distance = toTouch.distance;

      if (distance < maxEffectRadius) {
        final normalizedDistance = distance / maxEffectRadius;

        // 使用平滑衰减计算缩放
        scale = 0.3 + (pow(normalizedDistance, 1.5) * 0.7);

        // 使用钟形曲线计算位移，实现平滑过渡
        final displacementStrength = _dentStrength *
            (1 - normalizedDistance) *
            (1 - pow(normalizedDistance, 2));

        displacement = toTouch.normalize() * displacementStrength;
      }
    }

    return (
      center: originalCenter + displacement,
      size: dotSize * scale,
    );
  }

  @override
  bool shouldRepaint(_DotsPainter oldDelegate) {
    return touchLocation != oldDelegate.touchLocation;
  }
}

/// 向量标准化扩展
extension VectorNormalization on Offset {
  /// 返回偏移量（向量）的标准化版本（长度为1的向量）
  Offset normalize() {
    final length = sqrt(dx * dx + dy * dy);
    return Offset(dx / length, dy / length);
  }
}
