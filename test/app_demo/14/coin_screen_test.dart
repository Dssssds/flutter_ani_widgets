import 'dart:math' as math;
import 'dart:ui' show ImageByteFormat, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/models/coin_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/feedback_service.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/random_source.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/screens/coin_screen.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/animated_coin.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/coin_body_painter.dart';

/// 第一次抽到反面，第二次正面，依次交替。
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

  final flipButton = find.byKey(const ValueKey('flip-button'));
  final coinTrigger = find.byKey(const ValueKey('coin-trigger'));
  final flippingText = find.byKey(const ValueKey('coin-flipping'));
  final coinFace = find.byKey(const ValueKey('coin-face'));
  final rings = find.byKey(const ValueKey('coin-rings'));

  testWidgets('First entry shows the coin and a Flip button without any result', (tester) async {
    await mount(tester, SettingsViewModel(), FixedRandom(), RecordingFeedback());
    expect(find.text('抛一次'), findsOneWidget);
    expect(find.text('再抛一次'), findsNothing);
    expect(find.text('硬币说'), findsNothing);
    expect(find.text('正面'), findsNothing);
    expect(find.text('反面'), findsNothing);
    expect(flippingText, findsNothing);
    final painter = tester.widget<CustomPaint>(coinFace).painter as CoinBodyPainter;
    expect(painter.visibleSide, CoinSide.heads);
    expect(tester.widget<FilledButton>(flipButton).onPressed, isNotNull);
  });

  testWidgets('Header has only a centered title and a close button', (tester) async {
    await mount(tester, SettingsViewModel(), FixedRandom(), RecordingFeedback());
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byTooltip('关闭'), findsOneWidget);
    expect(find.byTooltip('游戏外观'), findsNothing);
    expect(tester.getCenter(find.text('抛硬币')).dx, closeTo(195, .5));
    expect(tester.getSize(find.byType(IconButton)).width, greaterThanOrEqualTo(44));
    expect(tester.getSize(find.byType(IconButton)).height, greaterThanOrEqualTo(44));
  });

  testWidgets('Coin rests at 43% of the screen height and takes about 58% of its width', (tester) async {
    await mount(tester, SettingsViewModel(), FixedRandom(), RecordingFeedback());
    expect(tester.getCenter(coinFace).dy / 844, closeTo(.43, .005));
    expect(tester.getSize(coinFace).width / 390, closeTo(.58, .005));
  });

  testWidgets('Coin rises about a third of the screen and the result sits below it', (tester) async {
    await mount(tester, SettingsViewModel(), FixedRandom(), RecordingFeedback());
    await tester.tap(flipButton);
    await tester.pump();
    // 约在抛起段的中点，硬币升到最高。
    await tester.pump(const Duration(milliseconds: 1050));
    final top = tester.getCenter(coinFace).dy;
    expect(top, lessThan(844 * .2));
    expect(top - tester.getSize(coinFace).height / 2, greaterThanOrEqualTo(-1), reason: 'The coin may reach the top of the screen but not leave it');
    await tester.pumpAndSettle();
    final result = tester.getCenter(find.byKey(const ValueKey('coin-result'))).dy / 844;
    expect(result, inInclusiveRange(.62, .75));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Background has no visible step under the status bar or notch', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(tester.view.reset);
    const key = ValueKey('shot');
    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(key: key, child: CoinScreen(settings: SettingsViewModel(), random: FixedRandom(), feedback: RecordingFeedback())),
      ),
    );
    await tester.pumpAndSettle();
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
    final data =
        (await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ImageByteFormat.rawRgba);
          image.dispose();
          return bytes;
        }))!;
    List<int> pixel(int x, int y) {
      final i = (y * 390 + x) * 4;
      return [data.getUint8(i), data.getUint8(i + 1), data.getUint8(i + 2)];
    }

    // x=330 避开标题和关闭按钮；背景是连续渐变，相邻两行的每个通道最多差 1。
    // 只检查安全区附近（0–130 行）：更往下是硬币光晕的渐变边缘，8 位量化会有 2 级跳变，肉眼不可见。
    for (var y = 0; y < 130; y++) {
      final a = pixel(330, y);
      final b = pixel(330, y + 1);
      for (var c = 0; c < 3; c++) {
        expect((a[c] - b[c]).abs(), lessThanOrEqualTo(1), reason: 'Colour step between rows $y and ${y + 1}: $a -> $b');
      }
    }
  });

  testWidgets('Coin stays on one vertical line during the whole toss', (tester) async {
    await mount(tester, SettingsViewModel(), FixedRandom(), RecordingFeedback());
    final restX = tester.getCenter(coinFace).dx;
    expect(restX, closeTo(195, .5), reason: 'The coin rests on the screen centre line');
    await tester.tap(flipButton);
    await tester.pump();
    var rose = false;
    for (var ms = 0; ms < 2600; ms += 50) {
      await tester.pump(const Duration(milliseconds: 50));
      final center = tester.getCenter(coinFace);
      expect(center.dx, closeTo(restX, .01), reason: 'Horizontal drift at ${ms + 50}ms');
      if (center.dy < 844 * .3) rose = true;
    }
    expect(rose, isTrue, reason: 'The sampled toss really left the resting position');
    await tester.pumpAndSettle();
  });

  testWidgets('Both triggers share a locked round and reveal the predetermined side', (tester) async {
    final settings = SettingsViewModel();
    final random = FixedRandom();
    final feedback = RecordingFeedback();
    await mount(tester, settings, random, feedback);
    final semantics = tester.ensureSemantics();
    for (var i = 0; i < 5; i++) {
      await tester.tap(flipButton);
    }
    await tester.pump();
    // 抛掷中点击硬币没有任何响应，也不排队。
    await tester.tap(coinTrigger, warnIfMissed: false);
    await tester.pump();
    expect(random.calls, 1);
    expect(tester.widget<FilledButton>(flipButton).onPressed, isNull);
    expect(find.text('抛掷中…'), findsOneWidget, reason: 'Only the dimmed button shows it before the stage text fades in');
    expect(find.text('反面'), findsNothing);
    expect(find.bySemanticsLabel('本轮结果：反面'), findsNothing);
    await tester.pump(const Duration(milliseconds: 400));
    expect(flippingText, findsOneWidget);
    expect(find.text('硬币说'), findsNothing);
    expect(find.text('反面'), findsNothing);
    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text('硬币说'), findsOneWidget);
    expect(find.text('反面'), findsOneWidget);
    expect(find.bySemanticsLabel('本轮结果：反面'), findsOneWidget);
    expect(feedback.calls, 1);
    await tester.pumpAndSettle();
    expect(find.text('再抛一次'), findsOneWidget);
    expect(flippingText, findsNothing);
    final painter = tester.widget<CustomPaint>(coinFace).painter as CoinBodyPainter;
    // 静止时朝向用户的一面必须和结果一致。
    expect(painter.visibleSide, CoinSide.tails);
    // 旋转角是半圈数的奇数倍，落地时硬币停在反面。
    expect(painter.angle / math.pi, closeTo(7, 0.001));
    final lastTarget = tester.widget<AnimatedCoin>(find.byType(AnimatedCoin)).targetHalfTurns;
    // 点击硬币和点击按钮是同一个命令。
    await tester.tap(coinTrigger);
    await tester.pump();
    expect(random.calls, 2);
    expect(tester.widget<AnimatedCoin>(find.byType(AnimatedCoin)).startHalfTurns, lastTarget);
    // 新一轮开始时，旧结果先淡出，不会瞬间消失，也不会和新结果叠在一起。
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('反面'), findsOneWidget);
    expect(find.text('正面'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('正面'), findsOneWidget);
    expect(find.text('反面'), findsNothing);
    expect(feedback.calls, 2);
    semantics.dispose();
  });

  testWidgets('Coin hit area follows the coin outline plus a small margin', (tester) async {
    final random = FixedRandom();
    await mount(tester, SettingsViewModel(), random, RecordingFeedback());
    final rect = tester.getRect(coinTrigger);
    // 方形热区的角落在硬币轮廓之外，不响应。
    await tester.tapAt(rect.topLeft + const Offset(3, 3));
    await tester.pump();
    expect(random.calls, 0);
    // 外扩 8pt 的边缘仍然在轮廓内，可以点中。
    await tester.tapAt(rect.topCenter + const Offset(0, 3));
    await tester.pump();
    expect(random.calls, 1);
    await tester.pumpAndSettle();
  });

  testWidgets('Coin trigger has a readable label and is disabled while flipping', (tester) async {
    final semantics = tester.ensureSemantics();
    await mount(tester, SettingsViewModel(), FixedRandom(), RecordingFeedback());
    expect(find.bySemanticsLabel('点击硬币开始抛掷'), findsOneWidget);
    expect(tester.getSemantics(coinTrigger).getSemanticsData().flagsCollection.isEnabled, Tristate.isTrue);
    await tester.tap(coinTrigger);
    await tester.pump();
    expect(tester.getSemantics(coinTrigger).getSemanticsData().flagsCollection.isEnabled, Tristate.isFalse);
    await tester.pumpAndSettle();
    semantics.dispose();
  });

  testWidgets('Reveal rings expand once and are cancelled by the next flip', (tester) async {
    await mount(tester, SettingsViewModel(), FixedRandom(), RecordingFeedback());
    expect(rings, findsNothing);
    await tester.tap(flipButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2000));
    expect(rings, findsNothing, reason: 'Rings only appear after the reveal');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));
    expect(rings, findsOneWidget);
    // 解锁之后圆环仍在扩散。
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<FilledButton>(flipButton).onPressed, isNotNull);
    expect(rings, findsOneWidget);
    double opacity() => (tester.widget<CustomPaint>(rings).painter as CoinRingsPainter).opacity;
    expect(opacity(), 1);
    // 下一轮开始：残留圆环随文字切换一起淡出。
    await tester.tap(coinTrigger);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(rings, findsOneWidget);
    expect(opacity(), inExclusiveRange(0, 1));
    await tester.pump(const Duration(milliseconds: 200));
    expect(opacity(), 0);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Background settles once without extra draw or feedback', (tester) async {
    final random = FixedRandom();
    final feedback = RecordingFeedback();
    await mount(tester, SettingsViewModel(), random, feedback);
    await tester.tap(flipButton);
    await tester.pump(const Duration(milliseconds: 300));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('反面'), findsOneWidget);
    expect(random.calls, 1);
    expect(feedback.calls, 0);
    expect(rings, findsNothing);
    expect(tester.widget<FilledButton>(flipButton).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reduced motion is short, has no rings, commits orientation and honors vibration off', (tester) async {
    final settings =
        SettingsViewModel()
          ..setReduceMotion(true)
          ..setHapticsEnabled(false);
    final random = FixedRandom();
    final feedback = RecordingFeedback();
    await mount(tester, settings, random, feedback);
    await tester.tap(flipButton);
    await tester.pump();
    expect(tester.widget<AnimatedCoin>(find.byType(AnimatedCoin)).reduceMotion, isTrue);
    await tester.pump(const Duration(milliseconds: 210));
    await tester.pump();
    expect(find.text('反面'), findsOneWidget);
    expect(find.text('再抛一次'), findsOneWidget);
    expect(rings, findsNothing);
    expect(feedback.calls, 0);
    settings.setReduceMotion(false);
    settings.setMotionSpeed(MotionSpeed.fast);
    await tester.tap(flipButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1160));
    await tester.pump();
    expect(find.text('正面'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('System reduced motion enabled mid-round settles without feedback', (tester) async {
    final random = FixedRandom();
    final feedback = RecordingFeedback();
    await mount(tester, SettingsViewModel(), random, feedback);
    await tester.tap(coinTrigger);
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
      await tester.tap(coinTrigger);
      await tester.pump();
      final coin = tester.widget<AnimatedCoin>(find.byType(AnimatedCoin));
      expect(coin.startHalfTurns, previousTarget);
      previousTarget = coin.targetHalfTurns;
      await tester.pumpAndSettle();
      expect(find.text(i.isEven ? '反面' : '正面'), findsOneWidget);
      expect(random.calls, i + 1);
      expect(feedback.calls, i + 1);
      expect(tester.widget<FilledButton>(flipButton).onPressed, isNotNull);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('System reduced motion keeps the explicit 200ms timeline', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final feedback = RecordingFeedback();
    await mount(tester, SettingsViewModel(), FixedRandom(), feedback);
    await tester.tap(coinTrigger);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('反面'), findsNothing);
    expect(feedback.calls, 0);
    await tester.pump(const Duration(milliseconds: 80));
    expect(feedback.calls, 1);
    expect(tester.widget<FilledButton>(flipButton).onPressed, isNull);
    await tester.pumpAndSettle();
    expect(find.text('再抛一次'), findsOneWidget);
    expect(find.text('反面'), findsOneWidget);
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
      await tester.tap(coinTrigger);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      if (closeButton) {
        await tester.tap(find.byTooltip('关闭'));
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
    await tester.tap(flipButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(feedback.calls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Disposal while rings expand cancels without ticker errors', (tester) async {
    await mount(tester, SettingsViewModel(), FixedRandom(), RecordingFeedback());
    await tester.tap(flipButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 100));
    expect(rings, findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
