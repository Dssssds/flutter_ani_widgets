import 'package:flutter/material.dart';

// 运动数据模型
class RunningData {
  const RunningData({
    required this.distance,
    required this.time,
    required this.pace,
    required this.calories,
    required this.steps,
    required this.stepFrequency,
    required this.stepLength,
    required this.date,
    required this.userName,
  });

  final double distance;
  final Duration time;
  final Duration pace;
  final double calories;
  final int steps;
  final int stepFrequency;
  final int stepLength;
  final DateTime date;
  final String userName;

  bool get isValid =>
      distance >= 0 &&
      time.inSeconds > 0 &&
      calories >= 0 &&
      steps >= 0 &&
      stepFrequency >= 0 &&
      stepLength >= 0;

  // 添加缓存支持
  Map<String, dynamic> toJson() => {
        'distance': distance,
        'time': time.inSeconds,
        'pace': pace.inSeconds,
        'calories': calories,
        'steps': steps,
        'stepFrequency': stepFrequency,
        'stepLength': stepLength,
        'date': date.toIso8601String(),
        'userName': userName,
      };

  factory RunningData.fromJson(Map<String, dynamic> json) => RunningData(
        distance: json['distance'] as double,
        time: Duration(seconds: json['time'] as int),
        pace: Duration(seconds: json['pace'] as int),
        calories: json['calories'] as double,
        steps: json['steps'] as int,
        stepFrequency: json['stepFrequency'] as int,
        stepLength: json['stepLength'] as int,
        date: DateTime.parse(json['date'] as String),
        userName: json['userName'] as String,
      );
}

class RunningError extends Error {
  RunningError(this.message);
  final String message;

  @override
  String toString() => message;
}

class App02 extends StatelessWidget {
  const App02({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '运动追踪 App',
      home: RunningScreen(),
    );
  }
}

class RunningScreen extends StatefulWidget {
  const RunningScreen({super.key});

  @override
  RunningScreenState createState() => RunningScreenState();
}

class RunningScreenState extends State<RunningScreen>
    with SingleTickerProviderStateMixin {
  static const double _padding = 16.0;
  static const double _borderRadius = 10.0;
  static const double _chartHeight = 100.0;

  // 状态变量
  bool _isLoading = true;
  String? _error;
  RunningData? _runningData;

  // 动画控制器
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadRunningData();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRunningData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await Future.delayed(const Duration(seconds: 1));

      final data = RunningData(
        distance: 0.40,
        time: const Duration(minutes: 5, seconds: 40),
        pace: const Duration(minutes: 13, seconds: 51),
        calories: 24.9,
        steps: 542,
        stepFrequency: 95,
        stepLength: 75,
        date: DateTime.now(),
        userName: '皮卡瘦',
      );

      if (!data.isValid) {
        throw RunningError('运动数据无效');
      }

      setState(() {
        _runningData = data;
        _isLoading = false;
      });

      // 重置并开始动画
      _controller.reset();
      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => {},
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('分享功能开发中...')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _isLoading ? null : _loadRunningData,
        ),
      ],
      title: const Text('户外跑'),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '加载失败: $_error',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRunningData,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_runningData == null) {
      return const Center(
        child: Text('暂无运动数据'),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: child,
        ),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: _buildMap(),
            ),
            Expanded(
              flex: 3,
              child: _buildDataPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      color: Colors.blue[200], // 使用浅蓝色作为背景
      width: double.infinity, // 容器宽度占满
      height: double.infinity, // 容器高度占满
    );
  }

  Widget _buildDataPanel() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(), // 添加弹性滚动效果
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 添加数据视图和步频图表
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '0.40  公里',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        // 如何生成一个
                      ),
                      Text(
                        '皮卡瘦 1月13日 01:21',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '13\'51\'\'',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '平均配速',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '00:05:40',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '时长',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '24.9',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '千卡',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '542',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '步数(步)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '95',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '平均步频 (步/分钟)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '75',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '平均步幅 (厘米)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '步频',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Icon(Icons.help_outline),
                        Text(
                          '高级分析',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '112',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text('95',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('(步/分钟)',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('最快步频',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('平均步频',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey))
                        ]),
                    SizedBox(height: 15),
                    Container(height: 100, child: _buildStepFrequencyChart()),
                  ]),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text('海拔'),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text('更多'),
            ),
            // 添加更多内容以测试滚动效果
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text('更多1'),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text('更多2'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepFrequencyChart() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildAnimatedChartPoint(60),
            _buildAnimatedChartPoint(80),
            _buildAnimatedChartPoint(110),
            _buildAnimatedChartPoint(100),
            _buildAnimatedChartPoint(105),
            _buildAnimatedChartPoint(90),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedChartPoint(double value) {
    final double maxHeight = (value / 120) * 80;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 5,
      height: maxHeight * _fadeAnimation.value,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
}

// 提取常用样式到独立的类
class RunningStyles {
  static const TextStyle headerStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subHeaderStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  static const TextStyle valueStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}

// 优化StatItem组件
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: RunningStyles.valueStyle),
        Text(label, style: RunningStyles.labelStyle),
      ],
    );
  }
}
