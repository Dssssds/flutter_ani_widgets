import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/settings_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';

/// Reduced motion keeps the bottom-sheet surface but replaces its slide with a fade.
Future<void> showGameSheet({required BuildContext context, required SettingsViewModel settings, required WidgetBuilder builder}) {
  final motion = MotionSpec.of(context, settings.state);
  if (!motion.reduceMotion) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle: AnimationStyle(duration: motion.route, reverseDuration: motion.route),
      builder: builder,
    );
  }
  return Navigator.of(context).push<void>(
    _ReducedSheetRoute(
      duration: motion.route,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      themes: InheritedTheme.capture(from: context, to: Navigator.of(context).context),
      builder: builder,
    ),
  );
}

class _ReducedSheetRoute extends RawDialogRoute<void> {
  _ReducedSheetRoute({
    required Duration duration,
    required String barrierLabel,
    required CapturedThemes themes,
    required WidgetBuilder builder,
  }) : super(
         barrierDismissible: true,
         barrierLabel: barrierLabel,
         barrierColor: Colors.black54,
         transitionDuration: duration,
         pageBuilder: (context, _, _) {
           final theme = Theme.of(context).bottomSheetTheme;
           return themes.wrap(
             SafeArea(
               bottom: false,
               child: Align(
                 alignment: Alignment.bottomCenter,
                 child: Material(
                   color: theme.modalBackgroundColor ?? theme.backgroundColor ?? Theme.of(context).colorScheme.surface,
                   shape: theme.shape,
                   clipBehavior: Clip.antiAlias,
                   child: ConstrainedBox(
                     constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height - MediaQuery.paddingOf(context).top),
                     child: Builder(builder: builder),
                   ),
                 ),
               ),
             ),
           );
         },
         transitionBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
       );

  @override
  AnimationController createAnimationController() => AnimationController(
    vsync: navigator!,
    duration: transitionDuration,
    reverseDuration: reverseTransitionDuration,
    animationBehavior: AnimationBehavior.preserve,
  );
}
