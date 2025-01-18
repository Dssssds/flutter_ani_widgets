import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class HyperText extends StatefulWidget {
  const HyperText({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 800),
    this.style,
    this.animationTrigger = false,
    this.animateOnLoad = true,
  });

  final bool animateOnLoad; // 是否在加载时自动播放动画
  final bool animationTrigger; // 动画触发器
  final Duration duration; // 动画持续时间
  final TextStyle? style; // 文本样式
  final String text; // 显示的文本内容

  @override
  HyperTextState createState() => HyperTextState();
}

class HyperTextState extends State<HyperText> {
  int _animationCount = 0; // 动画计数器
  late List<String> _displayText; // 显示的文本列表
  bool _isFirstRender = true; // 是否是首次渲染
  double _iterations = 0; // 迭代次数

  final Random _random = Random();
  Timer? _timer;

  @override
  void didUpdateWidget(HyperText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当动画触发器状态改变且为true时，开始动画
    if (widget.animationTrigger != oldWidget.animationTrigger &&
        widget.animationTrigger) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _displayText = widget.text.split('');
    if (widget.animateOnLoad) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _iterations = 0;
    _timer?.cancel();
    _animationCount++;
    final currentAnimationCount = _animationCount;

    _timer = Timer.periodic(
      widget.duration ~/
          (widget.text.isNotEmpty ? widget.text.length * 10 : 10),
      (timer) {
        if (!widget.animateOnLoad && _isFirstRender) {
          timer.cancel();
          _isFirstRender = false;
          return;
        }
        if (_iterations < widget.text.length &&
            currentAnimationCount == _animationCount) {
          setState(() {
            _displayText = List.generate(
              widget.text.length,
              (i) => widget.text[i] == ' '
                  ? ' '
                  : i <= _iterations
                      ? widget.text[i]
                      : String.fromCharCode(_random.nextInt(26) + 65),
            );
          });
          _iterations += 0.1;
        } else {
          timer.cancel();
          if (currentAnimationCount == _animationCount) {
            setState(() {
              _displayText = widget.text.split('');
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_displayText.length, (index) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 50),
            child: Text(
              _displayText[index],
              key: ValueKey<String>('$_animationCount-$index'),
              style: widget.style ?? Theme.of(context).textTheme.titleLarge,
            ),
          );
        }),
      ),
    );
  }
}
