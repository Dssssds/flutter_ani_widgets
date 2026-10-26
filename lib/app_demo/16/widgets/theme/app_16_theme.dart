import 'package:flutter/material.dart';

abstract final class App16Colors {
  static const berry = Color(0xFF9D3C65);
  static const berryHover = Color(0xFF873353);
  static const ink = Color(0xFF49323D);
  static const muted = Color(0xFF765D68);
  static const appBg = Color(0xFFF7F0F3);
  static const outerBg = Color(0xFFEAE3E7);
  static const pink = Color(0xFFEED0DD);
  static const paper = Color(0xFFFFFDF8);
  static const line = Color(0xFFE4D9DF);
  static const surface = Color(0xFFFCF9FB);
  static const selected = Color(0xFFEEDCE5);
  static const noteInk = Color(0xFF6C5147);
  static const captionInk = Color(0xFF725845);
  static const ticketBg = Color(0xFFF7E7CF);
  static const ticketInk = Color(0xFF9C674B);
  static const errorInk = Color(0xFF873053);
  static const dotGrid = Color(0xFFCFC4B8);
  static const photoPaper = Color(0xFFFFFEFB);
  static const noteText = Color(0xFF825846);
  static const miniPaper = Color(0xFFFFF7EC);
  static const ticketBorder = Color(0x7ABC8768);
  static const toastBg = Color(0xED654456);
  static const sheetScrim = Color(0xB3432334);
  static const inputBorder = Color(0xFFDDC8D3);
  static const inputBg = Color(0xFFFFFDF9);
  static const materialCover = Color(0xFFEFDAE4);
  static const dashedBerry = Color(0xCC9D3C65);
}

abstract final class App16Typography {
  static const handFamily = 'Kaiti SC';
  static const handFallback = <String>['STKaiti', 'KaiTi', 'WenKai', 'serif'];
  static const numberFamily = 'Georgia';
  static const numberFallback = <String>['Times New Roman', 'serif'];

  static const brand = TextStyle(
    fontFamily: handFamily,
    fontFamilyFallback: handFallback,
    fontSize: 25,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
    color: App16Colors.berry,
  );

  static const screenTitle = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    color: App16Colors.ink,
  );

  static const bigDay = TextStyle(
    fontFamily: numberFamily,
    fontFamilyFallback: numberFallback,
    fontSize: 67,
    height: 1,
    fontStyle: FontStyle.italic,
    letterSpacing: -4,
    color: App16Colors.ink,
  );

  static const monthNumber = TextStyle(
    fontFamily: numberFamily,
    fontFamilyFallback: numberFallback,
    fontSize: 72,
    height: 1,
    fontStyle: FontStyle.italic,
    letterSpacing: -3,
    color: App16Colors.ink,
  );

  static const dateLine = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: App16Colors.ink,
  );

  static const yearLine = TextStyle(fontSize: 13, color: App16Colors.muted);

  static const handTitle = TextStyle(
    fontFamily: handFamily,
    fontFamilyFallback: handFallback,
    fontSize: 25,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: App16Colors.ink,
  );

  static const handBody = TextStyle(
    fontFamily: handFamily,
    fontFamilyFallback: handFallback,
    fontSize: 18,
    height: 1.65,
    fontWeight: FontWeight.w500,
    color: App16Colors.noteInk,
  );

  static const primaryButton = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const navLabel = TextStyle(
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w500,
  );

  static const materialTab = TextStyle(fontSize: 14);

  static const sectionLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: App16Colors.ink,
  );

  static const helper = TextStyle(fontSize: 12, color: App16Colors.muted);

  static TextStyle hand({
    double? fontSize,
    double? height,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: handFamily,
      fontFamilyFallback: handFallback,
      fontSize: fontSize ?? 18,
      height: height ?? 1.4,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? App16Colors.noteInk,
    );
  }

  static TextStyle number({
    double? fontSize,
    double? letterSpacing,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: numberFamily,
      fontFamilyFallback: numberFallback,
      fontSize: fontSize ?? 12,
      height: 1,
      fontStyle: FontStyle.italic,
      letterSpacing: letterSpacing ?? 0.5,
      fontWeight: fontWeight,
      color: color ?? App16Colors.muted,
    );
  }
}

abstract final class App16Theme {
  static ThemeData get theme {
    final scheme = ColorScheme.fromSeed(
      seedColor: App16Colors.berry,
      brightness: Brightness.light,
    ).copyWith(
      primary: App16Colors.berry,
      onPrimary: Colors.white,
      surface: App16Colors.surface,
      onSurface: App16Colors.ink,
      error: App16Colors.errorInk,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: App16Colors.appBg,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: App16Colors.berry,
        selectionColor: App16Colors.pink,
        selectionHandleColor: App16Colors.berry,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: App16Colors.ink),
        bodySmall: TextStyle(color: App16Colors.muted),
      ),
    );
  }
}

Color app16Color(String? hex, Color fallback) {
  if (hex == null) {
    return fallback;
  }
  final value = hex.replaceFirst('#', '');
  if (value.length != 6 && value.length != 8) {
    return fallback;
  }
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) {
    return fallback;
  }
  return Color(value.length == 6 ? 0xFF000000 | parsed : parsed);
}
