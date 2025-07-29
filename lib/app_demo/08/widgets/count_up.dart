import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 数字递增动画组件
/// 支持数值变化的从上到下过渡动画和复杂的计数动画
class CountUpText extends StatefulWidget {
  /// 表情符号
  final String emoji;
  /// 数值
  final double value;
  /// 标签文本
  final String label;
  /// 是否播放复杂的计数动画
  final bool shouldAnimate;

  const CountUpText({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    this.shouldAnimate = false,
  });

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

/// CountUpText的状态管理类
/// 负责管理数值变化的过渡动画
class _CountUpTextState extends State<CountUpText> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.emoji,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          height: 23,
          child: widget.shouldAnimate
              ? _buildComplexAnimation()
              : _buildSimpleAnimation(),
        ),
        const SizedBox(width: 4),
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// 构建复杂的计数动画（原有逻辑）
  /// 当shouldAnimate为true时使用
  Widget _buildComplexAnimation() {
    return Animate(
      onPlay: (controller) {
        controller.reset();
        controller.forward(from: 0);
      },
    )
        .custom(
          delay: .35.seconds,
          curve: Curves.easeInToLinear,
          duration: 1.2.seconds,
          begin: 0,
          end: widget.value,
          builder: (_, value, __) => Text(
            softWrap: true,
            "${value.round()}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        )
        .fadeIn()
        .slideY(begin: -.5)
        .swap(
          builder: (context, widget) => Text(
            softWrap: true,
            "${this.widget.value.round()}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
  }

  /// 构建简单的从上到下过渡动画
  /// 当shouldAnimate为false时使用，为数值变化添加平滑过渡
  Widget _buildSimpleAnimation() {
    return AnimatedSwitcher(
      /// 过渡动画持续时间
      duration: const Duration(milliseconds: 400),
      /// 自定义过渡动画：从上到下的滑动效果
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          /// 位置动画：从上方(-0.3)滑动到正常位置(0.0)
          position: Tween<Offset>(
            begin: const Offset(0.0, -0.3), // 起始位置：上方
            end: Offset.zero, // 结束位置：正常位置
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut, // 缓入缓出曲线
          )),
          child: FadeTransition(
            /// 同时添加淡入效果，让过渡更自然
            opacity: animation,
            child: child,
          ),
        );
      },
      /// 切换动画：旧组件向下滑出
      switchOutCurve: Curves.easeInOut,
      /// 切换动画：新组件从上滑入  
      switchInCurve: Curves.easeInOut,
      child: Text(
        "${widget.value.round()}",
        /// 关键：为每个不同的值设置唯一的key
        /// 这样AnimatedSwitcher才能识别内容变化并播放动画
        key: ValueKey<int>(widget.value.round()),
        softWrap: true,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
