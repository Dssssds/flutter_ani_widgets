import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:forge2d/forge2d.dart';
import 'package:table_calendar/table_calendar.dart';

// 添加形状枚举
enum ShapeType {
  // 圆形
  circle,
  // 八边形
  octagon,
  // 六边形
  hexagon,
}

// 添加形状配置类
class ShapeConfig {
  final ShapeType type;
  final double size;
  final Color color;
  final String imageUrl;

  ShapeConfig({
    required this.type,
    required this.size,
    required this.color,
    required this.imageUrl,
  });
}

class DateFoods {
  final DateTime date;
  final double weight;
  final List<String> foods;

  DateFoods(this.date, this.weight, this.foods);
}

class CalendarDemo extends StatefulWidget {
  const CalendarDemo({super.key});

  @override
  State<CalendarDemo> createState() => _CalendarDemoState();
}

class _CalendarDemoState extends State<CalendarDemo> {
  static const cdnUrl =
      "https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/foods";
  // 图片列表
  final List<String> imageList = [
    "$cdnUrl/01.png",
    "$cdnUrl/02.png",
    "$cdnUrl/03.png",
    "$cdnUrl/04.png",
    "$cdnUrl/05.png",
    "$cdnUrl/06.png",
    "$cdnUrl/07.png",
    "$cdnUrl/08.png",
    "$cdnUrl/09.png",
    "$cdnUrl/10.png",
  ];

  // 将 currentDate 改为可变的
  late DateTime currentDate;
  late DateTime focusedDate;
  double currentWeight = 70;
  ShapeType currentShape = ShapeType.circle;
  final List<DateFoods> dateFoods = [
    DateFoods(DateTime(2025, 1, 7), 75, [
      "$cdnUrl/01.png",
      "$cdnUrl/02.png",
      "$cdnUrl/03.png",
      "$cdnUrl/04.png",
      "$cdnUrl/05.png",
      "$cdnUrl/06.png",
      "$cdnUrl/07.png",
      "$cdnUrl/08.png",
      "$cdnUrl/09.png",
      "$cdnUrl/10.png"
    ]),
    DateFoods(DateTime(2025, 1, 8), 73, [
      "$cdnUrl/04.png",
      "$cdnUrl/05.png",
      "$cdnUrl/06.png",
      "$cdnUrl/07.png",
      "$cdnUrl/08.png"
    ]),
    DateFoods(DateTime(2025, 1, 9), 74, [
      "$cdnUrl/07.png",
      "$cdnUrl/08.png",
      "$cdnUrl/09.png",
      "$cdnUrl/10.png"
    ]),
  ];

  List<String> currentImageList = [];

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    focusedDate = DateTime.now();
    _onDateChanged(currentDate, focusedDate);
  }

  // 添加更新日期的方法
  void _onDateChanged(DateTime selectedDay, DateTime focusedDay) {
    final selectedDateFoods = dateFoods.where((element) =>
        element.date.year == selectedDay.year &&
        element.date.month == selectedDay.month &&
        element.date.day == selectedDay.day);

    final weight =
        selectedDateFoods.isEmpty ? 70 : selectedDateFoods.first.weight;
    setState(() {
      currentDate = selectedDay;
      focusedDate = focusedDay;
      currentImageList =
          selectedDateFoods.isEmpty ? [] : selectedDateFoods.first.foods;
      currentWeight = weight.toDouble();
    });
  }

  void _onChangeShape(ShapeType shape) {
    setState(() {
      currentShape = shape;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 顶部栏
            const TopBarWidget(),
            const SizedBox(height: 0),
            // 标题
            const TitleWidget(),
            const SizedBox(height: 30),
            // 物理碰撞动画
            MoodLogScreen(
              key: ValueKey(
                  '${currentDate.toString()}_${currentImageList.length}_${currentShape.name}'),
              imageList: currentImageList,
              shape: currentShape,
            ),
            // 当前体重
            CurrentWeight(
              weight: currentWeight,
            ),
            // 选择日期
            ChoseCalendarScreen(
              currentDate: currentDate,
              dateFoods: dateFoods,
              onDateChanged: _onDateChanged,
              focusedDate: focusedDate,
            ),

            const SizedBox(height: 20),
            // 形状选择
            ShapeWidget(
              onShapeChanged: _onChangeShape,
            ),
          ],
        ),
      ),
    );
  }
}

