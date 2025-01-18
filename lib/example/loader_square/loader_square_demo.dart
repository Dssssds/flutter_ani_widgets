import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/loader_square/loader_square.dart';
import 'package:flutter_x_widgets/example/scroll_progress/scroll_progress_demo.dart';

/// 方形加载动画演示组件
/// 展示了一个带有网格背景的弹跳方块加载动画
class LoaderSquareDemo extends StatefulWidget {
  const LoaderSquareDemo({super.key});

  @override
  State<LoaderSquareDemo> createState() => _LoaderSphereDemoState();
}

class _LoaderSphereDemoState extends State<LoaderSquareDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 设置脚手架背景为透明
      body: Stack(
        fit: StackFit.expand, // 让Stack填充所有可用空间
        children: [
          // 网格背景
          CustomPaint(
            painter: GridPatternPainter(isDarkMode: false), // 使用网格图案绘制器，设置为亮色模式
            size: Size.infinite, // 设置网格大小为无限，填充整个屏幕
          ),
          // 居中显示的弹跳方块
          const Center(
            child: BouncingSquare(), // 弹跳方块组件，实现加载动画效果
          ),
        ],
      ),
    );
  }
}
