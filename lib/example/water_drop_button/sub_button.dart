import 'package:flutter/material.dart';

class SubButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onPressed;

  const SubButton({
    super.key,
    required this.icon,
    this.color = Colors.white,
    this.size = 60,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed, // 可选的点击事件
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color, // 使用透明度来调整颜色
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, color: Colors.black),
        ),
      ),
    );
  }
}
