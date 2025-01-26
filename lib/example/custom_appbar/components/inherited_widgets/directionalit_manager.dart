import 'package:flutter/material.dart';

/// 用于更新文字方向的自定义 InheritedWidget
///
/// 这个 widget 用于管理应用的文字方向
class DirectionalityManager extends InheritedWidget {
  /// 要使用的文字方向
  final TextDirection textDirection;

  /// 切换文字方向的回调函数
  final VoidCallback toggleDirection;

  /// 构造函数
  const DirectionalityManager({
    super.key,
    required this.textDirection,
    required this.toggleDirection,
    required super.child,
  });

  /// 从 [BuildContext] 中获取 [DirectionalityManager]
  static DirectionalityManager? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DirectionalityManager>();
  }

  @override
  bool updateShouldNotify(DirectionalityManager oldWidget) {
    return textDirection != oldWidget.textDirection;
  }
}
