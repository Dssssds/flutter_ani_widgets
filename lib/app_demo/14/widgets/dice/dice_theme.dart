import 'package:flutter/material.dart';

/// 掷骰子页的主题：深黑底、暗红光晕、酒红按钮（抛硬币页是金色，两者靠主题色区分）。
abstract final class DiceTheme {
  static const background = Color(0xFF100F14);
  static const glow = Color(0xFF22121C);
  static const bottomGlow = Color(0xFF1D0512);

  static const wine = Color(0xFF65031A);
  static const wineEdge = Color(0xFF55061D);
  static const wineGlow = Color(0xFFB0102F);

  static const disabled = Color(0xFF1C1B20);
  static const disabledText = Color(0xFF8E8C93);

  static const segmentTrack = Color(0xFF48484C);

  /// 辅助文字：比抛硬币页稍亮，保证在近黑底上对比度不低于 4.5:1。
  static const muted = Color(0xFFA9A4B3);
}
