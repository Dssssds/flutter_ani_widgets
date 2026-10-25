import 'package:flutter/widgets.dart';

class PipMotionSpec {
  final bool reduceMotion;

  const PipMotionSpec({required this.reduceMotion});

  factory PipMotionSpec.of(BuildContext context) {
    return PipMotionSpec(reduceMotion: MediaQuery.maybeOf(context)?.disableAnimations ?? false);
  }

  Duration get buttonPress => _effective(const Duration(milliseconds: 100));

  Duration get navTransition => _effective(const Duration(milliseconds: 280));

  Duration get navIcon => _effective(const Duration(milliseconds: 180));

  Duration get feedbackRise => _effective(const Duration(milliseconds: 280));

  Duration get comboPop => _effective(const Duration(milliseconds: 320));

  Duration get cheer => _effective(const Duration(milliseconds: 460));

  Duration get wordFly => _effective(const Duration(milliseconds: 360));

  Duration get celebrationPop => _effective(const Duration(milliseconds: 500));

  Duration get modalPop => _effective(const Duration(milliseconds: 180));

  Duration _effective(Duration duration) => reduceMotion ? Duration.zero : duration;
}
