abstract final class StudyRules {
  static DateTime localDay(DateTime value) => DateTime(value.year, value.month, value.day, 12);

  static DateTime shiftDays(DateTime value, int days) {
    final day = localDay(value);
    return DateTime(day.year, day.month, day.day - days, 12);
  }

  static String dayKey(DateTime value) {
    final day = localDay(value);
    return '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }

  static int computeStreak(Set<String> dates, DateTime now) {
    if (dates.isEmpty) return 0;
    var cursor = dates.contains(dayKey(now)) ? 0 : 1;
    var count = 0;
    while (dates.contains(dayKey(shiftDays(now, cursor)))) {
      count++;
      cursor++;
    }
    return count;
  }

  static Set<String> withToday(Set<String> dates, DateTime now) {
    return {...dates, dayKey(now)};
  }

  static Set<String> previousDays(DateTime now, int count) {
    return {for (var index = 1; index <= count; index++) dayKey(shiftDays(now, index))};
  }
}
