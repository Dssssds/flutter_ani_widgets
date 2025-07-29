import 'package:flutter/material.dart';

class TopHeader extends StatelessWidget {
  const TopHeader({
    super.key,
    required this.headerMainColor,
    required this.headerSecondaryColor,
  });

  final Color headerMainColor;
  final Color headerSecondaryColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 动画文本样式, 显示当前的时间
              AnimatedDefaultTextStyle(
                curve: Curves.linearToEaseOut,
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: headerMainColor,
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
                child: const Text("09"),
              ),
              // 水平间距
              const SizedBox(width: 8),
              // 红色原型指示器(可能表示其他的状态)
              const CircleAvatar(backgroundColor: Colors.red, radius: 10),
              // 弹性空间,将日期信息推到邮编
              const Spacer(),
              // 动画文本样式,
              AnimatedDefaultTextStyle(
                curve: Curves.linearToEaseOut,
                style: TextStyle(color: headerSecondaryColor, fontSize: 24),
                duration: const Duration(milliseconds: 300),
                child: const Text.rich(
                    textAlign: TextAlign.end,     // 右对齐文本
                    TextSpan(
                      text: "Sep' 30\n",         // 日期（九月30日）
                      children: [
                        TextSpan(
                          text: "Tuesday",        // 星期二
                          style: TextStyle(
                            fontSize: 16,         // 更小的字号显示星期
                          ),
                        ),
                      ],
                    ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
