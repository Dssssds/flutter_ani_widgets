import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/06/screens/glass_screen.dart';

class App06 extends StatelessWidget {
  const App06({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IOS26玻璃效果',
      theme: ThemeData(
        useMaterial3: true, // 使用 Material Design 3 主题
        brightness: Brightness.light, // 设置亮色主题 
        primarySwatch: Colors.blue, // 主色调设置为蓝色
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // 设置脚手架背景色
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const GlassScreen(),
      debugShowCheckedModeBanner: false, // 隐藏调试标记
    );
  }
}
