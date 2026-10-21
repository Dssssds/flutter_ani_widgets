import 'dart:math';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_meteor_background.dart';

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
    MeteorConfig config = const MeteorConfig(),
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
                  Positioned.fill(
                    child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap),
                  ),
                  Positioned.fill(child: MenuMeteorBackground(enabled: enabled, config: config)),
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

  meteorTest('Field constructor produces a deterministic empty field and respects seeded rng', (tester) async {
    final empty = MeteorField(random: Random(1));
    expect(empty.count, 0);
    expect(empty.streaks, isEmpty);

    // Field with built-in randomness: configurable.
    const config = MeteorConfig(
      flightSeconds: 3,
      maxConcurrent: 4,
      appearFraction: .3,
      vanishFraction: .2,
      minBrightness: .3,
      maxBrightness: 1.0,
    );
    final seeded = MeteorField(random: Random(7));
    expect(seeded.canSpawn(config), isTrue);
    seeded.spawn(config);
    seeded.spawn(config);
    seeded.spawn(config);
    expect(seeded.count, 3);
    expect(seeded.canSpawn(config), isTrue);
    seeded.spawn(config);
    expect(seeded.canSpawn(config), isFalse, reason: 'maxConcurrent=4 caps the field');
  });

  meteorTest('Meteor.advance grows age until it reaches 1', (tester) async {
    var meteor = _meteor(direction: const Offset(1, 1), brightness: .5, lifeSeconds: 1)
      ..advance(const Duration(milliseconds: 250));
    expect(meteor.age, closeTo(.25, .001));
    meteor.advance(const Duration(milliseconds: 250));
    expect(meteor.age, closeTo(.5, .001));
    meteor.advance(const Duration(milliseconds: 500));
    expect(meteor.age, 1.0);
  });

  meteorTest('Meteor visibility curve ramps up, holds, ramps down across the lifetime', (tester) async {
    const config = MeteorConfig(appearFraction: .3, vanishFraction: .2);
    var meteor = _meteor(direction: const Offset(1, 0), brightness: 1, lifeSeconds: 1);
    meteor.advance(const Duration(milliseconds: 50));
    // age 0.05 -> inside appear ramp, visibility small but non-zero.
    expect(_visibility(meteor, config), greaterThan(0));
    expect(_visibility(meteor, config), lessThan(.25));

    meteor.advance(const Duration(milliseconds: 250));
    // age 0.30 -> just past appear end, visibility near 1.
    expect(_visibility(meteor, config), greaterThan(.9));

    meteor.advance(const Duration(milliseconds: 500));
    // age 0.80 -> inside vanish ramp, visibility still substantial.
    expect(_visibility(meteor, config), greaterThan(0));

    meteor.advance(const Duration(milliseconds: 199));
    // age 0.999 -> essentially 0.
    expect(_visibility(meteor, config), lessThan(.05));
  });

  meteorTest('Field spawn respects min/max concurrent and removes meteors past their lifetime', (tester) async {
    final field = MeteorField(random: Random(11));
    const config = MeteorConfig(maxConcurrent: 3, flightSeconds: .1);
    field.spawn(config);
    field.spawn(config);
    field.spawn(config);
    field.spawn(config); // ignored
    expect(field.count, 3);
    field.advance(const Duration(milliseconds: 200), config);
    expect(field.count, 0, reason: 'All meteors expired past age=1');
  });

  meteorTest('Every streak travels from the top-right corner toward the bottom-left one', (tester) async {
    const config = MeteorConfig(fanSpreadDeg: 7, angleJitterDeg: 2, entryScatter: .07);
    for (var seed = 0; seed < 200; seed++) {
      final field = MeteorField(random: Random(seed));
      field.spawn(config);
      expect(field.count, 1);
      final meteor = field.streaks.first;

      // The axis points left and down: that is the top-right -> bottom-left
      // diagonal in Flutter's y-down space.
      expect(meteor.direction.dx, lessThan(0), reason: 'seed $seed must head left');
      expect(meteor.direction.dy, greaterThan(0), reason: 'seed $seed must head down');

      // The entry point hugs the top-right corner.
      expect(meteor.origin.dx, greaterThan(.9));
      expect(meteor.origin.dy, lessThan(.1));

      // The head moves strictly left and strictly down as it ages.
      final start = meteor.headPosition(0);
      final mid = meteor.headPosition(.5);
      final end = meteor.headPosition(1);
      expect(mid.dx, lessThan(start.dx));
      expect(mid.dy, greaterThan(start.dy));
      expect(end.dx, lessThan(mid.dx));
      expect(end.dy, greaterThan(mid.dy));

      // It must run past the bottom-left corner, not stop inside the header.
      expect(end.dx, lessThan(0));
      expect(end.dy, greaterThan(1));
    }
  });

  meteorTest('Streak angles stay within the configured fan around the main axis', (tester) async {
    const config = MeteorConfig(axisAngleDeg: 135, fanSpreadDeg: 7, angleJitterDeg: 2);
    for (var seed = 0; seed < 200; seed++) {
      final field = MeteorField(random: Random(seed));
      field.spawn(config);
      final direction = field.streaks.first.direction;
      final deg = math.atan2(direction.dy, direction.dx) * 180 / math.pi;
      // Normalize into [0, 360).
      final normalized = deg < 0 ? deg + 360 : deg;
      expect(normalized, closeTo(135, 9), reason: 'seed $seed drifted outside the fan');
    }
  });

  meteorTest('Spawned streaks land on distinct lanes so they do not overlap', (tester) async {
    const config = MeteorConfig(maxConcurrent: 3, fanSpreadDeg: 7, angleJitterDeg: 0);
    final field = MeteorField(random: Random(5));
    field.spawnBatch(config, 3);
    final angles = field.streaks
        .map((m) => math.atan2(m.direction.dy, m.direction.dx))
        .toList();
    for (var i = 0; i < angles.length; i++) {
      for (var j = i + 1; j < angles.length; j++) {
        final delta = (angles[i] - angles[j]).abs();
        expect(delta, greaterThan(.005), reason: 'streaks $i and $j share the same lane');
      }
    }
  });

  meteorTest('decoration structure clips, isolates and excludes semantics', (tester) async {
    var taps = 0;
    await mount(tester, onTap: () => taps++);
    final background = find.byType(MenuMeteorBackground);
    for (final type in [IgnorePointer, ExcludeSemantics, RepaintBoundary, ClipRect]) {
      expect(find.descendant(of: background, matching: find.byType(type)), findsOneWidget);
    }
    expect(tester.widget<IgnorePointer>(find.descendant(of: background, matching: find.byType(IgnorePointer))).ignoring, isTrue);
    expect(tester.widget<ExcludeSemantics>(find.descendant(of: background, matching: find.byType(ExcludeSemantics))).excluding, isTrue);
    await tester.tapAt(const Offset(200, 100));
    expect(taps, 1);
  });

  meteorTest('disableAnimations, ticker-disabled, and lifecycle gates suppress scheduling', (tester) async {
    for (final entry in {'reduced', 'ticker', 'lifecycle'}.toList()) {
      if (entry == 'lifecycle') tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await mount(
        tester,
        enabled: entry != 'enabled',
        reduced: entry == 'reduced',
        ticker: entry != 'ticker',
      );
      await tester.pump(const Duration(seconds: 30));
      expect(tester.binding.transientCallbackCount, 0, reason: '$entry must produce zero scheduled frames');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    }
  });

  meteorTest('Reduced motion yields no streak spawns even after a long pump', (tester) async {
    await mount(tester, reduced: true);
    await tester.pump(const Duration(seconds: 12));
    final p = painter(tester);
    final field = p.field;
    expect(field.count, 0);
    expect(tester.binding.transientCallbackCount, 0);
  });

  meteorTest('Pixel scans: nothing painted outside the header, alpha below blinding ceiling', (tester) async {
    const config = MeteorConfig(
      flightSeconds: .8,
      speedJitter: 0,
      maxConcurrent: 6,
      spawnRange: Duration.zero,
      spawnJitter: Duration.zero,
    );
    Future<Uint8List> pixels(MeteorField field) async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)..translate(10, 10);
      MenuMeteorPainter(field: field, config: config).paint(canvas, const Size(200, 120));
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

    // Two fields: very bright (all max) and very dim (all min), nothing should
    // push past the bright-glow ceiling once blurred together.
    final bright = MeteorField(random: Random(7));
    final dim = MeteorField(random: Random(11));
    for (var i = 0; i < 6; i++) {
      bright.spawn(const MeteorConfig(maxBrightness: 1.0, minBrightness: 1.0));
      dim.spawn(const MeteorConfig(maxBrightness: .3, minBrightness: .3));
    }
    // Move both into their visible mid-life window.
    bright.advance(const Duration(milliseconds: 300), config);
    dim.advance(const Duration(milliseconds: 300), config);

    final brightData = await pixels(bright);
    final dimData = await pixels(dim);
    for (final data in [brightData, dimData]) {
      for (var y = 0; y < 140; y++) {
        for (var x = 0; x < 220; x++) {
          final alpha = data[(y * 220 + x) * 4 + 3];
          if (x < 10 || x >= 210 || y < 10 || y >= 130) expect(alpha, 0, reason: 'No paint outside header');
          expect(alpha, lessThan(230));
        }
      }
    }
    // The bright run paints strictly more pixels than the dim run, asserting
    // the brightness coefficient actually drives visual prominence.
    int paintPixels(Uint8List data) {
      var count = 0;
      for (var i = 3; i < data.length; i += 4) {
        if (data[i] > 0) count++;
      }
      return count;
    }

    expect(paintPixels(brightData), greaterThan(paintPixels(dimData)));
  });

  meteorTest('End-to-end: a fresh field with active meteors paints visible pixels', (tester) async {
    const config = MeteorConfig(
      flightSeconds: 5,
      maxConcurrent: 6,
      spawnRange: Duration(milliseconds: 1),
      spawnJitter: Duration.zero,
    );
    // Drop a 6-meteor burst directly into a field and age them into their
    // visible window — this bypasses the scheduler/Timer plumbing and proves
    // the painter can produce a visible result.
    final field = MeteorField(random: Random(42));
    field.spawnBatch(config, config.maxConcurrent);
    field.advance(const Duration(milliseconds: 250), config);
    expect(field.count, config.maxConcurrent);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    MenuMeteorPainter(field: field, config: config).paint(canvas, const Size(390, 240));
    final picture = recorder.endRecording();
    // Both toImage and toByteData must run inside runAsync: the widget-test
    // binding uses a fake async zone where real GPU work would never complete.
    final data = await tester.runAsync(() async {
      final image = await picture.toImage(390, 240);
      try {
        final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        return bytes!.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    });
    picture.dispose();
    var visible = 0;
    for (var i = 3; i < data!.length; i += 4) {
      if (data[i] > 0) visible++;
    }
    expect(visible, greaterThan(0), reason: 'Painter must paint visible pixels for an active field');
  });
}

/// Reconstruction of the painter's visibility math so the unit test can verify
/// the age curve without bringing up a painter.
double _visibility(Meteor meteor, MeteorConfig config) {
  final age = meteor.age;
  if (age <= 0 || age >= 1) return 0;
  final appearEnd = config.appearFraction;
  final vanishStart = 1 - config.vanishFraction;
  if (age < appearEnd) return Curves.easeIn.transform(age / appearEnd);
  if (age > vanishStart) return Curves.easeOut.transform((1 - age) / config.vanishFraction);
  return 1;
}

/// Builds a [Meteor] with sensible defaults for the unit tests.
Meteor _meteor({
  required Offset direction,
  required double brightness,
  required double lifeSeconds,
  Offset origin = const Offset(1, 0),
  double travelDistance = 1.7,
}) => Meteor(
  direction: direction,
  brightness: brightness,
  lifeSeconds: lifeSeconds,
  origin: origin,
  travelDistance: travelDistance,
);
