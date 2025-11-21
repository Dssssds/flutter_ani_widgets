import 'package:flutter/material.dart';

import '../../../example/blurfade/blur_fade.dart';
import '../models/user_model.dart';

class ListSection extends StatelessWidget {
  final List<User> users;

  const ListSection({super.key, required this.users});

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFE0E0E0),
                        child:
                            users[index].iconPath != null
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
                      const Spacer(),
                      // 如果有好友，显示重叠头像
                      if (users[index].friends.isNotEmpty)
                        SizedBox(
                          height: 44,
                          // 根据好友数量动态计算宽度 (44是头像宽, 24是重叠偏移量)
                          width:
                              44.0 +
                              (users[index].friends.take(3).length - 1) * 24.0,
                          child: Stack(
                            children: [
                              for (
                                int i = 0;
                                i < users[index].friends.take(3).length;
                                i++
                              )
                                Positioned(
                                  left: i * 24.0, // 每个头像向右偏移 24
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      image: DecorationImage(
                                        image: AssetImage(
                                          users[index].friends[i],
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      color: const Color(0xFFE0E0E0),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD200), // 亮黄色
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Add',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.person_add_alt_1,
                                size: 18,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 6), // 右侧留一点间距
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
