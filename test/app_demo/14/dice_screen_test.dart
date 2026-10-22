import 'dart:math' as math;
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/models/game_definition.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/feedback_service.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/random_source.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/screens/dice_screen.dart';
import 'package:flutter_x_widgets/app_demo/14/screens/navigation/demo_routes.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/dice/dice_count_selector.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/dice/dice_motion.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/dice/dice_painter.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';

/// 按给定序列依次返回点数（内部换算成 0 起的下标）。
class ScriptedDice implements IntRandomSource {
  ScriptedDice(this.faces);
  final List<int> faces;
  int calls = 0;

  @override
  int nextInt(int max) => faces[calls++ % faces.length] - 1;
}

class RecordingFeedback implements FeedbackService {
  int calls = 0;
  @override
  Future<void> reveal() async {
    calls++;
  }
}

void main() {
  // 测试视图 390×844，没有安全区，所以顶部栏之下就是 y = 56。
  const layout = DiceStageLayout(width: 390, screenHeight: 844, headerBottom: 56);

  final rollButton = find.byKey(const ValueKey('roll-button'));
  final countOne = find.byKey(const ValueKey('dice-count-one'));
  final countTwo = find.byKey(const ValueKey('dice-count-two'));
  final selectorFade = find.byKey(const ValueKey('dice-selector'));
  final idleFade = find.byKey(const ValueKey('dice-idle'));
  final resultFade = find.byKey(const ValueKey('dice-result'));
  final total = find.byKey(const ValueKey('dice-total'));
  final breakdown = find.byKey(const ValueKey('dice-breakdown'));

  double opacityOf(WidgetTester tester, Finder fade) => tester.widget<AnimatedOpacity>(fade).opacity;
  DiceStagePainter painterOf(WidgetTester tester) => tester.widget<CustomPaint>(find.byKey(const ValueKey('dice-stage'))).painter as DiceStagePainter;
  List<int> shownFaces(WidgetTester tester) => [for (final die in painterOf(tester).dice) DiceFaces.topFace(die.rotation)];

  void useView(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<ScriptedDice> mount(
    WidgetTester tester, {
    List<int> faces = const [5, 2],
    SettingsViewModel? settings,
    RecordingFeedback? feedback,
    int seed = 1,
  }) async {
    useView(tester);
    final random = ScriptedDice(faces);
    await tester.pumpWidget(
      MaterialApp(
        home: DiceScreen(settings: settings ?? SettingsViewModel(), random: random, feedback: feedback ?? RecordingFeedback(), motionRandom: math.Random(seed)),
      ),
    );
    await tester.pumpAndSettle();
    return random;
  }

  group('Menu and routing', () {
    test('the menu entry is available and points to /dice', () {
      final dice = partyGames.singleWhere((game) => game.id == 'dice');
      expect(dice.isAvailable, isTrue);
      expect(dice.route, '/dice');
    });

    testWidgets('the /dice route opens the dice screen with the injected dice source and feedback', (tester) async {
      useView(tester);
      final settings = SettingsViewModel();
      addTearDown(settings.dispose);
      final random = ScriptedDice(const [6]);
      final feedback = RecordingFeedback();
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/dice',
          onGenerateRoute: (route) => DemoRoutes.create(route, settings, MotionSpec(settings.state), null, diceRandom: random, feedback: feedback),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DiceScreen), findsOneWidget);
      await tester.tap(rollButton);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(total).data, '6');
      expect(random.calls, 1);
      expect(feedback.calls, 1);
    });
  });

  group('Idle', () {
    testWidgets('shows one die facing up, the selector, the tagline and an enabled button', (tester) async {
      await mount(tester);
      expect(tester.widget<DiceCountSelector>(find.byType(DiceCountSelector)).count, 1);
      expect(opacityOf(tester, selectorFade), 1);
      expect(opacityOf(tester, idleFade), 1);
      expect(opacityOf(tester, resultFade), 0);
      expect(find.text('手气如何？'), findsOneWidget);
      expect(find.text('掷一次'), findsOneWidget);
      expect(tester.widget<FilledButton>(rollButton).onPressed, isNotNull);
      final dice = painterOf(tester).dice;
      expect(dice.length, 1);
      expect(dice.single.center, layout.toPx(const Offset(.5, .49)));
      expect(shownFaces(tester), [1]);
      expect(painterOf(tester).side, closeTo(390 * .26, 1e-9));
    });

    testWidgets('two dice sit side by side with a gap of 55% of the side and show 1 and 2', (tester) async {
      await mount(tester);
      await tester.tap(countTwo);
      await tester.pumpAndSettle();
      final dice = painterOf(tester).dice;
      expect(dice.length, 2);
      expect(shownFaces(tester), [1, 2]);
      final side = painterOf(tester).side;
      expect(dice[1].center.dx - dice[0].center.dx, closeTo(side * 1.55, 1e-9));
      expect(dice[0].center.dy, dice[1].center.dy);
      expect((dice[0].center.dx + dice[1].center.dx) / 2, closeTo(195, 1e-9));
    });

    testWidgets('the header has only a centered title and a close button', (tester) async {
      await mount(tester);
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byTooltip('关闭'), findsOneWidget);
      expect(tester.getCenter(find.text('掷骰子')).dx, closeTo(195, .5));
    });
  });

  group('Rolling', () {
    testWidgets('locks the screen, hides the selector and the result area, and keeps the values hidden', (tester) async {
      final random = await mount(tester);
      await tester.tap(countTwo);
      await tester.pumpAndSettle();
      await tester.tap(rollButton);
      await tester.pump();
      expect(random.calls, 2);
      expect(tester.widget<FilledButton>(rollButton).onPressed, isNull);
      expect(find.text('投掷中…'), findsOneWidget);
      expect(opacityOf(tester, selectorFade), 0);
      expect(tester.widget<IgnorePointer>(find.descendant(of: selectorFade, matching: find.byType(IgnorePointer))).ignoring, isTrue);
      expect(opacityOf(tester, idleFade), 0);
      expect(opacityOf(tester, resultFade), 0);
      expect(find.byKey(const ValueKey('dice-hit-0')), findsNothing);
      await tester.pump(const Duration(milliseconds: 1000));
      expect(opacityOf(tester, resultFade), 0, reason: 'Nothing is revealed while the dice are in the air');
      final airborne = painterOf(tester).dice;
      expect(airborne.any((die) => die.lift > .3), isTrue, reason: 'The dice are really thrown up');
      await tester.pumpAndSettle();
    });

    testWidgets('five taps and a tap on a die start exactly one roll', (tester) async {
      final random = await mount(tester);
      for (var i = 0; i < 5; i++) {
        await tester.tap(rollButton);
      }
      await tester.pump();
      await tester.tap(countTwo, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(random.calls, 1);
      expect(tester.widget<DiceCountSelector>(find.byType(DiceCountSelector)).count, 1, reason: 'The count cannot change while rolling');
      await tester.pumpAndSettle();
    });

    testWidgets('the roll lasts about 2.25 seconds and the button unlocks together with the result', (tester) async {
      await mount(tester);
      await tester.tap(rollButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2200));
      expect(find.text('投掷中…'), findsOneWidget);
      expect(opacityOf(tester, resultFade), 0);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('再掷一次'), findsOneWidget);
      expect(tester.widget<FilledButton>(rollButton).onPressed, isNotNull);
      expect(opacityOf(tester, resultFade), 1, reason: 'The result starts fading in at the same moment');
      expect(opacityOf(tester, selectorFade), 1);
      await tester.pumpAndSettle();
    });

    testWidgets('fast mode shortens the same timeline', (tester) async {
      final settings = SettingsViewModel()..setMotionSpeed(MotionSpeed.fast);
      await mount(tester, settings: settings);
      await tester.tap(rollButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1120));
      expect(find.text('再掷一次'), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('Result', () {
    testWidgets('two dice show the total and the breakdown and the dice show the same faces', (tester) async {
      final feedback = RecordingFeedback();
      await mount(tester, feedback: feedback);
      await tester.tap(countTwo);
      await tester.pumpAndSettle();
      await tester.tap(rollButton);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(total).data, '7');
      expect(tester.widget<Text>(breakdown).data, '5 + 2');
      expect(opacityOf(tester, resultFade), 1);
      expect(opacityOf(tester, idleFade), 0);
      expect(opacityOf(tester, selectorFade), 1);
      expect(find.text('再掷一次'), findsOneWidget);
      expect(shownFaces(tester), [5, 2], reason: 'The landing pose must match the rolled values');
      final dice = painterOf(tester).dice;
      expect(dice[0].center.dx, lessThan(dice[1].center.dx), reason: 'First die on the left so the breakdown reads in screen order');
      expect(feedback.calls, 1);
    });

    testWidgets('one die shows only the number, without a breakdown', (tester) async {
      await mount(tester, faces: const [3]);
      await tester.tap(rollButton);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(total).data, '3');
      expect(breakdown, findsNothing);
      expect(shownFaces(tester), [3]);
    });

    testWidgets('dice land inside the stage, clear of the result text, the selector and the edges', (tester) async {
      await mount(tester, faces: const [1, 2, 3, 4, 5, 6]);
      await tester.tap(countTwo);
      await tester.pumpAndSettle();
      final half = painterOf(tester).side / 2;
      final ext = half * 1.36;
      for (var i = 0; i < 25; i++) {
        await tester.tap(rollButton);
        await tester.pumpAndSettle();
        final dice = painterOf(tester).dice;
        for (final die in dice) {
          expect(die.center.dx - ext, greaterThanOrEqualTo(16 - 1e-6), reason: 'round $i left edge');
          expect(die.center.dx + ext, lessThanOrEqualTo(390 - 16 + 1e-6), reason: 'round $i right edge');
          final bottom = die.center.dy + layout.headerBottom + ext;
          final top = die.center.dy + layout.headerBottom - ext;
          expect(bottom, lessThan(844 * .63), reason: 'round $i must not touch the result text');
          expect(top, greaterThan(844 * .17 + 22), reason: 'round $i must not touch the selector');
        }
        expect((dice[0].center - dice[1].center).distance, greaterThanOrEqualTo(painterOf(tester).side * 1.3 - 1e-6), reason: 'round $i dice overlap');
      }
    });

    testWidgets('landing spots differ from roll to roll', (tester) async {
      await mount(tester, faces: const [4]);
      final spots = <int>{};
      for (var i = 0; i < 12; i++) {
        await tester.tap(rollButton);
        await tester.pumpAndSettle();
        final center = painterOf(tester).dice.single.center;
        spots.add(center.dx.round() ~/ 15 * 100 + center.dy.round() ~/ 15);
      }
      expect(spots.length, greaterThan(5));
    });

    testWidgets('thirty rounds keep text, faces and feedback consistent while the count changes', (tester) async {
      final feedback = RecordingFeedback();
      final faces = [for (var i = 0; i < 60; i++) (i * 5 + 1) % 6 + 1];
      final random = await mount(tester, faces: faces, feedback: feedback);
      var drawn = 0;
      for (var round = 0; round < 30; round++) {
        final count = round % 3 == 2 ? 2 : (round.isEven ? 1 : 2);
        if (tester.widget<DiceCountSelector>(find.byType(DiceCountSelector)).count != count) {
          await tester.tap(count == 1 ? countOne : countTwo);
          await tester.pumpAndSettle();
          expect(find.text('掷一次'), findsOneWidget);
        }
        final expected = [for (var i = 0; i < count; i++) faces[(drawn + i) % faces.length]];
        drawn += count;
        await tester.tap(rollButton);
        await tester.pumpAndSettle();
        expect(random.calls, drawn);
        expect(tester.widget<Text>(total).data, '${expected.fold<int>(0, (a, b) => a + b)}');
        expect(shownFaces(tester), expected, reason: 'round $round');
        expect(feedback.calls, round + 1);
        expect(tester.widget<FilledButton>(rollButton).onPressed, isNotNull);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a die rolls just like the button, and rolls again from the result', (tester) async {
      final random = await mount(tester, faces: const [2, 6]);
      await tester.tap(find.byKey(const ValueKey('dice-hit-0')));
      await tester.pumpAndSettle();
      expect(random.calls, 1);
      expect(tester.widget<Text>(total).data, '2');
      await tester.tap(find.byKey(const ValueKey('dice-hit-0')));
      await tester.pumpAndSettle();
      expect(random.calls, 2);
      expect(tester.widget<Text>(total).data, '6');
    });
  });

  group('Switching the count', () {
    testWidgets('clears the result at once, resets the dice and the button, and keeps the old text only while it fades out', (tester) async {
      final random = await mount(tester, faces: const [5, 2, 4]);
      await tester.tap(countTwo);
      await tester.pumpAndSettle();
      await tester.tap(rollButton);
      await tester.pumpAndSettle();
      expect(find.text('再掷一次'), findsOneWidget);
      await tester.tap(countOne);
      await tester.pump();
      expect(tester.widget<DiceCountSelector>(find.byType(DiceCountSelector)).count, 1);
      expect(find.text('掷一次'), findsOneWidget);
      expect(opacityOf(tester, resultFade), 0);
      expect(opacityOf(tester, idleFade), 1);
      expect(total, findsOneWidget, reason: 'The old total stays in the tree just long enough to fade out');
      // 旧结果快速淡出，待机文字晚 100ms 才开始淡入。
      expect(tester.widget<AnimatedOpacity>(resultFade).duration, const Duration(milliseconds: 150));
      expect(tester.widget<AnimatedOpacity>(idleFade).duration, const Duration(milliseconds: 350));
      expect(tester.widget<AnimatedOpacity>(idleFade).curve, isA<Interval>());
      expect(shownFaces(tester), [1]);
      expect(painterOf(tester).dice.single.center, layout.toPx(const Offset(.5, .49)));
      await tester.pumpAndSettle();
      expect(random.calls, 2, reason: 'Switching never draws');
    });

    testWidgets('choosing the count that is already selected keeps the result', (tester) async {
      final random = await mount(tester, faces: const [6]);
      await tester.tap(rollButton);
      await tester.pumpAndSettle();
      await tester.tap(countOne);
      await tester.pumpAndSettle();
      expect(find.text('再掷一次'), findsOneWidget);
      expect(tester.widget<Text>(total).data, '6');
      expect(opacityOf(tester, resultFade), 1);
      expect(random.calls, 1);
    });
  });

  group('Accessibility', () {
    testWidgets('the result is announced once it is revealed, with total and parts', (tester) async {
      final semantics = tester.ensureSemantics();
      await mount(tester);
      await tester.tap(countTwo);
      await tester.pumpAndSettle();
      const label = '本轮结果：合计 7，分别是 5 和 2';
      expect(find.bySemanticsLabel(label), findsNothing);
      await tester.tap(rollButton);
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.bySemanticsLabel(label), findsNothing, reason: 'Nothing is announced while rolling');
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(label), findsOneWidget);
      expect(find.bySemanticsLabel('点击骰子掷骰'), findsNWidgets(2));
      await tester.tap(countOne);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(label), findsNothing, reason: 'A cleared result is no longer exposed');
      semantics.dispose();
    });

    testWidgets('count options are announced as selectable buttons', (tester) async {
      final semantics = tester.ensureSemantics();
      await mount(tester);
      expect(find.bySemanticsLabel('一枚骰子'), findsOneWidget);
      expect(find.bySemanticsLabel('两枚骰子'), findsOneWidget);
      expect(tester.getSemantics(countOne).getSemanticsData().flagsCollection.isSelected.toBoolOrNull(), isTrue);
      expect(tester.getSemantics(countTwo).getSemanticsData().flagsCollection.isSelected.toBoolOrNull(), isFalse);
      semantics.dispose();
    });
  });

  group('Lifecycle and motion settings', () {
    testWidgets('going to the background settles the already decided result without drawing or vibrating', (tester) async {
      final feedback = RecordingFeedback();
      final random = await mount(tester, feedback: feedback);
      await tester.tap(countTwo);
      await tester.pumpAndSettle();
      await tester.tap(rollButton);
      await tester.pump(const Duration(milliseconds: 400));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(total).data, '7');
      expect(shownFaces(tester), [5, 2]);
      expect(random.calls, 2);
      expect(feedback.calls, 0);
      expect(tester.widget<FilledButton>(rollButton).onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('system reduced motion turned on mid roll settles without vibration', (tester) async {
      final feedback = RecordingFeedback();
      final random = await mount(tester, feedback: feedback);
      await tester.tap(rollButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(total).data, '5');
      expect(random.calls, 1);
      expect(feedback.calls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion fades the dice in on their landing pose within 200ms and still vibrates once', (tester) async {
      final settings = SettingsViewModel()..setReduceMotion(true);
      final feedback = RecordingFeedback();
      await mount(tester, settings: settings, feedback: feedback);
      await tester.tap(rollButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final mid = painterOf(tester).dice.single;
      expect(mid.opacity, inExclusiveRange(0, 1));
      expect(mid.lift, 0, reason: 'No tossing under reduced motion');
      expect(mid.scale, 1);
      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.widget<Text>(total).data, '5');
      expect(painterOf(tester).dice.single.opacity, 1);
      expect(feedback.calls, 1);
      await tester.pumpAndSettle();
    });

    testWidgets('vibration can be switched off', (tester) async {
      final settings = SettingsViewModel()..setHapticsEnabled(false);
      final feedback = RecordingFeedback();
      await mount(tester, settings: settings, feedback: feedback);
      await tester.tap(rollButton);
      await tester.pumpAndSettle();
      expect(find.text('再掷一次'), findsOneWidget);
      expect(feedback.calls, 0);
    });

    for (final closeButton in [true, false]) {
      testWidgets('leaving during a roll stops it without feedback or errors (close button: $closeButton)', (tester) async {
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
                            pageBuilder: (_, _, _) => DiceScreen(settings: settings, random: ScriptedDice(const [5, 2]), feedback: feedback),
                          ),
                        ),
                    child: const Text('open'),
                  ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        await tester.tap(rollButton);
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
        expect(find.byType(DiceScreen), findsNothing);
        expect(tester.takeException(), isNull);
        settings.dispose();
      });
    }

    testWidgets('disposing during a roll cancels cleanly', (tester) async {
      final feedback = RecordingFeedback();
      await mount(tester, feedback: feedback);
      await tester.tap(rollButton);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(feedback.calls, 0);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('Background has no visible step under the status bar or notch', (tester) async {
    useView(tester);
    tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
    const key = ValueKey('shot');
    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(key: key, child: DiceScreen(settings: SettingsViewModel(), random: ScriptedDice(const [5]), feedback: RecordingFeedback())),
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
    for (var y = 0; y < 130; y++) {
      final a = pixel(330, y);
      final b = pixel(330, y + 1);
      for (var c = 0; c < 3; c++) {
        expect((a[c] - b[c]).abs(), lessThanOrEqualTo(1), reason: 'Colour step between rows $y and ${y + 1}: $a -> $b');
      }
    }
  });
}
