import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/dice/dice_theme.dart';

/// 掷骰子页的背景：近黑底，舞台后一团很弱的暗红光晕，底部一层更淡的红色渐变。
///
/// 铺满整屏（包括状态栏下方），所以不会在安全区边缘出现色阶。
class DiceStageBackground extends StatelessWidget {
  const DiceStageBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [DiceTheme.background, DiceTheme.background, DiceTheme.bottomGlow],
          stops: [0, .62, 1],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            // 光晕中心对准待机时骰子所在的屏高 49% 处。
            center: const Alignment(0, -.02),
            radius: .75,
            colors: [DiceTheme.glow, DiceTheme.glow.withValues(alpha: .4), Colors.transparent],
            stops: const [0, .5, 1],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
