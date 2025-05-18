import 'package:flutter/material.dart';

import '../models/session_model.dart';
import '../utils/constants.dart';

/// 历史会话卡片组件
class SessionCard extends StatelessWidget {
  final Session session;
  final bool isSelected;
  final VoidCallback? onTap;

  const SessionCard({
    Key? key,
    required this.session,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 格式化日期
    final dateStr = _formatDate(session.date);

    // 格式化持续时间
    final durationStr = _formatDuration(session.duration);

    return GestureDetector(
      onTap: onTap,
      // 添加点击效果反馈
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? AppColors.primaryBlue.withOpacity(0.4)
                : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
              spreadRadius: isSelected ? 2 : 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 日期和时间段
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    session.timeOfDay,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 持续时间
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    durationStr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 格式化日期
  String _formatDate(DateTime? date) {
    if (date == null) {
      // 返回固定日期用于演示
      return 'June 22, 2023';
    }

    // 获取月份名称
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    // 使用月份名称数组获取正确的月份名称
    final monthName = months[date.month - 1];
    return '$monthName ${date.day}, ${date.year}';
  }

  // 格式化持续时间
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    // 按照截图格式：例如 "5:12 min"
    return '${minutes}:${seconds.toString().padLeft(2, '0')} min';
  }
}
