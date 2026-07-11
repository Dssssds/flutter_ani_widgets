import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/13/screens/glow_chat_screen.dart';

class App13 extends StatelessWidget {
  const App13({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '流光聊天',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF5030EF),
      ),
      home: const GlowChatScreen(),
    );
  }
}
