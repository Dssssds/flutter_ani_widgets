import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/app_14.dart';
import 'package:flutter_x_widgets/app_demo/14/models/game_definition.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/screens/coin_screen.dart';
import 'package:flutter_x_widgets/app_demo/14/screens/demo_screen.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';
import 'package:flutter_x_widgets/main.dart';

Future<void> secondPage(WidgetTester tester) async {
  await tester.drag(find.byKey(const ValueKey('menu-pages')), const Offset(-600, 0));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('Menu identities and availability are stable', () {
    expect(partyGames.map((game) => game.id), [
      'headbands',
      'truth-dare',
      'bottle',
      'charades',
      'would-rather',
      'dice',
      'coin',
      'pick',
      'elimination',
      'teams',
    ]);
    expect(partyGames.where((game) => game.isAvailable).map((game) => game.id), ['dice', 'coin']);
    expect(HomeScreen().demoApps.singleWhere((example) => example.title == 'APP-14(聚会游戏盒)').isFullScreen, isTrue);
  });

  test('Session settings and motion respect system preferences', () {
    final settings = SettingsViewModel();
    final standard = MotionSpec(settings.state);
    expect(standard.coinRound, const Duration(milliseconds: 2550));
    expect(standard.coinRing, const Duration(milliseconds: 750));
    settings.setMotionSpeed(MotionSpeed.fast);
    expect(MotionSpec(settings.state).coinRound, const Duration(milliseconds: 1150));
    expect(MotionSpec(settings.state, systemReduceMotion: true).coinRound, const Duration(milliseconds: 200));
    expect(MotionSpec(settings.state, systemReduceMotion: true).coinRing, Duration.zero);
    expect(MotionSpec(settings.state).route, lessThan(standard.route));
    expect(MotionSpec(settings.state, systemReduceMotion: true).reduceMotion, isTrue);
    settings.setReduceMotion(true);
    expect(MotionSpec(settings.state).pressIn, Duration.zero);
    settings.dispose();
  });

  testWidgets('Menu pages, locked entries and navigation work', (tester) async {
    await tester.pumpWidget(const App14());
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Pick a Game'), findsOneWidget);
    await tester.tap(find.text('Headbands'));
    await tester.pumpAndSettle();
    expect(find.byType(CoinScreen), findsNothing);
    await secondPage(tester);
    expect(find.bySemanticsLabel('第2页，共2页'), findsOneWidget);
    await tester.tap(find.text('Coin Toss'));
    await tester.tap(find.text('Coin Toss'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(CoinScreen), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const ValueKey('flip-button'))).onPressed, isNotNull);
    expect(find.byTooltip('关闭'), findsOneWidget);
    await tester.tap(find.byTooltip('关闭'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    final returnedRow = tester.widget<Transform>(find.byKey(const ValueKey('menu-row-1-0')));
    expect(returnedRow.transform.storage[13], greaterThan(0));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('第2页，共2页'), findsOneWidget);
    await tester.tap(find.text('Coin Toss'));
    await tester.pumpAndSettle();
    expect(find.byType(CoinScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home hides settings without removing the game menu', (tester) async {
    await tester.pumpWidget(const App14());
    await tester.pumpAndSettle();
    expect(find.text('设置'), findsNothing);
    expect(find.byTooltip('游戏设置'), findsNothing);
    expect(find.text('Headbands'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Unknown route returns home', (tester) async {
    await tester.pumpWidget(const App14());
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(DemoScreen))).pushNamed('/missing');
    await tester.pumpAndSettle();
    expect(find.text('找不到这个游戏页面'), findsOneWidget);
    await tester.tap(find.text('回到游戏首页'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Pick a Game'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Nested navigation returns to host and disposes during transition', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const App14())),
                  child: const Text('打开 Demo'),
                ),
              ),
        ),
      ),
    );
    await tester.tap(find.text('打开 Demo'));
    await tester.pumpAndSettle();
    await secondPage(tester);
    await tester.tap(find.text('Coin Toss'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Pick a Game'), findsOneWidget);
    await tester.tap(find.byTooltip('返回案例列表'));
    await tester.pumpAndSettle();
    expect(find.text('打开 Demo'), findsOneWidget);
    await tester.tap(find.text('打开 Demo'));
    await tester.pumpAndSettle();
    await secondPage(tester);
    await tester.tap(find.text('Coin Toss'));
    await tester.pump(const Duration(milliseconds: 30));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets('Small viewport $size supports large text without overflow', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MediaQuery(data: MediaQueryData(textScaler: TextScaler.linear(2)), child: App14()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await secondPage(tester);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('coin')),
        150,
        scrollable: find.descendant(of: find.byKey(const PageStorageKey('game-page-1')), matching: find.byType(Scrollable)).first,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('coin')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coin Toss'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const ValueKey('flip-button')));
      await tester.tap(find.byKey(const ValueKey('flip-button')));
      await tester.pumpAndSettle();
      expect(find.text('再抛一次'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
