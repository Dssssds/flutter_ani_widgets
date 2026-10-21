import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/random_source.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/feedback_service.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/screens/coin_screen.dart';
import 'package:flutter_x_widgets/app_demo/14/screens/demo_screen.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';

/// Demo 内部路由，不接管 Showcase 的导航。
abstract final class DemoRoutes {
  static Route<void> create(
    RouteSettings route,
    SettingsViewModel settings,
    MotionSpec motion,
    VoidCallback? onExit, {
    ValueNotifier<int>? menuVisits,
    RandomSource? random,
    FeedbackService? feedback,
  }) {
    final Widget page = switch (route.name) {
      '/' => DemoScreen(settings: settings, onExit: onExit, menuVisits: menuVisits),
      '/coin' => CoinScreen(settings: settings, random: random, feedback: feedback),
      _ => const _UnknownRouteScreen(),
    };
    return _DemoPageRoute(route: route, settingsModel: settings, initialMotion: motion, page: page);
  }
}

/// Read current preferences again on pop, rather than retaining push-time motion.
class _DemoPageRoute extends PageRouteBuilder<void> {
  final SettingsViewModel settingsModel;
  final MotionSpec initialMotion;

  _DemoPageRoute({required RouteSettings route, required this.settingsModel, required this.initialMotion, required Widget page})
    : super(settings: route, pageBuilder: (_, _, _) => page);

  MotionSpec get _motion => MotionSpec(
    settingsModel.state,
    systemReduceMotion: navigator == null ? initialMotion.reduceMotion : MediaQuery.maybeOf(navigator!.context)?.disableAnimations ?? false,
  );

  @override
  Duration get transitionDuration => _motion.route;

  @override
  Duration get reverseTransitionDuration => _motion.route;

  @override
  AnimationController createAnimationController() => AnimationController(
    vsync: navigator!,
    duration: transitionDuration,
    reverseDuration: reverseTransitionDuration,
    animationBehavior: AnimationBehavior.preserve,
  );

  @override
  bool didPop(void result) {
    controller?.reverseDuration = reverseTransitionDuration;
    return super.didPop(result);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return ListenableBuilder(
      listenable: settingsModel,
      builder: (context, _) {
        final motion = MotionSpec.of(context, settingsModel.state);
        final fade = FadeTransition(opacity: animation, child: child);
        if (motion.reduceMotion) return fade;
        return SlideTransition(
          position: Tween(begin: const Offset(0, 0.025), end: Offset.zero).animate(animation.drive(CurveTween(curve: Curves.easeOut))),
          child: fade,
        );
      },
    );
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('找不到这个游戏页面', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                FilledButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: const Text('回到游戏首页')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
