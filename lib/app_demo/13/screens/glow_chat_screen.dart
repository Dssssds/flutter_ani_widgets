import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_x_widgets/app_demo/13/models/chat_model.dart';
import 'package:flutter_x_widgets/app_demo/13/widgets/particle_emitter.dart';
import 'package:flutter_x_widgets/app_demo/13/widgets/typing_indicator.dart';

/// 动态背景发光浮体
class BackgroundBlob {
  double x, y;
  double vx, vy;
  final double radius;
  final Color color;

  BackgroundBlob({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
  });

  void update(double dt, double width, double height) {
    x += vx * dt;
    y += vy * dt;

    // 边界反弹
    if (x < radius * 0.5) {
      x = radius * 0.5;
      vx = -vx;
    } else if (x > width + radius * 0.5) {
      x = width + radius * 0.5;
      vx = -vx;
    }

    if (y < radius * 0.5) {
      y = radius * 0.5;
      vy = -vy;
    } else if (y > height + radius * 0.5) {
      y = height + radius * 0.5;
      vy = -vy;
    }
  }
}

class GlowChatScreen extends StatefulWidget {
  const GlowChatScreen({super.key});

  @override
  State<GlowChatScreen> createState() => _GlowChatScreenState();
}

class _GlowChatScreenState extends State<GlowChatScreen>
    with SingleTickerProviderStateMixin {
  // 数据与控制
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _sendButtonKey = GlobalKey();

  // 物理与动画系统
  late final Ticker _ticker;
  DateTime? _lastTickTime;
  final List<ChatParticle> _particles = [];
  final List<BackgroundBlob> _blobs = [];

  // 状态变量
  bool _isAiTyping = false;
  double _screenHeight = 600.0;
  double _screenWidth = 300.0;

  // 聊天机器人回答语料库
  final List<String> _aiReplies = [
    "你好呀！我是 GlowBot。今天有什么想聊的吗？✨",
    "每一句看似平常的对话，其实都是思维火花的碰撞哦 ⚡",
    "哈哈，你的想法真的很独特，我要把它记入我的流光核心 💡",
    "听起来很棒！不过别忘了，工作/学习之余也要多喝水休息一下 ☀️",
    "其实，自律的真谛就是每天比昨天多前进一步。我们一起加油 🧗‍♂️",
    "收到你的波段信号啦！我的量子处理器正在高速运转中 🧠",
    "感觉这个思路非常有趣！需要我帮你列一个具体的计划表吗？📝",
    "只要内心有光，黑夜也只是极光的背景。送你一缕流光 🌈",
  ];

  @override
  void initState() {
    super.initState();

    // 注入初始消息
    _messages.addAll([
      ChatMessage(
        id: 'init_1',
        text: '欢迎来到流光聊天空间！✨ 我是你的 AI 伙伴 GlowBot。',
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        sender: MessageSender.ai,
      ),
      ChatMessage(
        id: 'init_2',
        text: '在这里，你发送的消息会触发粒子溅射，我的回复也带有灵动的气泡效果。随便输入点什么试试吧！🚀',
        time: DateTime.now().subtract(const Duration(minutes: 4)),
        sender: MessageSender.ai,
      ),
    ]);

    // 初始化流体发光球体
    _blobs.addAll([
      BackgroundBlob(
        x: 50.0,
        y: 150.0,
        vx: 15.0,
        vy: 20.0,
        radius: 180.0,
        color: const Color(0xFF8B5CF6), // 亮紫
      ),
      BackgroundBlob(
        x: 250.0,
        y: 400.0,
        vx: -18.0,
        vy: -12.0,
        radius: 220.0,
        color: const Color(0xFF3B82F6), // 靛蓝
      ),
      BackgroundBlob(
        x: 100.0,
        y: 600.0,
        vx: 10.0,
        vy: -25.0,
        radius: 190.0,
        color: const Color(0xFFEC4899), // 玫粉
      ),
    ]);

    // 注册高帧率物理时钟循环
    _ticker = createTicker((elapsed) {
      if (!mounted) return;
      final now = DateTime.now();
      if (_lastTickTime == null) {
        _lastTickTime = now;
        return;
      }
      final dt = now.difference(_lastTickTime!).inMicroseconds / 1000000.0;
      _lastTickTime = now;

      _updatePhysics(dt.clamp(0.001, 0.03));
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 更新物理系统粒子与流体背景
  void _updatePhysics(double dt) {
    // 1. 更新背景漂浮球体
    for (var blob in _blobs) {
      blob.update(dt, _screenWidth, _screenHeight);
    }

    // 2. 更新粒子系统寿命和位置
    for (int i = _particles.length - 1; i >= 0; i--) {
      _particles[i].update(dt);
      if (_particles[i].life <= 0) {
        _particles.removeAt(i);
      }
    }

    setState(() {});
  }

  /// 喷射发送按钮发光粒子
  void _emitSendParticles() {
    // 获取发送按钮的物理坐标
    final RenderBox? box = _sendButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    
    // 找到相对于当前画布的坐标
    final pos = box.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
    final centerX = pos.dx + box.size.width / 2;
    final centerY = pos.dy + box.size.height / 2;

    final random = math.Random();
    // 喷射 30 个向左上方辐射的亮彩色粒子
    for (int i = 0; i < 30; i++) {
      double angle = -math.pi * 0.75 + (random.nextDouble() - 0.5) * (math.pi * 0.5); // 向左上角发散
      double speed = 100.0 + random.nextDouble() * 180.0;
      
      _particles.add(ChatParticle(
        x: centerX,
        y: centerY,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        size: 3.0 + random.nextDouble() * 4.0,
        life: 0.7 + random.nextDouble() * 0.5,
        color: const Color(0xFF00FFCC), // 荧光绿
      ));
    }
  }

  /// 发送消息
  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    
    // 1. 触发喷射粒子物理回馈
    _emitSendParticles();

    // 2. 插入用户消息
    final userMsg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      time: DateTime.now(),
      sender: MessageSender.user,
    );

    setState(() {
      _messages.insert(0, userMsg);
    });

    // 3. 启动机器人的延迟输入与应答逻辑
    _triggerBotReply();
  }

  /// 模拟机器人智能打字与自动回复
  void _triggerBotReply() {
    // 600毫秒后显示对方“正在输入”的跳动圆点
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isAiTyping = true;
      });
      
      // 正在输入 1.5 秒后，真正投递消息
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        
        final random = math.Random();
        final replyText = _aiReplies[random.nextInt(_aiReplies.length)];
        
        setState(() {
          _isAiTyping = false;
          _messages.insert(
            0,
            ChatMessage(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              text: replyText,
              time: DateTime.now(),
              sender: MessageSender.ai,
            ),
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _screenWidth = size.width;
    _screenHeight = size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. 底部流光溢彩浮体背景层
          Positioned.fill(
            child: CustomPaint(
              painter: _GlowBackgroundPainter(blobs: _blobs),
            ),
          ),

          // 2. 毛玻璃高斯模糊层 (营造霜化玻璃感)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 55.0, sigmaY: 55.0),
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),

          // 3. 聊天内容交互与列表层
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // 顶部导航栏 (毛玻璃卡片风格)
                  _buildHeader(),

                  // 聊天历史列表层
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      reverse: true, // 聊天室常规设计：新消息在最底部的 0 索引
                      itemCount: _messages.length + (_isAiTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isAiTyping && index == 0) {
                          return const Padding(
                            padding: EdgeInsets.only(left: 8, top: 6, bottom: 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TypingIndicator(),
                            ),
                          );
                        }
                        
                        final msgIndex = index - (_isAiTyping ? 1 : 0);
                        final message = _messages[msgIndex];
                        return GlowMessageBubble(
                          key: ValueKey(message.id),
                          message: message,
                        );
                      },
                    ),
                  ),

                  // 底部输入区域 (毛玻璃包裹)
                  _buildInputArea(),
                ],
              ),
            ),
          ),

          // 4. 最顶层粒子爆发绘制层 (穿透交互)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ParticlePainter(particles: _particles),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 绘制毛玻璃顶部标头
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          // 机器人头像
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF00FFCC), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFCC).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ],
            ),
            child: const Center(
              child: Icon(Icons.adb_rounded, color: Colors.black87, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          // 状态标题
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GlowBot Companion',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF00FFCC),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'AI 在线流光电波中',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  /// 绘制毛玻璃底部输入框
  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          // 输入域
          Expanded(
            child: TextFormField(
              controller: _inputController,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: const InputDecoration(
                hintText: '流光倾吐，在这里输入消息...',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
              textInputAction: TextInputAction.send,
              onFieldSubmitted: (_) => _sendMessage(),
            ),
          ),
          // 发送按钮 (使用 GlobalKey 锁定粒子放射起点)
          GestureDetector(
            key: _sendButtonKey,
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF5030EF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.send_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 绘制软模糊流体彩色圆背景
class _GlowBackgroundPainter extends CustomPainter {
  final List<BackgroundBlob> blobs;

  _GlowBackgroundPainter({required this.blobs});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var blob in blobs) {
      final rect = Rect.fromCircle(
        center: Offset(blob.x, blob.y),
        radius: blob.radius,
      );
      // 径向渐变，使边缘向透明自然过渡
      paint.shader = RadialGradient(
        colors: [
          blob.color.withOpacity(0.35),
          blob.color.withOpacity(0.0),
        ],
      ).createShader(rect);

      canvas.drawCircle(Offset(blob.x, blob.y), blob.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlowBackgroundPainter oldDelegate) => true;
}

/// 消息气泡弹性缩放进入小部件
class GlowMessageBubble extends StatefulWidget {
  final ChatMessage message;
  const GlowMessageBubble({super.key, required this.message});

  @override
  State<GlowMessageBubble> createState() => _GlowMessageBubbleState();
}

class _GlowMessageBubbleState extends State<GlowMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack, // 舒适的反弹效果
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.sender == MessageSender.user;
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _controller,
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              gradient: isUser
                  ? const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF5030EF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isUser ? null : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border: Border.all(
                color: isUser
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.08),
                width: 1.0,
              ),
              boxShadow: [
                if (isUser)
                  BoxShadow(
                    color: const Color(0xFF5030EF).withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
              ],
            ),
            child: Text(
              widget.message.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
