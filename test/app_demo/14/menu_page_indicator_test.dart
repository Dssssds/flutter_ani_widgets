import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/screens/demo_screen.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_page_indicator.dart';

import 'support/fonts.dart';

void main() {
  setUpAll(loadDisplayFont);

  final indicator = find.byKey(const ValueKey('menu-page-indicator'));

  String label(WidgetTester tester) =>
      tester.widget<Text>(find.descendant(of: indicator, matching: find.byType(Text))).textSpan!.toPlainText();
  List<double> dotWidths(WidgetTester tester) => [
    for (final dot in find.descendant(of: indicator, matching: find.byType(Container)).evaluate()) tester.getSize(find.byElementPredicate((e) => e == dot)).width,
  ];

  Future<ValueNotifier<double>> mount(WidgetTester tester, {double progress = 0, bool reduceMotion = false}) async {
    final notifier = ValueNotifier<double>(progress);
    addTearDown(notifier.dispose);
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: MenuPageIndicator(progress: notifier, reduceMotion: reduceMotion)))),
    );
    return notifier;
  }

  group('MenuPageIndicator', () {
    testWidgets('shows the current page out of two and switches at the midpoint', (tester) async {
      final progress = await mount(tester);
      expect(label(tester), '1 / 2');
      for (final (value, expected) in [(.49, '1 / 2'), (.51, '2 / 2'), (1.0, '2 / 2'), (.75, '2 / 2'), (.25, '1 / 2'), (0.0, '1 / 2')]) {
        progress.value = value;
        await tester.pump();
        expect(label(tester), expected, reason: 'progress $value');
      }
    });

    testWidgets('the active dot stretches into a pill and follows the drag continuously', (tester) async {
      final progress = await mount(tester);
      expect(dotWidths(tester), [22, 6]);
      progress.value = .5;
      await tester.pump();
      expect(dotWidths(tester), [14, 14]);
      progress.value = .25;
      await tester.pump();
      final quarter = dotWidths(tester);
      expect(quarter[0], inExclusiveRange(14, 22));
      expect(quarter[1], inExclusiveRange(6, 14));
      progress.value = 1;
      await tester.pump();
      expect(dotWidths(tester), [6, 22]);
      for (final size in tester.widgetList<Container>(find.descendant(of: indicator, matching: find.byType(Container)))) {
        expect(size.constraints?.maxHeight, 6);
      }
    });

    testWidgets('reduced motion jumps between pages instead of interpolating', (tester) async {
      final progress = await mount(tester, reduceMotion: true);
      for (final (value, expected) in [(.3, [22.0, 6.0]), (.5, [6.0, 22.0]), (.7, [6.0, 22.0]), (.2, [22.0, 6.0])]) {
        progress.value = value;
        await tester.pump();
        expect(dotWidths(tester), expected, reason: 'progress $value');
      }
    });

    testWidgets('it is only a hint: no touch handling and nothing for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await mount(tester);
      expect(tester.widget<IgnorePointer>(find.ancestor(of: indicator, matching: find.byType(IgnorePointer)).first).ignoring, isTrue);
      expect(find.bySemanticsLabel(RegExp('1 / 2')), findsNothing, reason: 'The menu itself already announces page 1 of 2');
      semantics.dispose();
    });

    test('measurements are sensible', () {
      final width = MenuPageIndicator.widthFor(2);
      expect(width, inExclusiveRange(60, 140), reason: 'With the real display font the indicator is under 140pt wide');
      expect(MenuPageIndicator.widthFor(3), greaterThan(width));
      expect(MenuPageIndicator.belowBaseline(2), inExclusiveRange(0, 24));
    });
  });

  group('On the home screen', () {
    Future<SettingsViewModel> mountHome(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      // 减少动态效果会关掉流星，页面才能安静下来。
      final settings = SettingsViewModel()..setReduceMotion(true);
      addTearDown(settings.dispose);
      await tester.pumpWidget(MaterialApp(home: DemoScreen(settings: settings)));
      await tester.pumpAndSettle();
      return settings;
    }

    testWidgets('follows paging by dragging the menu and by dragging the header', (tester) async {
      await mountHome(tester);
      expect(label(tester), '1 / 2');
      await tester.drag(find.byKey(const ValueKey('menu-pages')), const Offset(-350, 0));
      await tester.pumpAndSettle();
      expect(label(tester), '2 / 2');
      expect(dotWidths(tester), [6, 22]);
      await tester.drag(find.byKey(const ValueKey('menu-header')), const Offset(350, 0));
      await tester.pumpAndSettle();
      expect(label(tester), '1 / 2', reason: 'The indicator must not swallow the header drag');
      expect(dotWidths(tester), [22, 6]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a released short drag springs back and the indicator returns with it', (tester) async {
      await mountHome(tester);
      await tester.drag(find.byKey(const ValueKey('menu-pages')), const Offset(-120, 0));
      await tester.pumpAndSettle();
      expect(label(tester), '1 / 2');
      expect(dotWidths(tester), [22, 6]);
    });

    testWidgets('with normal motion the dots move while the finger is still down', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final settings = SettingsViewModel();
      addTearDown(settings.dispose);
      await tester.pumpWidget(MaterialApp(home: DemoScreen(settings: settings)));
      await tester.pump(const Duration(seconds: 3));
      final gesture = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('menu-pages'))));
      await gesture.moveBy(const Offset(-20, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(-100, 0));
      await tester.pump();
      final widths = dotWidths(tester);
      expect(widths[0], inExclusiveRange(6, 22));
      expect(widths[1], inExclusiveRange(6, 22));
      expect(label(tester), '1 / 2', reason: 'Not yet past the midpoint');
      await gesture.moveBy(const Offset(-160, 0));
      await tester.pump();
      expect(label(tester), '2 / 2');
      await gesture.up();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpWidget(const SizedBox());
    });
  });
}
