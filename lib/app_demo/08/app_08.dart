
import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/08/screens/todolist_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class App08 extends StatelessWidget {
  const App08({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp (
      debugShowCheckedModeBanner: false,
      title: '动画待办事项',
      theme: ThemeData(
        textTheme:GoogleFonts.poppinsTextTheme(),
      ),
      home: const TodolistScreen(),
    );
  }

}