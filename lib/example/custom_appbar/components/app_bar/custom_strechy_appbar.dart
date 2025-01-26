import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/custom_appbar/components/app_bar/custom_flexible_space_bar.dart';
import 'package:flutter_x_widgets/example/custom_appbar/components/inherited_widgets/directionalit_manager.dart';

/// 自定义可伸缩 AppBar, 使用 CustomFlexibleSpaceBar 作为可伸缩空间
///
/// 这个 AppBar 是固定的,并且在背景图片上有模糊效果
class CustomStrechyAppBar extends StatelessWidget {
  const CustomStrechyAppBar({
    super.key,
    required this.mainTitle,
    required this.subTitle,
    required this.image,
    this.expandedHeight = 300,
  });

  /// AppBar 的主标题
  final String mainTitle;

  /// AppBar 的副标题
  final String subTitle;

  /// 用作 AppBar 背景的图片
  final String image;

  /// AppBar 展开时的高度
  final double expandedHeight;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      /// Enable the strechy properties of the app bar
      stretch: true,

      /// Ensure the app bar is pinned
      pinned: true,
      expandedHeight: expandedHeight,
      leading: const BackButton(),
      actions: [
        IconButton(
          onPressed: () {
            /// Change the text direction
            DirectionalityManager.of(context)?.toggleDirection();
          },
          icon: const Icon(Icons.sort),
        )
      ],
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: CustomFlexibleSpaceBar(
            background: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
            // 展开时标题的缩放效果
            expandedTitleScale: 2,
            titlePadding: const EdgeInsets.all(11.0),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mainTitle,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  subTitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
