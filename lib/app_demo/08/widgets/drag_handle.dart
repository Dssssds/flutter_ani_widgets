import 'package:flutter/material.dart';

class DragHandle extends StatelessWidget {
  const DragHandle({super.key, required this.verticalOffset, required this.isVisible});

  final double verticalOffset;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        curve: Curves.linearToEaseOut,
        duration: Duration(milliseconds: 400),
        margin: EdgeInsets.symmetric(vertical: verticalOffset),
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: isVisible ? Colors.grey.shade400 : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
