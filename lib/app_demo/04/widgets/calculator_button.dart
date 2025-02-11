import 'package:flutter/material.dart';

class CalculatorButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color buttonColor;
  final Color textColor;
  final String? fontFamily;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.buttonColor,
    required this.textColor,
    this.fontFamily = 'SF Pro Display',
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  // 动画控制器
  late final AnimationController _animationController;
  // 缩放动画
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // 创建缩放动画
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.75,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // 监听动画状态，完成后自动重置
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 处理按钮点击
  void _handleTap() {
    _animationController.forward();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: widget.buttonColor,
              foregroundColor: widget.textColor,
              padding: const EdgeInsets.all(20.0),
              textStyle: TextStyle(
                fontSize: 60.0,
                fontWeight: FontWeight.bold,
                fontFamily: widget.fontFamily,
                fontStyle: FontStyle.normal,
              ),
              shape: const RoundedRectangleBorder(),
              splashFactory: NoSplash.splashFactory,
              overlayColor: const Color.fromARGB(0, 68, 63, 63),
            ),
            onPressed: _handleTap,
            child: Text(widget.text),
          ),
        ),
      ),
    );
  }
}
