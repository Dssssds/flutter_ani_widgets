import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/15/app_15.dart';
import 'package:flutter_x_widgets/app_demo/15/data/demo_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/app_launch_config.dart';
import 'package:flutter_x_widgets/app_demo/15/models/repositories/pip_repository.dart';
import 'package:flutter_x_widgets/app_demo/15/models/run_state.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_icon.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_progress_bar.dart';
import 'package:flutter_x_widgets/main.dart';

import 'support/fakes.dart';

void main() {
  setUpAll(loadNunito);

  Future<void> pumpApp(
    WidgetTester tester, {
    FakePreferencesService? preferences,
    DateTime? now,
    FakePipAudio? audio,
    FakePipShare? share,
    AppLaunchConfig config = const AppLaunchConfig(),
  }) async {
    final clockNow = now ?? DateTime(2026, 10, 25, 9, 30);
    final repository = PipRepository(preferencesService: preferences ?? FakePreferencesService());
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      App15(
        repository: repository,
        clock: FixedClock(clockNow),
        audio: audio ?? FakePipAudio(),
        share: share ?? FakePipShare(),
        config: config,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the seeded learning path', (tester) async {
    await pumpApp(tester);

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).title, 'Pip 英语学习');
    expect(find.byKey(const ValueKey('path-screen')), findsOneWidget);
    expect(find.text('pip'), findsOneWidget);
    expect(find.text('第 3 单元 · 通勤英语'), findsOneWidget);
    expect(find.text('咖啡店，开口不慌'), findsOneWidget);

    expect(find.descendant(of: find.byKey(const ValueKey('path-resource-streak')), matching: find.text('7')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('path-resource-xp')), matching: find.text('1,284')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('path-resource-lives')), matching: find.text('4')), findsOneWidget);

    expect(find.text('今日目标'), findsOneWidget);
    expect(find.text('6 / 10 分钟'), findsOneWidget);
    final daily = tester.widget<PipProgressBar>(find.byKey(const ValueKey('path-daily-progress')));
    expect(daily.fraction, closeTo(0.6, 0.001));

    for (final nodeId in ['greeting', 'menu', 'coffee', 'directions', 'challenge']) {
      expect(find.byKey(ValueKey('path-node-$nodeId')), findsOneWidget);
    }
    expect(find.text('5 道题 · 约 2 分钟'), findsOneWidget);
    expect(find.text('开始这一课'), findsOneWidget);

    expect(find.byKey(const ValueKey('root-nav-path')), findsOneWidget);
    expect(find.text('学习'), findsOneWidget);
    expect(find.text('复习'), findsOneWidget);
    expect(find.text('成就'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('describes completed, current and locked nodes', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester);

    try {
      expect(find.bySemanticsLabel('已完成：打个招呼，复习'), findsOneWidget);
      expect(find.bySemanticsLabel('已完成：看懂菜单，复习'), findsOneWidget);
      expect(find.bySemanticsLabel('开始：点杯咖啡'), findsOneWidget);
      expect(find.bySemanticsLabel('未解锁：问个方向'), findsOneWidget);
      expect(find.bySemanticsLabel('未解锁：单元挑战'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('locked nodes explain the previous lesson requirement', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('path-node-directions')));
    await tester.pumpAndSettle();
    expect(find.text('先完成「点杯咖啡」，就能解锁「问个方向」。'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('path-node-challenge')));
    await tester.pumpAndSettle();
    expect(find.text('先完成「问个方向」，就能解锁单元挑战。'), findsOneWidget);
  });

  testWidgets('path call to action opens the current quiz', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('path-cta')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('quiz-screen')), findsOneWidget);
    expect(find.text('帮 Pip 点杯咖啡'), findsOneWidget);
    expect(find.text('选词填空 · 1 / 5'), findsOneWidget);
  });

  testWidgets('every bottom tab opens a real page', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('root-nav-review')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('review-hub-screen')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('root-nav-achievements')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('achievements-screen')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('root-nav-profile')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('profile-screen')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('root-nav-path')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('path-cta')).hitTestable(), findsOneWidget);
  });

  testWidgets('bottom nav glides its highlight and keeps icons untinted', (tester) async {
    await pumpApp(tester);

    Finder navIcon(String tab) => find.descendant(of: find.byKey(ValueKey('root-nav-$tab')), matching: find.byType(PipIcon));
    final indicator = find.byKey(const ValueKey('root-nav-indicator'));

    expect(indicator, findsOneWidget);
    expect(tester.widget<PipIcon>(navIcon('path')).color, isNull);
    expect(tester.getCenter(indicator).dx, closeTo(tester.getCenter(find.byKey(const ValueKey('root-nav-path'))).dx, 0.5));

    final start = tester.getCenter(indicator).dx;
    await tester.tap(find.byKey(const ValueKey('root-nav-review')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 140));
    final midway = tester.getCenter(indicator).dx;
    await tester.pumpAndSettle();
    final end = tester.getCenter(indicator).dx;

    expect(midway, greaterThan(start));
    expect(midway, lessThan(end));
    expect(end, closeTo(tester.getCenter(find.byKey(const ValueKey('root-nav-review'))).dx, 0.5));
    expect(tester.widget<PipIcon>(navIcon('review')).color, isNull);
  });

  testWidgets('shows resume status for an unfinished lesson', (tester) async {
    final now = DateTime(2026, 10, 25, 9, 30);
    final preferences = FakePreferencesService();
    final repository = PipRepository(preferencesService: preferences);
    await repository.save(
      createDemoState(now).copyWith(
        run: const RunState(lessonId: 'coffee', mode: RunMode.lesson, qIndex: 2, answered: 2, correctFirstTry: 1, selection: 'milk'),
      ),
    );
    final semantics = tester.ensureSemantics();

    await pumpApp(tester, preferences: preferences, now: now);

    try {
      expect(find.text('继续这一课'), findsOneWidget);
      expect(find.text('已完成 2 / 5 题'), findsOneWidget);
      expect(find.bySemanticsLabel('继续：点杯咖啡'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('shows the completion state when the unit is finished', (tester) async {
    final now = DateTime(2026, 10, 25, 9, 30);
    final preferences = FakePreferencesService();
    final repository = PipRepository(preferencesService: preferences);
    await repository.save(
      createDemoState(
        now,
      ).copyWith(completedLessons: const {'greeting': true, 'menu': true, 'coffee': true, 'directions': true, 'challenge': true}),
    );
    final semantics = tester.ensureSemantics();

    await pumpApp(tester, preferences: preferences, now: now);

    try {
      expect(find.text('本单元已通关 · 可随时复习'), findsOneWidget);
      expect(find.text('复习点单'), findsOneWidget);
      expect(find.bySemanticsLabel('Pip 为你庆祝'), findsOneWidget);
      expect(find.bySemanticsLabel('已完成：点杯咖啡，复习'), findsOneWidget);
      expect(find.bySemanticsLabel('已完成：单元挑战，复习'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  test('App 15 is registered in the showcase', () {
    expect(HomeScreen().demoApps.singleWhere((example) => example.title == 'APP-15(Pip 英语学习)').isFullScreen, isTrue);
  });
}
