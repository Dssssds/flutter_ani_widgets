import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/11/screens/gallery_page.dart';

class App11 extends StatelessWidget {
  const App11({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      child: const GalleryPage(),
    );
  }
}
