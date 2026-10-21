import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/coin_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/coin_motion.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/coin_painter.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

/// 单控制器驱动的硬币舞台；不执行规则或平台副作用。
class AnimatedCoin extends StatelessWidget {
  final double progress;
  final int startHalfTurns;
  final int targetHalfTurns;
  final bool reduceMotion;
  final CoinAppearance appearance;

  const AnimatedCoin({
    super.key,
    required this.progress,
    required this.startHalfTurns,
    required this.targetHalfTurns,
    required this.reduceMotion,
    required this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    final turns = CoinMotion.halfTurns(progress, startHalfTurns, targetHalfTurns, reduceMotion: reduceMotion);
    final cosine = math.cos(turns * math.pi);
    final height = reduceMotion ? 0.0 : CoinMotion.height(progress);
    final colors = PartyTheme.coinColors(appearance);
    final edgeHeight = 10 + cosine.abs() * 200;
    final ring = ((progress - CoinMotion.revealAt) / (1 - CoinMotion.revealAt)).clamp(0.0, 1.0);
    final charge = !reduceMotion && progress < 120 / 2200 ? math.sin(progress / (120 / 2200) * math.pi) * 0.05 : 0.0;
    final faceOpacity =
        !reduceMotion
            ? 1.0
            : (progress < CoinMotion.revealAt
                ? 1 - progress / CoinMotion.revealAt
                : (progress - CoinMotion.revealAt) / (1 - CoinMotion.revealAt));
    return ExcludeSemantics(
      child: SizedBox(
        width: 280,
        height: 360,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 24,
              child: Container(
                width: 160 - height * 0.8,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35 - height / 400),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            if (!reduceMotion && ring > 0 && ring < 1)
              IgnorePointer(
                child: Opacity(
                  opacity: 1 - ring,
                  child: Container(
                    width: 220 + ring * 50,
                    height: 220 + ring * 50,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colors[1], width: 2)),
                  ),
                ),
              ),
            Transform.translate(
              offset: Offset(0, -height),
              child: Transform.scale(
                scale: 1 - charge,
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 216,
                        height: edgeHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.elliptical(108, edgeHeight / 2)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [colors[1], colors.last, colors[1]],
                          ),
                        ),
                      ),
                      if (cosine.abs() > 0.035)
                        Opacity(
                          opacity: faceOpacity.clamp(0.0, 1.0),
                          child: Transform(
                            alignment: Alignment.center,
                            transform:
                                Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateX(CoinMotion.faceAngle(turns)),
                            child: CustomPaint(
                              key: const ValueKey('coin-face'),
                              size: const Size(240, 240),
                              painter: CoinPainter(appearance, side: cosine >= 0 ? CoinSide.heads : CoinSide.tails),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
