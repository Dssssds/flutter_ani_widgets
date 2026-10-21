import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/screens/demo_screen.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_swipe_arrow.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_motion.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/game_menu_tile.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_meteor_background.dart';

void main() {
  Future<void> mount(WidgetTester tester, {SettingsViewModel? settings, ValueNotifier<int>? visits}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('menu-capture'),
        child: MaterialApp(home: DemoScreen(settings: settings ?? SettingsViewModel(), menuVisits: visits)),
      ),
    );
  }

  Offset translation(WidgetTester tester, int row, {int page = 0}) {
    final transform = tester.widget<Transform>(find.byKey(ValueKey('menu-row-$page-$row')));
    return Offset(transform.transform.storage[12], transform.transform.storage[13]);
  }

  testWidgets('Page palettes move with whole tiles and slanted underlays use their own page colors', (tester) async {
    await mount(tester);
    await tester.pumpAndSettle();
    final first = tester.widget<GameMenuTile>(find.byKey(const ValueKey('headbands')));
    expect(first.color, PartyTheme.menuColor(0, 0));
    expect(first.nextColor, PartyTheme.menuColor(0, 1));
    await tester.drag(find.byKey(const ValueKey('menu-pages')), const Offset(-350, 0));
    await tester.pumpAndSettle();
    final second = tester.widget<GameMenuTile>(find.byKey(const ValueKey('dice')));
    expect(second.color, PartyTheme.menuColor(1, 0));
    expect(second.nextColor, PartyTheme.menuColor(1, 1));
    expect(second.color, isNot(first.color));
    expect(tester.widget<GameMenuTile>(find.byKey(const ValueKey('teams'))).nextColor, isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Header meteor pauses under pages and popup routes without restarting menu entry', (tester) async {
    final settings = SettingsViewModel();
    await mount(tester, settings: settings);
    await tester.pumpAndSettle();
    final home = tester.element(find.byType(DemoScreen));
    bool enabled() => tester.widget<MenuMeteorBackground>(find.byType(MenuMeteorBackground, skipOffstage: false)).enabled;
    expect(enabled(), isTrue);
    for (var kind = 0; kind < 3; kind++) {
      if (kind == 0) {
        Navigator.of(home).push(MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('cover'))));
      } else if (kind == 1) {
        showDialog<void>(context: home, builder: (_) => const AlertDialog(content: Text('cover')));
      } else {
        showModalBottomSheet<void>(context: home, builder: (_) => const SizedBox(height: 100));
      }
      await tester.pumpAndSettle();
      expect(enabled(), isFalse);
      Navigator.of(home).pop();
      await tester.pumpAndSettle();
      expect(enabled(), isTrue);
      expect(translation(tester, 0).dy, 0);
    }
    settings.setReduceMotion(true);
    await tester.pump();
    expect(enabled(), isFalse);
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets('All ten menu assets share fixed bounds and decode on both pages', (tester) async {
    await mount(tester);
    await tester.pumpAndSettle();
    for (final entry
        in {
          'headbands': 'headbands.png',
          'truth-dare': 'truth_or_dare.png',
          'bottle': 'spin_the_bottle.png',
          'charades': 'charades.png',
          'would-rather': 'would_you_rather.png',
          'dice': 'dice.png',
          'coin': 'coin_toss.png',
          'pick': 'pick_one.png',
          'elimination': 'elimination.png',
          'teams': 'random-team.png',
        }.entries) {
      if (entry.key == 'dice') {
        await tester.drag(find.byKey(const ValueKey('menu-pages')), const Offset(-350, 0));
        await tester.pumpAndSettle();
      }
      final imageFinder = find.descendant(of: find.byKey(ValueKey(entry.key)), matching: find.byType(Image));
      final image = tester.widget<Image>(imageFinder);
      await tester.runAsync(() => precacheImage(image.image, tester.element(imageFinder)));
      await tester.pump();
      expect((image.image as AssetImage).assetName, 'assets/images/14/${entry.value}');
      expect(image.fit, BoxFit.contain);
      expect(image.excludeFromSemantics, isTrue);
      expect(tester.getSize(imageFinder), const Size(56, 56));
      final texts = tester.widgetList<Text>(find.descendant(of: find.byKey(ValueKey(entry.key)), matching: find.byType(Text))).toList();
      expect(texts.first.style!.fontWeight, FontWeight.w900);
      expect(texts.last.style!.fontWeight, FontWeight.w600);
      final raw = tester.widget<RawImage>(find.descendant(of: imageFinder, matching: find.byType(RawImage)));
      expect(raw.image, isNotNull, reason: 'The bundled image must decode rather than display its fallback');
    }
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Menu extends through bottom safe area and entry remains visible after 760ms', (tester) async {
    tester.view.padding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.resetPadding);
    await mount(tester);
    await tester.pump(const Duration(milliseconds: 760));
    expect(translation(tester, 4).dy, greaterThan(0));
    await tester.pumpAndSettle();
    final viewport = tester.getRect(find.byKey(const ValueKey('menu-viewport')));
    final last = tester.getRect(find.byKey(const ValueKey('would-rather')));
    expect(viewport.bottom, 844);
    expect(last.bottom, closeTo(844, .01));
    final tile = tester.widget<Padding>(
      find.descendant(of: find.byKey(const ValueKey('would-rather')), matching: find.byType(Padding)).last,
    );
    expect(tile.padding.resolve(TextDirection.ltr).bottom, greaterThanOrEqualTo(34));
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Entry starts below viewport, staggers, overshoots and settles into seamless rows', (tester) async {
    await mount(tester);
    final viewport = tester.getRect(find.byKey(const ValueKey('menu-viewport')));
    expect(tester.getTopLeft(find.byKey(const ValueKey('headbands'))).dy, greaterThan(viewport.bottom));
    await tester.pump(const Duration(milliseconds: 100));
    expect(translation(tester, 0).dy, lessThan(viewport.height + 24));
    expect(translation(tester, 4).dy, closeTo(104 + 24, 0.01));
    await tester.pumpAndSettle();
    final first = tester.getRect(find.byKey(const ValueKey('headbands')));
    final next = tester.getRect(find.byKey(const ValueKey('truth-dare')));
    expect(first.left, 0);
    expect(first.right, 390);
    expect(first.bottom, next.top);
    expect(first.height, 104);
    expect(first.top, viewport.top);
    expect(tester.getRect(find.byKey(const ValueKey('would-rather'))).bottom, viewport.bottom);
    expect(translation(tester, 0), Offset.zero);
    expect(find.byKey(const ValueKey('pagination')), findsNothing);
    expect(find.textContaining('更多游戏'), findsNothing);
    expect(find.byTooltip('游戏设置'), findsNothing);
    expect(find.text('设置'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Dragging cascades rows, cancellation restores and header can page both directions', (tester) async {
    await mount(tester);
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('menu-pages'))));
    await gesture.moveBy(const Offset(-20, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(-110, 0));
    await tester.pump();
    expect(translation(tester, 0).dx, isNot(translation(tester, 4).dx));
    await gesture.moveBy(const Offset(125, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('第1页，共2页'), findsOneWidget);
    expect(translation(tester, 0), Offset.zero);
    await tester.drag(find.byKey(const ValueKey('menu-header')), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('第2页，共2页'), findsOneWidget);
    await tester.drag(find.byKey(const ValueKey('menu-pages')), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('第1页，共2页'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Header fills menu whitespace and arrow follows drag and cancellation', (tester) async {
    await mount(tester);
    await tester.pumpAndSettle();
    double arrowScale() => tester.widget<Transform>(find.byKey(const ValueKey('menu-arrow-turn'))).transform.storage[0];
    void expectSynchronized() {
      final page = tester.widget<PageView>(find.byKey(const ValueKey('menu-pages'))).controller!.page!;
      expect(arrowScale(), closeTo(2 * page - 1, .001));
    }

    final header = tester.getRect(find.byKey(const ValueKey('menu-header')));
    final viewport = tester.getRect(find.byKey(const ValueKey('menu-viewport')));
    expect(header.height, 324);
    expect(header.bottom, viewport.top);
    expectSynchronized();
    final pages = find.byKey(const ValueKey('menu-pages'));
    final gesture = await tester.startGesture(tester.getCenter(pages));
    await gesture.moveBy(const Offset(-20, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(-120, 0));
    await tester.pump();
    expectSynchronized();
    final forwardScale = arrowScale();
    expect(forwardScale, inExclusiveRange(-1, 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(arrowScale(), forwardScale, reason: 'Holding the drag must not run an independent arrow animation');
    await gesture.moveBy(const Offset(70, 0));
    await tester.pump();
    expectSynchronized();
    expect(arrowScale(), lessThan(forwardScale));
    await gesture.cancel();
    await tester.pumpAndSettle();
    expectSynchronized();
    await tester.drag(pages, const Offset(-350, 0));
    await tester.pumpAndSettle();
    expectSynchronized();
    final reverse = await tester.startGesture(tester.getCenter(pages));
    await reverse.moveBy(const Offset(20, 0));
    await tester.pump();
    await reverse.moveBy(const Offset(100, 0));
    await tester.pump();
    expectSynchronized();
    await reverse.moveBy(const Offset(-60, 0));
    await tester.pump();
    expectSynchronized();
    await reverse.cancel();
    await tester.pumpAndSettle();
    expectSynchronized();
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Released swipe retains a visible slow cascade before settling', (tester) async {
    await mount(tester);
    await tester.pumpAndSettle();
    final pages = find.byKey(const ValueKey('menu-pages'));
    final gesture = await tester.startGesture(tester.getCenter(pages));
    await gesture.moveBy(const Offset(-20, 0));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(-230, 0));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));
    final controller = tester.widget<PageView>(pages).controller!;
    expect(controller.page, greaterThan(0));
    expect(controller.page, lessThan(1));
    final turn = tester.widget<Transform>(find.byKey(const ValueKey('menu-arrow-turn')));
    expect(turn.transform.storage[0], closeTo(2 * controller.page! - 1, .001));
    expect(translation(tester, 0).dx, isNot(translation(tester, 4).dx));
    await tester.pumpAndSettle();
    expect(controller.page, closeTo(1, .001));
    expect(translation(tester, 4, page: 1), Offset.zero);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Painted cascade keeps colored bands across page seams', (tester) async {
    await mount(tester);
    await tester.pumpAndSettle();
    final pages = find.byKey(const ValueKey('menu-pages'));
    final gesture = await tester.startGesture(tester.getCenter(pages));
    await gesture.moveBy(const Offset(-20, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(-160, 0));
    await tester.pump();
    final viewport = tester.getRect(find.byKey(const ValueKey('menu-viewport')));
    final menuTop = viewport.bottom - 104 * 5;
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('menu-capture')));
    final captured = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final width = image.width;
      image.dispose();
      return (bytes!, width);
    });
    final (bytes, width) = captured!;
    for (var row = 0; row < 5; row++) {
      expect(PartyTheme.menuColor(0, row), isNot(PartyTheme.menuColor(1, row)));
      final y = (menuTop + 104 * (row + .08)).floor();
      for (final x in [2, 80, 200, 385]) {
        final offset = (y * width + x) * 4;
        final progress = tester.widget<PageView>(pages).controller!.page!;
        final seam = width * (1 - MenuMotion.rowProgress(progress, row));
        final expected = PartyTheme.menuColor(x < seam ? 0 : 1, row).toARGB32();
        expect(bytes.getUint8(offset), (expected >> 16) & 255, reason: 'row $row, x $x');
        expect(bytes.getUint8(offset + 1), (expected >> 8) & 255, reason: 'row $row, x $x');
      }
    }
    // 斜切交界下方的三角由下一行颜色填满；抽样不能落到页面底色。
    for (final row in [0, 3]) {
      for (var x = 2; x < 388; x += 7) {
        for (var dy = 1; dy < 14; dy += 3) {
          final y = (menuTop + (row + 1) * 104 - dy).floor();
          final offset = (y * width + x) * 4;
          final rgb = (bytes.getUint8(offset) << 16) | (bytes.getUint8(offset + 1) << 8) | bytes.getUint8(offset + 2);
          expect(rgb, isNot(PartyTheme.background.toARGB32() & 0xFFFFFF));
        }
      }
    }
    await gesture.up();
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Small screen paging aligns vertical scroll slots and entry blocks activation', (tester) async {
    final visits = ValueNotifier(0);
    await mount(tester, visits: visits);
    tester.view.physicalSize = const Size(390, 450);
    await tester.pumpAndSettle();
    final first = find.descendant(of: find.byKey(const PageStorageKey('game-page-0')), matching: find.byType(Scrollable)).first;
    await tester.drag(first, const Offset(0, -120));
    await tester.pumpAndSettle();
    final scroll = tester.state<ScrollableState>(first).position.pixels;
    expect(scroll, greaterThan(0));
    await tester.drag(find.byKey(const ValueKey('menu-pages')), const Offset(-350, 0));
    await tester.pumpAndSettle();
    final second = find.descendant(of: find.byKey(const PageStorageKey('game-page-1')), matching: find.byType(Scrollable)).first;
    expect(tester.state<ScrollableState>(second).position.pixels, closeTo(scroll, 0.01));
    visits.value++;
    await tester.pump();
    final blocked = find.ancestor(of: find.byKey(const ValueKey('coin')), matching: find.byType(ExcludeFocus));
    expect(tester.widget<ExcludeFocus>(blocked.first).excluding, isTrue);
    await tester.pumpWidget(const SizedBox());
    visits.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets('System reduced motion, interrupted entry and resize settle without ticker errors', (tester) async {
    await mount(tester);
    await tester.pump(const Duration(milliseconds: 120));
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpAndSettle();
    expect(translation(tester, 0).dy, 0);
    expect(tester.widget<MenuSwipeArrow>(find.byType(MenuSwipeArrow)).pointsLeft, isTrue);
    await tester.drag(find.byKey(const ValueKey('menu-pages')), const Offset(120, 0));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('第1页，共2页'), findsOneWidget);
    expect(tester.widget<MenuSwipeArrow>(find.byType(MenuSwipeArrow)).pointsLeft, isTrue);
    await tester.drag(find.byKey(const ValueKey('menu-pages')), const Offset(-350, 0));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('第2页，共2页'), findsOneWidget);
    expect(tester.widget<MenuSwipeArrow>(find.byType(MenuSwipeArrow)).pointsLeft, isFalse);
    tester.view.physicalSize = const Size(844, 390);
    await tester.pumpAndSettle();
    expect(translation(tester, 0, page: 1), Offset.zero);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Visit replays current page, settings do not replay and reduced motion has no displacement', (tester) async {
    final visits = ValueNotifier(0);
    final settings = SettingsViewModel();
    await mount(tester, settings: settings, visits: visits);
    await tester.pumpAndSettle();
    await tester.drag(find.byKey(const ValueKey('menu-pages')), const Offset(-350, 0));
    await tester.pumpAndSettle();
    visits.value++;
    await tester.pump();
    expect(translation(tester, 0, page: 1).dy, greaterThan(0));
    await tester.pumpAndSettle();
    settings.setHapticsEnabled(false);
    await tester.pumpAndSettle();
    expect(translation(tester, 0, page: 1).dy, 0);
    settings.setReduceMotion(true);
    visits.value++;
    await tester.pump();
    expect(translation(tester, 0, page: 1).dy, 0);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('第1页，共2页'), findsOneWidget);
    expect(tester.widget<MenuSwipeArrow>(find.byType(MenuSwipeArrow)).pointsLeft, isTrue);
    await tester.pumpWidget(const SizedBox());
    visits.dispose();
    settings.dispose();
    expect(tester.takeException(), isNull);
  });
}
