/// Shared, reversible menu timelines. Progress always uses the full controller
/// range, so fast playback preserves the same stagger and keyframes.
abstract final class MenuMotion {
  static const int enterDurationMs = 1480;
  static const int rowDurationMs = 1000;
  static const int rowDelayMs = 120;
  static const double overshoot = 8;

  /// Local progress for one of the five rows on the entrance timeline.
  static double enterProgress(double progress, int index) {
    assert(index >= 0 && index < 5);
    final elapsed = _clamp(progress) * enterDurationMs;
    return _clamp((elapsed - index * rowDelayMs) / rowDurationMs);
  }

  /// [distance] is the caller's distance from the row's target to below the
  /// viewport. Exactly one overshoot occurs at 75% of the row's local timeline.
  static double enterOffset(double progress, int index, double distance, {bool reduceMotion = false}) {
    assert(distance >= 0);
    if (reduceMotion) return 0;
    final local = enterProgress(progress, index);
    if (local <= 0) return distance;
    if (local >= 1) return 0;
    if (local <= 0.75) {
      final t = local / 0.75;
      final eased = t * t * (3 - 2 * t);
      return distance + (-overshoot - distance) * eased;
    }
    return -overshoot * (1 - _easeOutCubic((local - 0.75) / 0.25));
  }

  /// Normal entrance keeps color bands opaque; reduced motion fades uniformly.
  static double enterOpacity(double progress, {bool reduceMotion = false}) => reduceMotion ? _clamp(progress) : 1;

  /// Absolute first-to-second-page progress; reversing a gesture retraces the
  /// same curve rather than switching to a discontinuous reverse timeline.
  static double rowProgress(double progress, int index) {
    assert(index >= 0 && index < 5);
    final normalized = _clamp(progress);
    if (normalized == 0 || normalized == 1) return normalized;
    return _clamp(normalized * 1.6 - index * 0.15);
  }

  /// Matching outgoing/incoming bands remain exactly [width] apart.
  /// Reduced motion switches pages in place without large translations.
  static double pageOffset(double progress, int index, double width, {required bool incoming, bool reduceMotion = false}) {
    assert(width >= 0);
    if (reduceMotion) return 0;
    final local = rowProgress(progress, index);
    return width * ((incoming ? 1 : 0) - local);
  }

  static double _clamp(double value) => value.clamp(0.0, 1.0).toDouble();

  static double _easeOutCubic(double value) {
    final remaining = 1 - value;
    return 1 - remaining * remaining * remaining;
  }
}
