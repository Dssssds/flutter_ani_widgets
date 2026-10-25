import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/15/app_15.dart';
import 'package:flutter_x_widgets/app_demo/15/data/asset_manifest.dart';
import 'package:flutter_x_widgets/app_demo/15/data/demo_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/app_launch_config.dart';
import 'package:flutter_x_widgets/app_demo/15/models/repositories/pip_repository.dart';
import 'package:flutter_x_widgets/app_demo/15/models/root_tab.dart';

import 'support/fakes.dart';

void main() {
  setUpAll(loadNunito);

  final now = DateTime(2026, 10, 25, 9, 30);

  Future<FakePreferencesService> pumpApp(
    WidgetTester tester,
    AppLaunchConfig config, {
    FakePreferencesService? preferences,
    FakePipAudio? audio,
    FakePipShare? share,
  }) async {
    final store = preferences ?? FakePreferencesService();
    final repository = PipRepository(preferencesService: store);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      App15(repository: repository, clock: FixedClock(now), audio: audio ?? FakePipAudio(), share: share ?? FakePipShare(), config: config),
    );
    await tester.pumpAndSettle();
    return store;
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('read-only demo keeps seeded data, opens the initial tab and can force sound on', (tester) async {
    final preferences = FakePreferencesService();
    await PipRepository(preferencesService: preferences).save(createDemoState(now).copyWith(xp: 999, soundOn: false));
    final audio = FakePipAudio();

    await pumpApp(
      tester,
      const AppLaunchConfig(initialTab: RootTab.review, readOnlyDemo: true, soundOn: true),
      preferences: preferences,
      audio: audio,
    );

    expect(find.byKey(const ValueKey('review-hub-screen')), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const ValueKey('root-nav-path')));
    expect(find.descendant(of: find.byKey(const ValueKey('path-resource-xp')), matching: find.text('1,284')), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const ValueKey('path-cta')));
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('关闭答题音效'), findsOneWidget);
    semantics.dispose();

    await tapAndSettle(tester, find.byKey(const ValueKey('quiz-word-milk')));
    await tapAndSettle(tester, find.byKey(const ValueKey('quiz-check')));
    expect(audio.playedAssets, contains(PipAssets.chime));

    final stored = (await PipRepository(preferencesService: preferences).load(now)).state;
    expect(stored.xp, 999);
    expect(stored.soundOn, isFalse);
  });

  testWidgets('demo correct feedback opens the quiz on the first answer', (tester) async {
    await pumpApp(tester, const AppLaunchConfig(demoCorrectFeedback: true));

    expect(find.byKey(const ValueKey('quiz-screen')), findsOneWidget);
    expect(find.text('帮 Pip 点杯咖啡'), findsOneWidget);
    expect(find.byKey(const ValueKey('quiz-feedback-correct')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('quiz-blank')), matching: find.text('milk')), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const ValueKey('quiz-close')));
    expect(find.byKey(const ValueKey('path-screen')), findsOneWidget);
  });

  testWidgets('demo completion opens the finish screen and returns to the path', (tester) async {
    await pumpApp(tester, const AppLaunchConfig(demoComplete: true));

    expect(find.byKey(const ValueKey('complete-screen')), findsOneWidget);
    expect(find.text('这杯英语，你拿下了！'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const ValueKey('complete-accuracy'))).data, '100%');
    expect(tester.widget<Text>(find.byKey(const ValueKey('complete-reward-xp'))).data, '+24');
    expect(find.text('这是演示结算页，可以直接返回路径。'), findsOneWidget);
    expect(find.text('返回学习路径'), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const ValueKey('complete-cta')));
    expect(find.byKey(const ValueKey('path-screen')), findsOneWidget);
  });
}
