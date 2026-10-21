import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/models/game_definition.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/game_menu_tile.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_motion.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/press_scale_button.dart';

void main() {
  group('Menu entrance timeline', () {
    test('MotionSpec selects standard, fast and reduced durations without changing coin timing', () {
      final standard = MotionSpec(const SettingsState());
      final fast = MotionSpec(const SettingsState(motionSpeed: MotionSpeed.fast));
      final reduced = MotionSpec(const SettingsState(motionSpeed: MotionSpeed.fast, reduceMotion: true));
      final system = MotionSpec(const SettingsState(), systemReduceMotion: true);
      expect(standard.menuEnter, const Duration(milliseconds: 1480));
      expect(fast.menuEnter, const Duration(milliseconds: 900));
      expect(reduced.menuEnter, const Duration(milliseconds: 120));
      expect(system.menuEnter, const Duration(milliseconds: 120));
      expect(standard.page, const Duration(milliseconds: 850));
      expect(fast.page, const Duration(milliseconds: 480));
      expect(standard.coinRound, const Duration(milliseconds: 2200));
      expect(fast.coinRound, const Duration(milliseconds: 1000));
      expect(reduced.coinRound, const Duration(milliseconds: 200));
    });

    test('Rows start fully below a viewport and stagger by 120ms', () {
      const viewportHeight = 700.0;
      const rowHeight = 140.0;
      for (var index = 0; index < 5; index++) {
        final targetTop = index * rowHeight;
        final distance = viewportHeight - targetTop;
        final start = index * MenuMotion.rowDelayMs / MenuMotion.enterDurationMs;
        expect(targetTop + MenuMotion.enterOffset(0, index, distance), viewportHeight);
        expect(MenuMotion.enterProgress(start, index), closeTo(0, 1e-12));
        expect(MenuMotion.enterOffset(start, index, distance), closeTo(distance, 1e-9));
        expect(MenuMotion.enterProgress(start + 1 / MenuMotion.enterDurationMs, index), greaterThan(0));
      }
      expect(MenuMotion.enterProgress(30 / MenuMotion.enterDurationMs, 0), greaterThan(0));
      expect(MenuMotion.enterProgress(30 / MenuMotion.enterDurationMs, 1), 0);
    });

    test('Each row overshoots once at 75%, settles at 1000ms and ends exactly at zero', () {
      for (var index = 0; index < 5; index++) {
        const distance = 700.0;
        final delay = index * MenuMotion.rowDelayMs;
        final peak = (delay + MenuMotion.rowDurationMs * 0.75) / MenuMotion.enterDurationMs;
        final end = (delay + MenuMotion.rowDurationMs) / MenuMotion.enterDurationMs;
        expect(MenuMotion.enterOffset(peak, index, distance), closeTo(-8, 1e-9));
        expect(MenuMotion.enterOffset(end, index, distance), 0);
        expect(MenuMotion.enterOffset(1, index, distance), 0);
        var previous = distance;
        for (var sample = 0; sample <= 300; sample++) {
          final local = sample / 400;
          final progress = (delay + local * MenuMotion.rowDurationMs) / MenuMotion.enterDurationMs;
          final offset = MenuMotion.enterOffset(progress, index, distance);
          expect(offset, greaterThanOrEqualTo(-8.000000001));
          expect(offset, lessThanOrEqualTo(previous + 1e-9));
          previous = offset;
        }
        previous = -8;
        for (var sample = 301; sample <= 400; sample++) {
          final local = sample / 400;
          final progress = (delay + local * MenuMotion.rowDurationMs) / MenuMotion.enterDurationMs;
          final offset = MenuMotion.enterOffset(progress, index, distance);
          expect(offset, greaterThanOrEqualTo(previous - 1e-9));
          expect(offset, lessThanOrEqualTo(0));
          previous = offset;
        }
      }
    });

    test('Out-of-range progress clamps and reduced motion fades without displacement', () {
      for (var index = 0; index < 5; index++) {
        expect(MenuMotion.enterOffset(-1, index, 700), 700);
        expect(MenuMotion.enterOffset(2, index, 700), 0);
        for (final progress in [0.0, 0.25, 0.75, 1.0]) {
          expect(MenuMotion.enterOffset(progress, index, 700, reduceMotion: true), 0);
          expect(MenuMotion.enterOpacity(progress, reduceMotion: true), progress);
          expect(MenuMotion.enterOpacity(progress), 1);
        }
      }
      expect(MenuMotion.enterOpacity(-1, reduceMotion: true), 0);
      expect(MenuMotion.enterOpacity(2, reduceMotion: true), 1);
    });
  });

  group('Menu horizontal timeline', () {
    test('Five rows follow the requested stagger with exact stable endpoints', () {
      for (var index = 0; index < 5; index++) {
        expect(MenuMotion.rowProgress(0, index), 0);
        expect(MenuMotion.rowProgress(1, index), 1);
        expect(MenuMotion.rowProgress(-1, index), 0);
        expect(MenuMotion.rowProgress(2, index), 1);
        expect(MenuMotion.rowProgress(0.5, index), closeTo(0.8 - index * 0.15, 1e-12));
      }
    });

    test('Paired bands touch continuously in either direction and cancel to exact origins', () {
      const width = 390.0;
      for (var index = 0; index < 5; index++) {
        for (var step = 0; step <= 100; step++) {
          final progress = step / 100;
          final outgoing = MenuMotion.pageOffset(progress, index, width, incoming: false);
          final incoming = MenuMotion.pageOffset(progress, index, width, incoming: true);
          expect(incoming - outgoing, closeTo(width, 1e-10));
          expect(outgoing, inInclusiveRange(-width, 0));
          expect(incoming, inInclusiveRange(0, width));
        }
        expect(MenuMotion.pageOffset(0, index, width, incoming: false), 0);
        expect(MenuMotion.pageOffset(0, index, width, incoming: true), width);
        expect(MenuMotion.pageOffset(1, index, width, incoming: false), -width);
        expect(MenuMotion.pageOffset(1, index, width, incoming: true), 0);
        expect(MenuMotion.pageOffset(0.5, index, width, incoming: true, reduceMotion: true), 0);
      }
    });
  });

  testWidgets('Menu rows retain rounded defaults and support fixed seamless bands with safe content padding', (tester) async {
    final motion = MotionSpec(const SettingsState());
    const game = GameDefinition('coin', 'Coin Toss', '抛硬币', route: '/coin');
    var taps = 0;
    Widget tile({bool seamless = false, EdgeInsets padding = EdgeInsets.zero}) => MaterialApp(
      home: Center(
        child: SizedBox(
          width: 390,
          height: 140,
          child: GameMenuTile(
            game: game,
            color: Colors.yellow,
            icon: Icons.toll,
            motion: motion,
            seamless: seamless,
            contentPadding: padding,
            onPressed: () => taps++,
          ),
        ),
      ),
    );
    await tester.pumpWidget(tile());
    final rounded = tester.widget<PressScaleButton>(find.byType(PressScaleButton));
    expect(rounded.pressScale, 0.97);
    expect(rounded.borderRadius, BorderRadius.circular(18));
    final iconLeft = tester.getTopLeft(find.byIcon(Icons.toll)).dx;
    await tester.pumpWidget(tile(seamless: true, padding: const EdgeInsets.only(left: 32, right: 20)));
    final seamless = tester.widget<PressScaleButton>(find.byType(PressScaleButton));
    expect(seamless.borderRadius, BorderRadius.zero);
    expect(seamless.pressScale, 1);
    expect(tester.getTopLeft(find.byIcon(Icons.toll)).dx, iconLeft + 32 + 4);
    final ink = tester.widget<Ink>(find.byType(Ink));
    expect((ink.decoration! as BoxDecoration).borderRadius, BorderRadius.zero);
    expect(tester.getSize(find.byType(Ink)), const Size(390, 140));
    final gesture = await tester.startGesture(tester.getCenter(find.byType(GameMenuTile)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    expect(tester.getSize(find.byType(Ink)), const Size(390, 140));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });
}
