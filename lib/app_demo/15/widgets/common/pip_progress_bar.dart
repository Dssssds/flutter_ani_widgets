import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';

class PipProgressBar extends StatelessWidget {
  final double fraction;
  final double width;
  final double height;
  final String? semanticsValue;

  const PipProgressBar({super.key, required this.fraction, this.width = 100, this.height = 11, this.semanticsValue});

  @override
  Widget build(BuildContext context) {
    final clamped = fraction.clamp(0.0, 1.0);

    return Semantics(
      container: true,
      label: '学习进度',
      value: semanticsValue,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: App15Theme.progressTrack,
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(color: App15Theme.ink, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2 - 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(widthFactor: clamped, heightFactor: 1, child: const ColoredBox(color: App15Theme.yellow)),
            ),
          ),
        ),
      ),
    );
  }
}
