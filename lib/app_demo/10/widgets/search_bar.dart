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
      child: const Row(
        children: [
          Icon(Icons.menu, color: Colors.white70),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Search your notes',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ),
          Icon(Icons.grid_view, color: Colors.white70),
          SizedBox(width: 16),
          CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage(
              'assets/images/data/b.png',
            ), // Placeholder
          ),
        ],
      ),
    );
  }
}
