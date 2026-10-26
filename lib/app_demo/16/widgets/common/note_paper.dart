import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';

class NotePaper extends StatelessWidget {
  const NotePaper({
    super.key,
    required this.text,
    required this.color,
    required this.width,
    required this.height,
    this.rotation = -6,
    this.fontSize = 17,
    this.listItem = false,
  });

  final String text;
  final Color color;
  final double width;
  final double height;
  final double rotation;
  final double fontSize;
  final bool listItem;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * math.pi / 180,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: listItem ? 4 : 8,
          vertical: listItem ? 3 : 6,
        ),
        decoration: BoxDecoration(
          color: color,
          boxShadow: const [
            BoxShadow(
              color: Color(0x12674C37),
              offset: Offset(1, 2),
              blurRadius: 3,
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: listItem ? 3 : 4,
          overflow: TextOverflow.ellipsis,
          style: App16Typography.hand(
            fontSize: fontSize,
            height: 1.4,
            color: App16Colors.noteText,
          ),
        ),
      ),
    );
  }
}
