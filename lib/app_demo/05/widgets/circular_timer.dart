import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// 圆形计时器组件
class CircularTimer extends StatefulWidget {
  final Duration duration;
  final Duration targetDuration;
  final bool isRunning;
  final VoidCallback? onComplete;
  final ValueChanged<Duration>? onDurationChange;

  const CircularTimer({
    super.key,
    required this.duration,
    required this.targetDuration,
    this.isRunning = true,
    this.onComplete,
    this.onDurationChange,
  });

  @override
  State<CircularTimer> createState() => _CircularTimerState();
}

class _CircularTimerState extends State<CircularTimer>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Duration _currentDuration;
  late Timer _timer;
  
  // 添加呼吸动画控制器
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    // 初始化为倒计时，从目标时间开始递减
    _currentDuration = widget.targetDuration;

    // 设置动画控制器
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 计算进度值（倒计时，所以是剩余时间比例）
    double progress = 1.0 - (_currentDuration.inSeconds - widget.duration.inSeconds) / 
                            widget.targetDuration.inSeconds;
    progress = progress.clamp(0.0, 1.0);

    // 设置动画
    _animation = Tween<double>(
      begin: 0.0,
      end: progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // 初始化呼吸动画控制器
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // 重复执行并反转，形成呼吸效果
    
    _breathAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    // 如果计时器正在运行，启动定时器
    if (widget.isRunning) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(CircularTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果运行状态改变，更新计时器
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _startTimer();
      } else {
        _timer.cancel();
      }
    }

    // 如果持续时间改变，更新动画
    if (widget.duration != oldWidget.duration) {
      _currentDuration = widget.targetDuration - widget.duration;
      _updateAnimation();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // 倒计时，减少当前持续时间
        if (_currentDuration > Duration.zero) {
          _currentDuration -= const Duration(seconds: 1);
          _updateAnimation();
          
          // 调用持续时间变化回调
          if (widget.onDurationChange != null) {
            widget.onDurationChange!(widget.targetDuration - _currentDuration);
          }
        } else {
          _timer.cancel();
          if (widget.onComplete != null) {
            widget.onComplete!();
          }
        }
      });
    });
  }

  void _updateAnimation() {
    // 倒计时进度计算：剩余时间占总时间的比例
    double progress = 1.0 - _currentDuration.inSeconds / widget.targetDuration.inSeconds;
    progress = progress.clamp(0.0, 1.0);

    _animation = Tween<double>(
      begin: _animation.value,
      end: progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _breathController.dispose();
    if (widget.isRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 呼吸动画背景圆
              AnimatedBuilder(
                animation: _breathAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breathAnimation.value,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.grey.shade300,
                            Colors.grey.shade100.withOpacity(0.6),
                          ],
                          stops: const [0.7, 1.0],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),

              // 进度圆环
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(185, 185),
                    painter: CircularTimerPainter(
                      progress: _animation.value,
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  );
                },
              ),

              // 白色圆形背景（略微凸显）
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),

              // 时间文本和状态
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDuration(_currentDuration),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),

              // 当前进度标记
              AnimatedBuilder(
                animation: Listenable.merge([_animation, _breathAnimation]),
                builder: (context, child) {
                  // 使用组件的实际尺寸而非屏幕尺寸
                  // 圆形计时器的固定尺寸是240x240，中心点在120,120
                  const centerX = 120.0;
                  const centerY = 120.0;
                  const radius = 92.5; // 与CircularTimerPainter中的半径对应
                  
                  // 计算标记点角度位置
                  final angle = 2 * pi * _animation.value - (pi / 2);
                  
                  return Positioned(
                    left: centerX + radius * cos(angle) - 5, // 减去标记点宽度的一半以居中
                    top: centerY + radius * sin(angle) - 5,  // 减去标记点高度的一半以居中
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        // 使用与主圆环相同的颜色
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        // 添加阴影效果使标记更明显
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.6),
                            blurRadius: 4 * _breathAnimation.value, // 呼吸效果影响阴影
                            spreadRadius: 1 * _breathAnimation.value,
                          ),
                        ],
                        // 添加边框
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

/// 圆形计时器绘制器
class CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircularTimerPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - strokeWidth / 2;

    // 绘制进度圆环
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressRect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -pi / 2; // 从顶部开始
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(progressRect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
