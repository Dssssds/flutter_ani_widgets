import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/15/data/demo_state.dart';
import 'package:flutter_x_widgets/app_demo/15/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/15/models/lesson_result.dart';
import 'package:flutter_x_widgets/app_demo/15/models/repositories/pip_repository.dart';
import 'package:flutter_x_widgets/app_demo/15/models/root_tab.dart';
import 'package:flutter_x_widgets/app_demo/15/models/run_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/view_models/pip_controller.dart';

import 'support/fakes.dart';

LessonResult? answerLesson(PipController controller, {bool missFirst = false}) {
  LessonResult? result;
  final lesson = PipSeed.lessonsById[controller.run!.lessonId]!;
  for (var index = 0; index < lesson.questions.length; index++) {
    final question = controller.currentQuestion!;
    if (missFirst && index == 0) {
      controller.selectAnswer(question.words.firstWhere((word) => word != question.answer));
      expect(controller.checkAnswer(), AnswerCheck.wrong);
      expect(controller.retryAnswer(), isTrue);
    }
    controller.selectAnswer(question.answer);
    expect(controller.checkAnswer(), AnswerCheck.correct);
    result = controller.advanceQuestion();
  }
  return result;
}

void main() {
  final now = DateTime(2026, 10, 25, 9, 30);

  late FakePreferencesService preferences;
  late PipRepository repository;

  setUp(() {
    preferences = FakePreferencesService();
    repository = PipRepository(preferencesService: preferences);
  });

  PipController createController() {
    final controller = PipController(repository: repository, clock: FixedClock(now));
    addTearDown(controller.dispose);
    return controller;
  }

  test('initializes from the repository and exposes the demo state', () async {
    final controller = createController();

    expect(controller.initialized, isFalse);
    await controller.initialize();

    expect(controller.initialized, isTrue);
    expect(controller.state.xp, 1284);
    expect(controller.state.streak, 7);
    expect(controller.activeRunFor('coffee'), isNull);
    expect(controller.takeLoadWarning(), isNull);
  });

  test('surfaces a load warning only once', () async {
    preferences.values[PipRepository.storageKey] = '{broken';
    final controller = createController();

    await controller.initialize();

    expect(controller.takeLoadWarning(), '无法读取学习进度，已使用演示数据。');
    expect(controller.takeLoadWarning(), isNull);
    expect(controller.state.xp, 1284);
  });

  test('switches tabs', () async {
    final controller = createController();
    await controller.initialize();

    expect(controller.activeTab, RootTab.path);
    controller.setTab(RootTab.review);
    expect(controller.activeTab, RootTab.review);
  });

  test('persists the daily goal and clamps daily seconds', () async {
    final controller = createController();
    await controller.initialize();

    await controller.setDailyGoal(5);
    await controller.flushSaves();

    expect(controller.state.dailyGoal, 5);
    expect(controller.state.dailySeconds, 300);
    final loaded = (await repository.load(now)).state;
    expect(loaded.dailyGoal, 5);
    expect(loaded.dailySeconds, 300);
  });

  test('ignores unsupported daily goals', () async {
    final controller = createController();
    await controller.initialize();

    await controller.setDailyGoal(7);

    expect(controller.state.dailyGoal, 10);
  });

  test('persists sound and mastered review terms', () async {
    final controller = createController();
    await controller.initialize();

    await controller.setSoundOn(true);
    await controller.markReviewMastered('coffee', 'milk');
    await controller.markReviewMastered('coffee', 'milk');
    await controller.markReviewMastered('coffee', 'unknown');
    await controller.markReviewMastered('unknown', 'milk');
    await controller.flushSaves();

    expect(controller.state.soundOn, isTrue);
    expect(controller.state.reviewMastered['coffee'], ['milk']);

    final loaded = (await repository.load(now)).state;
    expect(loaded.soundOn, isTrue);
    expect(loaded.reviewMastered['coffee'], ['milk']);
  });

  test('finds the active run before paused runs', () async {
    final state = createDemoState(now).copyWith(
      run: const RunState(lessonId: 'coffee', mode: RunMode.lesson, qIndex: 1, answered: 1),
      pausedRuns: const {
        'coffee:lesson': RunState(lessonId: 'coffee', mode: RunMode.lesson, qIndex: 2, answered: 2),
        'directions:review': RunState(lessonId: 'directions', mode: RunMode.review, qIndex: 3, answered: 3),
      },
    );
    await repository.save(state);
    final controller = createController();

    await controller.initialize();

    expect(controller.activeRunFor('coffee')!.qIndex, 1);
    expect(controller.activeRunFor('directions')!.mode, RunMode.review);
    expect(controller.activeRunFor('challenge'), isNull);
  });

  test('completes the three lesson chain and awards XP only for new lessons', () async {
    final controller = createController();
    await controller.initialize();

    expect(controller.startLesson('coffee', RunMode.lesson), StartLessonStatus.started);
    final coffee = answerLesson(controller)!;
    expect(coffee.accuracy, 100);
    expect(coffee.xpAwarded, 24);
    expect(coffee.allDone, isFalse);
    expect(controller.state.xp, 1308);
    expect(controller.state.streak, 8);
    expect(controller.state.dailySeconds, 510);
    expect(controller.currentLessonId, 'directions');

    expect(controller.startLesson('directions', RunMode.lesson), StartLessonStatus.started);
    final directions = answerLesson(controller)!;
    expect(directions.accuracy, 100);
    expect(directions.xpAwarded, 24);
    expect(controller.state.xp, 1332);
    expect(controller.currentLessonId, 'challenge');

    expect(controller.startLesson('challenge', RunMode.lesson), StartLessonStatus.started);
    final challenge = answerLesson(controller)!;
    expect(challenge.accuracy, 100);
    expect(challenge.xpAwarded, 50);
    expect(challenge.allDone, isTrue);
    expect(controller.state.xp, 1382);
    expect(controller.allDone, isTrue);

    expect(controller.startLesson('coffee', RunMode.lesson), StartLessonStatus.started);
    expect(controller.run!.mode, RunMode.review);
    final review = answerLesson(controller)!;
    expect(review.xpAwarded, 0);
    expect(review.completedNow, isFalse);
    expect(controller.state.xp, 1382);
  });

  test('retry keeps the original accuracy and refills lives only after zero', () async {
    final controller = createController();
    await controller.initialize();
    controller.startLesson('coffee', RunMode.lesson);

    controller.selectAnswer('tea');
    expect(controller.checkAnswer(), AnswerCheck.wrong);
    expect(controller.state.lives, 3);
    expect(controller.retryAnswer(), isTrue);
    expect(controller.state.lives, 3);

    final result = answerLesson(controller)!;
    expect(result.accuracy, 80);

    final second = PipController(repository: PipRepository(preferencesService: FakePreferencesService()), clock: FixedClock(now));
    addTearDown(second.dispose);
    await second.initialize();
    second.startLesson('coffee', RunMode.lesson);
    for (var attempt = 0; attempt < 4; attempt++) {
      second.selectAnswer('tea');
      expect(second.checkAnswer(), AnswerCheck.wrong);
      if (attempt < 3) expect(second.retryAnswer(), isTrue);
    }
    expect(second.state.lives, 0);
    expect(second.run!.qIndex, 0);
    expect(second.retryAnswer(), isTrue);
    expect(second.state.lives, 4);
    expect(second.run!.qIndex, 0);
    expect(second.run!.selection, isEmpty);
  });

  test('switching lessons pauses the current run with its answer state', () async {
    final state = createDemoState(
      now,
    ).copyWith(completedLessons: const {'greeting': true, 'menu': true, 'coffee': true, 'directions': false, 'challenge': false});
    await repository.save(state);
    final controller = createController();
    await controller.initialize();

    controller.startLesson('directions', RunMode.lesson);
    controller.selectAnswer('station');
    expect(controller.checkAnswer(), AnswerCheck.correct);

    controller.startLesson('coffee', RunMode.lesson);
    expect(controller.run!.lessonId, 'coffee');
    final paused = controller.activeRunFor('directions')!;
    expect(paused.qIndex, 0);
    expect(paused.selection, 'station');
    expect(paused.feedback, AnswerFeedback.correct);

    controller.startLesson('directions', RunMode.lesson);
    expect(controller.run!.lessonId, 'directions');
    expect(controller.run!.selection, 'station');
    expect(controller.run!.feedback, AnswerFeedback.correct);
  });
}
