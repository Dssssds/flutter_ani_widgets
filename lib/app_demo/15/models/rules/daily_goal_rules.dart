import 'dart:math' as math;

abstract final class DailyGoalRules {
  static const secondsPerCorrectAnswer = 30;

  static int displayMinutes(int dailySeconds, int dailyGoal) {
    return math.min(dailyGoal, dailySeconds ~/ 60);
  }

  static int progressPercent(int dailySeconds, int dailyGoal) {
    if (dailyGoal <= 0) return 0;
    return math.min(100, (dailySeconds / (dailyGoal * 60) * 100).round());
  }

  static int addCorrectAnswer(int dailySeconds, int dailyGoal) {
    return math.min(dailyGoal * 60, dailySeconds + secondsPerCorrectAnswer);
  }

  static int clampSeconds(int dailySeconds, int dailyGoal) {
    return dailySeconds.clamp(0, dailyGoal * 60);
  }

  static int remainingMinutes(int dailySeconds, int dailyGoal) {
    return math.max(0, dailyGoal - displayMinutes(dailySeconds, dailyGoal));
  }
}
