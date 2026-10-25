import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/15/data/demo_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/lesson_result.dart';
import 'package:flutter_x_widgets/app_demo/15/models/repositories/pip_repository.dart';
import 'package:flutter_x_widgets/app_demo/15/models/run_state.dart';

import 'support/fakes.dart';

void main() {
  final now = DateTime(2026, 10, 25, 9, 30);

  late FakePreferencesService preferences;
  late PipRepository repository;

  setUp(() {
    preferences = FakePreferencesService();
    repository = PipRepository(preferencesService: preferences);
  });

  test('loads the demo state when storage is empty', () async {
    final result = await repository.load(now);

    expect(result.warning, isNull);
    expect(result.state.xp, 1284);
    expect(result.state.lives, 4);
    expect(result.state.streak, 7);
    expect(result.state.dailyGoal, 10);
    expect(result.state.dailySeconds, 360);
    expect(result.state.dailyDate, '2026-10-25');
    expect(result.state.completedLessons['greeting'], isTrue);
    expect(result.state.completedLessons['menu'], isTrue);
    expect(result.state.completedLessons['coffee'], isFalse);
    expect(result.state.reviewMastered.keys, hasLength(4));
    expect(result.state.soundOn, isFalse);
  });

  test('round-trips the full state through storage', () async {
    final state = createDemoState(now).copyWith(
      xp: 1400,
      lives: 3,
      dailySeconds: 420,
      completedLessons: const {'greeting': true, 'menu': true, 'coffee': true, 'directions': false, 'challenge': false},
      pausedRuns: const {
        'coffee:review': RunState(lessonId: 'coffee', mode: RunMode.review, qIndex: 2, answered: 2, correctFirstTry: 1, selection: 'milk'),
      },
      lastResult: const LessonResult(
        lessonId: 'coffee',
        title: '点杯咖啡',
        eyebrow: '第 3 课',
        xpAwarded: 24,
        accuracy: 80,
        correctFirstTry: 4,
        total: 5,
        mode: RunMode.lesson,
        completedNow: true,
        streak: 7,
        dailySeconds: 420,
        dailyGoal: 10,
        allDone: false,
      ),
      soundOn: true,
    );

    expect(await repository.save(state), isTrue);
    final loaded = (await repository.load(now)).state;

    expect(loaded.xp, 1400);
    expect(loaded.lives, 3);
    expect(loaded.streak, 7);
    expect(loaded.dailySeconds, 420);
    expect(loaded.completedLessons['coffee'], isTrue);
    expect(loaded.pausedRuns.keys, ['coffee:review']);
    expect(loaded.pausedRuns['coffee:review']!.answered, 2);
    expect(loaded.lastResult!.accuracy, 80);
    expect(loaded.lastResult!.mode, RunMode.lesson);
    expect(loaded.soundOn, isTrue);
  });

  test('resets daily seconds when the stored day is not today', () async {
    final state = createDemoState(now).copyWith(dailySeconds: 540, dailyDate: '2026-10-24');
    await repository.save(state);

    final loaded = (await repository.load(now)).state;

    expect(loaded.dailySeconds, 0);
    expect(loaded.dailyDate, '2026-10-25');
    expect(loaded.dailyGoal, 10);
  });

  test('falls back to demo data on malformed storage', () async {
    preferences.values[PipRepository.storageKey] = '{not-json';

    final result = await repository.load(now);

    expect(result.warning, '无法读取学习进度，已使用演示数据。');
    expect(result.state.xp, 1284);
    expect(result.state.dailySeconds, 360);
  });

  test('falls back to demo data for an unsupported schema', () async {
    preferences.values[PipRepository.storageKey] = jsonEncode({'schema': 1, 'state': {}});

    final result = await repository.load(now);

    expect(result.warning, isNotNull);
    expect(result.state.xp, 1284);
  });

  test('falls back to demo data when reading storage throws', () async {
    preferences.failReads = true;

    final result = await repository.load(now);

    expect(result.warning, isNotNull);
    expect(result.state.xp, 1284);
  });

  test('clamps and filters partially invalid state instead of discarding it', () async {
    preferences.values[PipRepository.storageKey] = jsonEncode({
      'schema': PipRepository.schemaVersion,
      'state': {
        'xp': -5,
        'lives': 500,
        'streak': 99,
        'studyDates': ['2026-10-24', '2026-10-25', 'not-a-date'],
        'dailyGoal': 7,
        'dailySeconds': 9999,
        'dailyDate': '2026-10-25',
        'completedLessons': {'coffee': true, 'directions': 'yes'},
        'reviewMastered': {
          'coffee': ['milk', 'milk', 'unknown'],
          'directions': 'nope',
        },
        'run': {'lessonId': 'unknown'},
        'pausedRuns': {
          'first': {'lessonId': 'coffee', 'mode': 'lesson', 'qIndex': 99, 'answered': 99, 'correctFirstTry': 99, 'feedback': 'odd'},
          'second': {'lessonId': 'directions', 'mode': 'review', 'qIndex': -3},
          'third': {'lessonId': 'unknown'},
        },
        'lastResult': {'lessonId': 'unknown'},
        'soundOn': 'yes',
      },
    });

    final result = await repository.load(now);
    final state = result.state;

    expect(result.warning, isNull);
    expect(state.xp, 0);
    expect(state.lives, 99);
    expect(state.streak, 2);
    expect(state.dailyGoal, 10);
    expect(state.dailySeconds, 600);
    expect(state.completedLessons['greeting'], isTrue);
    expect(state.completedLessons['menu'], isTrue);
    expect(state.completedLessons['coffee'], isTrue);
    expect(state.completedLessons['directions'], isFalse);
    expect(state.reviewMastered.keys, hasLength(4));
    expect(state.reviewMastered['coffee'], ['milk']);
    expect(state.reviewMastered['directions'], isEmpty);
    expect(state.run, isNull);
    expect(state.lastResult, isNull);
    expect(state.soundOn, isFalse);
    expect(state.pausedRuns.keys, {'coffee:lesson', 'directions:review'});
    expect(state.pausedRuns['coffee:lesson']!.qIndex, 4);
    expect(state.pausedRuns['coffee:lesson']!.answered, 5);
    expect(state.pausedRuns['coffee:lesson']!.correctFirstTry, 5);
    expect(state.pausedRuns['directions:review']!.qIndex, 0);
    expect(state.pausedRuns['directions:review']!.answered, 0);
  });

  test('reports a failed write without throwing', () async {
    preferences.failWrites = true;

    expect(await repository.save(createDemoState(now)), isFalse);
  });

  test('uses the case storage namespace and schema version', () {
    expect(PipRepository.storageKey, 'party_box.demo15.pip_learning_v2');
    expect(PipRepository.schemaVersion, 2);
  });
}
