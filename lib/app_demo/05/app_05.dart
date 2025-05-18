import 'package:flutter/material.dart';

class App05 extends StatelessWidget {
  const App05({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '认知APP',
      theme: ThemeData(
        useMaterial3: true, // 使用 Material Design 3 主题
        brightness: Brightness.dark, // 设置暗色主题
        primarySwatch: Colors.grey, // 主色调设置为灰色
      ),
      home: Container(
        decoration: const BoxDecoration(),
        child: const Text('认知APP'),
      ),
    );
  }
}
