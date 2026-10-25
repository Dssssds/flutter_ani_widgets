import 'dart:convert';

import 'package:flutter_x_widgets/app_demo/15/data/demo_state.dart';
import 'package:flutter_x_widgets/app_demo/15/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/15/models/app_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/lesson_result.dart';
import 'package:flutter_x_widgets/app_demo/15/models/review_topic.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/daily_goal_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/lesson_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/study_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/run_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/preferences_service.dart';

class PipLoadResult {
  final AppState state;
  final String? warning;

  const PipLoadResult({required this.state, this.warning});
}

class PipRepository {
  static const storageKey = 'party_box.demo15.pip_learning_v2';
  static const schemaVersion = 2;

  final PreferencesService _preferences;

  PipRepository({PreferencesService? preferencesService}) : _preferences = preferencesService ?? const SharedPreferencesService();

  Future<PipLoadResult> load(DateTime now) async {
    try {
      final raw = await _preferences.getString(storageKey);
      if (raw == null) {
        return PipLoadResult(state: createDemoState(now));
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> || decoded['schema'] != schemaVersion || decoded['state'] is! Map<String, dynamic>) {
        throw const FormatException('Unsupported learning state');
      }

      return PipLoadResult(state: _decodeState(decoded['state'] as Map<String, dynamic>, now));
    } catch (_) {
      return PipLoadResult(state: createDemoState(now), warning: '无法读取学习进度，已使用演示数据。');
    }
  }

  Future<bool> save(AppState state) async {
    try {
      return await _preferences.setString(storageKey, jsonEncode({'schema': schemaVersion, 'state': _encodeState(state)}));
    } catch (_) {
      return false;
    }
  }

  AppState _decodeState(Map<String, dynamic> raw, DateTime now) {
    final today = StudyRules.dayKey(now);
    final dailyGoal = _validDailyGoal(_int(raw['dailyGoal'], 10));
    final crossDay = _string(raw['dailyDate'], today) != today;
    final dailySeconds = crossDay ? 0 : DailyGoalRules.clampSeconds(_int(raw['dailySeconds'], 0), dailyGoal);
    final studyDates = _decodeStudyDates(raw['studyDates']);
    final completedLessons = _decodeCompletedLessons(raw['completedLessons']);
    final reviewMastered = _decodeReviewMastered(raw['reviewMastered']);
    final run = _decodeRun(raw['run']);
    final pausedRuns = _decodePausedRuns(raw['pausedRuns']);
    final lastResult = _decodeResult(raw['lastResult']);

    return AppState(
      xp: _int(raw['xp'], 0, min: 0),
      lives: _int(raw['lives'], 0, min: 0, max: 99),
      streak: StudyRules.computeStreak(studyDates, now),
      studyDates: studyDates,
      dailyGoal: dailyGoal,
      dailySeconds: dailySeconds,
      dailyDate: today,
      completedLessons: completedLessons,
      reviewMastered: reviewMastered,
      run: run,
      pausedRuns: pausedRuns,
      lastResult: lastResult,
      soundOn: _bool(raw['soundOn'], false),
    );
  }

  Map<String, dynamic> _encodeState(AppState state) {
    final dates = state.studyDates.toList()..sort();
    return {
      'xp': state.xp,
      'lives': state.lives,
      'streak': state.streak,
      'studyDates': dates,
      'dailyGoal': state.dailyGoal,
      'dailySeconds': state.dailySeconds,
      'dailyDate': state.dailyDate,
      'completedLessons': state.completedLessons,
      'reviewMastered': state.reviewMastered,
      'run': state.run == null ? null : _encodeRun(state.run!),
      'pausedRuns': {for (final entry in state.pausedRuns.entries) entry.key: _encodeRun(entry.value)},
      'lastResult': state.lastResult == null ? null : _encodeResult(state.lastResult!),
      'soundOn': state.soundOn,
    };
  }

  Set<String> _decodeStudyDates(Object? value) {
    if (value is! List) return <String>{};
    final dates = <String>{};
    for (final item in value) {
      if (item is String && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(item)) {
        dates.add(item);
      }
    }
    return dates;
  }

  Map<String, bool> _decodeCompletedLessons(Object? value) {
    final raw = _map(value);
    return {
      'greeting': true,
      'menu': true,
      'coffee': _bool(raw?['coffee'], false),
      'directions': _bool(raw?['directions'], false),
      'challenge': _bool(raw?['challenge'], false),
    };
  }

  Map<String, List<String>> _decodeReviewMastered(Object? value) {
    final raw = _map(value);
    return {for (final topic in PipSeed.reviewTopics) topic.id: _decodeMasteredTerms(raw?[topic.id], topic)};
  }

