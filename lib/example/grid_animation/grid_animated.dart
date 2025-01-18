import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AnimatedGrid extends StatefulWidget {
  // 存储子组件列表
  final List<Widget> children;
  // 定义网格布局的列数
  final int crossAxisCount;
  // 定义网格项之间的间距
  final double spaceing;
  // 定义每个网格项动画的延迟时间
  final Duration staggerDuration;
  // 定义每个网格项动画的持续时间
  final Duration animationDuration;

  const AnimatedGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.spaceing = 16,
    this.staggerDuration = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  AnimatedGridState createState() => AnimatedGridState();
}

class AnimatedGridState extends State<AnimatedGrid> {
  bool isAnimationReady = false;

  @override
  void initState() {
    super.initState();
    // 添加一个帧回调,在第一帧渲染完成后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 延迟500毫秒后执行
      Future.delayed(const Duration(milliseconds: 300), () {
        // 检查组件是否还在widget树中
        if (mounted) {
          // 更新状态,将isAnimationReady设置为true,触发动画开始
          setState(() => isAnimationReady = true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // 返回一个GridView.count组件,用于创建固定列数的网格布局
    return GridView.count(
      // 设置网格的内边距为15
      padding: const EdgeInsets.all(15),
      // 设置网格的列数,从widget参数中获取
      crossAxisCount: widget.crossAxisCount,
      // 设置主轴(垂直)方向的网格间距
      mainAxisSpacing: widget.spaceing,
      // 设置交叉轴(水平)方向的网格间距
      crossAxisSpacing: widget.spaceing,
      // 使用List.generate生成子组件列表
      children: List.generate(widget.children.length, (index) {
        // 获取当前索引对应的子组件
        Widget child = widget.children[index];
        // 如果子组件是网络图片,则使用CachedNetworkImage进行缓存处理
        if (child is Image && child.image is NetworkImage) {
          child = CachedNetworkImage(
            // 获取图片URL
            imageUrl: (child.image as NetworkImage).url,
            // 设置图片填充模式,如果原图片未设置则使用cover模式
            fit: child.fit ?? BoxFit.cover,
            // 加载占位组件显示灰色容器
            placeholder: (context, url) => Container(
              color: Colors.grey[500],
            ),
            // 加载错误时显示错误图标
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        }

        // 返回一个AnimationGridItem组件用于实现动画效果
        return AnimationGridItem(
          // 设置动画延迟时间,根据索引位置计算
          delay: Duration(
              microseconds: index * widget.staggerDuration.inMicroseconds),
          // 设置动画持续时间
          duration: widget.animationDuration,
          // 设置动画是否准备就绪
          isReadyToAnimation: isAnimationReady,
          // 传入处理后的子组件
          child: child,
        );
      }),
    );
  }
}

class AnimationGridItem extends StatefulWidget {
  // 存储子组件,用于显示网格项的内容
  final Widget child;
  // 动画延迟时间,控制每个网格项动画开始的时间差
  final Duration delay;
  // 动画持续时间,控制单个网格项动画的执行时长
  final Duration duration;
  // 标记动画是否准备就绪,用于控制动画的开始时机
  final bool isReadyToAnimation;

  const AnimationGridItem({
    super.key,
    required this.child,
    required this.delay,
    required this.duration,
    required this.isReadyToAnimation,
  });

  @override
  AnimationGridItemState createState() => AnimationGridItemState();
}

class AnimationGridItemState extends State<AnimationGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // 创建动画控制器,设置动画时长和vsync
    _controller = AnimationController(duration: widget.duration, vsync: this);

    // 创建位移动画,从50像素位移到0像素,使用easeOutCubic缓动曲线
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // 创建透明度动画,从0到1,在0-70%的时间内完成,使用easeOut缓动曲线
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOut)));

    // 创建模糊动画,从10到0,在40-100%的时间内完成,使用easeOut缓动曲线
    _blurAnimation = Tween<double>(begin: 10.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));
  }

  @override
  void didUpdateWidget(AnimationGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReadyToAnimation && !_hasAnimated) {
      _hasAnimated = true;
      // 使用 Future.delayed 创建一个延迟执行的异步操作,延迟时间由 widget.delay 指定
      Future.delayed(widget.delay, () {
        // 检查当前 widget 是否仍然挂载在 widget 树中
        if (mounted) {
          // 如果仍然挂载,则启动动画控制器开始执行动画
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // 使用 Transform.translate 实现垂直方向的位移动画效果
          return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              // 使用 Opacity 实现透明度渐变动画效果
              child: Opacity(
                  opacity: _opacityAnimation.value,
                  // 使用 ImageFiltered 实现模糊动画效果
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                        sigmaX: _blurAnimation.value,
                        sigmaY: _blurAnimation.value),
                    // 使用 Container 设置装饰效果
                    child: Container(
                        // BoxDecoration 用于设置圆角、背景色和阴影效果
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            // 添加阴影效果
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              )
                            ]),
                        // 设置裁剪行为为抗锯齿
                        clipBehavior: Clip.antiAlias,
                        // 显示传入的子组件
                        child: widget.child),
                  )));
        });
  }
}

// GridAnimatedDemo 类继承自 StatelessWidget,用于展示网格动画效果
class GridAnimatedDemo extends StatelessWidget {
  // 构造函数,接收一个可选的 key 参数
  const GridAnimatedDemo({super.key});

  // 重写 build 方法,构建 UI 界面
  @override
  Widget build(BuildContext context) {
    // 返回一个 Scaffold 脚手架组件
    return Scaffold(
        // body 使用 AnimatedGrid 组件
        body: AnimatedGrid(
            // 设置网格的列数为2
            crossAxisCount: 2,
            // 设置网格间距为15
            spaceing: 15,
            // children 数组包含4个网络图片
            children: [
          // 第一张网络图片
          Image.network(
              'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-01.jpg',
              fit: BoxFit.cover),
          // 第二张网络图片
          Image.network(
              'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-02.jpg',
              fit: BoxFit.cover),
          // 第三张网络图片
          Image.network(
              'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-03.jpg',
              fit: BoxFit.cover),
          // 第四张网络图片
          Image.network(
              'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-04.jpg',
              fit: BoxFit.cover),
        ]));
  }
}
