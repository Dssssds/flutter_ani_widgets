import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/loader_sphere/loader_sphere.dart';
import 'package:flutter_x_widgets/example/scroll_progress/scroll_progress_demo.dart';

class LoaderSphereDemo extends StatefulWidget {
  const LoaderSphereDemo({super.key});

  @override
  State<LoaderSphereDemo> createState() => _LoaderSphereDemoState();
}

class _LoaderSphereDemoState extends State<LoaderSphereDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 将脚手架背景设置为透明
      body: Stack(
        fit: StackFit.expand, // 让Stack填充所有可用空间
        children: [
          // 网格背景
          CustomPaint(
            painter: GridPatternPainter(isDarkMode: false),
            size: Size.infinite,
          ),
          // 居中显示的演示组件
          Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 120,
                maxHeight: 120,
              ),
              child: const RippleDemo(),
            ),
          ),
        ],
      ),
    );
  }
}

class RippleDemo extends StatelessWidget {
  const RippleDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // 设置略微透明的背景色
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 40,
            spreadRadius: 10,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Center(
        child: AnimatedWaveRipple(
          size: 120,
          duration: Duration(seconds: 2),
          opacity: 0.6,
        ),
      ),
    );
  }
}
