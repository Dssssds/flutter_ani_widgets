import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/design_tokens.dart';

/// 宽屏时把 App 内容限制在 430 宽度内，外侧保持设计稿设备底色。
class PipFrame extends StatelessWidget {
  final Widget child;

  const PipFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= App15Design.contentMaxWidth) {
          return child;
        }
        return ColoredBox(
          color: App15Theme.deviceBackground,
          child: Center(
            child: SizedBox(
              width: App15Design.contentMaxWidth,
              height: constraints.maxHeight,
              child: ColoredBox(color: App15Theme.paper, child: child),
            ),
          ),
        );
      },
    );
  }
}
