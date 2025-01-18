import 'dart:math' as math;

import 'package:flutter/material.dart';

class CardScrollJoystick extends StatefulWidget {
  const CardScrollJoystick({super.key});

  @override
  State<CardScrollJoystick> createState() => _CardScrollJoystickState();
}

class _CardScrollJoystickState extends State<CardScrollJoystick>
    with TickerProviderStateMixin {
  PageController _pageController = PageController(
    viewportFraction: 0.8,
  );

  bool _isLongPressed = false;

  // 添加小圆圈位置控制
  Offset _smallCirclePosition = const Offset(0, -55); // 初始位置在正上方
  final double _mainCircleRadius = 75; // 主圆半径
  final double _smallCircleRadius = 10; // 小圆半径
  double _currentAngle = -math.pi / 2; // 初始角度（正上方）

  // 将 cdnUrl 改为静态常量
  static const String _cdnUrl =
      "https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter";

  // 计算小圆圈在圆周上的位置
  Offset _calculateCirclePosition(Offset position) {
    // 计算当前触摸点相对于圆心的角度
    _currentAngle = math.atan2(position.dy, position.dx);

    // 计算圆周上的位置（固定在内壁）
    double radius = _mainCircleRadius - _smallCircleRadius - 10;
    return Offset(
      radius * math.cos(_currentAngle),
      radius * math.sin(_currentAngle),
    );
  }

  // 添加位置转换方法
  // 将全局坐标转换为局部坐标的方法
  Offset _globalToLocal(Offset globalPosition) {
    // 获取当前组件的RenderBox对象,用于坐标转换
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    // 将全局坐标转换为相对于当前组件的局部坐标
    final Offset localPosition = renderBox.globalToLocal(globalPosition);

    // 圆形容器的尺寸
    const double circleSize = 150.0;
    // 计算圆形容器的中心点位置
    final Offset circleCenter = Offset(
      renderBox.size.width / 2, // 屏幕宽度的一半
      renderBox.size.height - (circleSize / 2) - 55.0, // 考虑底部间距50和圆形容器高度的一半
    );

    // 返回相对于圆形中心的偏移量
    return localPosition - circleCenter;
  }

  final List<CardItem> _items = [
    CardItem(
      title: 'Short',
      subtitle: 'Chat Wisdom',
      color: Colors.yellow.shade200,
      author: 'Gardner',
      image: '$_cdnUrl/image/pic-01.jpg',
    ),
    CardItem(
      title: 'Short',
      subtitle: 'Chat Wisdom',
      color: Colors.purple.shade200,
      author: 'Jackie McBride',
      image: '$_cdnUrl/image/pic-02.jpg',
    ),
    CardItem(
      title: '中心值',
      subtitle: 'Wisdom',
      color: Colors.green.shade200,
      author: 'Bessie Alvarado',
      image: '$_cdnUrl/image/pic-03.jpg',
    ),
    CardItem(
      title: 'Short',
      subtitle: 'Wisdom',
      color: Colors.blue.shade200,
      author: 'Bessie Alvarado',
      image: '$_cdnUrl/image/pic-04.jpg',
    ),
    CardItem(
      title: 'Short',
      subtitle: 'Wisdom',
      color: Colors.red.shade200,
      author: 'Bessie Alvarado',
      image: '$_cdnUrl/foods/01.png',
    ),
    CardItem(
      title: 'Short',
      subtitle: 'Wisdom',
      color: Colors.orange.shade200,
      author: 'Bessie Alvarado',
      image: '$_cdnUrl/foods/02.png',
    ),
  ];

  double _currentPage = 1.0;

  // 添加动画控制器
  late AnimationController _scrollAnimationController;

  // 添加滚动速度控制
  double _scrollVelocity = 0.0;
  final double _maxScrollVelocity = 2.0; // 将最大速度从2.0降低到1.0

  // 添加缩放动画控制器
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;

  // 定义缩放比例
  final double _minScale = 0.9; // 最小缩放比例
  final double _maxScale = 1.0; // 最大缩放比例

  // 添加颜色动画控制器
  late AnimationController _colorAnimationController;
  late Animation<Color?> _startColorAnimation;
  late Animation<Color?> _endColorAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化缩放动画控制器
    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(
      begin: _maxScale,
      end: _minScale,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.easeInOut,
    ));

    // 初始化滚动动画控制器
    _scrollAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateScroll);

    // 初始化颜色动画控制器
    _colorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 创建颜色动画
    _startColorAnimation = ColorTween(
      begin: Colors.grey.withOpacity(0.3),
      end: Colors.blue.shade200,
    ).animate(CurvedAnimation(
      parent: _colorAnimationController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
    ));

    _endColorAnimation = ColorTween(
      begin: Colors.grey.withOpacity(0.3),
      end: Colors.purple.shade200,
    ).animate(CurvedAnimation(
      parent: _colorAnimationController,
      // 使用 Interval 和 Curves.easeOutBack 组合实现从顶部扩散的效果
      curve: const Interval(
        0.2, // 延迟开始时间
        1.0,
        curve: Curves.easeOutBack, // 使用 easeOutBack 曲线实现弹性效果
      ),
    ));

    try {
      // 计算中值索引
      final int medianIndex = (_items.length - 1) ~/ 2;
      _currentPage = medianIndex.toDouble();

      // 初始化 PageController 并设置初始页为中值
      _pageController = PageController(
        initialPage: medianIndex,
        viewportFraction: 0.8,
      );

      // 监听页面滑动
      _pageController.addListener(() {
        if (mounted) {
          setState(() {
            _currentPage = _pageController.page ?? medianIndex.toDouble();
          });
        }
      });

      // 确保在下一帧渲染时滚动到中值位置
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients && mounted) {
          _pageController.jumpToPage(medianIndex);
        }
      });
    } catch (e) {
      debugPrint('初始化错误: $e');
    }
  }

  // 更新滚动位置
  void _updateScroll() {
    if (_isLongPressed && _scrollVelocity != 0 && _pageController.hasClients) {
      try {
        // 获取当前页面
        double? currentPage = _pageController.page;
        if (currentPage == null) return;

        // 计算新的页面位置
        // 根据滚动速度的方向来决定滚动方向，将速度系数从35改为60
        double newPage = currentPage - _scrollVelocity / 60;

        // 边界检查
        newPage = newPage.clamp(0.0, _items.length - 1.0);

        // 使用animateTo实现平滑滚动
        _pageController.animateTo(
          newPage *
              _pageController.viewportFraction *
              MediaQuery.of(context).size.width,
          duration: const Duration(milliseconds: 16),
          curve: Curves.linear,
        );
      } catch (e) {
        // 处理可能的错误
        debugPrint('滚动更新错误: $e');
        _scrollAnimationController.stop();
        setState(() {
          _isLongPressed = false;
          _currentAngle = -math.pi / 2;
          _smallCirclePosition = const Offset(0, -55);
          _scrollVelocity = 0;
        });
      }
    }
  }

  // 计算滚动速度
  void _calculateScrollVelocity() {
    try {
      // 根据角度计算滚动方向和速度
      // 使用余弦函数：-1到1的值，当摇杆在水平方向时最大
      double horizontalFactor = math.cos(_currentAngle);

      // 计算到中心的距离，并确保不为负
      double distanceFromCenter = _smallCirclePosition.distance.abs();

      // 确保不会除以0
      double maxRadius = (_mainCircleRadius - _smallCircleRadius).abs();
      if (maxRadius <= 0) maxRadius = 1.0;

      // 计算速度因子，限制在0到1之间
      double speedFactor = (distanceFromCenter / maxRadius).clamp(0.0, 1.0);

      // 设置最终滚动速度
      // 当摇杆向右时（horizontalFactor > 0），页面向右滚动（正值）
      // 当摇杆向左时（horizontalFactor < 0），页面向左滚动（负值）
      _scrollVelocity = (horizontalFactor * speedFactor * _maxScrollVelocity)
          .clamp(-_maxScrollVelocity, _maxScrollVelocity);
    } catch (e) {
      debugPrint('速度计算错误: $e');
      _scrollVelocity = 0;
    }
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    _scrollAnimationController.dispose();
    _pageController.dispose();
    _colorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 0),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sphere',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Stack(
                  children: [
                    ...List.generate(_items.length, (index) {
                      final double difference = index - _currentPage;
                      // 使用动画值来控制缩放
                      final double scale =
                          (_maxScale - (difference.abs() * 0.0)) *
                              (_scaleAnimationController.isAnimating
                                  ? _scaleAnimation.value
                                  : (_isLongPressed ? _minScale : _maxScale));
                      final double translateX = difference *
                          210 *
                          (_scaleAnimationController.isAnimating
                              ? _scaleAnimation.value
                              : (_isLongPressed ? _minScale : _maxScale));

                      return Positioned(
                        left: MediaQuery.of(context).size.width * 0.1 +
                            translateX,
                        right: MediaQuery.of(context).size.width * 0.1 -
                            translateX,
                        top: math.pow(difference, 2) *
                            23 *
                            (_scaleAnimationController.isAnimating
                                ? _scaleAnimation.value
                                : (_isLongPressed ? _minScale : _maxScale)),
                        height: MediaQuery.of(context).size.height *
                            0.48 *
                            (_scaleAnimationController.isAnimating
                                ? _scaleAnimation.value
                                : (_isLongPressed ? _minScale : _maxScale)),
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..scale(scale),
                          alignment: Alignment.center,
                          child: _buildCard(_items[index], index),
                        ),
                      );
                    }),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _isLongPressed = true;
                  });
                  _calculateScrollVelocity();
                  _scrollAnimationController.repeat();
                  _scaleAnimationController.forward();
                  // 开始颜色动画
                  _colorAnimationController.forward();
                },
                onPanEnd: (_) {
                  setState(() {
                    _isLongPressed = false;
                    _currentAngle = -math.pi / 2;
                    _smallCirclePosition = const Offset(0, -55);
                    _scrollVelocity = 0;
                  });
                  _scrollAnimationController.stop();
                  _scaleAnimationController.reverse();
                  // 反向播放颜色动画
                  _colorAnimationController.reverse();
                },
                onPanUpdate: (details) {
                  if (_isLongPressed) {
                    setState(() {
                      Offset localPosition =
                          _globalToLocal(details.globalPosition);
                      _smallCirclePosition =
                          _calculateCirclePosition(localPosition);
                    });
                    _calculateScrollVelocity();
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 主圆形背景
                    AnimatedBuilder(
                      animation: _colorAnimationController,
                      builder: (context, child) {
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                _startColorAnimation.value ??
                                    Colors.black.withOpacity(0.6),
                                _endColorAnimation.value ??
                                    Colors.black.withOpacity(0.6),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // 顶部小圆圈装饰
                    Transform.translate(
                      offset: _smallCirclePosition,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 内部渐变叠加
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.8],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(CardItem item, int index) {
    return Transform.scale(
      scale: 0.85,
      child: Transform(
        transform: Matrix4.identity()..rotateZ((index - _currentPage) * 0.2),
        alignment: Alignment.center,
        child: Container(
          height: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部图片区域
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.network(
                  item.image,
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 230,
                      width: double.infinity,
                      color: Colors.grey.withOpacity(0.1),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // 内容区域
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 副标题
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // 作者信息
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: item.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.author,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class CardItem {
  final String title;
  final String subtitle;
  final Color color;
  final String author;
  final String image;

  CardItem({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.author,
    required this.image,
  });
}
