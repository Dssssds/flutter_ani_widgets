import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundColor = Color(0xFF1e1e1e); // 黑色背景
  static const Color numberButtonColor = Color(0xFF333333); // 数字按钮颜色
  static const Color operatorButtonColor = Color(0xFFFFB202); // 运算符按钮颜色 (橙色)
  static const Color clearButtonColor = Color(0xFF616161); // 清除按钮
  static const Color numberTextColor = Colors.white; // 文本颜色
  static const Color operatorTextColor = Colors.white; // 文本颜色
  static const Color transparentColor = Colors.transparent; // 透明颜色
}

/// 应用图片资源管理类
/// 集中管理所有图片资源的路径常量
class AppImages {
  // 私有构造函数，防止实例化
  const AppImages._();

  /// 计算器背景图片
  static const String calculatorBackground = 'assets/images/app-04-bg.jpg';

  // 在这里可以继续添加其他图片资源路径
}

/// 文字字体
class AppFonts {
  static const String neumaticGothicSemiBold = 'NeumaticGothic-SemiBold';
  static const String sfProDisplayRegular = 'SF Pro Display';
}
