import 'dart:math' as math;
import 'package:flutter/animation.dart';

/// 标准和快速模式共用的归一化时间轴。
abstract final class CoinMotion {
  static const revealAt = 0.75;

  static double flight(double progress) => ((progress - 120 / 2200) / ((1650 - 120) / 2200)).clamp(0.0, 1.0);

  static double halfTurns(double progress, int start, int target, {required bool reduceMotion}) {
    if (reduceMotion) return progress < revealAt ? start.toDouble() : target.toDouble();
    return start + (target - start) * Curves.easeOutCubic.transform(flight(progress));
  }

  static double height(double progress) => math.sin(flight(progress) * math.pi) * 64;
  static double revealProgress(double progress) => ((progress - revealAt) / (1950 / 2200 - revealAt)).clamp(0.0, 1.0);
  static bool showsHeads(double halfTurns) => math.cos(halfTurns * math.pi) >= 0;
  static double faceAngle(double halfTurns) => halfTurns * math.pi + (showsHeads(halfTurns) ? 0 : math.pi);
}
