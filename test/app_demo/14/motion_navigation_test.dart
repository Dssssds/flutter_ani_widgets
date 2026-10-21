import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/screens/navigation/demo_routes.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/sheets/show_game_sheet.dart';

void main() {
  testWidgets('Existing route adopts system reduced motion on exit without a slide', (tester) async {
    final settings = SettingsViewModel();
    final reduced = ValueNotifier(false);
    final navigator = GlobalKey<NavigatorState>();
    addTearDown(settings.dispose);
    addTearDown(reduced.dispose);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        builder:
            (context, child) => ValueListenableBuilder<bool>(
              valueListenable: reduced,
              builder: (context, value, _) => MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: value), child: child!),
            ),
        home: const SizedBox(),
      ),
    );
    final route = DemoRoutes.create(const RouteSettings(name: '/missing'), settings, MotionSpec(settings.state), null);
    navigator.currentState!.push(route);
    await tester.pumpAndSettle();
    expect(find.ancestor(of: find.text('找不到这个游戏页面'), matching: find.byType(SlideTransition)), findsOneWidget);
    reduced.value = true;
    await tester.pump();
    expect(find.ancestor(of: find.text('找不到这个游戏页面'), matching: find.byType(SlideTransition)), findsNothing);
    expect((route as TransitionRoute<void>).reverseTransitionDuration, const Duration(milliseconds: 120));
    navigator.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('找不到这个游戏页面'), findsOneWidget);
    expect(find.ancestor(of: find.text('找不到这个游戏页面'), matching: find.byType(SlideTransition)), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('找不到这个游戏页面'), findsNothing);
  });

  for (final fast in [false, true]) {
    testWidgets('${fast ? 'Fast' : 'Standard'} sheets use configured slide duration', (tester) async {
      final settings = SettingsViewModel();
      if (fast) settings.setMotionSpeed(MotionSpeed.fast);
      addTearDown(settings.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => TextButton(
                  onPressed: () => showGameSheet(context: context, settings: settings, builder: (_) => const Text('sheet content')),
                  child: const Text('open'),
                ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final context = tester.element(find.text('sheet content'));
      final route = ModalRoute.of(context)!;
      expect(route, isA<ModalBottomSheetRoute<void>>());
      expect(route.transitionDuration, Duration(milliseconds: fast ? 140 : 280));
      Navigator.of(context).pop();
      await tester.pumpAndSettle();
    });
  }

  for (final system in [false, true]) {
    testWidgets('${system ? 'System' : 'App'} reduced sheets fade in place and dismiss with back', (tester) async {
      final settings = SettingsViewModel()..setReduceMotion(!system);
      addTearDown(settings.dispose);
      tester.binding.platformDispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(disableAnimations: system);
      addTearDown(tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => showGameSheet(
                        context: context,
                        settings: settings,
                        builder: (_) => const SizedBox(width: double.infinity, height: 180, child: Text('sheet content')),
                      ),
                  child: const Text('open'),
                ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 30));
      final sheet = find.text('sheet content');
      final top = tester.getTopLeft(sheet);
      final route = ModalRoute.of(tester.element(sheet))!;
      expect(route, isNot(isA<ModalBottomSheetRoute<void>>()));
      expect(route.transitionDuration, const Duration(milliseconds: 120));
      expect(route.animation!.value, greaterThan(0));
      expect(route.animation!.value, lessThan(1));
      expect(find.ancestor(of: sheet, matching: find.byType(SlideTransition)), findsNothing);
      await tester.pump(const Duration(milliseconds: 40));
      expect(tester.getTopLeft(sheet), top);
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(sheet, findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
