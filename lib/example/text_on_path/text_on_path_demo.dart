import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/text_on_path/text_on_path_editor.dart';

class TextOnPathDemo extends StatelessWidget {
  const TextOnPathDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // 设置默认主题为暗色模式
      darkTheme: ThemeData.dark(), // 设置暗色主题以确保保持暗色
      themeMode: ThemeMode.dark,
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: TextOnPathEditor()),
      ),
    );
  }
}
