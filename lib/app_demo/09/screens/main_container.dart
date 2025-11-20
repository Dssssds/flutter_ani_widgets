import 'package:flutter/material.dart';
import '../widgets/retro_nav_bar.dart';
import 'retro_home_page.dart';
import 'chat_page.dart';
import 'shop_page.dart';
import 'profile_page.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  // 所有页面列表
  final List<Widget> _pages = const [
    RetroHomePage(),
    ChatPage(),
    ShopPage(),
    ProfilePage(),
  ];

  void _handleNavigation(int index) {
    setState(() {
      _currentIndex = index;
    });
    debugPrint('📍 Navigate to index: $index');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: RetroNavBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
        onFabPressed: () {
          debugPrint('🎤 FAB pressed');
          // TODO: Handle FAB press
        },
      ),
    );
  }
}
