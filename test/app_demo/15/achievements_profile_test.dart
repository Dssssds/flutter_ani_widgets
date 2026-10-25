import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<FakePreferencesService> pumpApp(
    WidgetTester tester, {
    RootTab tab = RootTab.achievements,
    FakePreferencesService? preferences,
    FakePipShare? share,
  }) async {
    final store = preferences ?? FakePreferencesService();
    final repository = PipRepository(preferencesService: store);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      App15(
        repository: repository,
        clock: FixedClock(now),
        audio: FakePipAudio(),
        share: share ?? FakePipShare(),
        config: AppLaunchConfig(initialTab: tab),
      ),
    );
    await tester.pumpAndSettle();
    return store;
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('achievements', () {
    testWidgets('shows the seeded badges, shares an earned one and falls back to the clipboard', (tester) async {
      final clipboard = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard.add((call.arguments as Map<Object?, Object?>)['text']! as String);
        }
        return null;
      });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );

      final share = FakePipShare()..result = false;
      await pumpApp(tester, share: share);

      expect(tester.widget<Text>(find.byKey(const ValueKey('achievements-earned'))).data, '已解锁 2 / 5 枚徽章');
      expect(tester.widget<Text>(find.byKey(const ValueKey('achievements-percent'))).data, '40%');
      expect(find.text('已获得'), findsNWidgets(2));
      expect(find.text('待解锁'), findsNWidgets(3));
      final lockedOpacity = tester.widget<Opacity>(
        find.descendant(of: find.byKey(const ValueKey('achievement-coffee')), matching: find.byType(Opacity)),
      );
      expect(lockedOpacity.opacity, 0.65);

      await tapAndSettle(tester, find.byKey(const ValueKey('achievement-streak')));
      expect(find.byKey(const ValueKey('achievement-modal')), findsOneWidget);
      expect(find.text('一周不掉线'), findsWidgets);
      expect(find.text('已获得'), findsWidgets);
      expect(find.text('分享成就'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('achievement-modal-action')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const ValueKey('achievement-modal')), findsNothing);
      expect(share.sharedTexts, ['我在 Pip 英语学习里解锁了「一周不掉线」：连续学习 7 天。连续学习 7 天，累计 1,284 XP。']);
      expect(clipboard, [share.sharedTexts.single]);
      expect(find.text('分享文案已复制到剪贴板。'), findsOneWidget);
    });

    testWidgets('shares without a clipboard fallback when the platform succeeds', (tester) async {
      var clipboardCalls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') clipboardCalls++;
        return null;
      });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );

      final share = FakePipShare();
      await pumpApp(tester, share: share);
      await tapAndSettle(tester, find.byKey(const ValueKey('achievement-xp')));
      await tapAndSettle(tester, find.byKey(const ValueKey('achievement-modal-action')));

      expect(share.sharedTexts, hasLength(1));
      expect(clipboardCalls, 0);
      expect(find.text('分享文案已复制到剪贴板。'), findsNothing);
    });

    testWidgets('starts the current lesson from a locked badge and explains deeper locks', (tester) async {
      await pumpApp(tester);

      await tapAndSettle(tester, find.byKey(const ValueKey('achievement-coffee')));
      expect(find.text('去完成这一步'), findsOneWidget);
      await tapAndSettle(tester, find.byKey(const ValueKey('achievement-modal-action')));
      expect(find.byKey(const ValueKey('quiz-screen')), findsOneWidget);
      expect(find.text('帮 Pip 点杯咖啡'), findsOneWidget);

      await tapAndSettle(tester, find.byKey(const ValueKey('quiz-close')));
      await tapAndSettle(tester, find.byKey(const ValueKey('root-nav-achievements')));
      await tapAndSettle(tester, find.byKey(const ValueKey('achievement-directions')));
      await tester.tap(find.byKey(const ValueKey('achievement-modal-action')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('先完成「点杯咖啡」，就能解锁「问个方向」。'), findsOneWidget);
      expect(find.byKey(const ValueKey('quiz-screen')), findsNothing);
    });
  });

  group('profile', () {
    testWidgets('derives live stats and clamps the daily goal through the chips', (tester) async {
      final preferences = await pumpApp(tester, tab: RootTab.profile);

      expect(find.byKey(const ValueKey('profile-screen')), findsOneWidget);
      expect(find.text('小林的学习日常'), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('profile-xp')), matching: find.text('1,284 XP')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('profile-streak')), matching: find.text('7 天')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('profile-lessons')), matching: find.text('2 / 5')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('profile-mastered')), matching: find.text('0 / 17')), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const ValueKey('profile-goal-text'))).data, '6 / 10 分钟');

      await tester.tap(find.byKey(const ValueKey('profile-goal-20')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.widget<Text>(find.byKey(const ValueKey('profile-goal-text'))).data, '6 / 20 分钟');
      expect(find.text('每日目标已改为 20 分钟。'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('profile-goal-5')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.widget<Text>(find.byKey(const ValueKey('profile-goal-text'))).data, '5 / 5 分钟');
      expect(find.text('每日目标已改为 5 分钟。'), findsOneWidget);

      final saved = (await PipRepository(preferencesService: preferences).load(now)).state;
      expect(saved.dailyGoal, 5);
      expect(saved.dailySeconds, 300);
    });

    testWidgets('reflects completed lessons and mastered terms', (tester) async {
      final preferences = FakePreferencesService();
      final repository = PipRepository(preferencesService: preferences);
      await repository.save(
        createDemoState(now).copyWith(
          completedLessons: const {'greeting': true, 'menu': true, 'coffee': true, 'directions': false, 'challenge': false},
          reviewMastered: const {
            'coffee': ['milk'],
          },
        ),
      );

      await pumpApp(tester, tab: RootTab.profile, preferences: preferences);

      expect(find.descendant(of: find.byKey(const ValueKey('profile-lessons')), matching: find.text('3 / 5')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('profile-mastered')), matching: find.text('1 / 17')), findsOneWidget);
    });
  });
}
