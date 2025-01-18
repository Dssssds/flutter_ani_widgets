import 'dart:ui';

import 'package:flutter/material.dart';

class BlurFadeDemo extends StatefulWidget {
  const BlurFadeDemo({super.key});

  @override
  State<BlurFadeDemo> createState() => BlurFadeDemoState();
}

class BlurFadeDemoState extends State<BlurFadeDemo> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlurFadeContent(
                      isVisble: isVisible,
                      child: titleText('你好, 我的哥!'),
                    ),
                    padding(),
                    BlurFadeContent(
                      delay: const Duration(milliseconds: 100),
                      isVisble: isVisible,
                      child: normalText('今天.................'),
                    ),
                    padding(),
                    BlurFadeContent(
                      delay: const Duration(milliseconds: 200),
                      isVisble: isVisible,
                      child: normalText('明天.................'),
                    ),
                    padding(),
                    BlurFadeContent(
                      delay: const Duration(milliseconds: 300),
                      isVisble: isVisible,
                      child: normalText('昨天.................'),
                    ),
                    padding(),
                    BlurFadeContent(
                      delay: const Duration(milliseconds: 400),
                      isVisble: isVisible,
                      child: normalText('所以.................'),
                    ),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: () => setState(() => isVisible = !isVisible),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(150, 50),
                      ),
                      child: Text(
                        isVisible ? 'Hide' : 'Show',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ))));
  }

  Padding padding() => const Padding(padding: EdgeInsets.all(5));

  Text titleText(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold));
  }

  Text normalText(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }
}

class BlurFadeContent extends StatefulWidget {
  // 子组件,用于显示实际内容
  final Widget child;
  // 动画延迟开始的时间
  final Duration delay;
  // 动画持续时间
  final Duration duration;
  // 控制组件是否可见的状态
  final bool? isVisble;

  const BlurFadeContent({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.isVisble,
  });

  @override
  BlurFadeContentState createState() => BlurFadeContentState();
}

class BlurFadeContentState extends State<BlurFadeContent>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> opacityAnimation;
  late Animation<double> blurAnimation;

  bool isFirstBuild = false;

  @override
  void initState() {
    super.initState();

    // 创建一个动画控制器,持续时间由widget.duration指定,需要vsync来驱动动画
    controller = AnimationController(duration: widget.duration, vsync: this);

    // 优化不透明度动画曲线
    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        // 使用 easeInOut 使动画更平滑
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // 优化模糊动画效果
    blurAnimation = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        // 调整模糊动画区间，使其与透明度动画更好地重叠
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    hanldeVisibilityChange();
  }

  void hanldeVisibilityChange() {
    // 使用帧回调确保在布局完成后执行动画
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 等待延迟时间
      await Future.delayed(widget.delay);

      // 检查组件是否还在widget树中
      if (!mounted) return;

      // 根据可见性状态执行相应动画
      if (widget.isVisble ?? isFirstBuild) {
        controller.forward();
      } else {
        controller.reverse();
      }

      // 标记首次构建完成
      isFirstBuild = false;
    });
  }

  @override
  void didUpdateWidget(BlurFadeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisble != oldWidget.isVisble) {
      hanldeVisibilityChange();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Opacity(
              opacity: opacityAnimation.value,
              child: Transform.scale(
                scale: 0.95 + (opacityAnimation.value * 0.05),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: blurAnimation.value,
                      sigmaY: blurAnimation.value,
                    ),
                    child: widget.child,
                  ),
                ),
              ));
        });
  }
}
