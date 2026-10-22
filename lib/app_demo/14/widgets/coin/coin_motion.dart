import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter_x_widgets/app_demo/14/models/coin_state.dart';

/// 标准和快速模式共用的归一化时间轴。
///
/// 归一化以 2550ms 为基准，关键帧比例固定，快速模式只是把整段压短：
///
/// - 0–150ms：蓄力，硬币下沉并轻微缩小；旧结果淡出、“抛掷中…” 淡入。
/// - 150–1950ms：抛起翻转，沿同一条垂直线升起再回落，没有横向位移。
/// - 1950–2250ms：落地，小幅弹跳后阻尼停稳。
/// - 2250–2550ms：“抛掷中…” 淡出，结果文字淡入并轻微上移。
///
/// 揭晓圆环由页面另用一个控制器播放，不占用这条时间轴。
abstract final class CoinMotion {
  /// 蓄力结束。
  static const double chargeEnd = 150 / 2550;

  /// 抛起结束，落地的时刻。
  static const double flightEnd = 1950 / 2550;

  /// 落地停稳，同时也是结果揭晓点。
  static const double landEnd = 2250 / 2550;

  /// 结果文字入场结束，也是整条时间轴的终点。
  static const double resultEnd = 1.0;

  /// 揭晓点：结果文案从此处开始出现。
  static const double revealAt = landEnd;

  /// 旧结果淡出结束。
  static const double _textOutEnd = 200 / 2550;

  /// “抛掷中…” 淡入区间，比旧结果淡出晚 100ms 开始，避免两段文字叠在一起。
  static const double _flippingInStart = 100 / 2550;
  static const double _flippingInEnd = 300 / 2550;

  /// 揭晓时 “抛掷中…” 先淡出，结果晚 100ms 再淡入。
  static const double _flippingOutEnd = revealAt + 150 / 2550;
  static const double _resultInStart = revealAt + 100 / 2550;

  /// 旧结果的淡出进度 0..1。
  static double textOut(double progress) => (progress / _textOutEnd).clamp(0.0, 1.0);

  /// “抛掷中…” 的淡入进度 0..1。
  static double flippingIn(double progress) => ((progress - _flippingInStart) / (_flippingInEnd - _flippingInStart)).clamp(0.0, 1.0);

  /// 揭晓时 “抛掷中…” 的淡出进度 0..1。
  static double flippingOut(double progress) => ((progress - revealAt) / (_flippingOutEnd - revealAt)).clamp(0.0, 1.0);

  /// 结果文字的淡入进度 0..1。
  static double resultIn(double progress) => ((progress - _resultInStart) / (resultEnd - _resultInStart)).clamp(0.0, 1.0);

  /// 静止时的外发光强度。
  static const double glowRest = .42;

  /// 翻转曲线：接近线性，只在首尾轻微加减速。
  ///
  /// 纯 easeOut 会让大部分圈数挤在开头、末尾几乎不动，看起来像卡住；
  /// 纯线性则在落地瞬间戛然而止。这条曲线兼顾两者。
  static const Curve flipCurve = _FlipCurve();

  /// 旋转进度：从蓄力结束到落地停稳。
  static double turn(double progress) => ((progress - chargeEnd) / (landEnd - chargeEnd)).clamp(0.0, 1.0);

  /// 当前半圈数。
  ///
  /// 减少动态效果时不翻转：硬币直接切到结果朝向，配合一次淡入。
  static double halfTurns(double progress, int start, int target, {required bool reduceMotion}) {
    if (reduceMotion) return target.toDouble();
    return start + (target - start) * flipCurve.transform(turn(progress));
  }

  /// 抛起高度。落地后有一次小幅弹跳并阻尼归零。
  static double height(double progress, double apex) {
    if (progress <= chargeEnd) return 0;
    if (progress <= flightEnd) {
      final t = (progress - chargeEnd) / (flightEnd - chargeEnd);
      return math.sin(t * math.pi) * apex;
    }
    final t = ((progress - flightEnd) / (landEnd - flightEnd)).clamp(0.0, 1.0);
    return apex * .22 * math.sin(t * math.pi) * (1 - .55 * t);
  }

  /// 蓄力下沉量，为负值。
  static double sink(double progress) {
    if (progress >= chargeEnd) return 0;
    final t = (progress / chargeEnd).clamp(0.0, 1.0);
    return -6 * math.sin(t * math.pi);
  }

  /// 蓄力时的缩小比例。
  static double chargeScale(double progress) {
    if (progress >= chargeEnd) return 1;
    final t = (progress / chargeEnd).clamp(0.0, 1.0);
    return 1 - .045 * math.sin(t * math.pi);
  }

  /// 抛起时绕竖轴的轻微摆动，强化立体感。
  static double tilt(double progress) {
    if (progress <= chargeEnd || progress >= flightEnd) return 0;
    final t = (progress - chargeEnd) / (flightEnd - chargeEnd);
    return math.sin(t * math.pi * 1.8) * .12;
  }

  /// 外发光强度：最高点最亮，落地后回到静态弱光。
  static double glowFactor(double progress) {
    if (progress <= chargeEnd) {
      final t = (progress / chargeEnd).clamp(0.0, 1.0);
      return glowRest + (.9 - glowRest) * t;
    }
    if (progress <= flightEnd) {
      final t = (progress - chargeEnd) / (flightEnd - chargeEnd);
      return .9 + .1 * math.sin(t * math.pi);
    }
    if (progress <= landEnd) {
      final t = (progress - flightEnd) / (landEnd - flightEnd);
      return .9 - .25 * t;
    }
    final t = ((progress - landEnd) / (1 - landEnd)).clamp(0.0, 1.0);
    return .65 + (glowRest - .65) * t;
  }

  /// 投影的缩放：抛得越高，投影越小。
  static double shadowScale(double progress, double apex) => 1 - .45 * (height(progress, apex) / apex);

  /// 投影的浓度：抛得越高，投影越淡。
  static double shadowAlpha(double progress, double apex) => 1 - .65 * (height(progress, apex) / apex);

  /// 减少动态效果时硬币的淡入进度。
  ///
  /// 整段动画压缩到约 200ms，硬币不翻转，直接淡入到结果朝向。
  static double reduceMotionFade(double progress) => progress.clamp(0.0, 1.0);

  /// 偶数半圈是正面，奇数半圈是反面。
  ///
  /// 与 [CoinRules.targetHalfTurns] 的奇偶约定一致：投到正面停在偶数半圈，
  /// 投到反面停在奇数半圈，因此每一轮都会自然接上上一轮的朝向。
  static bool showsHeads(double halfTurns) => math.cos(halfTurns * math.pi) >= 0;

  /// 当前朝向用户的那一面。
  ///
  /// 硬币绕横轴旋转，奇数半圈时反面朝向用户。
  static CoinSide visibleSide(double halfTurns) => showsHeads(halfTurns) ? CoinSide.heads : CoinSide.tails;

  /// 硬币的旋转角。0 表示正面正对用户。
  ///
  /// 半圈数为整数时，正面出现在偶数半圈、反面出现在奇数半圈；
  /// 连续过程中硬币自然转过侧面，厚度随之显现。
  static double faceAngle(double halfTurns) => halfTurns * math.pi;
}

/// 接近线性的翻转曲线：首尾加减速，中间保持匀速。
class _FlipCurve extends Curve {
  const _FlipCurve();

  @override
  double transformInternal(double t) {
    // y = t + k·sin(2πt)，在 t=0 和 t=1 处与直线重合。
    return t + .0796 * math.sin(2 * math.pi * t);
  }
}