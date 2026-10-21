import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';

/// 聚会舞台色板；仅使用项目已有字体和 Flutter 图形。
abstract final class PartyTheme {
  static const background = Color(0xFF151019);
  static const surface = Color(0xFF28212D);
  static const muted = Color(0xFFC6BDCB);
  static const ink = Color(0xFF211526);
  static const menuColors = [Color(0xFFD9C3F3), Color(0xFFFFA890), Color(0xFFBDE2CA), Color(0xFFF4D780), Color(0xFFAFCFEF)];

  static Color menuColor(int page, int row) => menuColors[(row + page) % menuColors.length];

  static ThemeData get theme => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(primary: Color(0xFFF4D780), surface: surface),
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'SF Pro Display'),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      modalBackgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
  );

  static String appearanceName(CoinAppearance appearance) => switch (appearance) {
    CoinAppearance.gold => '金色',
    CoinAppearance.ice => '冰蓝',
    CoinAppearance.rose => '玫瑰',
  };

  static List<Color> coinColors(CoinAppearance appearance) => switch (appearance) {
    CoinAppearance.gold => const [Color(0xFFFFF7A5), Color(0xFFE9C94A), Color(0xFF98731B)],
    CoinAppearance.ice => const [Color(0xFFE3FAFF), Color(0xFF9DD8ED), Color(0xFF426B91)],
    CoinAppearance.rose => const [Color(0xFFFFE3DD), Color(0xFFEBA39D), Color(0xFF955361)],
  };
}
