import 'package:flutter/material.dart';

/// 应用颜色常量
class AppColors {
  // 主要颜色
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFF64B5F6);
  static const Color green = Color(0xFF4CAF50);
  static const Color orange = Color(0xFFFFA726);
  
  // 背景颜色
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  
  // 文本颜色
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  
  // 特殊颜色
  static const Color avatarBlue = Color(0xFF1E88E5);
  static const Color selectedCardBlue = Color(0xFF2196F3);
  static const Color unselectedCardGrey = Color(0xFFF5F5F5);
}

/// 文本样式常量
class AppTextStyles {
  // 标题样式
  static const TextStyle title = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  // 副标题样式
  static const TextStyle subtitle = TextStyle(
    fontSize: 14.0,
    color: AppColors.textSecondary,
  );
  
  // 计时器样式
  static const TextStyle timer = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  // 进度文本样式
  static const TextStyle progress = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  // 卡片标题样式
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  // 卡片内容样式
  static const TextStyle cardContent = TextStyle(
    fontSize: 14.0,
    color: Colors.white,
  );
  
  // 笔记样式
  static const TextStyle notes = TextStyle(
    fontSize: 14.0,
    color: AppColors.textPrimary,
  );
  
  // 历史会话日期样式
  static const TextStyle sessionDate = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  // 历史会话时间样式
  static const TextStyle sessionTime = TextStyle(
    fontSize: 14.0,
    color: AppColors.textSecondary,
  );
  
  // 历史会话持续时间样式
  static const TextStyle sessionDuration = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryBlue,
  );
}
