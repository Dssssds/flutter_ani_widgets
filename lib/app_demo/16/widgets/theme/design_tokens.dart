import 'package:flutter/widgets.dart';

abstract final class App16Design {
  static const frameWidth = 390.0;
  static const frameHeight = 844.0;
  static const narrowBreakpoint = 390.0;
  static const shortBreakpoint = 800.0;

  static const pagePadding = 20.0;
  static const pagePaddingNarrow = 16.0;
  static const paperHeight = 496.0;
  static const headerHeight = 60.0;
  static const headerHeightShort = 56.0;
  static const dateHeight = 72.0;
  static const dateHeightShort = 64.0;
  static const navHeight = 64.0;
  static const navHeightShort = 58.0;
  static const trayHeight = 89.0;
  static const trayHeightShort = 80.0;
}

class App16Metrics {
  const App16Metrics(this.size, {this.bottomInset = 0});

  final Size size;
  final double bottomInset;

  factory App16Metrics.of(BuildContext context) => App16Metrics(
    MediaQuery.sizeOf(context),
    bottomInset: MediaQuery.paddingOf(context).bottom,
  );

  bool get narrow => size.width < App16Design.narrowBreakpoint;
  bool get short => size.height <= App16Design.shortBreakpoint;

  double get pagePadding =>
      narrow ? App16Design.pagePaddingNarrow : App16Design.pagePadding;
  double get headerHeight =>
      short ? App16Design.headerHeightShort : App16Design.headerHeight;
  double get dateHeight =>
      short ? App16Design.dateHeightShort : App16Design.dateHeight;
  double get navHeight =>
      short ? App16Design.navHeightShort : App16Design.navHeight;
  double get navTotalHeight => navHeight + bottomInset;
  double get trayHeight =>
      short ? App16Design.trayHeightShort : App16Design.trayHeight;
  double get paperWidth => size.width - pagePadding * 2;
  double get paperHeight => App16Design.paperHeight;
}
