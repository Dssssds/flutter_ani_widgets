import 'package:flutter/material.dart';

/// 任务条目组件
/// 显示单个任务的信息，包括标题、时间、完成状态等
/// 现在支持删除线的从左到右动画效果
class TaskTile extends StatefulWidget {
  /// 任务标题
  final String title;
  /// 任务时间
  final String time;
  /// 任务完成状态
  final bool completed;
  /// 前置组件（图标或其他Widget）
  final Widget? leading;
  /// 完成状态变化回调函数
  /// 当用户点击checkbox时会被调用，传递新的完成状态
  final ValueChanged<bool?>? onChanged;

  const TaskTile({
    super.key,
    required this.title,
    required this.time,
    this.leading,
    this.completed = false,
    this.onChanged, // 新增：状态变化回调
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

/// TaskTile的状态管理类
/// 负责管理删除线动画和状态变化
class _TaskTileState extends State<TaskTile> with TickerProviderStateMixin {
  /// 删除线动画控制器
  late AnimationController _strikethroughController;
  /// 删除线动画
  late Animation<double> _strikethroughAnimation;

  @override
  void initState() {
    super.initState();
    
    /// 初始化删除线动画控制器
    /// 动画持续时间为600毫秒，提供平滑的视觉效果
    _strikethroughController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    /// 创建从0到1的线性动画
    /// 这个值将用于控制删除线的宽度比例
    _strikethroughAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _strikethroughController,
      curve: Curves.easeInOut, // 使用缓入缓出曲线，让动画更自然
    ));

    /// 如果初始状态就是完成状态，立即显示删除线（无动画）
    if (widget.completed) {
      _strikethroughController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TaskTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    /// 当完成状态发生变化时，播放相应的动画
    if (widget.completed != oldWidget.completed) {
      if (widget.completed) {
        /// 任务变为完成状态：播放删除线出现动画
        _strikethroughController.forward();
      } else {
        /// 任务变为未完成状态：播放删除线消失动画
        _strikethroughController.reverse();
      }
    }
  }

  @override
  void dispose() {
    /// 释放动画控制器资源
    _strikethroughController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// 根据是否有自定义leading组件来决定显示内容
    final leading = widget.leading != null
        ? Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
            ),
            child: widget.leading,
          )
        : Checkbox(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            value: widget.completed,
            /// 现在checkbox变为可交互的，点击时调用回调函数
            onChanged: widget.onChanged,
          );

    return ListTile(
      leading: leading,
      title: _buildAnimatedTitle(),
      trailing: Text(
        widget.time,
        style: TextStyle(
          fontSize: 18,
          /// 时间文字也根据完成状态调整颜色
          color: widget.completed ? Colors.black26 : Colors.black54,
        ),
      ),
    );
  }

  /// 构建带动画删除线效果的标题组件
  Widget _buildAnimatedTitle() {
    return Stack(
      children: [
        /// 底层：任务标题文本
        Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            /// 完成的任务文字颜色变淡，但不使用系统删除线
            color: widget.completed ? Colors.black38 : Colors.black,
          ),
        ),
        /// 顶层：自定义动画删除线
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _strikethroughAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: StrikethroughPainter(
                  progress: _strikethroughAnimation.value,
                  color: widget.completed ? Colors.black54 : Colors.transparent,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 自定义删除线绘制器
/// 负责绘制从左到右的动画删除线效果
class StrikethroughPainter extends CustomPainter {
  /// 动画进度（0.0 - 1.0）
  final double progress;
  /// 删除线颜色
  final Color color;

  StrikethroughPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    /// 如果进度为0或颜色透明，不绘制任何内容
    if (progress <= 0 || color == Colors.transparent) return;

    /// 创建画笔
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5 // 删除线粗细
      ..strokeCap = StrokeCap.round; // 圆角端点

    /// 计算删除线的垂直位置（文本中央偏上一点）
    final y = size.height * 0.45;
    
    /// 计算删除线的起始和结束位置
    const startX = 0.0;
    final endX = size.width * progress; // 根据动画进度计算终点

    /// 绘制删除线
    canvas.drawLine(
      Offset(startX, y),
      Offset(endX, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(StrikethroughPainter oldDelegate) {
    /// 当进度或颜色发生变化时重新绘制
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// 预定义的任务列表数据
/// 这些是示例任务，展示了一天的完整日程安排
final tasks = [
  const TaskTile(
    leading: Text(
      "🏃",
      style: TextStyle(
        fontSize: 20,
        // color: Colors.yellow,
      ),
    ),
    title: "跑步5公里",
    time: "05:00",
  ),
  const TaskTile(
    title: "每日晨会",
    time: "09:00",
  ),
  const TaskTile(
    title: "健身1小时",
    time: "12:30",
  ),
  const TaskTile(
    title: "写代码, 完成今日的功能计划",
    time: "14:00",
  ),
  const TaskTile(
    title: "阅读1小时",
    time: "21:00",
  ),
];
