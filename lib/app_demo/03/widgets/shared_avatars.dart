import 'package:flutter/material.dart';

class SharedAvatars extends StatelessWidget {
  final List<String> userIds; // 这里主要是用户 id 列表, 而不是头像的 url
  final double avatarSize;

  const SharedAvatars(
      {super.key, required this.userIds, this.avatarSize = 24.0});

  @override
  Widget build(BuildContext context) {
    String avatarUrl =
        'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-01.jpg'; // 使用 dicebear API 生成头像
    return Row(
      children: userIds.take(3).map((userId) {
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl), // 使用 userId 作为种子生成不同头像
            radius: avatarSize / 2,
          ),
        );
      }).toList(), // 需要转换为 List<Widget>
    );
  }
}
