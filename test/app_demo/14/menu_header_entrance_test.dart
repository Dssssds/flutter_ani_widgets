import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_header.dart';

/// Counts cream headline pixels inside the capture region.
Future<int> litPixels(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('header-capture')));
  final result = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final width = image.width;
    final height = image.height;
    image.dispose();
    var lit = 0;
    // Skip the back button and arrow: they are cream too.
    for (var y = 40; y < height; y++) {
      for (var x = 12; x < width - 90; x++) {
        final offset = (y * width + x) * 4;
        if (bytes.getUint8(offset + 3) > 200 && bytes.getUint8(offset) > 240 && bytes.getUint8(offset + 1) > 220) {
          lit++;
        }
      }
    }
    return lit;
  });
  return result!;
}

void main() {
  const key = ValueKey('header-capture');

  Future<void> mount(WidgetTester tester, {ValueNotifier<int>? visits, bool reduceMotion = false}) async {
    tester.view.physicalSize = const Size(390, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            key: key,
            child: MenuHeader(reduceMotion: reduceMotion, visits: visits),
          ),
        ),
      ),
    );
  }

  testWidgets('characters stagger in and the headline settles fully painted', (tester) async {
    await mount(tester);
    expect(await litPixels(tester), 0, reason: 'Frame zero has not painted any glyph yet');

    await tester.pump(const Duration(milliseconds: 120));
    final early = await litPixels(tester);
    expect(early, greaterThan(0), reason: 'Leading glyphs have entered');

    await tester.pumpAndSettle();
    final settled = await litPixels(tester);
    expect(settled, greaterThan(early), reason: 'Trailing glyphs finish the entrance');
  });

  testWidgets('a new visit replays the entrance from frame zero', (tester) async {
    final visits = ValueNotifier(0);
    await mount(tester, visits: visits);
    await tester.pumpAndSettle();
    final settled = await litPixels(tester);
    expect(settled, greaterThan(0));

    visits.value++;
    await tester.pump();
    expect(await litPixels(tester), 0, reason: 'The replay restarts empty');

    await tester.pumpAndSettle();
    expect(await litPixels(tester), settled, reason: 'The headline lands on the same resting frame');

    visits.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion shows the headline immediately with no entrance', (tester) async {
    await mount(tester);
    await tester.pumpAndSettle();
    final normal = await litPixels(tester);

    await mount(tester, reduceMotion: true);
    expect(await litPixels(tester), normal, reason: 'Reduced motion paints the settled frame on the first build');
    expect(tester.binding.hasScheduledFrame, isFalse, reason: 'Reduced motion leaves no ticker running');
    expect(tester.takeException(), isNull);
  });

  testWidgets('backgrounding stops the ticker instead of leaking frames', (tester) async {
    await mount(tester);
    await tester.pump(const Duration(milliseconds: 100));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.binding.hasScheduledFrame, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(await litPixels(tester), greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  test('timeline puts the last character exactly on the duration', () {
    expect(TitleEntrance.characterProgress(1, 0), 1);
    expect(TitleEntrance.characterProgress(0, 0), 0);
    expect(TitleEntrance.offset(0, 0), TitleEntrance.lift);
    expect(TitleEntrance.offset(1, 8), 0, reason: 'The ninth and last glyph has landed');
    expect(TitleEntrance.opacity(0, 0), 0);
    expect(TitleEntrance.opacity(1, 8), 1);
    // The overshoot lifts a glyph above its resting baseline before settling.
    final overshoots = [
      for (var i = 0; i < 400; i++)
        if (TitleEntrance.offset(i / 400, 0) < 0) true,
    ];
    expect(overshoots, isNotEmpty, reason: 'The entrance overshoots like MenuMotion.enterOffset');
  });

  test('a descending glyph stays inside the room the layout leaves under the title', () {
    // The non-compact title is positioned with 12px below it; a glyph dropped
    // to its lowest point must not reach the menu rows underneath.
    const breathingRoom = 12.0;
    expect(TitleEntrance.lift, lessThanOrEqualTo(breathingRoom));
    var lowest = 0.0;
    for (var i = 0; i < 400; i++) {
      final dy = TitleEntrance.offset(i / 400, 0);
      if (dy > lowest) lowest = dy;
    }
    expect(lowest, TitleEntrance.lift);
    expect(lowest, lessThanOrEqualTo(breathingRoom));
  });

  test('later characters trail earlier ones across the whole entrance', () {
    // Each character must never be ahead of its predecessor at any point on
    // the shared timeline.
    for (var frame = 0; frame <= 400; frame++) {
      final progress = frame / 400;
      for (var i = 1; i < 9; i++) {
        final earlier = TitleEntrance.characterProgress(progress, i - 1);
        final later = TitleEntrance.characterProgress(progress, i);
        expect(later, lessThanOrEqualTo(earlier), reason: 'character $i must never lead character ${i - 1}');
      }
    }
  });
}