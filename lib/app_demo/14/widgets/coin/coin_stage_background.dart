import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

/// 硬币舞台的背景：近黑的深色渐变，加一层很弱的暖色径向光晕。
///
/// 光晕固定在硬币静止位置附近，硬币抛起时它留在原地，让画面中央保持聚焦。
class CoinStageBackground extends StatelessWidget {
  const CoinStageBackground({super.key});

  /// 舞台底色：顶部略偏紫的近黑，向下更深。
  static const top = Color(0xFF111015);
  static const bottom = Color(0xFF0A090F);

  @override
  Widget build(BuildContext context) {
    final accent = PartyTheme.coinColors[1];
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom]),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -.14),
            radius: .72,
            colors: [accent.withValues(alpha: .10), accent.withValues(alpha: .04), Colors.transparent],
            stops: const [0, .55, 1],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
