import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/15/app_15.dart';
import 'package:flutter_x_widgets/app_demo/15/data/asset_manifest.dart';
import 'package:flutter_x_widgets/app_demo/15/models/app_launch_config.dart';
import 'package:flutter_x_widgets/app_demo/15/models/lesson.dart';
import 'package:flutter_x_widgets/app_demo/15/models/repositories/pip_repository.dart';
import 'package:flutter_x_widgets/app_demo/15/models/run_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/view_models/pip_controller.dart';
import 'package:flutter_x_widgets/app_demo/15/screens/quiz_screen.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';

import 'support/fakes.dart';

class GatedPipAudio extends FakePipAudio {
  final gate = Completer<bool>();

  @override
  Future<bool> playAsset(String asset) {
    playedAssets.add(asset);
    return gate.future;
  }
}

void main() {
  setUpAll(loadNunito);

  final now = DateTime(2026, 10, 25, 9, 30);

  Future<FakePreferencesService> pumpApp(
    WidgetTester tester, {
    FakePipAudio? audio,
    bool reduceMotion = false,
    AppLaunchConfig config = const AppLaunchConfig(),
  }) async {
    final preferences = FakePreferencesService();
    final repository = PipRepository(preferencesService: preferences);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    if (reduceMotion) {
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    }
    addTearDown(() {
      tester.view.reset();
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
    });

    await tester.pumpWidget(
      App15(repository: repository, clock: FixedClock(now), audio: audio ?? FakePipAudio(), share: FakePipShare(), config: config),
    );
    await tester.pumpAndSettle();
    return preferences;
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> answerFill(WidgetTester tester, String word) async {
    await tapAndSettle(tester, find.byKey(ValueKey('quiz-word-$word')));
    await tapAndSettle(tester, find.byKey(const ValueKey('quiz-check')));
    await tapAndSettle(tester, find.byKey(const ValueKey('quiz-next')));
  }

  testWidgets('wrong answer costs a life, retry keeps 80% accuracy and awards XP once', (tester) async {
    final audio = FakePipAudio();
    final preferences = await pumpApp(tester, audio: audio);
    final repository = PipRepository(preferencesService: preferences);

    await tapAndSettle(tester, find.byKey(const ValueKey('path-cta')));
    expect(find.byKey(const ValueKey('quiz-screen')), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const ValueKey('quiz-sound-toggle')));
    expect(find.bySemanticsLabel('关闭答题音效'), findsOneWidget);
    expect(audio.playedAssets, contains(PipAssets.chime));

    await tapAndSettle(tester, find.byKey(const ValueKey('quiz-word-tea')));
    expect(find.descendant(of: find.byKey(const ValueKey('quiz-blank')), matching: find.text('tea')), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const ValueKey('quiz-check')));

    expect(find.byKey(const ValueKey('quiz-feedback-wrong')), findsOneWidget);
    expect(find.text('差一点，再试试'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const ValueKey('quiz-lives'))).data, '3');
    expect(find.text('再选一次'), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const ValueKey('quiz-retry')));
    expect(find.descendant(of: find.byKey(const ValueKey('quiz-blank')), matching: find.text('···')), findsOneWidget);
    expect(find.byKey(const ValueKey('quiz-feedback-wrong')), findsNothing);

    await answerFill(tester, 'milk');

    await answerFill(tester, 'to go');
    await answerFill(tester, 'small');

    expect(find.byKey(const ValueKey('quiz-audio-prompt')), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const ValueKey('quiz-option-small')));
    await tapAndSettle(tester, find.byKey(const ValueKey('quiz-check')));
    await tapAndSettle(tester, find.byKey(const ValueKey('quiz-next')));

    await answerFill(tester, 'Thank you');

    expect(find.byKey(const ValueKey('complete-screen')), findsOneWidget);
    expect(find.text('这杯英语，你拿下了！'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const ValueKey('complete-accuracy'))).data, '80%');
    expect(tester.widget<Text>(find.byKey(const ValueKey('complete-reward-xp'))).data, '+24');
    expect(find.text('收下奖励'), findsOneWidget);
    expect(audio.playedAssets.where((asset) => asset == PipAssets.chime).length, greaterThanOrEqualTo(2));

    final saved = (await repository.load(now)).state;
    expect(saved.completedLessons['coffee'], isTrue);
    expect(saved.xp, 1308);
    expect(saved.lives, 3);

    await tapAndSettle(tester, find.byKey(const ValueKey('complete-cta')));
    expect(find.byKey(const ValueKey('path-screen')), findsOneWidget);
    expect(find.text('学习问路'), findsOneWidget);
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('开始：问个方向'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('leaving after one answer preserves the run and resumes on the next question', (tester) async {
    final audio = FakePipAudio();
    await pumpApp(tester, audio: audio);

    await tapAndSettle(tester, find.byKey(const ValueKey('path-cta')));
    await answerFill(tester, 'milk');
    expect(find.text('选词填空 · 2 / 5'), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const ValueKey('quiz-close')));
    expect(find.byKey(const ValueKey('path-screen')), findsOneWidget);
    expect(find.text('继续这一课'), findsOneWidget);
    expect(find.text('已完成 1 / 5 题'), findsOneWidget);
    expect(audio.stopCount, greaterThan(0));

    await tapAndSettle(tester, find.byKey(const ValueKey('path-cta')));
    expect(find.text('选词填空 · 2 / 5'), findsOneWidget);
    expect(find.text('告诉店员，你想带走'), findsOneWidget);
  });

  testWidgets('a correct fill answer flies the chosen word into the blank', (tester) async {
    await pumpApp(tester);
    await tapAndSettle(tester, find.byKey(const ValueKey('path-cta')));
    await tapAndSettle(tester, find.byKey(const ValueKey('quiz-word-milk')));

    await tester.tap(find.byKey(const ValueKey('quiz-check')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    final flying = tester.getTopLeft(find.byKey(const ValueKey('quiz-blank')));

    await tester.pumpAndSettle();
    final settled = tester.getTopLeft(find.byKey(const ValueKey('quiz-blank')));
    expect((flying - settled).distance, greaterThan(20));
    expect(find.byKey(const ValueKey('quiz-feedback-correct')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion skips the word fly', (tester) async {
    await pumpApp(tester, reduceMotion: true);
    await tapAndSettle(tester, find.byKey(const ValueKey('path-cta')));
    await tapAndSettle(tester, find.byKey(const ValueKey('quiz-word-milk')));

    await tester.tap(find.byKey(const ValueKey('quiz-check')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    final immediate = tester.getTopLeft(find.byKey(const ValueKey('quiz-blank')));

    await tester.pumpAndSettle();
    final settled = tester.getTopLeft(find.byKey(const ValueKey('quiz-blank')));
    expect((immediate - settled).distance, lessThan(1));
    expect(find.byKey(const ValueKey('quiz-feedback-correct')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('listening question', () {
    late FakePreferencesService preferences;
    late PipController controller;
    late FakePipAudio audio;
    late PipRepository repository;

    setUp(() async {
      preferences = FakePreferencesService();
      repository = PipRepository(preferencesService: preferences);
      audio = FakePipAudio();
      controller = PipController(repository: repository, clock: FixedClock(now));
      await controller.initialize();
      controller.startLesson('coffee', RunMode.lesson);
      for (var index = 0; index < 3; index++) {
        controller.selectAnswer(controller.currentQuestion!.answer);
        expect(controller.checkAnswer(), AnswerCheck.correct);
        controller.advanceQuestion();
      }
      expect(controller.currentQuestion!.type, QuestionType.listen);
    });

    tearDown(() => controller.dispose());

    Future<void> pumpQuiz(WidgetTester tester, {FakePipAudio? customAudio}) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: App15Theme.theme,
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: Center(
                    child: TextButton(
                      key: const ValueKey('open-quiz'),
                      onPressed:
                          () => Navigator.of(
                            context,
                          ).push(MaterialPageRoute<void>(builder: (_) => QuizScreen(controller: controller, audio: customAudio ?? audio))),
                      child: const Text('open'),
                    ),
                  ),
                ),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('open-quiz')));
      await tester.pumpAndSettle();
    }

    testWidgets('plays the local WAV and keeps the selected option readable when disabled', (tester) async {
      await pumpQuiz(tester);

      expect(find.byKey(const ValueKey('quiz-lives')), findsOneWidget);
      expect(find.text('播放英文'), findsOneWidget);
      await tapAndSettle(tester, find.byKey(const ValueKey('quiz-audio-prompt')));
      expect(audio.playedAssets, contains(PipAssets.audio('small')));
      expect(find.text('再听一遍'), findsOneWidget);
      expect(find.text('点这里再听一遍'), findsOneWidget);

      await tapAndSettle(tester, find.byKey(const ValueKey('quiz-option-large')));
      await tapAndSettle(tester, find.byKey(const ValueKey('quiz-check')));
      expect(find.byKey(const ValueKey('quiz-feedback-wrong')), findsOneWidget);

      final selectedCard = find.byKey(const ValueKey('quiz-option-large'));
      expect(find.descendant(of: selectedCard, matching: find.byType(Opacity)), findsNothing);
      final disabledOpacity = tester.widget<Opacity>(
        find.descendant(of: find.byKey(const ValueKey('quiz-option-small')), matching: find.byType(Opacity)),
      );
      expect(disabledOpacity.opacity, 0.55);

      await tapAndSettle(tester, find.byKey(const ValueKey('quiz-retry')));
      await tapAndSettle(tester, find.byKey(const ValueKey('quiz-option-small')));
      await tapAndSettle(tester, find.byKey(const ValueKey('quiz-check')));
      expect(find.byKey(const ValueKey('quiz-feedback-correct')), findsOneWidget);
    });

    testWidgets('shows the playing state until the clip completes', (tester) async {
      final gated = GatedPipAudio();
      await pumpQuiz(tester, customAudio: gated);

      await tester.tap(find.byKey(const ValueKey('quiz-audio-prompt')));
      await tester.pump();
      expect(find.text('正在播放…'), findsNWidgets(2));

      gated.gate.complete(true);
      await tester.pumpAndSettle();
      expect(find.text('正在播放…'), findsNothing);
      expect(find.text('再听一遍'), findsOneWidget);
    });

    testWidgets('falls back with a toast when the clip cannot play', (tester) async {
      final failing = FakePipAudio()..failAssets = true;
      await pumpQuiz(tester, customAudio: failing);

      await tester.tap(find.byKey(const ValueKey('quiz-audio-prompt')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('这次没播放出来，点一下再听。'), findsOneWidget);
      expect(find.text('播放英文'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('quiz-close')));
      await tester.pumpAndSettle();
      expect(failing.stopCount, greaterThan(0));
    });
  });
}
