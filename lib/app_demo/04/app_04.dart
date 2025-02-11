import 'package:flutter/material.dart';

import 'screens/calculator_screen.dart';
import 'utils/constants.dart';

class App04 extends StatelessWidget {
  const App04({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D计算器',
      theme: ThemeData(
        useMaterial3: true, // 使用 Material Design 3 主题
        brightness: Brightness.dark, // 设置暗色主题
        primarySwatch: Colors.grey, // 主色调设置为灰色
      ),
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(AppImages.calculatorBackground),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: const CalculatorScreen(),
      ),
    );
  }
}
