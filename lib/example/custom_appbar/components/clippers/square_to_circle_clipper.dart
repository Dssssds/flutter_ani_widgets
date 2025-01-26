import 'package:flutter/material.dart';

/// 自定义方形到圆形的变形裁剪器
///
/// 接收一个动画进度值 t 用于控制从方形到圆形的变形
class MorphingClipper extends CustomClipper<Path> {
  MorphingClipper(this.t);

  /// 动画进度值,用于裁剪
  final double t;

  @override
  Path getClip(Size size) {
    /// 计算裁剪圆的半径
    double cornerRadius = (size.width / 2) * t;

    /// 创建路径
    Path path = Path();

    /// 添加裁剪圆
    path.addRRect(
      RRect.fromRectAndCorners(
        /// 裁剪矩形
        Rect.fromLTWH(0, 0, size.width, size.height),

        /// 裁剪圆的半径
        topLeft: Radius.circular(cornerRadius),

        /// 裁剪圆的半径
        topRight: Radius.circular(cornerRadius),

        /// 裁剪圆的半径
        bottomLeft: Radius.circular(cornerRadius),

        /// 裁剪圆的半径
        bottomRight: Radius.circular(cornerRadius),
      ),
    );

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    /// `t` 发生变化,则重新裁剪
    return (oldClipper as MorphingClipper).t != t;
  }
}
