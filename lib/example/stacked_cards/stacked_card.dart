/// 堆叠卡片动画演示
/// 功能特点：
/// 1. 支持卡片堆叠展示，带有3D效果
/// 2. 支持暗/亮主题切换
/// 3. 新卡片添加时的入场动画
/// 4. 超出显示限制的卡片退场动画
/// 5. 网格背景支持
import 'dart:math';

import 'package:flutter/material.dart';

import 'widget_theme.dart';

/// 堆叠卡片演示组件
/// 管理卡片的添加、移除和主题切换
class StackedCardDemo extends StatefulWidget {
  const StackedCardDemo({super.key});

  @override
  State<StackedCardDemo> createState() => _StackedCardDemoState();
}

class _StackedCardDemoState extends State<StackedCardDemo> {
  // 存储当前显示的卡片列表
  final List<CardModel> cards = [];
  // 用于生成卡片的唯一ID
  int nextCardNumber = 1;
  // 当前主题模式（暗/亮）
  bool isDarkMode = false;

  // 卡片位置配置
  // 新卡片的入场位置
  static const entryPosition = CardPosition(x: 0, y: 70, z: -75);
  // 退场卡片的最终位置
  static const exitPosition = CardPosition(x: 0, y: 0, z: 225);

  // 定义最多显示的三张卡片的位置
  final List<CardPosition> positions = [
    const CardPosition(x: 0.0, y: 0.0, z: 0.0), // 最上层卡片位置
    const CardPosition(x: 0.0, y: -20.0, z: 90.0), // 中间层卡片位置
    const CardPosition(x: 0.0, y: -40.0, z: 180.0), // 最底层卡片位置
  ];

