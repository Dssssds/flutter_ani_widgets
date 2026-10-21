import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_header.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_swipe_arrow.dart';

void main() {
  Future<void> mount(
    WidgetTester tester, {
    double width = 390,
    double height = 320,
    double scale = 1,
    double pageProgress = 1,
    bool reduceMotion = false,
    bool systemReduceMotion = false,
    VoidCallback? onExit,
  }) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale), disableAnimations: systemReduceMotion),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              height: height,
              child: MenuHeader(pageProgress: pageProgress, onExit: onExit, reduceMotion: reduceMotion),
            ),
          ),
        ),
      ),
    ),
  );

  for (final width in [320.0, 390.0]) {
    for (final height in [64.0, 96.0, 170.0, 320.0]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('Bounded $width x $height at text scale $scale has no overlap', (tester) async {
          final semantics = tester.ensureSemantics();
          await mount(tester, width: width, height: height, scale: scale);
          final compact = height < 170;
          final text = find.text(compact ? 'Pick a Game' : 'Pick a\nGame');
          expect(text, findsOneWidget);
          expect(find.bySemanticsLabel('Pick a Game'), findsOneWidget);
          final bounds = tester.getRect(find.byType(MenuHeader));
          final title = tester.getRect(find.ancestor(of: text, matching: find.byType(FittedBox)));
          final arrow = tester.getRect(find.byType(MenuSwipeArrow));
          final button = tester.getRect(find.byType(IconButton));
          for (final rect in [title, arrow, button]) {
            expect(bounds.contains(rect.topLeft), isTrue);
            expect(rect.right, lessThanOrEqualTo(bounds.right));
            expect(rect.bottom, lessThanOrEqualTo(bounds.bottom));
          }
          expect(title.overlaps(arrow), isFalse);
          expect(title.overlaps(button), isFalse);
          expect(button.size, const Size(48, 48));
          expect(arrow.width, compact ? 48 : inInclusiveRange(64, 80));
          expect(find.descendant(of: find.byType(MenuSwipeArrow), matching: find.byType(AnimatedBuilder)), findsNothing);
          expect(find.byTooltip('游戏设置'), findsNothing);
          expect(tester.takeException(), isNull);
          semantics.dispose();
        });
      }
    }
  }

  testWidgets('Arrow directly tracks progress without a separate animation timeline', (tester) async {
    double direction() => tester.widget<Transform>(find.byKey(const ValueKey('menu-arrow-turn'))).transform.storage[0];
    for (final progress in [0.0, .25, .5, .75, 1.0, .75, .25, 0.0]) {
      await mount(tester, pageProgress: progress);
      expect(direction(), closeTo(2 * progress - 1, .001));
      await tester.pump(const Duration(milliseconds: 100));
      expect(direction(), closeTo(2 * progress - 1, .001));
    }
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  for (final system in [false, true]) {
    testWidgets('Reduced motion switches direction immediately (system: $system)', (tester) async {
      await mount(tester);
      for (final progress in [.25, .75, .25]) {
        await mount(tester, pageProgress: progress, reduceMotion: !system, systemReduceMotion: system);
        final turn = tester.widget<Transform>(find.byKey(const ValueKey('menu-arrow-turn')));
        expect(turn.transform.storage[0], progress < .5 ? -1 : 1);
      }
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Exit callback is optional and disabled until supplied', (tester) async {
    await mount(tester);
    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
    await tester.tap(find.byTooltip('返回案例列表'));
    var exits = 0;
    await mount(tester, onExit: () => exits++);
    await tester.tap(find.byTooltip('返回案例列表'));
    expect(exits, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Direction follows pointsLeft without flipping the eyes vertically', (tester) async {
    for (final pointsLeft in [false, true]) {
      await mount(tester, pageProgress: pointsLeft ? 0 : 1);
      await tester.pumpAndSettle();
      final turn = tester.widget<Transform>(find.byKey(const ValueKey('menu-arrow-turn')));
      expect(turn.transform.storage[0], pointsLeft ? -1 : 1);
      expect(turn.transform.storage[5], 1);
      final arrow = tester.widget<MenuSwipeArrow>(find.byType(MenuSwipeArrow));
      expect(arrow.pointsLeft, pointsLeft);
      final decorative = find.descendant(of: find.byType(MenuSwipeArrow), matching: find.byType(IgnorePointer));
      expect(tester.widget<IgnorePointer>(decorative).ignoring, isTrue);
      expect(find.descendant(of: decorative, matching: find.byType(ExcludeSemantics)), findsOneWidget);
      final customPaint = tester.widget<CustomPaint>(find.descendant(of: find.byType(MenuSwipeArrow), matching: find.byType(CustomPaint)));
      final recorder = ui.PictureRecorder();
      customPaint.painter!.paint(Canvas(recorder), const Size(200, 130));
      final picture = recorder.endRecording();
      final bytes =
          (await tester.runAsync(() async {
            final image = await picture.toImage(200, 130);
            final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
            image.dispose();
            return data;
          }))!;
      int pixel(double x, double y) {
        final px = (x * 200).floor();
        final py = (y * 130).floor();
        final index = (py * 200 + px) * 4;
        return (bytes.getUint8(index) << 24) |
            (bytes.getUint8(index + 1) << 16) |
            (bytes.getUint8(index + 2) << 8) |
            bytes.getUint8(index + 3);
      }

      expect(pixel(.65, .20), 0xD9C3F3FF, reason: 'Arrowhead points toward requested side');
      expect(pixel(.36, .48), 0x211526FF, reason: 'First eye remains upright');
      expect(pixel(.49, .48), 0x211526FF, reason: 'Second eye remains upright');
      picture.dispose();
    }
  });
}
