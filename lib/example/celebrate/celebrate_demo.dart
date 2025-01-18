import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/celebrate/celebrate.dart';

/// 庆祝效果演示组件
/// 展示了如何使用 CoolMode 组件来创建一个带有粒子动画效果的按钮
class CelebrateDemo extends StatelessWidget {
  const CelebrateDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // 使用 Center 组件使按钮居中显示
        child: CoolMode(
          // CoolMode 组件用于创建粒子动画效果
          particleImage: "your_image_url", // 粒子图片的URL，可以自定义粒子的外观
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('长按触发'), // 提示用户长按按钮来触发效果
          ),
        ),
      ),
    );
  }
}
