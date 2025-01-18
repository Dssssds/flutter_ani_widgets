import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/text_hyper/hyper_text.dart';

class HyperTextDemo extends StatefulWidget {
  const HyperTextDemo({super.key});

  @override
  HyperTextDemoState createState() => HyperTextDemoState();
}

class HyperTextDemoState extends State<HyperTextDemo> {
  Timer? _animationResetTimer;
  bool _isAnimationTriggered = false;

  @override
  void dispose() {
    _animationResetTimer?.cancel();
    super.dispose();
  }

  void _triggerAnimation() {
    setState(() {
      _isAnimationTriggered = true;
    });

    // 取消已存在的定时器
    _animationResetTimer?.cancel();

    // 设置新的定时器，300毫秒后重置触发器
    _animationResetTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _isAnimationTriggered = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: HyperText(
                          text: "Hello World",
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                          animationTrigger: _isAnimationTriggered,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _triggerAnimation,
                      child: const Text("触发动画"),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
