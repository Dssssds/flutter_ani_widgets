import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_header.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_page_indicator.dart';

import 'support/fonts.dart';

void main() {
  setUpAll(loadDisplayFont);

  Future<void> mount(
    WidgetTester tester, {
    double width = 390,
    double height = 320,
    double scale = 1,
    bool reduceMotion = false,
    bool systemReduceMotion = false,
    VoidCallback? onExit,
    ValueListenable<double>? pageProgress,
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
              child: MenuHeader(onExit: onExit, reduceMotion: reduceMotion, pageProgress: pageProgress),
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

  group('Page indicator', () {
    final indicator = find.byKey(const ValueKey('menu-page-indicator'));
    final headline = find.text('Pick a\nGame');

    /// 标题文字缩放后真正占据的矩形。FittedBox 自己的矩形是整个标题盒，不能用来判断是否重叠；
    /// getSize 给的是缩放前的版面尺寸，所以左上角和右下角都要经过变换取点。
    Rect headlineRect(WidgetTester tester) => Rect.fromPoints(tester.getTopLeft(headline), tester.getBottomRight(headline));

    testWidgets('sits in the lower right on the baseline of the second line, clear of the headline', (tester) async {
      final progress = ValueNotifier<double>(0);
      addTearDown(progress.dispose);
      await mount(tester, width: 390, height: 243, pageProgress: progress);
      expect(indicator, findsOneWidget);
      final bounds = tester.getRect(find.byType(MenuHeader));
      final text = headlineRect(tester);
      final box = tester.getRect(indicator);
      expect(box.right, closeTo(bounds.right - 24, .5));
      expect(box.left, greaterThan(text.right), reason: 'No overlap with the headline');
      expect(box.center.dy, greaterThan(text.center.dy), reason: 'Next to "Game", not next to "Pick a"');
      expect(tester.getRect(find.byType(IconButton)).overlaps(box), isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('its baseline is the baseline of the last headline line', (tester) async {
      final progress = ValueNotifier<double>(0);
      addTearDown(progress.dispose);
      // 与标题相同的样式，独立量出最后一行基线到文字顶部的距离。
      final painter = TextPainter(
        text: const TextSpan(
          text: 'Pick a\nGame',
          style: TextStyle(fontFamily: 'NeumaticGothic-Black', fontWeight: FontWeight.w400, fontSize: 140, height: .92, letterSpacing: -3),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
      )..layout();
      final lastBaseline = painter.computeLineMetrics().last.baseline;
      final layoutHeight = painter.height;
      painter.dispose();
      for (final size in const [Size(390, 243), Size(430, 319), Size(375, 260), Size(390, 280)]) {
        await mount(tester, width: size.width, height: size.height, pageProgress: progress);
        if (tester.getTopLeft(indicator).dx < tester.getBottomRight(headline).dx) continue; // 回退到右上角的尺寸不在这里检查
        final text = headlineRect(tester);
        final scale = text.height / layoutHeight;
        final headlineBaseline = text.top + lastBaseline * scale;
        final indicatorBaseline = tester.getRect(indicator).bottom - MenuPageIndicator.belowBaseline(2);
        expect((indicatorBaseline - headlineBaseline).abs(), lessThan(1), reason: '$size: headline baseline $headlineBaseline, indicator baseline $indicatorBaseline');
      }
    });

    testWidgets('moves to the top right, level with the back button, when the headline leaves no room beside "Game"', (tester) async {
      final progress = ValueNotifier<double>(0);
      addTearDown(progress.dispose);
      for (final (width, height, scale) in const [(390.0, 324.0, 1.0), (320.0, 320.0, 2.0), (390.0, 400.0, 1.0)]) {
        await mount(tester, width: width, height: height, scale: scale, pageProgress: progress);
        expect(indicator, findsOneWidget, reason: '$width x $height at $scale');
        final box = tester.getRect(indicator);
        final back = tester.getRect(find.byType(IconButton));
        expect(box.right, closeTo(width - 24, .5));
        expect(box.center.dy, closeTo(back.center.dy, 1), reason: 'Level with the back button');
        expect(box.overlaps(back), isFalse);
        expect(box.overlaps(headlineRect(tester)), isFalse, reason: '$width x $height at $scale');
        expect(box.bottom, lessThan(54), reason: 'Stays above the headline box');
      }
    });

    testWidgets('is not shown without a progress source or in the compact layout', (tester) async {
      final progress = ValueNotifier<double>(0);
      addTearDown(progress.dispose);
      await mount(tester, width: 390, height: 243);
      expect(indicator, findsNothing, reason: 'Nothing to show without a page progress');
      await mount(tester, width: 390, height: 120, pageProgress: progress);
      expect(indicator, findsNothing, reason: 'The compact single line headline fills the width');
      expect(tester.takeException(), isNull);
    });

    testWidgets('never overlaps the headline or the back button and never leaves the header, at any non-compact size', (tester) async {
      final progress = ValueNotifier<double>(0);
      addTearDown(progress.dispose);
      var bottomRight = 0;
      var topRight = 0;
      for (final width in [320.0, 360.0, 390.0, 430.0, 600.0]) {
        for (final height in [170.0, 200.0, 243.0, 320.0, 420.0]) {
          for (final scale in [1.0, 1.3, 2.0]) {
            await mount(tester, width: width, height: height, scale: scale, pageProgress: progress);
            expect(indicator, findsOneWidget, reason: '$width x $height at $scale must always show a page hint');
            final text = headlineRect(tester);
            final box = tester.getRect(indicator);
            expect(box.overlaps(text), isFalse, reason: '$width x $height at $scale overlaps the headline');
            expect(box.overlaps(tester.getRect(find.byType(IconButton))), isFalse, reason: '$width x $height at $scale overlaps the back button');
            expect(box.right, lessThanOrEqualTo(width), reason: '$width x $height at $scale leaves the header');
            expect(box.left, greaterThanOrEqualTo(0));
            expect(box.top, greaterThanOrEqualTo(0));
            expect(box.bottom, lessThanOrEqualTo(height), reason: '$width x $height at $scale falls out of the header');
            if (box.center.dy > text.center.dy) {
              bottomRight++;
            } else {
              topRight++;
            }
          }
        }
      }
      expect(bottomRight, greaterThan(10), reason: 'The lower right is used wherever it fits');
      expect(topRight, greaterThan(5), reason: 'The top right is the fallback where it does not');
    });
  });
}
