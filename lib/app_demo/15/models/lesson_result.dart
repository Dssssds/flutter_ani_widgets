import 'package:flutter_x_widgets/app_demo/15/models/run_state.dart';

class LessonResult {
  final String lessonId;
  final String title;
  final String eyebrow;
  final int xpAwarded;
  final int accuracy;
  final int correctFirstTry;
  final int total;
  final RunMode mode;
  final bool completedNow;
  final int streak;
  final int dailySeconds;
  final int dailyGoal;
  final bool allDone;
  final bool demo;

  const LessonResult({
    required this.lessonId,
    required this.title,
    required this.eyebrow,
    required this.xpAwarded,
    required this.accuracy,
    required this.correctFirstTry,
    required this.total,
    required this.mode,
    required this.completedNow,
    required this.streak,
    required this.dailySeconds,
    required this.dailyGoal,
    required this.allDone,
    this.demo = false,
  });
}
