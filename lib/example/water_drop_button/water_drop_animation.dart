import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/water_drop_button/bob_button_painter.dart';
import 'package:flutter_x_widgets/example/water_drop_button/sub_button.dart';

class WaterDropAnimation extends StatefulWidget {
  const WaterDropAnimation({super.key});

  @override
  State<WaterDropAnimation> createState() => _WaterDropAnimationState();
}

class _WaterDropAnimationState extends State<WaterDropAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isMenuOpen = false;

  // 存储子按钮的位置
  final List<Offset> _subButtonPositions = [];
  final GlobalKey _mainButtonKey = GlobalKey();
  final List<GlobalKey> _subButtonKeys =
      List.generate(4, (index) => GlobalKey());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 在动画更新时更新子按钮位置
    _animationController.addListener(_updateSubButtonPositions);
  }

  @override
  void dispose() {
    _animationController.removeListener(_updateSubButtonPositions);
    _animationController.dispose();
    super.dispose();
  }

  // 更新子按钮位置
  void _updateSubButtonPositions() {
    if (!_isMenuOpen) {
      _subButtonPositions.clear();
      return;
    }

    final mainButtonRenderBox =
        _mainButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (mainButtonRenderBox == null) return;

    final mainButtonPosition = mainButtonRenderBox.localToGlobal(Offset.zero);

    _subButtonPositions.clear();
    for (var key in _subButtonKeys) {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final center = Offset(
          position.dx + renderBox.size.width / 2,
          position.dy + renderBox.size.height / 2,
        );
        _subButtonPositions.add(center - mainButtonPosition);
      }
    }
    setState(() {});
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 子按钮
            _buildSubButton(icon: Icons.reply, angle: 0, index: 0),
            _buildSubButton(
                icon: Icons.folder_open, angle: math.pi / 2, index: 1),
            _buildSubButton(icon: Icons.delete, angle: math.pi, index: 2),
            _buildSubButton(
                icon: Icons.save_alt, angle: 3 * math.pi / 2, index: 3),

            // 中心按钮
            GestureDetector(
              key: _mainButtonKey,
              onTap: _toggleMenu,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: BlobButtonPainter(
                      animationValue: _animationController.value,
                      isMenuOpen: _isMenuOpen,
                      color: Colors.blue[400]!, // 使用更鲜艳的绿色
                      elasticity: 0.4, // 增加一点弹性
                      subButtonPositions: _subButtonPositions,
                      subButtonRadius: 25,
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: RotationTransition(
                              // 添加旋转动画
                              turns: animation,
                              child: child,
                            ),
                          );
                        },
                        child: _isMenuOpen
                            ? const Icon(Icons.close,
                                color: Colors.white,
                                key: ValueKey('close'),
                                size: 32)
                            : const Icon(Icons.add,
                                color: Colors.white,
                                key: ValueKey('add'),
                                size: 32),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubButton({
    required IconData icon,
    required double angle,
    required int index,
  }) {
    final animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.1 * index,
          0.6 + 0.1 * index,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    const double distance = 100; // 增加子按钮的距离

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // 确保动画值在0-1范围内
        final animationValue = animation.value.clamp(0.0, 1.0);
        final x = distance * math.cos(angle) * animationValue;
        final y = distance * math.sin(angle) * animationValue;

        return Transform.translate(
          offset: Offset(x, y),
          child: Transform.scale(
            scale: animationValue,
            child: Opacity(
              opacity: animationValue,
              child: Container(
                key: _subButtonKeys[index],
                child: SubButton(
                  icon: icon,
                  color: Colors.white,
                  size: 50,
                  onPressed: () {
                    _toggleMenu();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