class MoodLogScreen extends StatefulWidget {
  final List<String> imageList;
  final ShapeType shape;
  const MoodLogScreen({
    super.key,
    required this.imageList,
    required this.shape,
  });

  @override
  State<MoodLogScreen> createState() => _MoodLogScreenState();
}

class _MoodLogScreenState extends State<MoodLogScreen>
    with SingleTickerProviderStateMixin {
  late World world;
  late List<Body> squares = [];
  late AnimationController _controller;
  final ViewportTransform viewport =
      ViewportTransform(Vector2.zero(), Vector2(1.0, 1.0), 1.0);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();

    world = World(Vector2(0, 1500.0));
    _createSemiCircleBounds();

    // 创建形状配置列表
    final configs = _createShapeConfigs(widget.shape);
    _createSquares(configs);

    _controller.addListener(_updatePhysics);
  }

  @override
  void didUpdateWidget(MoodLogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageList != widget.imageList) {
      // 清除旧的物体
      for (final body in squares) {
        world.destroyBody(body);
      }
      squares.clear();

      // 创建新的物体
      final configs = _createShapeConfigs(widget.shape);
      _createSquares(configs);
    }
  }

  // 创建形状配置列表
  List<ShapeConfig> _createShapeConfigs(ShapeType shape) {
    final random = math.Random();
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return List.generate(widget.imageList.length, (i) {
      final baseSize = 10.0 + random.nextDouble() * 12.0;
      return ShapeConfig(
        type: shape,
        size: baseSize,
        color: colors[random.nextInt(colors.length)],
        imageUrl: widget.imageList[i % widget.imageList.length],
      );
    });
  }

  void _createSquares(List<ShapeConfig> configs) {
    final random = math.Random();
    const scale = 2.0;

    for (final config in configs) {
      final square = world.createBody(BodyDef()
        ..type = BodyType.dynamic
        ..position = Vector2(
          50.0 + random.nextDouble() * 220,
          -400.0 - random.nextDouble() * 100,
        )
        ..angle = random.nextDouble() * math.pi * 2);

      late Shape shape;
      double density = 1.0;
      double friction = 0.3;
      double restitution = 0.5;

      switch (config.type) {
        case ShapeType.circle:
          shape = CircleShape()..radius = config.size * scale;
          density = 1.5;
          restitution = 0.7;
        case ShapeType.octagon:
          final vertices = _createOctagon(config.size * scale);
          shape = PolygonShape()..set(vertices);
          density = 2.0;
          friction = 0.4;
        case ShapeType.hexagon:
          final vertices = _createHexagon(config.size * scale);
          shape = PolygonShape()..set(vertices);
          density = 1.2;
          restitution = 0.8;
      }

      density = density * (10.0 / config.size);

      final fixture = square.createFixture(FixtureDef(shape)
        ..density = density * 1.2
        ..friction = friction * 0.8
        ..restitution = restitution * 1.2);

      fixture.userData = config.color;
      squares.add(square);
    }
  }

  void _createSemiCircleBounds() {
    // 创建半圆形边界，与模糊效果层对齐
    const centerX = 180.0; // 屏幕宽度的一半
    const centerY = -15.0; // 与模糊效果层高度对齐
    const radius = 185.0; // 与模糊效果层的 borderRadius 一致
    const segments = 50; // 用多少线段来近似半圆

    // 创建半圆形底部边界
    final circleBody = world.createBody(BodyDef()
      ..type = BodyType.static
      ..position = Vector2(0.0, 0.0));

    // 使用多个小线段近似半圆
    for (int i = 0; i <= segments; i++) {
      // 调整角度范围，使其形成一个向上的半圆
      // 从 0 到 π，形成一个倒 U 形状
      final angle1 = (math.pi * i / segments);
      final angle2 = (math.pi * (i + 1) / segments);

      final x1 = centerX + radius * math.cos(angle1);
      final y1 = centerY + radius * math.sin(angle1); // 注意这里是加号，让半圆向下

      final x2 = centerX + radius * math.cos(angle2);
      final y2 = centerY + radius * math.sin(angle2);

      final edgeShape = EdgeShape()..set(Vector2(x1, y1), Vector2(x2, y2));

      circleBody.createFixture(FixtureDef(edgeShape)
        ..friction = 0.3
        ..restitution = 0.2);
    }
  }

  // 创建八边形（模拟圆角矩形）
  List<Vector2> _createOctagon(double size) {
    final vertices = <Vector2>[];
    final offset = size * 0.5; // 控制"圆角"程度

    // 八个顶点，模拟圆角矩形
    vertices.addAll([
      Vector2(-size + offset, -size), // 左上
      Vector2(size - offset, -size), // 右上
      Vector2(size, -size + offset),
      Vector2(size, size - offset),
      Vector2(size - offset, size), // 右下
      Vector2(-size + offset, size), // 左下
      Vector2(-size, size - offset),
      Vector2(-size, -size + offset),
    ]);

    return vertices;
  }

  // 创建六边形
  List<Vector2> _createHexagon(double size) {
    final vertices = <Vector2>[];

    // 六个顶点
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      vertices.add(Vector2(
        size * math.cos(angle),
        size * math.sin(angle),
      ));
    }

    return vertices;
  }

  void _updatePhysics() {
    // 每帧更新多次物理状态，使运动更快
    for (int i = 0; i < 3; i++) {
      world.stepDt(1.0 / 200.0);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Stack(
        children: [
          // 物理方块渲染层
          CustomPaint(
            size: const Size(120, 180),
            painter: PhysicsSquarePainter(squares, widget.imageList),
          ),
          // 模糊效果层
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 180,
              child: CustomPaint(
                child: ClipPath(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 213, 197, 197)
                            .withOpacity(0.15),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(180),
                          bottomRight: Radius.circular(180),
                        ),
                      ),
                    ),
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

class PhysicsSquarePainter extends CustomPainter {
  final List<Body> squares;
  final List<String> imageList;
  final Map<Body, ui.Image?> _imageCache = {};

  PhysicsSquarePainter(this.squares, this.imageList) {
    _loadImages();
  }

  void _loadImages() {
    for (int i = 0; i < squares.length; i++) {
      final imageUrl = imageList[i % imageList.length];
      _loadImage(squares[i], imageUrl);
    }
  }

  Future<void> _loadImage(Body square, String imageUrl) async {
    try {
      final imageProvider = NetworkImage(imageUrl);
      final imageStream = imageProvider.resolve(ImageConfiguration.empty);
      imageStream.addListener(ImageStreamListener((info, _) {
        _imageCache[square] = info.image;
      }));
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final square in squares) {
      final position = square.position;
      final angle = square.angle;
      final fixture = square.fixtures.first;
      final color =
          (fixture.userData as Color? ?? Colors.blue).withOpacity(0.6);

      canvas.save();
      canvas.translate(position.x, position.y);
      canvas.rotate(angle);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      if (fixture.shape is CircleShape) {
        final circle = fixture.shape as CircleShape;
        final radius = circle.radius;

        // 绘制圆形背景
        canvas.drawCircle(Offset.zero, radius, paint);

        // 绘制图片
        final image = _imageCache[square];
        if (image != null) {
          final src = Rect.fromLTWH(
              0, 0, image.width.toDouble(), image.height.toDouble());
          final dst = Rect.fromCircle(center: Offset.zero, radius: radius);

          // 计算缩放比例，确保图片完全填充圆形且保持宽高比
          final scale = _calculateFillScale(
            imageWidth: image.width.toDouble(),
            imageHeight: image.height.toDouble(),
            targetWidth: radius * 5,
            targetHeight: radius * 5,
          );

          final scaledSize = radius * 5 * scale;
          final scaledRect = Rect.fromCenter(
            center: Offset.zero,
            width: scaledSize,
            height: scaledSize,
          );

          // 使用圆形路径进行裁剪
          final clipPath = Path()..addOval(dst);
          canvas.clipPath(clipPath);
          canvas.drawImageRect(image, src, scaledRect, Paint());
        }
      } else if (fixture.shape is PolygonShape) {
        final polygon = fixture.shape as PolygonShape;
        final path = Path();

        if (polygon.vertices.isNotEmpty) {
          path.moveTo(polygon.vertices[0].x, polygon.vertices[0].y);
          for (int i = 1; i < polygon.vertices.length; i++) {
            path.lineTo(polygon.vertices[i].x, polygon.vertices[i].y);
          }
          path.close();
        }

        // 绘制多边形背景
        canvas.drawPath(path, paint);

        // 绘制图片
        final image = _imageCache[square];
        if (image != null) {
          // 计算多边形的包围盒
          double minX = double.infinity;
          double minY = double.infinity;
          double maxX = double.negativeInfinity;
          double maxY = double.negativeInfinity;

          for (final vertex in polygon.vertices) {
            minX = math.min(minX, vertex.x);
            minY = math.min(minY, vertex.y);
            maxX = math.max(maxX, vertex.x);
            maxY = math.max(maxY, vertex.y);
          }

          final src = Rect.fromLTWH(
              0, 0, image.width.toDouble(), image.height.toDouble());
          final targetWidth = maxX - minX;
          final targetHeight = maxY - minY;

          // 计算缩放比例，确保图片完全填充多边形且保持宽高比
          final scale = _calculateFillScale(
            imageWidth: image.width.toDouble(),
            imageHeight: image.height.toDouble(),
            targetWidth: targetWidth * 5,
            targetHeight: targetHeight * 5,
          );

          final scaledWidth = targetWidth * scale;
          final scaledHeight = targetHeight * scale;
          final centerX = (minX + maxX) / 2;
          final centerY = (minY + maxY) / 2;

          final dst = Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: scaledWidth,
            height: scaledHeight,
          );

          canvas.save();
          canvas.clipPath(path);
          canvas.drawImageRect(image, src, dst, Paint());
          canvas.restore();
        }
      }

      canvas.restore();
    }
  }

  // 计算填充缩放比例，确保图片完全覆盖目标区域且保持宽高比
  double _calculateFillScale({
    required double imageWidth,
    required double imageHeight,
    required double targetWidth,
    required double targetHeight,
  }) {
    final imageRatio = imageWidth / imageHeight;
    final targetRatio = targetWidth / targetHeight;

    if (imageRatio > targetRatio) {
      // 图片更宽，以高度为基准
      return targetHeight / imageHeight;
    } else {
      // 图片更高，以宽度为基准
      return targetWidth / imageWidth;
    }
  }

  @override
  bool shouldRepaint(covariant PhysicsSquarePainter oldDelegate) => true;
}

class ChoseCalendarScreen extends StatefulWidget {
  final DateTime currentDate;
  final List<DateFoods> dateFoods;
  final Function(DateTime, DateTime) onDateChanged;
  final DateTime focusedDate;
  const ChoseCalendarScreen({
    super.key,
    required this.currentDate,
    required this.dateFoods,
    required this.onDateChanged,
    required this.focusedDate,
  });

  @override
  State<ChoseCalendarScreen> createState() => _ChoseCalendarScreenState();
}

class _ChoseCalendarScreenState extends State<ChoseCalendarScreen>
    with SingleTickerProviderStateMixin {
  // 定义主题颜色
  static const surfaceColor = Color(0xFF1E1E1E);
  static const primaryColor = Color.fromARGB(255, 87, 210, 238);
  static const textColor = Colors.white;
  static const secondaryTextColor = Color(0xFFB3B3B3);
  static const weekTitleColor = Color(0xFF3C3C3C);

  // 添加动画持续时间常量
  static const animationDuration = Duration(milliseconds: 300);

  // 添加动画控制器
  late final AnimationController _animationController;
  DateTime? _lastDate;

  @override
  void initState() {
    super.initState();
    _lastDate = widget.currentDate;
    _animationController = AnimationController(
      vsync: this,
      duration: animationDuration,
    )..forward(); // 初始化时直接完成动画
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChoseCalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_lastDate == null || !isSameDay(_lastDate!, widget.currentDate)) {
      _lastDate = widget.currentDate;
      _animationController
        ..reset()
        ..forward();
    }
  }

  // 创建一个通用的日期单元格构建方法
  Widget _buildDateCell({
    required DateTime date,
    required List<DateFoods> records,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    bool showBorder = true,
  }) {
    final isCurrentDate = isSameDay(date, widget.currentDate);

    return Stack(
      children: [
        AnimatedContainer(
          duration: animationDuration,
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border:
                showBorder ? Border.all(color: borderColor, width: 1) : null,
          ),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (records.isNotEmpty) ...[
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (records.first.foods.isNotEmpty)
                            AnimatedContainer(
                              duration: animationDuration,
                              width: 20,
                              height: 20,
                              margin: EdgeInsets.only(
                                right: records.first.foods.length > 1 ? 13 : 0,
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Image.network(
                                    records.first.foods.first,
                                    width: 20,
                                    height: 20,
                                  ),
                                  if (records.first.foods.length > 1)
                                    Positioned(
                                      right: -13,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const ui.Color.fromARGB(
                                              255, 54, 134, 151),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          border: Border.all(
                                            color: const Color(0xFF1E1E1E),
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '+${records.first.foods.length}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 24),
                  AnimatedDefaultTextStyle(
                    duration: animationDuration,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Text(date.day.toString()),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (isCurrentDate)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: (1 - _animationController.value) * 8,
                    sigmaY: (1 - _animationController.value) * 8,
                  ),
                  child: Container(
                    color: Colors.white.withOpacity(
                      (1 - _animationController.value) * 0.3,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TableCalendar(
        // 修改手势设置, 允许所有手势
        availableGestures: AvailableGestures.all,
        // 设置日历的起始日期为2000年1月1日
        firstDay: DateTime.utc(2000, 1, 1),
        // 设置日历的结束日期为2030年12月31日
        lastDay: DateTime.utc(2030, 12, 31),
        // 设置当前聚焦的日期,由controller控制
        focusedDay: widget.focusedDate,
        // 设置选中日期的判定条件,通过isSameDay判断是否为选中的日期
        selectedDayPredicate: (day) => isSameDay(widget.currentDate, day),
        // 优化日期选择回调
        onDaySelected: (selectedDay, focusedDay) {
          widget.onDateChanged(selectedDay, focusedDay);
        },
        // 设置日历显示格式(月/双周/周),由controller控制
        calendarFormat: CalendarFormat.week,
        // 设置日历格式改变时的回调数
        onFormatChanged: (format) {},
        // 显示日历头部
        headerVisible: true,
        // 设置星期行的高度为30
        daysOfWeekHeight: 30,
        // 设置日历行的高度为50
        rowHeight: 60,
        // 设置头部样式
        headerStyle: const HeaderStyle(
          leftChevronIcon: SizedBox.shrink(),
          rightChevronIcon: SizedBox.shrink(),
        ),
        // 自定义格式文本
        availableCalendarFormats: const {
          CalendarFormat.week: '周视图',
        },
        // 设置日历主体样式
        calendarStyle: CalendarStyle(
          defaultTextStyle: const TextStyle(color: textColor), // 默认文本样式
          weekendTextStyle: const TextStyle(color: textColor), // 周末文本样式
          outsideTextStyle:
              const TextStyle(color: secondaryTextColor), // 非当前月份日期的文本样式
          selectedDecoration: const BoxDecoration(
            // 选中日期的装饰
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            // 今天日期的装饰
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: primaryColor),
          ),
          todayTextStyle: const TextStyle(color: primaryColor), // 今天日期的文本样式
        ),
        // 设置选中日期的装饰
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, date, _) {
            final records = widget.dateFoods
                .where((food) => isSameDay(food.date, date))
                .toList();
            return _buildDateCell(
              date: date,
              records: records,
              backgroundColor: surfaceColor,
              borderColor: Colors.transparent,
              textColor: textColor,
            );
          },
          selectedBuilder: (context, date, _) {
            final records = widget.dateFoods
                .where((food) => isSameDay(food.date, date))
                .toList();
            return _buildDateCell(
              date: date,
              records: records,
              backgroundColor: primaryColor.withOpacity(0.2),
              borderColor: primaryColor,
              textColor: Colors.black,
            );
          },
          todayBuilder: (context, date, _) {
            final records = widget.dateFoods
                .where((food) => isSameDay(food.date, date))
                .toList();
            return _buildDateCell(
              date: date,
              records: records,
              backgroundColor: Colors.transparent,
              borderColor: primaryColor,
              textColor: textColor,
            );
          },
          outsideBuilder: (context, date, _) {
            return _buildDateCell(
              date: date,
              records: [],
              backgroundColor: Colors.transparent,
              borderColor: Colors.transparent,
              textColor: textColor,
              showBorder: false,
            );
          },
          dowBuilder: (context, date) {
            final isSelected = isSameDay(date, widget.currentDate);
            return AnimatedContainer(
              duration: animationDuration,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color:
                    isSelected ? primaryColor.withOpacity(0.2) : weekTitleColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? primaryColor : weekTitleColor,
                  width: 1,
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: AnimatedDefaultTextStyle(
                    duration: animationDuration,
                    style: TextStyle(
                      color: isSelected ? primaryColor : secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Text(
                        ['一', '二', '三', '四', '五', '六', '日'][date.weekday - 1]),
                  ),
                ),
              ),
            );
          },
          // 头部标题构建器
          headerTitleBuilder: (context, date) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 只有当选择日期不是今日时才会显示 "今天" 的按钮
                Text(
                  '${date.year}-${date.month}-${date.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 0), // 为了平衡布局
              ],
            );
          },
          // 标记构建器（用于显示小圆点）
          markerBuilder: (context, date, events) {
            final food = widget.dateFoods
                .where((food) => isSameDay(food.date, date))
                .toList();
            if (food.isEmpty) {
              return const SizedBox.shrink();
            } else {
              return Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class TopBarWidget extends StatelessWidget {
  const TopBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧圆形返回按钮
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF5F5F5),
            ),
            child: const Icon(
              Icons.settings,
              size: 16,
              color: Colors.black54,
            ),
          ),
          // 右侧头像列表
          SizedBox(
            width: 130,
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 头像3
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: const DecorationImage(
                      image: NetworkImage('https://picsum.photos/202'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // 头像2
                Positioned(
                  right: 16,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://picsum.photos/201'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // 头像1
                Positioned(
                  right: 32,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://picsum.photos/200'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Today Diet',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// 今日体重
class CurrentWeight extends StatefulWidget {
  const CurrentWeight({
    super.key,
    required this.weight,
  });

  final double weight;

  @override
  State<CurrentWeight> createState() => _CurrentWeightState();
}

class _CurrentWeightState extends State<CurrentWeight> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.arrow_left, color: Colors.black),
          Text(
            '当前体重: ${widget.weight}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.arrow_right, color: Colors.black),
        ],
      ),
    );
  }
}

//  形状
class ShapeWidget extends StatefulWidget {
  final Function(ShapeType)? onShapeChanged;
  const ShapeWidget({super.key, this.onShapeChanged});

  @override
  State<ShapeWidget> createState() => _ShapeWidgetState();
}

class _ShapeWidgetState extends State<ShapeWidget> {
  ShapeType _selectedShape = ShapeType.circle;

  void _updateShape(ShapeType shape) {
    if (_selectedShape != shape) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedShape = shape;
        });
      });
      // 调用回调函数
      widget.onShapeChanged?.call(shape);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择形状',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ShapeType.values.map((shape) {
                final isSelected = _selectedShape == shape;
                String shapeText;
                IconData shapeIcon;

                switch (shape) {
                  case ShapeType.circle:
                    shapeText = '圆形';
                    shapeIcon = Icons.circle_outlined;
                  case ShapeType.octagon:
                    shapeText = '八边形';
                    shapeIcon = Icons.stop_outlined;
                  case ShapeType.hexagon:
                    shapeText = '六边形';
                    shapeIcon = Icons.hexagon_outlined;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => _updateShape(shape),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const ui.Color.fromARGB(255, 87, 220, 238)
                                .withOpacity(0.2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color.fromARGB(255, 87, 210, 238)
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            shapeIcon,
                            size: 20,
                            color: isSelected
                                ? const Color.fromARGB(255, 87, 210, 238)
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            shapeText,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color.fromARGB(255, 87, 210, 238)
                                  : Colors.grey.shade600,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
