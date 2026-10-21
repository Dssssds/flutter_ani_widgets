import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_meteor_background.dart';

const _interval = Duration(seconds: 5);
const _duration = Duration(seconds: 1);

void main() {
  void meteorTest(String description, Future<void> Function(WidgetTester) body) {
    testWidgets(description, (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      try {
        await body(tester);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();
      }
    });
  }

  Future<void> mount(
    WidgetTester tester, {
    bool enabled = true,
    bool reduced = false,
    bool ticker = true,
    Duration interval = _interval,
    Duration duration = _duration,
    VoidCallback? onTap,
  }) => tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: TickerMode(
          enabled: ticker,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 390,
              height: 240,
              child: Stack(
                children: [
                  Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap)),
                  Positioned.fill(child: MenuMeteorBackground(enabled: enabled, interval: interval, duration: duration)),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  MenuMeteorPainter painter(WidgetTester tester) =>
      tester.widget<CustomPaint>(find.descendant(of: find.byType(MenuMeteorBackground), matching: find.byType(CustomPaint))).painter!
          as MenuMeteorPainter;

  Future<void> start(WidgetTester tester) async {
    await tester.pump(_interval);
    await tester.pump();
    expect(painter(tester).animation.status, AnimationStatus.forward);
    await tester.pump(const Duration(milliseconds: 400));
    expect(painter(tester).animation.value, closeTo(.4, .001));
  }

  meteorTest('Default meteor cadence waits two seconds between one-second passes', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(data: const MediaQueryData(), child: SizedBox(width: 390, height: 240, child: MenuMeteorBackground())),
      ),
    );
    final animation = painter(tester).animation;
    await tester.pump(const Duration(milliseconds: 1999));
    expect(animation.status, AnimationStatus.dismissed);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(animation.status, AnimationStatus.forward);
    await tester.pump(const Duration(milliseconds: 1001));
    expect(animation.status, AnimationStatus.completed);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(animation.status, AnimationStatus.forward);
  });

  meteorTest('Waits a full interval, plays once, completes, then waits before another meteor', (tester) async {
    await mount(tester);
    final animation = painter(tester).animation;
    expect(animation.value, 0);
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pump(const Duration(milliseconds: 4999));
    expect(animation.status, AnimationStatus.dismissed);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(animation.status, AnimationStatus.forward);
    await tester.pump(const Duration(milliseconds: 500));
    expect(animation.value, closeTo(.5, .001));
    await tester.pump(const Duration(milliseconds: 501));
    expect(animation.status, AnimationStatus.completed);
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pump(const Duration(milliseconds: 4999));
    expect(animation.status, AnimationStatus.completed);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(animation.status, AnimationStatus.forward);
    await tester.pump(_duration + const Duration(milliseconds: 1));
    expect(animation.status, AnimationStatus.completed);
  });

  meteorTest('Unchanged enabled and inherited dependencies preserve the pending interval and active animation', (tester) async {
    await mount(tester);
    final originalPainter = painter(tester);
    final animation = originalPainter.animation;
    await tester.pump(const Duration(seconds: 3));
    await mount(tester);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(animation.status, AnimationStatus.forward);
    await tester.pump(const Duration(milliseconds: 300));
    final activePainter = painter(tester);
    await tester.pump(const Duration(milliseconds: 200));
    expect(identical(painter(tester), activePainter), isTrue, reason: 'Ticks repaint rather than rebuilding the widget tree');
    await mount(tester);
    expect(painter(tester).animation.value, closeTo(.5, .001));
    expect(identical(painter(tester).animation, animation), isTrue);
    await tester.pump(const Duration(milliseconds: 501));
    expect(animation.status, AnimationStatus.completed);
  });

  for (final playing in [false, true]) {
    for (final gate in ['enabled', 'reduced', 'ticker', 'inactive', 'hidden', 'paused', 'detached']) {
      meteorTest('$gate cancels ${playing ? 'playback' : 'waiting'} and resumes with a fresh full interval', (tester) async {
        await mount(tester);
        if (playing) {
          await start(tester);
        } else {
          await tester.pump(const Duration(seconds: 3));
        }
        final animation = painter(tester).animation;
        final lifecycle = switch (gate) {
          'inactive' => AppLifecycleState.inactive,
          'hidden' => AppLifecycleState.hidden,
          'paused' => AppLifecycleState.paused,
          'detached' => AppLifecycleState.detached,
          _ => null,
        };
        if (lifecycle != null) {
          tester.binding.handleAppLifecycleStateChanged(lifecycle);
          await tester.pump();
        } else {
          await mount(tester, enabled: gate != 'enabled', reduced: gate == 'reduced', ticker: gate != 'ticker');
        }
        expect(animation.value, 0);
        expect(animation.status, AnimationStatus.dismissed);
        expect(tester.binding.transientCallbackCount, 0);
        await tester.pump(const Duration(seconds: 20));
        expect(animation.value, 0);
        if (lifecycle != null) tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await mount(tester);
        await tester.pump(const Duration(milliseconds: 4999));
        expect(animation.status, AnimationStatus.dismissed);
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pump();
        expect(animation.status, AnimationStatus.forward);
        await tester.pump(const Duration(milliseconds: 200));
        expect(animation.value, closeTo(.2, .001));
      });
    }
  }

  for (final gate in ['enabled', 'reduced', 'ticker', 'lifecycle']) {
    meteorTest('Initially blocked by $gate does not schedule a meteor', (tester) async {
      if (gate == 'lifecycle') tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await mount(tester, enabled: gate != 'enabled', reduced: gate == 'reduced', ticker: gate != 'ticker');
      final animation = painter(tester).animation;
      await tester.pump(const Duration(seconds: 30));
      expect(animation.status, AnimationStatus.dismissed);
      expect(tester.binding.transientCallbackCount, 0);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await mount(tester);
      await start(tester);
    });
  }

  meteorTest('All visibility gates must allow motion before resuming', (tester) async {
    await mount(tester, enabled: false, reduced: true, ticker: false);
    await mount(tester, reduced: true, ticker: false);
    await tester.pump(const Duration(seconds: 10));
    expect(painter(tester).animation.value, 0);
    await mount(tester, ticker: false);
    await tester.pump(const Duration(seconds: 10));
    expect(painter(tester).animation.value, 0);
    await mount(tester);
    await start(tester);
  });

  meteorTest('Timing updates restart a full interval and use the new duration', (tester) async {
    await mount(tester);
    await start(tester);
    await mount(tester, interval: const Duration(seconds: 2), duration: const Duration(seconds: 2));
    final animation = painter(tester).animation;
    expect(animation.value, 0);
    await tester.pump(const Duration(milliseconds: 1999));
    expect(animation.status, AnimationStatus.dismissed);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(animation.value, closeTo(.5, .001));
  });

  for (final playing in [false, true]) {
    meteorTest('Dispose cleans up ${playing ? 'active ticker' : 'pending timer'} and lifecycle observer', (tester) async {
      await mount(tester);
      if (playing) await start(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(seconds: 30));
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  meteorTest('Decoration is clipped, isolated, non-interactive and excluded from semantics', (tester) async {
    var taps = 0;
    await mount(tester, onTap: () => taps++);
    final background = find.byType(MenuMeteorBackground);
    expect(tester.getSize(background), const Size(390, 240));
    for (final type in [IgnorePointer, ExcludeSemantics, RepaintBoundary, ClipRect]) {
      expect(find.descendant(of: background, matching: find.byType(type)), findsOneWidget);
    }
    expect(tester.widget<IgnorePointer>(find.descendant(of: background, matching: find.byType(IgnorePointer))).ignoring, isTrue);
    expect(tester.widget<ExcludeSemantics>(find.descendant(of: background, matching: find.byType(ExcludeSemantics))).excluding, isTrue);
    await tester.tapAt(const Offset(200, 100));
    expect(taps, 1);
    expect(await tester.pumpAndSettle(), lessThan(5), reason: 'Waiting has no ticking animation');
    await start(tester);
    expect(await tester.pumpAndSettle(const Duration(milliseconds: 100)), lessThanOrEqualTo(8));
    expect(painter(tester).animation.status, AnimationStatus.completed);
  });

  meteorTest('Fixed phases paint deterministic faint stars and one diagonal tail within header bounds', (tester) async {
    const size = Size(200, 120);
    Future<Uint8List> pixels(double phase) async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)..translate(10, 10);
      MenuMeteorPainter(animation: AlwaysStoppedAnimation(phase)).paint(canvas, size);
      final picture = recorder.endRecording();
      try {
        return (await tester.runAsync(() async {
          final image = await picture.toImage(220, 140);
          try {
            final data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
            return Uint8List.fromList(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
          } finally {
            image.dispose();
          }
        }))!;
      } finally {
        picture.dispose();
      }
    }

    final idle = await pixels(0);
    expect(await pixels(1), orderedEquals(idle));
    final early = await pixels(.3);
    final middle = await pixels(.5);
    final late = await pixels(.7);
    expect(await pixels(.5), orderedEquals(middle));
    for (final data in [idle, early, middle, late]) {
      var visible = 0;
      for (var y = 0; y < 140; y++) {
        for (var x = 0; x < 220; x++) {
          final alpha = data[(y * 220 + x) * 4 + 3];
          if (x < 10 || x >= 210 || y < 10 || y >= 130) expect(alpha, 0);
          if (alpha > 0) visible++;
          expect(alpha, lessThan(120), reason: 'No bright glow or high-opacity decoration');
        }
      }
      expect(visible, inInclusiveRange(28, 450));
    }
    Offset meteorHead(Uint8List data) {
      var brightest = 0;
      var point = Offset.zero;
      for (var y = 10; y < 130; y++) {
        for (var x = 10; x < 210; x++) {
          final index = (y * 220 + x) * 4 + 3;
          if (data[index] > idle[index] && data[index] > brightest) {
            brightest = data[index];
            point = Offset(x - 10.0, y - 10.0);
          }
        }
      }
      expect(brightest, greaterThan(30));
      return point;
    }

    final first = meteorHead(early);
    final second = meteorHead(middle);
    final third = meteorHead(late);
    expect(first.dx, greaterThan(second.dx));
    expect(second.dx, greaterThan(third.dx));
    expect(first.dy, lessThan(second.dy));
    expect(second.dy, lessThan(third.dy));
    expect((second - const Offset(108, 48)).distance, lessThan(4));
    const animation = AlwaysStoppedAnimation<double>(.5);
    expect(MenuMeteorPainter(animation: animation).shouldRepaint(MenuMeteorPainter(animation: animation)), isFalse);
    expect(MenuMeteorPainter(animation: animation).shouldRepaint(MenuMeteorPainter(animation: const AlwaysStoppedAnimation(.4))), isTrue);
    final recorder = ui.PictureRecorder();
    MenuMeteorPainter(animation: animation).paint(Canvas(recorder), Size.zero);
    recorder.endRecording().dispose();
  });
}
