import 'package:flutter/material.dart';

/// 聚会舞台色板；仅使用项目已有字体和 Flutter 图形。
abstract final class PartyTheme {
  /// 展示字体：标题与游戏名，仅拉丁字符，单一字重。
  static const displayFamily = 'NeumaticGothic-Black';

  /// 正文字体：中文与说明文字。
  static const bodyFamily = 'SF Pro Display';

  /// 舞台底色：从顶部 #2A2530 过渡到底部 #1C1820。
  static const backgroundTop = Color(0xFF2A2530);
  static const background = Color(0xFF211D26);
  static const backgroundBottom = Color(0xFF1C1820);
  static const surface = Color(0xFF28212D);

  /// 主文字色：比纯白柔和，在深色舞台上减轻眩光。
  static const chalk = Color(0xFFF3EEE6);
  static const muted = Color(0xFFB8B2C0);
  static const ink = Color(0xFF211526);
  static const menuColors = [Color(0xFFD9C3F3), Color(0xFFFFA890), Color(0xFFBDE2CA), Color(0xFFF4D780), Color(0xFFAFCFEF)];

  static Color menuColor(int page, int row) => menuColors[(row + page) % menuColors.length];

  static ThemeData get theme => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(primary: Color(0xFFF4D780), surface: surface),
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: bodyFamily),
  );

  /// 硬币固定为金色：高光、主色、暗部。
  static const coinColors = [Color(0xFFFFF7A5), Color(0xFFE9C94A), Color(0xFF98731B)];

  /// 硬币面上的图案与文字颜色，在金属底色上保持足够对比度。
  static const coinInk = Color(0xFF5C4310);
}
