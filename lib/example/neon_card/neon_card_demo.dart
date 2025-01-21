import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/neon_card/neon_card.dart';
import 'package:flutter_x_widgets/example/neon_card/neon_text.dart';

class NeonGradientCardDemo extends StatelessWidget {
  const NeonGradientCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 300,
        height: 200,
        child: Center(
          child: NeonCard(
            intensity: 0.7,
            glowSpread: 0.8,
            child: SizedBox(
              width: 300,
              height: 200,
              child: Center(
                child: GradientText(
                  text: '霓虹\n渐变\n卡片',
                  fontSize: 40,
                  gradientColors: [
                    // Pink
                    Color.fromARGB(255, 255, 41, 117),
                    Color.fromARGB(255, 255, 41, 117),
                    Color.fromARGB(255, 9, 221, 222), // Cyan
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
