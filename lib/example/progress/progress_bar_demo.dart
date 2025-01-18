import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/progress/progress_bar.dart';
import 'package:flutter_x_widgets/example/progress/strategies/circlula_progress_strategy.dart';
import 'package:flutter_x_widgets/example/progress/strategies/linear_progress_strategy.dart';
import 'package:flutter_x_widgets/example/progress/strategies/wave_progress_strategy.dart';
import 'package:flutter_x_widgets/example/scroll_progress/scroll_progress_demo.dart';

class ProgressBarDemo extends StatefulWidget {
  const ProgressBarDemo({super.key});

  @override
  State<ProgressBarDemo> createState() => _ProgressBarDemoState();
}

class _ProgressBarDemoState extends State<ProgressBarDemo> {
  // 当前进度值
  double _progress = 0.7;

  // 定义一致的调色板
  static const Color _primaryWhite = Color(0xFFFFFFFF);
  static const Color _softWhite = Color(0xFFE0E0E0);
  static const Color _mediumGray = Color(0xFF808080);
  static const Color _darkGray = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 深色网格背景
          CustomPaint(
            painter: GridPatternPainter(
              isDarkMode: true,
            ),
            size: Size.infinite,
          ),
          // 主要内容
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 进度信息文本，使用增强的排版
                Text(
                  '${(_progress * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: _primaryWhite,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 40),

                // 线性进度条，带有细微的渐变效果
                ProgressLoader(
                  progress: _progress,
                  strategy: LinearProgressStrategy(),
                  style: const ProgressStyle(
                    gradientColors: [
                      _softWhite,
                      _primaryWhite,
                    ],
                    height: 8, // 稍微减小高度以增加优雅感
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    backgroundColor: _mediumGray,
                  ),
                ),
                const SizedBox(height: 48),

                // 波浪进度条，带有精细的动画效果
                ProgressLoader(
                  progress: _progress,
                  strategy: const DynamicWaveProgressStrategy(
                    waveDuration: Duration(milliseconds: 2500),
                    autoAnimate: true,
                    waveCurve: Curves.linear,
                  ),
                  style: ProgressStyle(
                    height: 130,
                    width: 130,
                    borderRadius: BorderRadius.circular(12),
                    primaryColor: _primaryWhite.withOpacity(0.85),
                    backgroundColor: _mediumGray,
                  ),
                ),
                const SizedBox(height: 48),

                // 圆形进度条，带有精致的外观
                ProgressLoader(
                  progress: _progress,
                  strategy: CircularProgressStrategy(
                    strokeWidth: 10,
                  ),
                  style: const ProgressStyle(
                    width: 130,
                    gradientColors: [
                      _primaryWhite,
                      _primaryWhite,
                    ],
                    backgroundColor: _darkGray,
                  ),
                ),

                const SizedBox(height: 60),

                // 优化的滑块控制器
                Column(
                  children: [
                    Text(
                      '调整进度',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: _softWhite.withOpacity(0.7),
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        activeTrackColor: _primaryWhite,
                        inactiveTrackColor: _mediumGray,
                        thumbColor: _primaryWhite,
                        overlayColor: _primaryWhite.withOpacity(0.1),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7,
                          elevation: 2,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 18,
                        ),
                      ),
                      child: Slider(
                        value: _progress,
                        onChanged: (value) {
                          setState(() {
                            _progress = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
