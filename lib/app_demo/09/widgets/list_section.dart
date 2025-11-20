import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../../../example/blurfade/blur_fade.dart';

class ListSection extends StatelessWidget {
  final List<User> users;
  
  const ListSection({
    super.key,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Invite Button with BlurFade animation
          BlurFadeContent(
            delay: Duration.zero,
            isVisble: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: Colors.black, size: 28),
                  SizedBox(width: 12),
                  Text(
                    "Invite friends",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // User Items with BlurFade animation
          ...List.generate(users.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BlurFadeContent(
                delay: Duration(milliseconds: 100 * (index + 1)),
                isVisble: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFE0E0E0),
                        child: users[index].iconPath != null
                            ? ClipOval(
                                child: Image.asset(
                                  users[index].iconPath!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.person, color: Colors.black),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        users[index].name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
