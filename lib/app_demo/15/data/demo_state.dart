import 'package:flutter_x_widgets/app_demo/15/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/15/models/app_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/lesson_result.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/study_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/run_state.dart';

AppState createDemoState(DateTime now) {
  final studyDates = StudyRules.previousDays(now, 7);

  return AppState(
    xp: 1284,
    lives: 4,
    streak: StudyRules.computeStreak(studyDates, now),
    studyDates: studyDates,
    dailyGoal: 10,
    dailySeconds: 360,
    dailyDate: StudyRules.dayKey(now),
    completedLessons: const {'greeting': true, 'menu': true, 'coffee': false, 'directions': false, 'challenge': false},
    reviewMastered: {for (final topic in PipSeed.reviewTopics) topic.id: const <String>[]},
    run: null,
    pausedRuns: const {},
    lastResult: null,
    soundOn: false,
  );
}

LessonResult createDemoResult(AppState state) {
  return LessonResult(
    lessonId: 'coffee',
    title: '点杯咖啡',
    eyebrow: '第 3 课',
    xpAwarded: 24,
    accuracy: 100,
    correctFirstTry: 5,
    total: 5,
    mode: RunMode.lesson,
    completedNow: true,
    streak: state.streak,
    dailySeconds: state.dailySeconds,
    dailyGoal: state.dailyGoal,
    allDone: false,
    demo: true,
  );
}
