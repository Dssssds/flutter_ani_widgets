import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E), // Dark Grey
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu, color: Colors.white70),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Search your notes',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ),
          const Icon(Icons.grid_view, color: Colors.white70),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage(
              'assets/images/data/a.png',
            ), // Placeholder
          ),
        ],
      ),
    );
  }
}
