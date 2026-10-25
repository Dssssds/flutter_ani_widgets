import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/15/app_15.dart';
import 'package:flutter_x_widgets/app_demo/15/models/app_launch_config.dart';
import 'package:flutter_x_widgets/app_demo/15/models/repositories/pip_repository.dart';

import 'support/fakes.dart';

void main() {
  setUpAll(loadNunito);

  final now = DateTime(2026, 10, 25, 9, 30);

  Future<void> pumpApp(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
    bool reduceMotion = false,
    AppLaunchConfig config = const AppLaunchConfig(),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    if (reduceMotion) {
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    }
    addTearDown(() {
      tester.view.reset();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
    });

    await tester.pumpWidget(
      App15(
        repository: PipRepository(preferencesService: FakePreferencesService()),
        clock: FixedClock(now),
        audio: FakePipAudio(),
        share: FakePipShare(),
        config: config,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('short screens keep the path, quiz and footer reachable', (tester) async {
    await pumpApp(tester, size: const Size(320, 568));

    expect(find.byKey(const ValueKey('path-screen')), findsOneWidget);
    expect(find.byKey(const ValueKey('root-nav-path')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tapAndSettle(tester, find.byKey(const ValueKey('path-cta')));
    expect(find.byKey(const ValueKey('quiz-screen')), findsOneWidget);
    expect(find.byKey(const ValueKey('quiz-check')).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('short screens can still browse review, achievements and profile', (tester) async {
    await pumpApp(tester, size: const Size(320, 568));

    const pages = {'review': 'review-hub-screen', 'achievements': 'achievements-screen', 'profile': 'profile-screen'};
    for (final entry in pages.entries) {
      await tapAndSettle(tester, find.byKey(ValueKey('root-nav-${entry.key}')));
      expect(find.byKey(ValueKey(entry.value)), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('the finish screen scrolls on short devices', (tester) async {
    await pumpApp(tester, size: const Size(320, 568), config: const AppLaunchConfig(demoComplete: true));

    expect(find.byKey(const ValueKey('complete-screen')), findsOneWidget);
    expect(find.byKey(const ValueKey('complete-cta')).hitTestable(), findsOneWidget);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('complete-streak-title')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide screens centre a 430 wide app with device colour around it', (tester) async {
    await pumpApp(tester, size: const Size(768, 900));

    final path = find.byKey(const ValueKey('path-screen'));
    expect(tester.getSize(path).width, 430);
    expect(tester.getTopLeft(path).dx, closeTo((768 - 430) / 2, 0.5));
    expect(tester.takeException(), isNull);

    await tapAndSettle(tester, find.byKey(const ValueKey('root-nav-review')));
    expect(find.byKey(const ValueKey('review-hub-screen')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text keeps primary actions visible and tappable', (tester) async {
    await pumpApp(tester, textScale: 1.3);

    expect(find.byKey(const ValueKey('path-cta')).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tapAndSettle(tester, find.byKey(const ValueKey('path-cta')));
    expect(find.byKey(const ValueKey('quiz-check')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduce motion still supports reveal, modal and navigation', (tester) async {
    await pumpApp(tester, reduceMotion: true);

    await tapAndSettle(tester, find.byKey(const ValueKey('root-nav-review')));
    await tapAndSettle(tester, find.byKey(const ValueKey('review-topic-greeting')));
    await tapAndSettle(tester, find.byKey(const ValueKey('review-reveal')));
    expect(find.byKey(const ValueKey('review-card-cn')), findsOneWidget);
    expect(tester.takeException(), isNull);

    final semantics = tester.ensureSemantics();
    await tapAndSettle(tester, find.bySemanticsLabel('返回复习列表'));
    semantics.dispose();

    await tapAndSettle(tester, find.byKey(const ValueKey('root-nav-achievements')));
    await tapAndSettle(tester, find.byKey(const ValueKey('achievement-streak')));
    expect(find.byKey(const ValueKey('achievement-modal')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
