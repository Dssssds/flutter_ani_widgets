import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/08/widgets/count_up.dart';

class TasksSummary extends StatelessWidget {
  const TasksSummary({
    super.key,
    required this.taskCount,
    required this.meetingCount,
    required this.habitCount,
    required this.shouldAnimate,
  });

  // 任务数量
  final double taskCount;
  // 会议数量
  final double meetingCount;
  // 习惯数量
  final double habitCount;
  // 是否需要动画
  final bool shouldAnimate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, top: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '任务:',
                style: TextStyle(color: Colors.white70, fontSize: 25),
              ),
              SizedBox(width: 8),
              Text(
                '今天干啥呢',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // 统计信息的富文本 - 包含动态数据和计数动画
          Text.rich(
            TextSpan(
              text: "你今天有 ", // 开始文本
              style: const TextStyle(
                color: Colors.white60, // 半透明白色
                height: 36 / 20, // 行高比例
                fontSize: 24,
              ),
              children: [
                // 会议数量的动画计数组件
                WidgetSpan(
                  alignment: PlaceholderAlignment.top, // 顶部对齐
                  child: CountUpText(
                    emoji: "📅", // 日历表情符号
                    value: meetingCount, // 会议数量值
                    label: "个会议", // 标签文本
                    shouldAnimate: shouldAnimate, // 是否播放动画
                  ),
                ),
                // 换行：在会议数量和任务数量之间插入一个换行符
                const TextSpan(text: "\n"),
                // 任务数量的动画计数组件
                WidgetSpan(
                  alignment: PlaceholderAlignment.top, // 顶部对齐
                  child: CountUpText(
                    emoji: "✅", // 复选框表情符号
                    value: taskCount, // 任务数量值
                    label: "个任务", // 标签文本（注意末尾空格）
                    shouldAnimate: shouldAnimate, // 是否播放动画
                  ),
                ),
                // 连接词
                const TextSpan(
                  text: "and ",
                  style: TextStyle(
                    color: Colors.white60, // 半透明白色
                    fontSize: 24,
                  ),
                ),
                // 习惯数量的动画计数组件
                WidgetSpan(
                  alignment: PlaceholderAlignment.top, // 顶部对齐
                  child: CountUpText(
                    emoji: "🥋", // 武术表情符号
                    value: habitCount, // 习惯数量值
                    label: "个习惯", // 标签文本（注意末尾空格）
                    shouldAnimate: shouldAnimate, // 是否播放动画
                  ),
                ),
                const TextSpan(text: '\n'),
                // 继续的描述文本
                const TextSpan(
                  text: "今天, ",
                  style: TextStyle(
                    color: Colors.white60, // 半透明白色
                    fontSize: 24,
                  ),
                ),
                const TextSpan(
                  text: "18:00",
                  style: TextStyle(
                    color: Colors.white, // 纯白色
                    fontSize: 24,
                    fontWeight: FontWeight.bold, // 粗体强调
                  ),
                ),
                // 强调文本：空闲状态
                const TextSpan(
                  text: "后,将会属于你",
                  style: TextStyle(
                    color: Colors.white60, // 半透明白色
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.start, // 左对齐
          ),
        ],
      ),
    );
  }
}
