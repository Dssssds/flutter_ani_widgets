import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/coin_state.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/coin_body_painter.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/coin_motion.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

/// 单控制器驱动的硬币舞台：投影、外发光、蓄力、抛起、落地、揭晓圆环都在这里组合。
///
/// 舞台自身包含抛起所需的头部空间 [apex]，硬币静止时坐在舞台底部。
/// 调用方把舞台上移 [apex] 放置，让硬币的静止位置落在想要的屏幕位置。
/// 自身不执行规则，也不触发任何平台副作用。
class AnimatedCoin extends StatelessWidget {
  final double progress;
  final int startHalfTurns;
  final int targetHalfTurns;
  final bool reduceMotion;
  final double diameter;

  /// 硬币最高升起的高度（逻辑像素）。
  final double apex;

  /// 揭晓圆环的扩散进度；为空表示当前没有圆环。
  final double? ringProgress;

  /// 圆环整体不透明度，用来在新一轮开始时把残留的圆环淡出。
  final double ringOpacity;

  const AnimatedCoin({
    super.key,
    required this.progress,
    required this.startHalfTurns,
    required this.targetHalfTurns,
    required this.reduceMotion,
    required this.apex,
    this.diameter = CoinShape.diameter,
    this.ringProgress,
    this.ringOpacity = 1,
  });

  /// 舞台底部留给投影的高度。
  static const double shadowBand = 18;

  static double stageWidthFor(double diameter) => diameter * 1.7;

  /// 舞台总高度：抛起空间 + 硬币直径 + 底部投影。
  static double stageHeightFor(double diameter, double apex) => apex + diameter + shadowBand;

  @override
  Widget build(BuildContext context) {
    const colors = PartyTheme.coinColors;
    final turns = CoinMotion.halfTurns(progress, startHalfTurns, targetHalfTurns, reduceMotion: reduceMotion);
    // 硬币的正面永远是正面，旋转角决定当前朝向用户的是哪一面。
    // 半圈数为偶数时正面朝向用户，奇数时反面朝向用户。
    final angle = CoinMotion.faceAngle(turns);

    // 比例计算里除以 apex，下限 1 避免极小屏幕上出现 NaN。
    final rise = math.max(apex, 1.0);
    final lift = reduceMotion ? 0.0 : CoinMotion.height(progress, rise);
    final scale = diameter / CoinShape.diameter;
    final bodyScale = (reduceMotion ? 1.0 : CoinMotion.chargeScale(progress)) * scale;
    final glow = CoinMotion.glowFactor(progress) * (reduceMotion ? .55 : 1);

    final stageWidth = stageWidthFor(diameter);
    final stageHeight = stageHeightFor(diameter, apex);
    // 硬币静止时坐在舞台底部，投影落在同一水平线上。
    final restingCenterY = stageHeight - shadowBand - diameter / 2;
    final coinCenterY = restingCenterY - lift + CoinMotion.sink(progress);

    return ExcludeSemantics(
      child: SizedBox(
        width: stageWidth,
        height: stageHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topLeft,
          children: [
            // 舞台底部：随高度变化的椭圆投影。
            Positioned(
              left: 0,
              right: 0,
              top: stageHeight - shadowBand,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    width: diameter * 1.02 * CoinMotion.shadowScale(progress, rise),
                    height: shadowBand,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: RadialGradient(
                        colors: [
                          Colors.black.withValues(alpha: (reduceMotion ? .22 : .40) * CoinMotion.shadowAlpha(progress, rise)),
                          Colors.black.withValues(alpha: (reduceMotion ? .22 : .40) * CoinMotion.shadowAlpha(progress, rise) * .45),
                          Colors.transparent,
                        ],
                        stops: const [0, .55, 1],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 外发光：画在硬币下方，强度随高度增强，落地后回到静态弱光。
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: CoinGlowPainter(
                      colors: colors,
                      strength: glow.clamp(0.0, 1.4),
                      radius: diameter / 2,
                      center: Offset(stageWidth / 2, coinCenterY),
                    ),
                  ),
                ),
              ),
            ),
            // 揭晓圆环：以静止位置为圆心，向外扩散并变淡。
            if (ringProgress != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    key: const ValueKey('coin-rings'),
                    painter: CoinRingsPainter(
                      progress: ringProgress!,
                      opacity: ringOpacity,
                      color: colors[1],
                      radius: diameter / 2,
                      center: Offset(stageWidth / 2, restingCenterY),
                    ),
                  ),
                ),
              ),
            // 硬币本体：抛起时只有竖直位移，带绕竖轴的轻微倾斜强化立体感。
            Positioned(
              left: (stageWidth - diameter) / 2,
              top: coinCenterY - diameter / 2,
              child: IgnorePointer(
                child: Opacity(
                  // 减少动态效果时不做旋转，改用一次淡入把结果呈现出来。
                  opacity: reduceMotion ? CoinMotion.reduceMotionFade(progress) : 1,
                  // 只在竖直方向移动：横向位置固定在舞台中线上，抛起和回落走同一条垂直线。
                  child: Transform(
                    alignment: Alignment.center,
                    transform:
                        Matrix4.identity()
                          ..rotateY(reduceMotion ? 0 : CoinMotion.tilt(progress))
                          ..scaleByDouble(bodyScale, bodyScale, bodyScale, 1.0),
                    child: RepaintBoundary(
                      child: CustomPaint(
                        key: const ValueKey('coin-face'),
                        size: Size.square(diameter),
                        painter: CoinBodyPainter(side: CoinSide.heads, angle: angle),
                      ),
                    ),
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
