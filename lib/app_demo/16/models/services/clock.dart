abstract final class AppClock {
  static const bool useRealDate = bool.fromEnvironment('USE_REAL_TODAY');

  static DateTime get today =>
      useRealDate ? DateTime.now() : DateTime(2026, 10, 4);
}
