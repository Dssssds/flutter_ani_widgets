import 'package:flutter/material.dart';

/// 健康数据摘要组件
/// 展示用户的步数、睡眠时间和运动时间等健康指标
/// 采用现代化的卡片式设计，支持动画效果
class HealthSummary extends StatelessWidget {
  const HealthSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      /// 外层容器装饰
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          /// 步数统计卡片
          Expanded(
            child: _StatCard(
              icon: "🚶‍♂️",
              value: "4.7K",
              label: "步数",
              subtitle: "今日目标",
              gradient: LinearGradient(
                colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              iconBackground: Color(0xFF1976D2),
            ),
          ),
          SizedBox(width: 12),
          
          /// 睡眠时间统计卡片
          Expanded(
            child: _StatCard(
              icon: "🌙",
              value: "6.37",
              label: "小时",
              subtitle: "睡眠时间",
              gradient: LinearGradient(
                colors: [Color(0xFFAB47BC), Color(0xFF8E24AA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              iconBackground: Color(0xFF4A148C),
            ),
          ),
          SizedBox(width: 12),
          
          /// 运动时间统计卡片
          Expanded(
            child: _StatCard(
              icon: "🏃‍♂️",
              value: "36",
              label: "分钟",
              subtitle: "运动时间",
              gradient: LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              iconBackground: Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }
}

/// 现代化的统计卡片组件
/// 具有渐变背景、阴影效果和交互动画
class _StatCard extends StatefulWidget {
  /// 表情符号图标
  final String icon;
  /// 数值
  final String value;
  /// 单位标签
  final String label;
  /// 副标题描述
  final String subtitle;
  /// 渐变背景色
  final LinearGradient gradient;
  /// 图标背景色
  final Color iconBackground;

  const _StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.iconBackground,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

/// 统计卡片的状态管理类
/// 负责管理点击动画和交互效果
class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  /// 动画控制器
  late AnimationController _animationController;
  /// 缩放动画
  late Animation<double> _scaleAnimation;
  /// 是否被按下
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    /// 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    /// 创建缩放动画
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 处理按下事件
  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  /// 处理释放事件
  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  /// 处理取消事件
  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              /// 卡片装饰
              decoration: BoxDecoration(
                /// 渐变背景
                gradient: widget.gradient,
                /// 圆角设计
                borderRadius: BorderRadius.circular(16),
                /// 阴影效果
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.colors.first.withOpacity(0.3),
                    blurRadius: _isPressed ? 4 : 8,
                    offset: Offset(0, _isPressed ? 2 : 4),
                    spreadRadius: _isPressed ? 0 : 1,
                  ),
                ],
              ),
              /// 内边距
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 顶部图标区域
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.iconBackground.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.icon,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  /// 数值展示区域
                  Text(
                    widget.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  
                  /// 单位标签
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  /// 副标题描述
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
