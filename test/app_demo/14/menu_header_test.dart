import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_header.dart';

void main() {
  Future<void> mount(
    WidgetTester tester, {
    double width = 390,
    double height = 320,
    double scale = 1,
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
              child: MenuHeader(onExit: onExit, reduceMotion: reduceMotion),
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
          final button = tester.getRect(find.byType(IconButton));
          for (final rect in [title, button]) {
            expect(bounds.contains(rect.topLeft), isTrue);
            expect(rect.right, lessThanOrEqualTo(bounds.right));
            expect(rect.bottom, lessThanOrEqualTo(bounds.bottom));
          }
          expect(title.overlaps(button), isFalse);
          expect(button.size, const Size(48, 48));
          expect(find.byTooltip('游戏设置'), findsNothing);
          expect(tester.takeException(), isNull);
          semantics.dispose();
        });
      }
    }
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
}
