import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/book_open/book_open.dart';
import 'package:flutter_x_widgets/example/book_open/design/book_cover.dart';
import 'package:flutter_x_widgets/example/scroll_progress/scroll_progress_demo.dart';

class BookOpenDemo extends StatefulWidget {
  const BookOpenDemo({super.key});

  @override
  State<BookOpenDemo> createState() => _BookOpenState();
}

class _BookOpenState extends State<BookOpenDemo> {
  // 3D变换的旋转值初始化
  double _rotateX = 0.0; // X轴旋转角度
  double _rotateY = 0.0; // Y轴旋转角度
  double _rotateZ = 0.0; // Z轴旋转角度

  /// 构建自定义滑块控制器
  /// @param axis - 轴向名称（X/Y/Z）
  /// @param value - 当前旋转值
  /// @param onChanged - 值改变时的回调函数
  Widget _buildSlider({
    required String axis,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 轴向标签和当前值显示
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                axis.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '${value.toStringAsFixed(0)}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Menlo', // 使用等宽字体显示数值
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 自定义样式的滑块
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 6,
                elevation: 0,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 16,
              ),
            ),
            child: Slider(
              value: value,
              min: -180,
              max: 180,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 书籍展示区域
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 背景网格图案
                Positioned.fill(
                  child: CustomPaint(
                    painter: GridPatternPainter(isDarkMode: true),
                  ),
                ),
                // 3D变换容器
                Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // 设置透视效果
                    ..rotateX(_rotateX * pi / 180) // X轴旋转
                    ..rotateY(_rotateY * pi / 180) // Y轴旋转
                    ..rotateZ(_rotateZ * pi / 180), // Z轴旋转
                  alignment: Alignment.center,
                  child: const AnimatedBook(
                    coverChild: MinimalistBookCover(
                      bookCoverUrl:
                          'https://cdn.weread.qq.com/weread/cover/91/YueWen_737527/t6_YueWen_737527.jpg',
                      title: '我们生活在\n巨大的\n差距里',
                      author: '余华',
                      textColor: Colors.white,
                    ),
                    pageChild: Text('Book content ..'),
                    width: 150,
                    height: 200,
                    maxOpenAngle: 100,
                    numberOfPages: 25,
                  ),
                ),
                // 底部控制面板
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5), // 阴影向上偏移
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSlider(
                          axis: 'X',
                          value: _rotateX,
                          onChanged: (value) =>
                              setState(() => _rotateX = value),
                        ),
                        _buildSlider(
                          axis: 'Y',
                          value: _rotateY,
                          onChanged: (value) =>
                              setState(() => _rotateY = value),
                        ),
                        _buildSlider(
                          axis: 'Z',
                          value: _rotateZ,
                          onChanged: (value) =>
                              setState(() => _rotateZ = value),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
