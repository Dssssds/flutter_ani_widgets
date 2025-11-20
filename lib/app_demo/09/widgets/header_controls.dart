import 'package:flutter/material.dart';

class HeaderControls extends StatefulWidget {
  const HeaderControls({super.key});

  @override
  State<HeaderControls> createState() => _HeaderControlsState();
}

class _HeaderControlsState extends State<HeaderControls> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['Public', 'Duo', 'Private'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const Icon(Icons.notifications, size: 30, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tabWidth = (constraints.maxWidth - 8) / _tabs.length;
                  return Stack(
                    children: [
                      // 滑动指示器
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        left: 4 + (_selectedIndex * tabWidth),
                        top: 4,
                        child: Container(
                          width: tabWidth,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD200),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      // Tab 文字和点击区域
                      Row(
                        children: List.generate(
                          _tabs.length,
                          (index) => _buildTab(
                            _tabs[index],
                            _selectedIndex == index,
                            () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.power_settings_new,
              size: 20,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
