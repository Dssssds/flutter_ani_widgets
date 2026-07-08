import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_x_widgets/app_demo/12/models/todo_model.dart';
import 'package:flutter_x_widgets/app_demo/12/widgets/mountain_painter.dart';

class MountainTodoScreen extends StatefulWidget {
  const MountainTodoScreen({super.key});

  @override
  State<MountainTodoScreen> createState() => _MountainTodoScreenState();
}

class _MountainTodoScreenState extends State<MountainTodoScreen>
    with SingleTickerProviderStateMixin {
  // 日期管理
  DateTime _currentDate = DateTime.now();
  String _loadedDateKey = ''; // 当前装载的 UI 数据归属日期
  List<TodoItem> _todos = [];
  List<SettledLetter> _settledLetters = [];
  Map<String, List<SettledLetter>> _historicalMountains = {};

  // 物理模拟引擎数据
  final List<PhysicsLetter> _activeLetters = [];
  final List<UndoAnimation> _activeUndos = [];
  final List<PhysicsParticle> _particles = [];
  final ClimberState _climber = ClimberState();
  List<double> _heightmap = [];

  // Ticker 刷新循环
  late final Ticker _ticker;
  DateTime? _lastTickTime;

  // 界面参数
  final double _groundYMargin = 60.0; // 离屏幕底部间距
  double _groundY = 600.0; // 动态计算
  double _canvasWidth = 300.0;

  // 撤销堆栈（用于记录被完成待办的历史数据，结构：{ 'id', 'text', 'originalIndex', 'settledLettersList' }）
  final List<Map<String, dynamic>> _undoStack = [];

  // 动画控制列表项的组件定位
  final Map<String, GlobalKey> _itemKeys = {};

  // 记录当前正在完成且处于字母剥离渐隐过程中的待办项 ID
  final Set<String> _completingIds = {};

  @override
  void initState() {
    super.initState();
    TodoStorage.clearCache();
    _loadData();

    // 创建高帧率物理循环
    _ticker = createTicker((elapsed) {
      if (!mounted) return;
      final now = DateTime.now();
      if (_lastTickTime == null) {
        _lastTickTime = now;
        return;
      }
      final dt = now.difference(_lastTickTime!).inMicroseconds / 1000000.0;
      _lastTickTime = now;

      // 限制过大时钟步长（切后台恢复等情况）
      _stepPhysics(dt.clamp(0.001, 0.03));
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// 加载当前日期数据及历史视差山体
  Future<void> _loadData() async {
    final dayData = await TodoStorage.loadDay(_currentDate);
    final history = await TodoStorage.loadHistoricalMountains(_currentDate, 4);

    setState(() {
      _loadedDateKey = '${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.day.toString().padLeft(2, '0')}';
      _todos = List.from(dayData.todos);
      _settledLetters = List.from(dayData.settledLetters);
      _historicalMountains = history;
      _activeLetters.clear();
      _activeUndos.clear();
      _particles.clear();
      _undoStack.clear();
    });

    _rebuildHeightmap();
  }

  /// 将当前界面的数据安全地存入其所归属的日期缓存中（避开异步时间切换的竞争）
  Future<void> _saveLoadedDay() async {
    if (_loadedDateKey.isEmpty) return;

    final parts = _loadedDateKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    final date = DateTime(year, month, day);

    final data = DayMountain(
      dateKey: _loadedDateKey,
      todos: List.from(_todos),
      settledLetters: List.from(_settledLetters),
    );
    await TodoStorage.saveDay(date, data);
  }

  /// 重建高度图（供火柴人吸附和寻峰）
  void _rebuildHeightmap() {
    if (_canvasWidth <= 0) return;
    final len = _canvasWidth.round();
    
    // 初始化地面高度
    final newMap = List<double>.filled(len, _groundY);

    // 根据固定的山脉字母更新高度
    for (var letter in _settledLetters) {
      final radius = letter.size * 0.45;
      final leftX = (letter.x - radius).round().clamp(0, len - 1);
      final rightX = (letter.x + radius).round().clamp(0, len - 1);

      for (int x = leftX; x <= rightX; x++) {
        // 圆形山脊表面拟合
        final dx = x - letter.x;
        final dy = math.sqrt(math.max(0, radius * radius - dx * dx));
        final topY = letter.y - dy;
        if (topY < newMap[x]) {
          newMap[x] = topY;
        }
      }
    }

    _heightmap = newMap;
  }

  /// 单步物理时序解算
  void _stepPhysics(double dt) {
    if (_canvasWidth <= 0) return;

    // 1. 更新延迟释放倒计时
    for (var letter in _activeLetters) {
      if (letter.delay > 0) {
        letter.delay -= dt;
      }
    }

    // 物理环境参数
    const double g = 800.0; // 重力加速度 (从 420.0 上调至 800.0，加快掉落速度)
    const double restitution = 0.35; // 字母反弹系数
    const double friction = 0.85; // 滑动摩擦系数 (上调摩擦以更容易堆积成尖锐山峰)

    // 2. 积分计算位置与碰撞
    for (int i = 0; i < _activeLetters.length; i++) {
      var a = _activeLetters[i];
      if (a.delay > 0) continue;

      // 施加重力
      a.vy += g * dt;
      a.x += a.vx * dt;
      a.y += a.vy * dt;
      a.angle += a.angularVelocity * dt;

      // 施加轻微空气阻力阻尼，使其尽快平稳
      a.vx *= 0.98;
      a.vy *= 0.98;
      a.angularVelocity *= 0.97;

      // 地面碰撞
      double r = a.radius;
      if (a.y >= _groundY - r) {
        a.y = _groundY - r;
        
        // 当垂直反弹速度极小时，直接吸收能量，转为静止或滑动摩擦
        if (a.vy.abs() < 24.0) {
          a.vy = 0;
          a.vx *= 0.75;
          a.angularVelocity *= 0.75;
        } else {
          a.vy = -a.vy * restitution;
          a.vx *= friction;
          a.angularVelocity *= 0.6;
        }
      }

      // 两侧墙壁碰撞
      if (a.x <= r) {
        a.x = r;
        a.vx = -a.vx * restitution;
      } else if (a.x >= _canvasWidth - r) {
        a.x = _canvasWidth - r;
        a.vx = -a.vx * restitution;
      }


    }

    // 3. 动态字母相互碰撞 (Euler Impulse Solver)
    for (int i = 0; i < _activeLetters.length; i++) {
      var a1 = _activeLetters[i];
      if (a1.delay > 0) continue;

      for (int j = i + 1; j < _activeLetters.length; j++) {
        var a2 = _activeLetters[j];
        if (a2.delay > 0) continue;

        double dx = a1.x - a2.x;
        double dy = a1.y - a2.y;
        double dist = math.sqrt(dx * dx + dy * dy);
        double minDist = a1.radius + a2.radius;

        if (dist < minDist && dist > 0) {
          double overlap = minDist - dist;
          double nx = dx / dist;
          double ny = dy / dist;

          // 挤开重叠
          a1.x += nx * overlap * 0.5;
          a1.y += ny * overlap * 0.5;
          a2.x -= nx * overlap * 0.5;
          a2.y -= ny * overlap * 0.5;

          // 解算反弹速度
          double rvx = a1.vx - a2.vx;
          double rvy = a1.vy - a2.vy;
          double vn = rvx * nx + rvy * ny;

          if (vn < 0) {
            // 当相对碰撞速度过小时设弹性系数为 0，避免微弱反弹抖动
            double e = vn.abs() < 24.0 ? 0.0 : restitution;
            double impulse = -(1.0 + e) * vn * 0.5;
            a1.vx += nx * impulse;
            a1.vy += ny * impulse;
            a2.vx -= nx * impulse;
            a2.vy -= ny * impulse;

            // 应用切向滑动阻尼
            double tx = -ny;
            double ty = nx;
            double vt = rvx * tx + rvy * ty;
            a1.vx -= tx * vt * friction * 0.5;
            a1.vy -= ty * vt * friction * 0.5;
            a2.vx += tx * vt * friction * 0.5;
            a2.vy += ty * vt * friction * 0.5;
          }
        }
      }
    }

    // 4. 动态字母与已固定字母碰撞
    for (var a in _activeLetters) {
      if (a.delay > 0) continue;

      for (var s in _settledLetters) {
        double dx = a.x - s.x;
        double dy = a.y - s.y;
        double dist = math.sqrt(dx * dx + dy * dy);
        double radiusS = s.size * 0.45;
        double minDist = a.radius + radiusS;

        if (dist < minDist && dist > 0) {
          double overlap = minDist - dist;
          double nx = dx / dist;
          double ny = dy / dist;

          // 仅挤开动态字母
          a.x += nx * overlap;
          a.y += ny * overlap;

          double vn = a.vx * nx + a.vy * ny;
          if (vn < 0) {
            // 当相对碰撞速度过小时设弹性系数为 0，防止微幅反弹抖动
            double e = vn.abs() < 24.0 ? 0.0 : restitution;
            double impulse = -(1.0 + e) * vn;
            a.vx += nx * impulse;
            a.vy += ny * impulse;

            // 应用切向滑动阻尼
            double tx = -ny;
            double ty = nx;
            double vt = a.vx * tx + a.vy * ty;
            a.vx -= tx * vt * friction;
            a.vy -= ty * vt * friction;
          }
        }
      }
    }

    // 4.5 极低速阻尼过滤（帮助字母平稳极速进入完全静止状态，切断高频晃动）
    for (var a in _activeLetters) {
      if (a.delay > 0) continue;
      double speed = math.sqrt(a.vx * a.vx + a.vy * a.vy);
      if (speed < 12.0) {
        a.vx *= 0.5;
        a.vy *= 0.5;
        a.angularVelocity *= 0.5;
        if (speed < 1.5) {
          a.vx = 0;
          a.vy = 0;
          a.angularVelocity = 0;
        }
      }
    }

    // 4.8 休眠帧数判定：在完成所有碰撞和阻尼解析后，检测并累加静止帧数（防止重力瞬间增加的速度干扰）
    for (var a in _activeLetters) {
      if (a.delay > 0) continue;
      double speed = math.sqrt(a.vx * a.vx + a.vy * a.vy);
      if (speed < 4.0 && a.angularVelocity.abs() < 0.1) {
        a.settledFrames++;
      } else {
        a.settledFrames = 0;
      }
    }

    // 5. 休眠冻结：字母静止 25 帧以上后，快速固化为背景山体，避免堆积卡顿并加速高度图构建
    final List<PhysicsLetter> toFreeze = [];
    for (var a in _activeLetters) {
      if (a.settledFrames >= 25) {
        toFreeze.add(a);
      }
    }

    if (toFreeze.isNotEmpty) {
      setState(() {
        for (var a in toFreeze) {
          _activeLetters.remove(a);
          final settled = SettledLetter(
            todoId: a.id,
            char: a.char,
            x: a.x,
            y: a.y,
            angle: a.angle,
            size: a.size,
            colorValue: a.color.value,
          );
          _settledLetters.add(settled);

          // 绑定字母到撤销栈的最顶层记录中
          if (_undoStack.isNotEmpty) {
            final top = _undoStack.last;
            if (top['id'] == a.id) {
              (top['settledLetters'] as List<SettledLetter>).add(settled);
            }
          }
        }
        _saveLoadedDay();
      });
    }

    // 6. 更新攀登者高度图
    _rebuildHeightmap();

    _climber.update(dt, _heightmap, _canvasWidth, _groundY);

    // 7. 更新撤销动画
    _stepUndoAnimations(dt);

    // 8. 更新粒子系统
    for (int i = _particles.length - 1; i >= 0; i--) {
      _particles[i].update(dt);
      if (_particles[i].life <= 0) {
        _particles.removeAt(i);
      }
    }

    // 触发重绘
    setState(() {});
  }

  /// 撤销飞行动画更新
  void _stepUndoAnimations(double dt) {
    for (int i = _activeUndos.length - 1; i >= 0; i--) {
      final undo = _activeUndos[i];
      undo.progress += dt * 1.5; // 0.7秒内返回

      // 释放荧光拖尾粒子
      double t = undo.progress;
      double mt = 1 - t;
      double curX = mt * mt * undo.start.dx + 2 * mt * t * undo.control.dx + t * t * undo.target.dx;
      double curY = mt * mt * undo.start.dy + 2 * mt * t * undo.control.dy + t * t * undo.target.dy;

      _particles.add(PhysicsParticle(
        x: curX,
        y: curY,
        vx: (math.Random().nextDouble() - 0.5) * 40,
        vy: (math.Random().nextDouble() - 0.5) * 40,
        size: 3.0,
        life: 0.6,
        color: undo.color,
      ));

      if (undo.progress >= 1.0) {
        _activeUndos.removeAt(i);
      }
    }
  }

  /// 完成待办，触发字母掉落
  void _completeTodo(int index) {
    final todo = _todos[index];
    final key = _itemKeys[todo.id];

    double startY = 150.0;
    double startXMin = 50.0;
    double startXMax = _canvasWidth - 50.0;

    // 尝试寻找 DOM 卡片实际屏幕位置作为字母下落起点
    if (key != null) {
      final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final pos = box.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
        startY = pos.dy + box.size.height / 2;
        startXMin = pos.dx + 30;
        startXMax = pos.dx + box.size.width - 30;
      }
    }

    final charList = todo.text.split('');
    final listLen = charList.length;
    final List<PhysicsLetter> spawned = [];
    final List<SettledLetter> trackingList = [];

    // 创建撤销记录项
    _undoStack.add({
      'id': todo.id,
      'text': todo.text,
      'originalIndex': index,
      'settledLetters': trackingList, // 字母变静态时会塞入该数组
    });

    // 计算该待办项掉落的局部重心（以卡片中点为基础，加入随机偏移，使不同待办掉落的山峰错开）
    final double cardCenter = startXMin + (startXMax - startXMin) * 0.5;
    final double focalX = cardCenter + (math.Random().nextDouble() - 0.5) * 120.0;

    for (int i = 0; i < listLen; i++) {
      final char = charList[i];
      if (char.trim().isEmpty) continue;

      // 围绕落点重心进行适度宽度的随机分布（由 100 像素调大至 160 像素范围内分散），使它们堆积成更有层次的缓坡小山峰
      double charX = focalX + (math.Random().nextDouble() - 0.5) * 160.0;

      // 文字颜色为白色
      const color = Colors.white;

      final letter = PhysicsLetter(
        id: todo.id,
        char: char,
        x: charX.clamp(20.0, _canvasWidth - 20.0),
        y: startY,
        vx: (math.Random().nextDouble() - 0.5) * 40, // 稍微缩减水平初速度以维持堆积中心
        vy: -10.0 - math.Random().nextDouble() * 20, // 减小向上的初始弹力，使其更快向下俯冲坠落
        angle: (math.Random().nextDouble() - 0.5) * 0.5,
        angularVelocity: (math.Random().nextDouble() - 0.5) * 3,
        size: 16.0 + math.Random().nextDouble() * 6.0,
        color: color,
        delay: 0.0, // 字母整体同时掉落
      );

      spawned.add(letter);
    }

    setState(() {
      _completingIds.add(todo.id);
      _activeLetters.addAll(spawned);
    });

    // 字母整体立即掉落，因此卡片渐隐收编等待缩减为 400ms 即可
    final int delayMs = 400;
    final String currentLoadedKey = _loadedDateKey;
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) {
        if (_loadedDateKey == currentLoadedKey) {
          setState(() {
            _todos.removeWhere((t) => t.id == todo.id);
            _completingIds.remove(todo.id);
            _saveLoadedDay();
          });
        } else {
          // 如果在这 400ms 内用户已经切换了日期，直接去静态缓存中移除对应日期的 todo，避免跨日期数据越界破坏
          TodoStorage.removeTodoFromCache(currentLoadedKey, todo.id);
        }
      }
    });
  }

  /// 触发撤销操作（从山体抽回字母，变回待办列表）
  void _triggerUndo() {
    if (_undoStack.isEmpty) return;
    final record = _undoStack.removeLast();

    final String id = record['id'];
    final String text = record['text'];
    final int originalIndex = record['originalIndex'];
    final List<SettledLetter> attachedLetters = List.from(record['settledLetters']);

    // 寻找待办复原卡片的目标落点
    double targetY = 150.0;
    double targetXMin = 50.0;
    double targetXMax = _canvasWidth - 50.0;

    // 先把待办插回列表，等待渲染以获取目标位置
    setState(() {
      _todos.insert(originalIndex.clamp(0, _todos.length), TodoItem(id: id, text: text));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _itemKeys[id];
      if (key != null) {
        final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final pos = box.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
          targetY = pos.dy + box.size.height / 2;
          targetXMin = pos.dx + 30;
          targetXMax = pos.dx + box.size.width - 30;
        }
      }

      final undos = <UndoAnimation>[];

      // 收集并移除当前任务在物理世界的全部字母（包括已冻结和下落中）
      setState(() {
        // 从已固定山体中直接根据 todoId 剥离，完全解耦对坐标精度或状态时序的依赖
        _settledLetters.removeWhere((letter) {
          if (letter.todoId == id) {
            undos.add(UndoAnimation(
              id: id,
              char: letter.char,
              start: Offset(letter.x, letter.y),
              target: Offset(targetXMin + (targetXMax - targetXMin) * 0.5, targetY), // 飞回中点
              size: letter.size,
              color: Color(letter.colorValue),
              control: Offset((letter.x + targetXMin) / 2, math.min(letter.y, targetY) - 120),
            ));
            return true;
          }
          return false;
        });

        // 从正在下落列表中剥离
        _activeLetters.removeWhere((letter) {
          if (letter.id == id) {
            undos.add(UndoAnimation(
              id: id,
              char: letter.char,
              start: Offset(letter.x, letter.y),
              target: Offset(targetXMin + (targetXMax - targetXMin) * 0.5, targetY),
              size: letter.size,
              color: letter.color,
              control: Offset((letter.x + targetXMin) / 2, math.min(letter.y, targetY) - 120),
            ));
            return true;
          }
          return false;
        });

        _activeUndos.addAll(undos);
        _saveLoadedDay();
        _rebuildHeightmap();
      });
    });
  }

  /// 日期向后/向前切换
  void _changeDate(int offset) {
    // 切换日期前，同步保存当前装载的数据
    _saveLoadedDay();

    setState(() {
      _currentDate = _currentDate.add(Duration(days: offset));
    });
    _loadData();
  }

  /// 添加新的空待办项
  void _addTodo() {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    setState(() {
      _todos.add(TodoItem(id: id, text: ''));
    });
    _saveLoadedDay();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _canvasWidth = size.width;
    _groundY = size.height - _groundYMargin;

    final dateStr = '${_currentDate.year}年${_currentDate.month}月${_currentDate.day}日';

    return Scaffold(
      body: Stack(
        children: [
          // 1. 全屏物理渲染 Canvas 画布
          Positioned.fill(
            child: CustomPaint(
              painter: MountainPainter(
                activeLetters: _activeLetters,
                settledLetters: _settledLetters,
                historicalMountains: _historicalMountains,
                activeUndos: _activeUndos,
                particles: _particles,
                climber: _climber,
                heightmap: _heightmap,
                groundY: _groundY,
              ),
            ),
          ),

          // 2. 界面层 (待办列表 & 头部)
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部日期控制区
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        onPressed: () => _changeDate(-1),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                        onPressed: () => _changeDate(1),
                      ),
                    ],
                  ),
                ),

                // 中间待办事项卡片列表
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      // 确保每个 item 有独一无二的 Key 供测量物理坐标
                      final key = _itemKeys.putIfAbsent(todo.id, () => GlobalKey());
                      final bool isCompleting = _completingIds.contains(todo.id);

                      return AnimatedCrossFade(
                        duration: const Duration(milliseconds: 400),
                        firstCurve: Curves.easeInOut,
                        secondCurve: Curves.easeInOut,
                        sizeCurve: Curves.easeInOut,
                        crossFadeState: isCompleting
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        secondChild: const SizedBox(width: double.infinity, height: 0),
                        firstChild: Container(
                          key: key,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              // 检查圈
                              GestureDetector(
                                onTap: () => _completeTodo(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutBack,
                                  margin: const EdgeInsets.all(12),
                                  width: isCompleting ? 36 : 24,
                                  height: isCompleting ? 36 : 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCompleting ? Colors.white.withOpacity(0.2) : Colors.transparent,
                                    border: Border.all(
                                      color: isCompleting ? Colors.white : Colors.white54,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.check,
                                      size: 14,
                                      color: isCompleting ? Colors.white : Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                              // 输入框
                              Expanded(
                                child: TextFormField(
                                  initialValue: todo.text,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                  decoration: const InputDecoration(
                                    hintText: '写点什么待办事项...',
                                    hintStyle: TextStyle(color: Colors.white38),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (val) {
                                    todo.text = val;
                                    _saveLoadedDay();
                                  },
                                ),
                              ),
                              // 删除键
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white30, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _todos.removeAt(index);
                                    _saveLoadedDay();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. 悬浮浮标按钮：点击撤销（挂在攀登者头顶）
          if (_undoStack.isNotEmpty)
            Positioned(
              left: _climber.x - 24,
              top: _climber.y - 75,
              child: GestureDetector(
                onTap: _triggerUndo,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5030EF).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5030EF).withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.undo, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        '撤销完成',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 4. 右下角添加待办项悬浮按钮
          Positioned(
            right: 20,
            bottom: _groundYMargin + 20,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF5030EF),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: _addTodo,
            ),
          ),
        ],
      ),
    );
  }
}
