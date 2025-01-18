import 'package:flutter/material.dart';

class NotificationItem {
  final String name;
  final String description;
  final String icon;
  final Color color;
  final String time;

  NotificationItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.time,
  });
}

class AnimatedNotificationList extends StatefulWidget {
  final List<NotificationItem> notifications;
  final Duration delay;

  const AnimatedNotificationList({
    super.key,
    required this.notifications,
    this.delay = const Duration(milliseconds: 600),
  });

  @override
  State<AnimatedNotificationList> createState() =>
      _AnimatedNotificationListState();
}

class _AnimatedNotificationListState extends State<AnimatedNotificationList>
    with SingleTickerProviderStateMixin {
  final List<NotificationItem> _visibleNotifications = [];
  bool _isDisposed = false;
  bool _showClearButton = false;
  static const double cardHeight = 92.0; // Height of card + padding
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _startAddingNotifications();
  }

  void _startAddingNotifications() async {
    for (var notification in widget.notifications) {
      if (!mounted || _isDisposed) return;

      await Future.delayed(widget.delay);

      if (!mounted || _isDisposed) return;
      setState(() {
        _visibleNotifications.insert(0, notification);
      });
      if (_visibleNotifications.length == 2) {
        _showClearButton = true;
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _showClearButton = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 使用List.generate生成一个列表,列表长度为_visibleNotifications的长度
          // 每个元素都是一个AnimatedNotificationCard组件
          // index参数表示当前正在生成的元素的索引
          ...List.generate(_visibleNotifications.length, (index) {
            return AnimatedNotificationCard(
              key: ValueKey(_visibleNotifications[index]
                  .hashCode), // 使用通知项的哈希值作为key,确保每个卡片的唯一性
              item: _visibleNotifications[index], // 传入当前索引对应的通知项
              index: index, // 传入当前索引,用于确定卡片的顺序
              topOffset: index * cardHeight, // 根据索引计算每个卡片的垂直偏移量,实现卡片的堆叠效果
            );
          }),
          if (_visibleNotifications.isNotEmpty && _showClearButton)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              top: _visibleNotifications.length * cardHeight,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _visibleNotifications.isNotEmpty ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _visibleNotifications.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 8),
                        Text('清空所有通知', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AnimatedNotificationCard extends ImplicitlyAnimatedWidget {
  final NotificationItem item;
  final int index;
  final double topOffset;

  const AnimatedNotificationCard({
    super.key,
    required this.item,
    required this.index,
    required this.topOffset,
  }) : super(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

  @override
  AnimatedNotificationCardState createState() =>
      AnimatedNotificationCardState();
}

class AnimatedNotificationCardState
    extends AnimatedWidgetBaseState<AnimatedNotificationCard> {
  // 声明两个Tween对象用于动画插值
  // _topTween用于控制卡片的垂直位置动画
  Tween<double>? _topTween;
  // _slideTween用于控制卡片的水平滑动动画
  Tween<double>? _slideTween;

  @override
  void initState() {
    // 调用父类的initState方法
    super.initState();
    // 初始化滑动动画,从-100位置滑动到0位置
    _slideTween = Tween<double>(begin: -100.0, end: 0.0);
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    // 更新垂直位置的动画值
    _topTween = visitor(
      _topTween, // 当前tween
      widget.topOffset, // 目标值
      (dynamic value) => Tween<double>(begin: value as double), // 构造新的tween
    ) as Tween<double>?;

    // 更新水平滑动的动画值
    _slideTween = visitor(
      _slideTween,
      0.0, // 目标值为0,即滑动到原位
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    // 计算当前的垂直偏移值
    final topOffset = _topTween?.evaluate(animation) ?? widget.topOffset;
    // 计算当前的水平滑动值
    final slideOffset = _slideTween?.evaluate(animation) ?? 0.0;

    // 使用Positioned定位卡片
    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Transform.translate(
        // 应用水平滑动偏移
        offset: Offset(slideOffset, 0),
        child: Opacity(
          // 根据滑动距离计算透明度
          opacity: 1 - (slideOffset.abs() / 100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // 渲染通知卡片
            child: NotificationCard(
              item: widget.item,
              index: widget.index,
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final int index;

  const NotificationCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.grey[850],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      item.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('·'),
                          const SizedBox(width: 4),
                          Text(
                            item.time,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationDemo extends StatelessWidget {
  NotificationDemo({super.key});
  final List<NotificationItem> notifications = [
    NotificationItem(
      name: "张三! 💰",
      description: "张三给你转账了1000元",
      time: "15分钟前",
      icon: "💸",
      color: const Color(0xFF00C9A7),
    ),
    NotificationItem(
      name: "啥啥啥.....!",
      description: "好好好好",
      time: "10分钟前",
      icon: "👤",
      color: const Color(0xFFFFB800),
    ),
    NotificationItem(
      name: "收件箱爆满!",
      description: "有人在疯狂发送消息...带着爱 ❤️",
      time: "5m ago",
      icon: "💬",
      color: const Color(0xFFFF3D71),
    ),
    NotificationItem(
      name: "剧情反转!",
      description: "重大新闻:开发者找到了丢失的分号",
      time: "2m ago",
      icon: "🗞️",
      color: const Color(0xFF1E86FF),
    ),
    NotificationItem(
      name: "金钱雨! 🚿",
      description: "叮咚!是时候让钱像雨一样下...但要理性消费",
      time: "15m ago",
      icon: "💸",
      color: const Color(0xFF00C9A7),
    ),
    NotificationItem(
      name: "新玩家加入!",
      description: "欢迎来到马戏团!准备好爆米花 🍿",
      time: "10m ago",
      icon: "👤",
      color: const Color(0xFFFFB800),
    ),
    NotificationItem(
      name: "紧急消息!",
      description: "你的猫又替你发帖子了",
      time: "5m ago",
      icon: "💬",
      color: const Color(0xFFFF3D71),
    ),
    NotificationItem(
      name: "停止印刷!",
      description: "咖啡机现在接受击掌打招呼",
      time: "2m ago",
      icon: "🗞️",
      color: const Color(0xFF1E86FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedNotificationList(
            notifications: notifications,
          ),
        ),
      ),
    );
  }
}
