import 'package:flutter/material.dart';

class RetroNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final VoidCallback? onFabPressed;

  const RetroNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.onFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Black Bar
          Container(
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem('assets/images/friends.png', "Friends", 0),
                _buildNavItem('assets/images/chat.png', "Chat", 1),
                const SizedBox(width: 60), // Space for FAB
                _buildNavItem('assets/images/shop.png', "Shop", 2),
                _buildNavItem('assets/images/profile.png', "Profile", 3),
              ],
            ),
          ),

          // FAB
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onFabPressed,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD200),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4FD2F8), width: 4),
                ),
                child: const Icon(Icons.mic_off, color: Colors.black, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String imagePath, String label, int index) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap?.call(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: 26,
            height: 26,
            color: isSelected ? const Color(0xFFFFD200) : Colors.white,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFFD200) : Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
