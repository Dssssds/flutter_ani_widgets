import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home
          _buildIcon('assets/images/10/checkbox.png', 0),
          // edit
          _buildIcon('assets/images/10/pen-field.png', 1),
          // Add
          _buildAddButton(2),
          // make
          _buildIcon('assets/images/10/microphone.png', 3),
          // image
          _buildIcon('assets/images/10/picture.png', 4),
        ],
      ),
    );
  }

  Widget _buildIcon(String assetPath, int index) {
    final isSelected = currentIndex == index;
    return IconButton(
      onPressed: () => onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      icon: Image.asset(
        assetPath,
        color: isSelected ? Colors.white : Colors.white38,
        width: 20,
        height: 20,
      ),
    );
  }

  Widget _buildAddButton(int index) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Color(0xFF2C2C2E), // Match bar color
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : const Color(0xFF2C2C2E),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              color: isSelected ? Colors.black : Colors.white,
              size: 27,
            ),
          ),
        ),
      ),
    );
  }
}
