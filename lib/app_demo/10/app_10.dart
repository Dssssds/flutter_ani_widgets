import 'package:flutter/material.dart';

import 'screens/home_page.dart';

class App10 extends StatelessWidget {
  const App10({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        fontFamily:
            'SF Pro Display', // Use a modern font if available, or fallback
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}