  /// 切换暗/亮主题
  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  /// 添加新卡片
  /// 新卡片会从入场位置插入到卡片堆最上方
  /// 如果卡片数量超过显示限制，最后一张卡片会执行退场动画
  void addNewCard() {
    setState(() {
      // 创建新卡片
      final newCard = CardModel(
        content: 'Card $nextCardNumber',
        id: nextCardNumber,
      );
      cards.insert(0, newCard);
      nextCardNumber++;

      if (cards.length > positions.length) {
        // 延迟移除最后一张卡片，等待退场动画完成
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            cards.removeLast();
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: Container(
        // 创建渐变背景
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.getBackgroundGradient(isDarkMode),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // 绘制背景网格
              Positioned.fill(
                child: CustomPaint(
                  painter: GridPatternPainter(isDarkMode: isDarkMode),
                ),
              ),
              // 卡片堆叠区域
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ...cards
                        .asMap()
                        .entries
                        .map((entry) {
                          final index = entry.key;
                          final card = entry.value;

                          CardPosition position;

                          // 判断是否为新插入的卡片
                          bool isEntering =
                              index == 0 && card.id == nextCardNumber - 1;

                          // 根据卡片状态确定其位置
                          if (index >= positions.length) {
                            // 超出显示限制的卡片使用退场位置
                            position = exitPosition;
                          } else if (isEntering) {
                            // 新卡片使用入场位置
                            position = entryPosition;
                          } else {
                            // 其他卡片使用预设位置
                            position = positions[index];
                          }

                          return AnimatedCardWidget(
                            key: ValueKey(
                                card.id), // Important for proper animation
                            card: card,
                            position: position,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            isEntering: isEntering,
                            onAnimationComplete: index >= positions.length
                                ? () {
                                    setState(() {
                                      cards.remove(card);
                                    });
                                  }
                                : null,
                            isDarkMode: isDarkMode,
                          );
                        })
                        .toList()
                        .reversed,
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Add button
              Positioned(
                left: 16,
                bottom: 16,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: toggleTheme,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppTheme.getAccentGradient(isDarkMode),
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: AppTheme.cardShadows,
                      ),
                      child: Icon(
                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: isDarkMode ? Colors.black : Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),

              //Add button
              Positioned(
                right: 16,
                bottom: 16,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: addNewCard,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppTheme.getAccentGradient(isDarkMode),
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: AppTheme.cardShadows,
                      ),
                      child: Icon(
                        Icons.add,
                        color: isDarkMode ? Colors.black : Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 背景网格绘制器
/// 根据主题模式绘制不同颜色的网格线
class GridPatternPainter extends CustomPainter {
  final bool isDarkMode;

  GridPatternPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.getPatternColor(isDarkMode)
      ..strokeWidth = 1;

    const spacing = 20.0; // 网格线间距

    // 绘制垂直线
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // 绘制水平线
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 简单卡片组件
/// 展示卡片的基本UI，包括标题、描述文本和装饰条
class SimpleCard extends StatelessWidget {
  final String title;
  final bool isDarkMode;

  const SimpleCard({
    super.key,
    this.title = '简单卡片标题',
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.cardMargin),
      // 卡片外观装饰
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.getCardGradient(isDarkMode),
        ),
        boxShadow: AppTheme.cardShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.cardPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.getTitleStyle(isDarkMode),
              ),
              const SizedBox(height: 8),
              Text(
                '这是一张四周阴影均匀的卡片。',
                style: AppTheme.getDescriptionStyle(isDarkMode),
              ),
              // 底部装饰条
              Container(
                margin: const EdgeInsets.only(top: 16),
                height: AppTheme.accentBarHeight,
                width: AppTheme.accentBarWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppTheme.getAccentGradient(isDarkMode),
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.accentBarRadius),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 卡片数据模型
/// 存储卡片的内容和唯一标识
class CardModel {
  final String content;
  final int id;

  const CardModel({
    required this.content,
    required this.id,
  });
}

/// 卡片位置模型
/// 用于定义卡片在3D空间中的位置
class CardPosition {
  final double x; // X轴位置（左右）
  final double y; // Y轴位置（上下）
  final double z; // Z轴位置（前后）

  const CardPosition({
    this.x = 0.0,
    this.y = 0.0,
    this.z = 0.0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardPosition &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          z == other.z;

  @override
  int get hashCode => Object.hash(x, y, z);
}

/// 卡片动画组件
/// 控制卡片的位置动画、透明度动画等
class AnimatedCardWidget extends StatefulWidget {
  final CardModel card; // 卡片数据
  final CardPosition position; // 目标位置
  final Duration duration; // 动画持续时间
  final Curve curve; // 动画曲线
  final VoidCallback? onAnimationComplete; // 动画完成回调
  final bool exitAnimation; // 是否为退场动画
  final bool isEntering; // 是否为入场动画
  final bool isDarkMode; // 主题模式

  const AnimatedCardWidget({
    required this.card,
    required this.position,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutQuart,
    this.onAnimationComplete,
    this.exitAnimation = false,
    this.isEntering = false,
    required this.isDarkMode,
    super.key,
  });

  @override
  State<AnimatedCardWidget> createState() => _AnimatedCardWidgetState();
}

class _AnimatedCardWidgetState extends State<AnimatedCardWidget>
    with SingleTickerProviderStateMixin {
  // 动画控制器
  late AnimationController _controller;
  // 位置动画
  late Animation<double> _xAnimation;
  late Animation<double> _yAnimation;
  late Animation<double> _zAnimation;
  // 透明度动画
  late Animation<double> _opacityAnimation;

  // 记录上一次的位置，用于动画过渡
  CardPosition? _oldPosition;

  // 拖动相关变量
  Offset _dragOffset = Offset.zero;
  // 拖动阈值，超过这个值卡片会被移除
  static const double _removeThreshold = 100.0;
  // 旋转系数，控制拖动时的旋转角度
  static const double _rotationFactor = 0.008;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _setupAnimations();
  }

  /// 设置动画参数
  void _setupAnimations() {
    // 入场动画自动开始
    if (widget.isEntering) {
      _controller.forward();
    }

    // 计算动画的起始和结束位置
    final begin =
        widget.isEntering ? widget.position : (_oldPosition ?? widget.position);
    final end = widget.isEntering
        ? const CardPosition(x: 0.0, y: 0.0, z: 0.0)
        : widget.position;

    // 设置X轴动画
    _xAnimation = Tween<double>(
      begin: begin.x,
      end: end.x,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // 设置Y轴动画
    _yAnimation = Tween<double>(
      begin: begin.y,
      end: end.y,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // 设置Z轴动画
    _zAnimation = Tween<double>(
      begin: begin.z,
      end: end.z,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // 设置透明度动画
    _opacityAnimation = Tween<double>(
      begin: widget.isEntering ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    _controller.addStatusListener(_handleAnimationStatus);
  }

  /// 处理动画状态变化
  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onAnimationComplete?.call();
    }
  }

  /// 处理拖动开始
  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _dragOffset = Offset.zero;
    });
  }

  /// 处理拖动更新
  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  /// 处理拖动结束
  void _handleDragEnd(DragEndDetails details) {
    final distance = _dragOffset.distance;

    if (distance > _removeThreshold) {
      // 如果拖动距离超过阈值，触发移除动画
      final angle = _dragOffset.direction;

      // 计算最终位置（根据拖动方向投射）
      final endX = cos(angle) * 1000.0;
      final endY = sin(angle) * 1000.0;

      setState(() {
        _dragOffset = Offset(endX, endY);
        _opacityAnimation = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ));
      });

      // 触发移除回调
      widget.onAnimationComplete?.call();
    } else {
      // 如果未超过阈值，回弹到原位
      setState(() {
        _dragOffset = Offset.zero;
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.position != widget.position ||
        oldWidget.duration != widget.duration ||
        oldWidget.curve != widget.curve) {
      _oldPosition = CardPosition(
        x: _xAnimation.value,
        y: _yAnimation.value,
        z: _zAnimation.value,
      );

      _controller.duration = widget.duration;
      _setupAnimations();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // 计算旋转角度（根据水平拖动距离）
          final rotationAngle = _dragOffset.dx * _rotationFactor;

          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform(
              // 使用Matrix4进行3D变换
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // 设置透视效果
                ..translate(
                  _xAnimation.value + _dragOffset.dx,
                  _yAnimation.value + _dragOffset.dy,
                  _zAnimation.value,
                )
                ..rotateZ(rotationAngle), // 添加旋转效果
              alignment: FractionalOffset.center,
              child: child,
            ),
          );
        },
        child: SimpleCard(
          title: widget.card.content,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }
}
