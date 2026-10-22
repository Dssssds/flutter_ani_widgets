import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';

/// 基础 UI 动效；系统减少动态效果始终优先。
class MotionSpec {
  final bool reduceMotion;
  final bool fast;

  MotionSpec(SettingsState settings, {bool systemReduceMotion = false})
    : reduceMotion = systemReduceMotion || settings.reduceMotion,
      fast = settings.motionSpeed == MotionSpeed.fast;

  factory MotionSpec.of(BuildContext context, SettingsState settings) {
    return MotionSpec(settings, systemReduceMotion: MediaQuery.disableAnimationsOf(context));
  }

  Duration get pressIn => Duration(milliseconds: reduceMotion ? 0 : (fast ? 40 : 80));
  Duration get pressOut => Duration(milliseconds: reduceMotion ? 0 : (fast ? 70 : 140));
  Duration get route => Duration(milliseconds: reduceMotion ? 120 : (fast ? 140 : 280));
  Duration get page => Duration(milliseconds: reduceMotion ? 120 : (fast ? 480 : 850));
  Duration get menuEnter => Duration(milliseconds: reduceMotion ? 120 : (fast ? 900 : 1480));
  Duration get coinRound => Duration(milliseconds: reduceMotion ? 200 : (fast ? 1150 : 2550));

  /// 掷骰子一次的翻滚时长；落定后结果再淡入约 250ms，合计约 2.5 秒。
  Duration get diceRound => Duration(milliseconds: reduceMotion ? 200 : (fast ? 1100 : 2250));

  /// 掷骰子页文字与控件的淡入淡出时长。
  Duration get diceFadeIn => Duration(milliseconds: reduceMotion ? 120 : 250);
  Duration get diceFadeOut => Duration(milliseconds: reduceMotion ? 120 : 150);

  /// 揭晓圆环的扩散时长；减少动态效果时不播放。
  Duration get coinRing => Duration(milliseconds: reduceMotion ? 0 : (fast ? 400 : 750));
}
