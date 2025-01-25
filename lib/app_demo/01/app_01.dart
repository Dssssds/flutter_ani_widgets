import 'package:flutter/material.dart';

class App01 extends StatelessWidget {
  const App01({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _todayCardController;
  late AnimationController _statsCardController;
  late AnimationController _heartRateCardController;
  late AnimationController _menuListController;

  late Animation<Offset> _todayCardSlideAnimation;
  late Animation<Offset> _statsCardSlideAnimation;
  late Animation<Offset> _heartRateCardSlideAnimation;
  late Animation<Offset> _menuListSlideAnimation;

  late Animation<double> _todayCardFadeAnimation;
  late Animation<double> _statsCardFadeAnimation;
  late Animation<double> _heartRateCardFadeAnimation;
  late Animation<double> _menuListFadeAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _todayCardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _statsCardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartRateCardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _menuListController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 设置滑动动画
    _todayCardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _todayCardController,
      curve: Curves.easeOutQuad,
    ));

    _statsCardSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _statsCardController,
      curve: Curves.easeOutQuad,
    ));

    _heartRateCardSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heartRateCardController,
      curve: Curves.easeOutQuad,
    ));

    _menuListSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _menuListController,
      curve: Curves.easeOutQuad,
    ));

    // 设置透明度动画
    _todayCardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _todayCardController,
      curve: Curves.easeOut,
    ));

    _statsCardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsCardController,
      curve: Curves.easeOut,
    ));

    _heartRateCardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartRateCardController,
      curve: Curves.easeOut,
    ));

    _menuListFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _menuListController,
      curve: Curves.easeOut,
    ));

    // 同时执行动画
    _playAnimationsSequentially();
  }

  // 将所有的动画重新播放一遍.
  void _playAnimationsSequentially() {
    _todayCardController.forward();
    _statsCardController.forward();
    _heartRateCardController.forward();
    _menuListController.forward();
  }

  @override
  void dispose() {
    _todayCardController.dispose();
    _statsCardController.dispose();
    _heartRateCardController.dispose();
    _menuListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 顶部 app bar
              _buildAppBar(),
              const SizedBox(height: 10),

              /// 使用 SliderTransition 进行动画的控制.
              SlideTransition(
                position: _todayCardSlideAnimation,

                /// 子逐渐是一个 透明的 动画控制
                child: FadeTransition(
                  opacity: _todayCardFadeAnimation,
                  child: const TodayCard(itemsContainerHeight: 120),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SlideTransition(
                      position: _statsCardSlideAnimation,
                      child: FadeTransition(
                        opacity: _statsCardFadeAnimation,
                        child: const StatsCard(height: 180),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SlideTransition(
                      position: _heartRateCardSlideAnimation,
                      child: FadeTransition(
                        opacity: _heartRateCardFadeAnimation,
                        child: const HeartRateCard(height: 180),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SlideTransition(
                  position: _menuListSlideAnimation,
                  child: FadeTransition(
                    opacity: _menuListFadeAnimation,
                    child: const MenuList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 使用Row 横向排列, 并且使用 spaceBetween 进行两边居中的方式,
  /// 每次加载到 appbar 的时候, 将所有的动画进行重新开始动画.
  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.apps, color: Colors.white, size: 30),
        const Text(
          'TRAINING ONE',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        IconButton(
          onPressed: () {
            // 重新播放所有动画
            _todayCardController.reset();
            _statsCardController.reset();
            _heartRateCardController.reset();
            _menuListController.reset();
            _playAnimationsSequentially();
          },
          icon: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ],
    );
  }
}

// 训练项目数据模型
class TrainingItem {
  final String title;
  final String time;
  final IconData icon;

  const TrainingItem({
    required this.title,
    required this.time,
    required this.icon,
  });
}

// 今日训练卡片
class TodayCard extends StatefulWidget {
  final double itemsContainerHeight;

  const TodayCard({
    super.key,
    this.itemsContainerHeight = 120,
  });

  @override
  State<TodayCard> createState() => _TodayCardState();
}

class _TodayCardState extends State<TodayCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;

  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _iconTurns = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _itemAnimations = List.generate(
      trainingItems.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            1.0,
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    // 由于默认展开，需要将控制器设置为完成状态
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      await _controller.forward();
    } else {
      await _controller.reverse();
    }

    if (mounted) {
      setState(() {});
    }
  }

  // 训练项目列表
  static const List<TrainingItem> trainingItems = [
    TrainingItem(
      title: 'Running',
      time: '15 min',
      icon: Icons.directions_run,
    ),
    TrainingItem(
      title: 'Gym',
      time: '20×6',
      icon: Icons.fitness_center,
    ),
    TrainingItem(
      title: 'Cardio',
      time: '30 min',
      icon: Icons.favorite,
    ),
    TrainingItem(
      title: 'Swimming',
      time: '45 min',
      icon: Icons.pool,
    ),
    TrainingItem(
      title: 'Yoga',
      time: '60 min',
      icon: Icons.self_improvement,
    ),
    TrainingItem(
      title: 'Cycling',
      time: '40 min',
      icon: Icons.directions_bike,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Today',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _heightFactor.value,
                  child: Column(
                    children: [
                      ...List.generate(
                        trainingItems.length,
                        (index) {
                          final item = trainingItems[index];
                          final shouldShow = _isExpanded || index < 3;
                          if (!shouldShow) return const SizedBox.shrink();

                          return FadeTransition(
                            opacity: _itemAnimations[index],
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.2, 0),
                                end: Offset.zero,
                              ).animate(_itemAnimations[index]),
                              child: _buildTrainingItem(item),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: _handleTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Text(
                        _isExpanded ? '收起' : '展开全部',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                  RotationTransition(
                    turns: _iconTurns,
                    child: const Icon(
                      Icons.arrow_drop_down_sharp,
                      color: Colors.blue,
                      size: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingItem(TrainingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(item.icon, color: Colors.black, size: 20),
          const SizedBox(width: 8),
          Text(
            item.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                ".......................",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Text(
            item.time,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// 统计卡片
class StatsCard extends StatelessWidget {
  final double height;

  const StatsCard({
    super.key,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statist',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Text(
                'tics',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child:
                Image.asset('assets/images/graph.png', width: 50, height: 50),
          ),
        ],
      ),
    );
  }
}

// 心跳动画图标
class HeartbeatIcon extends StatefulWidget {
  final double size;
  final Color color;

  const HeartbeatIcon({
    super.key,
    this.size = 35,
    this.color = Colors.white,
  });

  @override
  State<HeartbeatIcon> createState() => _HeartbeatIconState();
}

class _HeartbeatIconState extends State<HeartbeatIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Icon(
              Icons.favorite,
              color: widget.color,
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}

// 心率卡片
class HeartRateCard extends StatefulWidget {
  final double height;

  const HeartRateCard({
    super.key,
    this.height = 180,
  });

  @override
  State<HeartRateCard> createState() => _HeartRateCardState();
}

class _HeartRateCardState extends State<HeartRateCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _numberController;
  late Animation<double> _numberAnimation;

  @override
  void initState() {
    super.initState();
    _numberController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _numberAnimation = Tween<double>(
      begin: 1,
      end: 102,
    ).animate(CurvedAnimation(
      parent: _numberController,
      // 使用 easeOut 让动画在接近目标值时变慢
      curve: Curves.easeOut,
    ));

    _numberController.forward();
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const HeartbeatIcon(size: 35),
              const SizedBox(width: 4),
              AnimatedBuilder(
                animation: _numberAnimation,
                builder: (context, child) {
                  return Text(
                    '${_numberAnimation.value.toInt()}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ],
          ),
          const Text(
            'Heart',
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Text(
            'rate',
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// 菜单列表
class MenuList extends StatelessWidget {
  const MenuList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          MenuItem(title: 'New program', icon: Icons.arrow_forward_ios),
          MenuItem(title: 'Training zone', icon: Icons.arrow_forward_ios),
          MenuItem(title: 'Settings', icon: Icons.arrow_forward_ios),
          MenuItem(title: 'My account', icon: Icons.arrow_forward_ios),
        ],
      ),
    );
  }
}

// 菜单项
class MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const MenuItem({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
              Icon(icon, color: Colors.black, size: 18),
            ],
          ),
          const Divider(
            color: Colors.grey,
            height: 16,
          )
        ],
      ),
    );
  }
}
