import 'package:flutter/material.dart';

/// APP-15 的唯一色板、文字样式与 ThemeData 来源。
abstract final class App15Theme {
  static const paper = Color(0xFFFFFEF8);
  static const deviceBackground = Color(0xFFE9E9E1);
  static const yellow = Color(0xFFFFD83D);
  static const yellowDark = Color(0xFFD8AE17);
  static const yellowPale = Color(0xFFFFF2B3);
  static const yellowSelected = Color(0xFFFFF0A8);
  static const ink = Color(0xFF242522);
  static const muted = Color(0xFF77786E);
  static const mutedLabel = Color(0xFF5E6258);
  static const line = Color(0xFFE8E7DF);
  static const mint = Color(0xFFB9EADD);
  static const mintDark = Color(0xFF80B4A6);
  static const mintTrack = Color(0xFFDFF3EC);
  static const red = Color(0xFFF47861);
  static const wrongFooter = Color(0xFFFFF0E9);
  static const wrongSelected = Color(0xFFFFD8CD);
  static const wrongBorder = Color(0xFFC95D49);
  static const neutralBorder = Color(0xFFD9DBD0);
  static const neutralShadow = Color(0xFFE2E3D7);
  static const lockedSurface = Color(0xFFEFEEE7);
  static const lockedBorder = Color(0xFFD7D9CE);
  static const lockedIcon = Color(0xFFB3B5A8);
  static const disabledSurface = Color(0xFFEEEEE5);
  static const disabledText = Color(0xFF878B7C);
  static const navInactive = Color(0xFF62695A);
  static const navHighlight = Color(0x33FFD83D);
  static const progressTrack = Color(0xFFE7E6DD);
  static const trailBase = Color(0xFFEAE9E0);
  static const quizClose = Color(0xFF909488);
  static const wordSlotFill = Color(0xFFF4F4ED);
  static const wordSlotBorder = Color(0xFFC8CDBB);

  static const fontFamily = 'Nunito';
  static const fontFamilyFallback = <String>['PingFang SC', 'Hiragino Sans GB', 'Noto Sans CJK SC', 'sans-serif'];

  static const brandStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 40,
    fontWeight: FontWeight.w900,
    letterSpacing: -3,
    height: 1,
    color: ink,
  );

  static const pathTitleStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 24,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.7,
    height: 1.1,
    color: ink,
  );

  static const quizTitleStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 26,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.7,
    height: 1.35,
    color: ink,
  );

  static const finishTitleStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 31,
    fontWeight: FontWeight.w900,
    letterSpacing: -1,
    height: 1.3,
    color: ink,
  );

  static const bodyStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.45,
    color: ink,
  );

  static const buttonStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 18,
    fontWeight: FontWeight.w900,
    height: 1.1,
    color: ink,
  );

  static const captionStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    height: 1.3,
    color: muted,
  );

  static const sentenceStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.7,
    height: 1.9,
    color: ink,
  );

  static ThemeData get theme {
    final baseTextTheme = ThemeData.light().textTheme.apply(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      bodyColor: ink,
      displayColor: ink,
    );

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: paper,
      canvasColor: paper,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      colorScheme: const ColorScheme.light(
        primary: yellow,
        onPrimary: ink,
        secondary: mint,
        onSecondary: ink,
        surface: paper,
        onSurface: ink,
        error: red,
        onError: paper,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: finishTitleStyle,
        headlineMedium: quizTitleStyle,
        headlineSmall: pathTitleStyle,
        bodyLarge: bodyStyle,
        bodyMedium: bodyStyle,
        labelLarge: buttonStyle,
        labelMedium: captionStyle,
      ),
    );
  }
}
