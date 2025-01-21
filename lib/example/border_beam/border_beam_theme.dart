import 'package:flutter/material.dart';

/// 边框光束效果的主题类
class BorderBeamTheme {
  final String name;
  final Color colorFrom;
  final Color colorTo;
  final Color staticBorderColor;

  const BorderBeamTheme({
    required this.name,
    required this.colorFrom,
    required this.colorTo,
    required this.staticBorderColor,
  });
}

/// 预设主题
class BorderBeamThemes {
  // 海洋主题
  static const ocean = BorderBeamTheme(
    name: '海洋',
    colorFrom: Color(0xFF00B4DB),
    colorTo: Color(0xFF0083B0),
    staticBorderColor: Color(0xFFE0E0E0),
  );

  // 日落主题
  static const sunset = BorderBeamTheme(
    name: '日落',
    colorFrom: Color(0xFFFF512F),
    colorTo: Color(0xFFDD2476),
    staticBorderColor: Color(0xFFE0E0E0),
  );

  // 森林主题
  static const forest = BorderBeamTheme(
    name: '森林',
    colorFrom: Color(0xFF56AB2F),
    colorTo: Color(0xFF00897B),
    staticBorderColor: Color(0xFFE0E0E0),
  );

  // 极光主题
  static const aurora = BorderBeamTheme(
    name: '极光',
    colorFrom: Color(0xFF43CEA2),
    colorTo: Color(0xFF185A9D),
    staticBorderColor: Color(0xFFE0E0E0),
  );

  // 所有预设主题列表
  static const List<BorderBeamTheme> all = [
    ocean,
    sunset,
    forest,
    aurora,
  ];
}
