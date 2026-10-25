import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/15/app_15.dart';
import 'package:flutter_x_widgets/app_demo/15/data/demo_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/app_launch_config.dart';
import 'package:flutter_x_widgets/app_demo/15/models/repositories/pip_repository.dart';
import 'package:flutter_x_widgets/app_demo/15/models/root_tab.dart';

import 'support/fakes.dart';

void main() {
  setUpAll(loadNunito);

  final now = DateTime(2026, 10, 25, 9, 30);

  Future<FakePreferencesService> pumpApp(WidgetTester tester, {FakePreferencesService? preferences, FakePipAudio? audio}) async {
    final store = preferences ?? FakePreferencesService();
    final repository = PipRepository(preferencesService: store);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      App15(
        repository: repository,
        clock: FixedClock(now),
        audio: audio ?? FakePipAudio(),
        share: FakePipShare(),
        config: const AppLaunchConfig(initialTab: RootTab.review),
      ),
    );
    await tester.pumpAndSettle();
    return store;
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('opens the directions deck and completes a round without mastering skipped terms', (tester) async {
    final audio = FakePipAudio();
    final preferences = await pumpApp(tester, audio: audio);

    expect(find.byKey(const ValueKey('review-hub-screen')), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const ValueKey('review-mastered-total'))).data, '已经掌握 0 / 17 个表达');
    expect(find.text('已掌握 0 / 5'), findsOneWidget);
    expect(find.text('已掌握 0 / 4'), findsNWidgets(3));

    await tapAndSettle(tester, find.byKey(const ValueKey('review-topic-directions')));
    expect(find.byKey(const ValueKey('review-deck-screen')), findsOneWidget);
    expect(find.text('问个方向'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const ValueKey('review-deck-counter'))).data, '1 / 4');
    expect(tester.widget<Text>(find.byKey(const ValueKey('review-card-en'))).data, 'station');
    expect(find.text('0 / 4 已掌握'), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const ValueKey('review-reveal')));
    expect(tester.widget<Text>(find.byKey(const ValueKey('review-card-cn'))).data, '车站');
    await tapAndSettle(tester, find.byKey(const ValueKey('review-master')));
    expect(tester.widget<Text>(find.byKey(const ValueKey('review-deck-counter'))).data, '2 / 4');
    expect(tester.widget<Text>(find.byKey(const ValueKey('review-card-en'))).data, 'go straight');
    expect(find.text('1 / 4 已掌握'), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const ValueKey('review-skip')));
    await tapAndSettle(tester, find.byKey(const ValueKey('review-skip')));
    await tapAndSettle(tester, find.byKey(const ValueKey('review-skip')));

    expect(find.byKey(const ValueKey('review-deck-finish-title')), findsOneWidget);
    expect(find.text('这一轮，复习完成！'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const ValueKey('review-deck-round'))).data, '本轮 1 轮');
    expect(find.text('已掌握 1 / 4'), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const ValueKey('review-deck-restart')));
    expect(tester.widget<Text>(find.byKey(const ValueKey('review-deck-counter'))).data, '1 / 4');
    expect(tester.widget<Text>(find.byKey(const ValueKey('review-card-en'))).data, 'station');
    expect(find.text('1 / 4 已掌握'), findsOneWidget);

    final semantics = tester.ensureSemantics();
    await tapAndSettle(tester, find.bySemanticsLabel('返回复习列表'));
    semantics.dispose();
    expect(find.byKey(const ValueKey('review-hub-screen')), findsOneWidget);
    expect(find.text('已掌握 1 / 4'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const ValueKey('review-mastered-total'))).data, '已经掌握 1 / 17 个表达');
    expect(audio.stopCount, greaterThan(0));

    final saved = (await PipRepository(preferencesService: preferences).load(now)).state;
    expect(saved.reviewMastered['directions'], ['station']);
  });

  testWidgets('starting a fully mastered topic keeps every card available from the beginning', (tester) async {
    final preferences = FakePreferencesService();
    final repository = PipRepository(preferencesService: preferences);
    await repository.save(
      createDemoState(now).copyWith(
        reviewMastered: const {
          'coffee': ['milk', 'to go', 'a small one', 'Thank you', 'Have a nice day!'],
        },
      ),
    );

    await pumpApp(tester, preferences: preferences);
    expect(find.text('已掌握 5 / 5'), findsOneWidget);
    expect(find.text('已掌握 0 / 4'), findsNWidgets(3));

    await tapAndSettle(tester, find.byKey(const ValueKey('review-topic-coffee')));
    expect(tester.widget<Text>(find.byKey(const ValueKey('review-deck-counter'))).data, '1 / 5');
    expect(tester.widget<Text>(find.byKey(const ValueKey('review-card-tag'))).data, '已掌握');
    expect(find.text('5 / 5 已掌握'), findsOneWidget);
  });

  testWidgets('speaks the term and reports a failed playback without leaving the deck', (tester) async {
    final audio = FakePipAudio()..failSpeak = true;
    await pumpApp(tester, audio: audio);

    await tapAndSettle(tester, find.byKey(const ValueKey('review-topic-greeting')));
    await tester.tap(find.byKey(const ValueKey('review-listen')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(audio.spoken, ['Hello.']);
    expect(find.text('这次没播放出来，点一下再听。'), findsOneWidget);
    expect(find.byKey(const ValueKey('review-deck-screen')), findsOneWidget);
  });
}