  List<String> _decodeMasteredTerms(Object? value, ReviewTopic topic) {
    if (value is! List) return const <String>[];
    final valid = topic.terms.map((term) => term.en).toSet();
    final result = <String>[];
    for (final item in value) {
      if (item is String && valid.contains(item) && !result.contains(item)) {
        result.add(item);
      }
    }
    return result;
  }

  RunState? _decodeRun(Object? value) {
    final raw = _map(value);
    if (raw == null) return null;

    final lessonId = _string(raw['lessonId'], '');
    final lesson = PipSeed.lessonsById[lessonId];
    if (lesson == null) return null;

    final total = lesson.questions.length;
    final answered = _int(raw['answered'], 0, min: 0, max: total);
    final correctFirstTry = _int(raw['correctFirstTry'], 0, min: 0, max: answered);

    return RunState(
      lessonId: lessonId,
      mode: _enumByName(RunMode.values, _string(raw['mode'], ''), RunMode.lesson),
      qIndex: _int(raw['qIndex'], 0, min: 0, max: total - 1),
      answered: answered,
      correctFirstTry: correctFirstTry,
      selection: _string(raw['selection'], ''),
      feedback: _enumByName(AnswerFeedback.values, _string(raw['feedback'], ''), AnswerFeedback.none),
      firstTry: _bool(raw['firstTry'], true),
      streak: _int(raw['streak'], 0, min: 0),
    );
  }

  Map<String, RunState> _decodePausedRuns(Object? value) {
    final raw = _map(value);
    if (raw == null) return const <String, RunState>{};
    final result = <String, RunState>{};
    for (final entry in raw.entries) {
      final run = _decodeRun(entry.value);
      if (run != null) {
        result[LessonRules.pauseKey(run.lessonId, run.mode)] = run;
      }
    }
    return result;
  }

  LessonResult? _decodeResult(Object? value) {
    final raw = _map(value);
    if (raw == null) return null;

    final lessonId = _string(raw['lessonId'], '');
    final lesson = PipSeed.lessonsById[lessonId];
    if (lesson == null) return null;

    return LessonResult(
      lessonId: lessonId,
      title: _string(raw['title'], lesson.title),
      eyebrow: _string(raw['eyebrow'], lesson.eyebrow),
      xpAwarded: _int(raw['xpAwarded'], 0, min: 0),
      accuracy: _int(raw['accuracy'], 0, min: 0, max: 100),
      correctFirstTry: _int(raw['correctFirstTry'], 0, min: 0, max: lesson.questions.length),
      total: _int(raw['total'], lesson.questions.length, min: 1, max: lesson.questions.length),
      mode: _enumByName(RunMode.values, _string(raw['mode'], ''), RunMode.lesson),
      completedNow: _bool(raw['completedNow'], false),
      streak: _int(raw['streak'], 0, min: 0),
      dailySeconds: _int(raw['dailySeconds'], 0, min: 0),
      dailyGoal: _validDailyGoal(_int(raw['dailyGoal'], 10)),
      allDone: _bool(raw['allDone'], false),
      demo: _bool(raw['demo'], false),
    );
  }

  Map<String, dynamic> _encodeRun(RunState run) {
    return {
      'lessonId': run.lessonId,
      'mode': run.mode.name,
      'qIndex': run.qIndex,
      'answered': run.answered,
      'correctFirstTry': run.correctFirstTry,
      'selection': run.selection,
      'feedback': run.feedback.name,
      'firstTry': run.firstTry,
      'streak': run.streak,
    };
  }

  Map<String, dynamic> _encodeResult(LessonResult result) {
    return {
      'lessonId': result.lessonId,
      'title': result.title,
      'eyebrow': result.eyebrow,
      'xpAwarded': result.xpAwarded,
      'accuracy': result.accuracy,
      'correctFirstTry': result.correctFirstTry,
      'total': result.total,
      'mode': result.mode.name,
      'completedNow': result.completedNow,
      'streak': result.streak,
      'dailySeconds': result.dailySeconds,
      'dailyGoal': result.dailyGoal,
      'allDone': result.allDone,
      'demo': result.demo,
    };
  }

  int _validDailyGoal(int value) => PipSeed.dailyGoalOptions.contains(value) ? value : 10;

  Map<String, dynamic>? _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  int _int(Object? value, int fallback, {int? min, int? max}) {
    final parsed =
        value is int
            ? value
            : value is num
            ? value.toInt()
            : fallback;
    final lowerBounded =
        min == null
            ? parsed
            : parsed < min
            ? min
            : parsed;
    return max == null
        ? lowerBounded
        : lowerBounded > max
        ? max
        : lowerBounded;
  }

  bool _bool(Object? value, bool fallback) => value is bool ? value : fallback;

  String _string(Object? value, String fallback) => value is String ? value : fallback;

  T _enumByName<T extends Enum>(List<T> values, String name, T fallback) {
    return values.firstWhere((value) => value.name == name, orElse: () => fallback);
  }
}
