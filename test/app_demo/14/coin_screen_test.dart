import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/models/coin_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/feedback_service.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/random_source.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/screens/coin_screen.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/animated_coin.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/coin_painter.dart';

class FixedRandom implements RandomSource {
  int calls = 0;
  @override
  bool nextBool() => calls++ % 2 != 0;
}

class RecordingFeedback implements FeedbackService {
  int calls = 0;
  @override
  Future<void> reveal() async {
    calls++;
  }
}

void main() {
  Future<void> mount(WidgetTester tester, SettingsViewModel settings, FixedRandom random, RecordingFeedback feedback) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: CoinScreen(settings: settings, random: random, feedback: feedback)));
    await tester.pumpAndSettle();
  }

  testWidgets('Both triggers share a locked round and reveal the predetermined side', (tester) async {
    final settings = SettingsViewModel();
    final random = FixedRandom();
    final feedback = RecordingFeedback();
    await mount(tester, settings, random, feedback);
    final semantics = tester.ensureSemantics();
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(const ValueKey('flip-button')));
    }
    await tester.pump();
    expect(random.calls, 1);
    expect(tester.widget<FilledButton>(find.byKey(const ValueKey('flip-button'))).onPressed, isNull);
    expect(tester.widget<IconButton>(find.ancestor(of: find.byTooltip('游戏外观'), matching: find.byType(IconButton))).onPressed, isNull);
    expect(find.text('反面'), findsNothing);
    expect(find.bySemanticsLabel('本轮结果：反面'), findsNothing);
    await tester.pump(const Duration(milliseconds: 1700));
    expect(find.text('反面'), findsOneWidget);
    expect(find.bySemanticsLabel('本轮结果：反面'), findsOneWidget);
    expect(feedback.calls, 1);
    await tester.pumpAndSettle();
    expect(find.text('再抛一次'), findsOneWidget);
    expect(
      tester.widget<CustomPaint>(find.byKey(const ValueKey('coin-face'))).painter,
      isA<CoinPainter>().having((p) => p.side, 'side', CoinSide.tails),
    );
    final lastTarget = tester.widget<AnimatedCoin>(find.byType(AnimatedCoin)).targetHalfTurns;
    await tester.tap(find.byKey(const ValueKey('coin-trigger')));
    await tester.pump();
    expect(random.calls, 2);
    expect(tester.widget<AnimatedCoin>(find.byType(AnimatedCoin)).startHalfTurns, lastTarget);
    await tester.pumpAndSettle();
    expect(find.text('正面'), findsOneWidget);
    expect(feedback.calls, 2);
    semantics.dispose();
  });

  testWidgets('Background settles once without extra draw or feedback', (tester) async {
    final random = FixedRandom();
    final feedback = RecordingFeedback();
    await mount(tester, SettingsViewModel(), random, feedback);
    await tester.tap(find.byKey(const ValueKey('flip-button')));
    await tester.pump(const Duration(milliseconds: 300));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('反面'), findsOneWidget);
    expect(random.calls, 1);
    expect(feedback.calls, 0);
    expect(tester.widget<FilledButton>(find.byKey(const ValueKey('flip-button'))).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reduced motion is short, commits orientation and honors vibration off', (tester) async {
    final settings =
        SettingsViewModel()
          ..setReduceMotion(true)
          ..setHapticsEnabled(false);
    final random = FixedRandom();
    final feedback = RecordingFeedback();
    await mount(tester, settings, random, feedback);
    await tester.tap(find.byKey(const ValueKey('flip-button')));
    await tester.pump();
    expect(tester.widget<AnimatedCoin>(find.byType(AnimatedCoin)).reduceMotion, isTrue);
    await tester.pump(const Duration(milliseconds: 210));
    await tester.pump();
    expect(find.text('反面'), findsOneWidget);
    expect(find.text('再抛一次'), findsOneWidget);
    expect(feedback.calls, 0);
    settings.setReduceMotion(false);
    settings.setMotionSpeed(MotionSpeed.fast);
    await tester.tap(find.byKey(const ValueKey('flip-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1010));
    await tester.pump();
    expect(find.text('正面'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('System reduced motion enabled mid-round settles without feedback', (tester) async {
    final random = FixedRandom();
    final feedback = RecordingFeedback();
    await mount(tester, SettingsViewModel(), random, feedback);
    await tester.tap(find.byKey(const ValueKey('coin-trigger')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpAndSettle();
    expect(find.text('反面'), findsOneWidget);
    expect(random.calls, 1);
    expect(feedback.calls, 0);
    expect(tester.widget<AnimatedCoin>(find.byType(AnimatedCoin)).targetHalfTurns.isOdd, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Thirty consecutive UI rounds preserve side, feedback and orientation', (tester) async {
    final random = FixedRandom();
    final feedback = RecordingFeedback();
    await mount(tester, SettingsViewModel(), random, feedback);
    var previousTarget = 0;
    for (var i = 0; i < 30; i++) {
      await tester.tap(find.byKey(const ValueKey('coin-trigger')));
      await tester.pump();
      final coin = tester.widget<AnimatedCoin>(find.byType(AnimatedCoin));
      expect(coin.startHalfTurns, previousTarget);
      previousTarget = coin.targetHalfTurns;
      await tester.pumpAndSettle();
      expect(find.text(i.isEven ? '反面' : '正面'), findsOneWidget);
      expect(random.calls, i + 1);
      expect(feedback.calls, i + 1);
      expect(tester.widget<FilledButton>(find.byKey(const ValueKey('flip-button'))).onPressed, isNotNull);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('System reduced motion keeps the explicit 200ms timeline', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final feedback = RecordingFeedback();
    await mount(tester, SettingsViewModel(), FixedRandom(), feedback);
    await tester.tap(find.byKey(const ValueKey('coin-trigger')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('反面'), findsNothing);
    expect(feedback.calls, 0);
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('反面'), findsOneWidget);
    expect(feedback.calls, 1);
    expect(tester.widget<FilledButton>(find.byKey(const ValueKey('flip-button'))).onPressed, isNull);
    await tester.pumpAndSettle();
    expect(find.text('再抛一次'), findsOneWidget);
  });

  for (final closeButton in [true, false]) {
    testWidgets('Pop before reveal cancels during reverse transition (button: $closeButton)', (tester) async {
      final feedback = RecordingFeedback();
      final settings = SettingsViewModel();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => Navigator.of(context).push(
                        PageRouteBuilder<void>(
                          transitionDuration: const Duration(milliseconds: 280),
                          reverseTransitionDuration: const Duration(milliseconds: 280),
                          pageBuilder: (_, _, _) => CoinScreen(settings: settings, random: FixedRandom(), feedback: feedback),
                        ),
                      ),
                  child: const Text('open'),
                ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('coin-trigger')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      if (closeButton) {
        await tester.tap(find.byTooltip('关闭游戏'));
      } else {
        await tester.binding.handlePopRoute();
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 180));
      expect(feedback.calls, 0);
      await tester.pumpAndSettle();
      expect(find.byType(CoinScreen), findsNothing);
      expect(tester.takeException(), isNull);
      settings.dispose();
    });
  }

  testWidgets('Disposal during toss cancels without result feedback or ticker errors', (tester) async {
    final feedback = RecordingFeedback();
    await mount(tester, SettingsViewModel(), FixedRandom(), feedback);
    await tester.tap(find.byKey(const ValueKey('flip-button')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(feedback.calls, 0);
    expect(tester.takeException(), isNull);
  });
}
