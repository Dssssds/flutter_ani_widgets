import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/12/screens/mountain_todo_screen.dart';

class App12 extends StatelessWidget {
  const App12({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '山景待办',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF5030EF),
      ),
      home: const MountainTodoScreen(),
    );
  }
}
