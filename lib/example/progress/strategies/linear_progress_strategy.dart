import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/progress/progress_bar.dart';

class LinearProgressStrategy implements ProgressAnimationStrategy {
  @override
  Widget buildProgressWidget({
    required double progress,
    required Animation<double> animation,
    required BuildContext context,
    required ProgressStyle style,
  }) {
    return Container(
      width: style.width,
      height: style.height,
      padding: style.padding,
      child: ClipRRect(
        borderRadius: style.borderRadius ?? BorderRadius.circular(8),
        child: Stack(
          children: [
            Container(color: style.backgroundColor),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: style.primaryColor,
                  gradient: style.gradientColors != null
                      ? LinearGradient(
                          colors: style.gradientColors!,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
