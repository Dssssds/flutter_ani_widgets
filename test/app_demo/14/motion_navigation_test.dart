import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/screens/navigation/demo_routes.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';

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
}
