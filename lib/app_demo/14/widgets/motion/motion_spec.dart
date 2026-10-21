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
  Duration get coinRound => Duration(milliseconds: reduceMotion ? 200 : (fast ? 1000 : 2200));
}
