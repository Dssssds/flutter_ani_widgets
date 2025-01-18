import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/gemini_splash/combined_.dart';
import 'package:flutter_x_widgets/example/gemini_splash/glowing_fog.dart';

class SparkleDemo extends StatefulWidget {
  const SparkleDemo({super.key});

  @override
  State<SparkleDemo> createState() => _SparkleDemoState();
}

class _SparkleDemoState extends State<SparkleDemo> {
  Key _combinedKey = UniqueKey();

  final GlobalKey<MysticalWavesState> _wavesKey = GlobalKey();

  void _replayAnimation() {
    setState(() {
      _combinedKey = UniqueKey();
      _wavesKey.currentState?.stopAnimation();
    });
  }

  void _onStarAnimationComplete() {
    // 当星星动画完成时开始波浪动画
    _wavesKey.currentState?.startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          UnifiedStarAnimation(
            key: _combinedKey,
            size: 50,
            color: Colors.yellow,
            totalDuration: const Duration(milliseconds: 2000),
            onAnimationComplete: _onStarAnimationComplete,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MysticalWaves(
                key: _wavesKey,
                height: 200,
                animationDuration: const Duration(milliseconds: 400),
                waveDuration: const Duration(seconds: 3),
                waveColors: [
                  const Color(0xFFFFD700).withOpacity(0.5), // 璀璨金色
                  const Color(0xFFFFA500).withOpacity(0.4), // 发光橙色
                  const Color(0xFFFFE4B5).withOpacity(0.3), // 柔和鹿皮色
                ]),
          ),
          Positioned(
            bottom: 50,
            child: Row(
              children: [
                IconButton(
                  onPressed: _replayAnimation,
                  icon: const Icon(
                    Icons.replay_circle_filled_rounded,
                    color: Colors.white,
                    size: 48,
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
