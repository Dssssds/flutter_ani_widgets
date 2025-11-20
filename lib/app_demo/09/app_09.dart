import 'package:flutter/material.dart';

import 'screens/main_container.dart';

class App09 extends StatelessWidget {
  const App09({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF4FD2F8), // Bright Cyan
        fontFamily: 'Courier', // Monospaced fallback for retro feel
        useMaterial3: true,
      ),
      home: const MainContainer(),
    );
  }
}
