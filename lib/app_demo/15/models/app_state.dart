import 'package:flutter_x_widgets/app_demo/15/models/lesson_result.dart';
import 'package:flutter_x_widgets/app_demo/15/models/run_state.dart';

const Object _notProvided = Object();

class AppState {
  final int xp;
  final int lives;
  final int streak;
  final Set<String> studyDates;
  final int dailyGoal;
  final int dailySeconds;
  final String dailyDate;
  final Map<String, bool> completedLessons;
  final Map<String, List<String>> reviewMastered;
  final RunState? run;
  final Map<String, RunState> pausedRuns;
  final LessonResult? lastResult;
  final bool soundOn;

  AppState({
    required this.xp,
    required this.lives,
    required this.streak,
    required Set<String> studyDates,
    required this.dailyGoal,
    required this.dailySeconds,
    required this.dailyDate,
    required Map<String, bool> completedLessons,
    required Map<String, List<String>> reviewMastered,
    required this.run,
    required Map<String, RunState> pausedRuns,
    required this.lastResult,
    required this.soundOn,
  }) : studyDates = Set<String>.unmodifiable(studyDates),
       completedLessons = Map<String, bool>.unmodifiable(completedLessons),
       reviewMastered = Map<String, List<String>>.unmodifiable({
         for (final entry in reviewMastered.entries) entry.key: List<String>.unmodifiable(entry.value),
       }),
       pausedRuns = Map<String, RunState>.unmodifiable(pausedRuns);

  AppState copyWith({
    int? xp,
    int? lives,
    int? streak,
    Set<String>? studyDates,
    int? dailyGoal,
    int? dailySeconds,
    String? dailyDate,
    Map<String, bool>? completedLessons,
    Map<String, List<String>>? reviewMastered,
    Object? run = _notProvided,
    Map<String, RunState>? pausedRuns,
    Object? lastResult = _notProvided,
    bool? soundOn,
  }) {
    return AppState(
      xp: xp ?? this.xp,
      lives: lives ?? this.lives,
      streak: streak ?? this.streak,
      studyDates: studyDates ?? this.studyDates,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      dailySeconds: dailySeconds ?? this.dailySeconds,
      dailyDate: dailyDate ?? this.dailyDate,
      completedLessons: completedLessons ?? this.completedLessons,
      reviewMastered: reviewMastered ?? this.reviewMastered,
      run: identical(run, _notProvided) ? this.run : run as RunState?,
      pausedRuns: pausedRuns ?? this.pausedRuns,
      lastResult: identical(lastResult, _notProvided) ? this.lastResult : lastResult as LessonResult?,
      soundOn: soundOn ?? this.soundOn,
    );
  }
}
