import 'package:flutter/material.dart';

/// Design tokens for the Photo Editor UI
class PhotoEditorTheme {
  PhotoEditorTheme._();

  // Colors
  static const Color bgMain = Color(0xFF000000);
  static const Color bgPanel = Color(0xA61C1C1E); // ~65% opacity
  static const Color bgPanelSolid = Color(0xFF1C1C1E);

  static const Color accentPrimary = Color(0xFFFFD700); // Gold
  static const Color accentSecondary = Color(0xFFFF9500); // Amber
  static const Color accentGlow = Color(0x4DFF9500); // 30% opacity

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFF48484A);

  static const Color gridLine = Color(0x1AFFFFFF); // 10% white

  // Blur
  static const double glassBlur = 25.0;

  // Border radius
  static const double radiusPanel = 32.0;
  static const double radiusCard = 20.0;
  static const double radiusButton = 12.0;

  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    const BoxShadow(color: accentGlow, blurRadius: 15, spreadRadius: 0),
  ];

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: 2,
  );

  static const TextStyle labelStyle = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle dialLabelStyle = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: textSecondary,
  );

  static const TextStyle indicatorStyle = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: accentPrimary,
    letterSpacing: 0.5,
  );
}
