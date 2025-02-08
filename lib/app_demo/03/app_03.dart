import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/03/screens/my_lists_screen.dart';

class App03 extends StatelessWidget {
  const App03({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
      ),
      home: const MyListsScreen(),
    );
  }
}
