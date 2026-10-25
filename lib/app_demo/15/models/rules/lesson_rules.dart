import 'package:flutter_x_widgets/app_demo/15/models/run_state.dart';

abstract final class LessonRules {
  static bool isUnlocked(String lessonId, Map<String, bool> completedLessons) {
    return switch (lessonId) {
      'coffee' => true,
      'directions' => completedLessons['coffee'] ?? false,
      'challenge' => completedLessons['directions'] ?? false,
      _ => false,
    };
  }

  static String? currentLessonId(Map<String, bool> completedLessons) {
    if (!(completedLessons['coffee'] ?? false)) return 'coffee';
    if (!(completedLessons['directions'] ?? false)) return 'directions';
    if (!(completedLessons['challenge'] ?? false)) return 'challenge';
    return null;
  }

  static RunMode normalizeMode({required bool completed, required RunMode requested}) {
    if (completed) return RunMode.review;
    return RunMode.lesson;
  }

  static String pauseKey(String lessonId, RunMode mode) => '$lessonId:${mode.name}';
}
