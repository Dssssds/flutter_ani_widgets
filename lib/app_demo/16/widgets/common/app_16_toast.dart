import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/motion/app_16_motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';

class App16Toast extends StatelessWidget {
  const App16Toast({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: message.isEmpty ? 0 : 1,
        duration: App16MotionSpec.motion(context, App16MotionSpec.toastFade),
        curve: Curves.easeOut,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
            decoration: BoxDecoration(
              color: App16Colors.toastBg,
              borderRadius: BorderRadius.circular(9),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x264F2F45),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Text(
              message,
              key: const ValueKey<String>('app-16-toast'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
