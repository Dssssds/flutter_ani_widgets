import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/theme/party_theme.dart';

/// 游戏页外壳：关闭按钮、居中的标题、舞台。
///
/// 右侧不放任何按钮，标题相对整个页面水平居中，不会因为右侧为空而偏移。
class GameScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? background;

  const GameScaffold({super.key, required this.title, required this.child, this.background});

  /// 顶部栏高度；舞台布局需要据此换算屏幕位置。
  static const double headerHeight = 56;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A090F),
      // 背景放在 SafeArea 外面铺满整屏，状态栏/灵动岛那一段才不会露出脚手架底色，
      // 与下方渐变之间也就没有明显的色阶。
      body: Stack(
        children: [
          if (background != null) Positioned.fill(child: background!),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  // 顶部栏要占满整行宽度，关闭按钮才会贴在左边而不是挤在标题旁。
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: headerHeight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: PartyTheme.chalk, fontSize: 22, fontWeight: FontWeight.w700, height: 1.2),
                            ),
                          ),
                          const Positioned(left: 6, top: 4, child: _CloseButton()),
                        ],
                      ),
                    ),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 圆形半透明底的关闭按钮；可点击区域固定为 48×48。
class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        tooltip: '关闭',
        onPressed: () => Navigator.of(context).pop(),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: .12),
          foregroundColor: PartyTheme.chalk,
          fixedSize: const Size(40, 40),
          minimumSize: const Size(40, 40),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
        icon: const Icon(Icons.close_rounded, size: 22),
      ),
    );
  }
}
