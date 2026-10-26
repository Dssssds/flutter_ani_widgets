import 'package:flutter/widgets.dart';

abstract final class App16MotionSpec {
  static const press = Duration(milliseconds: 180);
  static const tab = Duration(milliseconds: 240);
  static const paperEntrance = Duration(milliseconds: 420);
  static const stickerFlight = Duration(milliseconds: 680);
  static const toast = Duration(milliseconds: 4200);
  static const toastFade = Duration(milliseconds: 200);
  static const firstEntranceGuard = Duration(milliseconds: 600);

  static const tabCurve = Cubic(0.2, 0.75, 0.25, 1);

  static Duration motion(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }
}
