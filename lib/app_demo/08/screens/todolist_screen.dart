// ignore_for_file: prefer_const_constructors

// 导入Dart的UI库，用于图像滤镜效果
import 'dart:ui';

// 导入Flutter的核心Material设计组件库
import 'package:flutter/material.dart';
// 导入Flutter的系统服务库，用于控制状态栏样式
import 'package:flutter/services.dart';
// 导入健康数据摘要组件
import 'package:flutter_x_widgets/app_demo/08/models/health_summary.dart';
// 导入任务数据模型和任务项组件
import 'package:flutter_x_widgets/app_demo/08/models/tasks.dart';
// 导入拖拽手柄组件
import 'package:flutter_x_widgets/app_demo/08/widgets/drag_handle.dart';
// 导入任务摘要统计组件
import 'package:flutter_x_widgets/app_demo/08/widgets/tasks_summary.dart';
// 导入顶部时间日期显示组件
import 'package:flutter_x_widgets/app_demo/08/widgets/top_header.dart';

// 定义可拖拽面板的最小尺寸（屏幕高度的43%）
// 这个值决定了面板最小化时显示的高度
const minimumDragSize = 0.43;

// 定义可拖拽面板的最大尺寸（屏幕高度的100%）
// 面板完全展开时占满整个屏幕
const maximumDragSize = 1.0;

/// 待办事项列表主界面
/// 这是一个有状态的Widget，实现了可拖拽的任务管理界面
/// 具有动态主题切换、背景模糊、数字动画等特效
class TodolistScreen extends StatefulWidget {
  const TodolistScreen({super.key});

  @override
  State<TodolistScreen> createState() => _TodolistScreenState();
}

/// 待办事项界面的状态管理类
/// 使用TickerProviderStateMixin提供动画ticker支持
class _TodolistScreenState extends State<TodolistScreen>
    with TickerProviderStateMixin {
  
  /// 构造函数
  _TodolistScreenState();

  /// 动画列表的全局键，用于控制任务列表项的添加/删除动画
  /// GlobalKey允许我们从外部访问AnimatedList的状态
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  /// 可拖拽滚动面板的控制器
  /// 用于监听面板的拖拽状态和控制面板的展开/收缩
  final DraggableScrollableController _draggableScrollableController =
      DraggableScrollableController();

  /// 标题主要颜色（当前显示的颜色）- 初始为白色（深色主题）
  /// 这个颜色会根据面板的展开状态动态变化
  var headerMainDarkColor = Colors.white;

  /// 标题次要颜色（当前显示的颜色）- 初始为半透明白色（深色主题）
  /// 用于显示日期等次要信息
  var headerSecondaryDarkColor = Colors.white70;

  /// 标题主要颜色（浅色主题状态下的目标颜色）- 黑色
  /// 当面板展开到一定程度时，文字会变成这个颜色
  var headerMainLightColor = Colors.black;
  
  /// 标题次要颜色（浅色主题状态下的目标颜色）- 半透明黑色
  var headerSecondaryLightColor = Colors.black54;

  /// 拖拽手柄的垂直偏移量（像素）
  /// 控制拖拽手柄距离容器顶部的距离，用于实现隐藏效果
  double dragHandleVerticalOffset = 4;

  /// 是否应该显示拖拽手柄
  /// 当面板展开到一定程度时，手柄会隐藏以提供更清洁的界面
  bool shouldShowDragHandle = true;

  /// 当前可拖拽面板的尺寸比例（0.0-1.0）
  /// 初始值设为最小拖拽尺寸，表示面板处于最小化状态
  var draggableSheetSize = minimumDragSize;

  /// 状态栏亮度设置
  /// 控制状态栏文字和图标的颜色（dark=白色文字，light=黑色文字）
  var statusBarBrightness = Brightness.dark;

  /// 面板是否完全展开的标志
  /// 用于控制某些动画和UI状态，例如数字计数动画
  bool isExpanded = false;

  /// 任务完成状态列表
  /// 用于跟踪每个任务的完成状态，索引对应tasks列表中的任务
  List<bool> taskCompletionStates = List.filled(tasks.length, false);

  @override
  void initState() {
    /// 设置应用启动时的状态栏样式
    /// 由于初始背景是黑色，所以使用深色主题（白色状态栏内容）
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarBrightness: statusBarBrightness),
    );

    /// 为可拖拽面板控制器添加监听器
    /// 这个监听器会在面板尺寸发生变化时被调用，实现动态UI响应
    _draggableScrollableController.addListener(() {
      /// 实时更新当前面板尺寸变量
      /// 这个变量在多个地方被使用来判断当前面板状态
      draggableSheetSize = _draggableScrollableController.size;
      
      /// 当面板展开到80%以上时，开始切换到浅色主题状态
      /// 这个阈值是精心选择的，确保过渡效果自然
      if (_draggableScrollableController.size >= .8) {
        setState(() {
          /// 将状态栏切换为浅色主题
          /// Brightness.light 表示状态栏内容为黑色（适配白色背景）
          SystemChrome.setSystemUIOverlayStyle(
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
          );

          /// 更改标题文字颜色为黑色，以适应即将到来的白色背景
          /// 这样确保文字在白色背景上依然清晰可见
          headerMainDarkColor = Colors.black;
          headerSecondaryDarkColor = Colors.black54;
          
          /// 增加拖拽手柄的垂直偏移量，为隐藏动画做准备
          /// 更大的偏移量会让手柄向下移动，逐渐超出可视区域
          dragHandleVerticalOffset = 40;

          /// 设置拖拽手柄为不可见状态
          /// 这会触发手柄的透明度动画，让它逐渐消失
          shouldShowDragHandle = false;

          /// 当面板展开到95%以上时，标记为完全展开状态
          /// 这个状态用于触发一些特殊的动画效果，如数字计数动画
          if (_draggableScrollableController.size >= .95) {
            /// 检查是否已经是展开状态，避免重复设置
            if (!isExpanded) {
              isExpanded = true;
            }
          }
        });
      }
      /// 当面板收缩到85%以下时，切换回深色主题状态
      /// 使用不同的阈值（85% vs 80%）创建迟滞效果，防止抖动
      else if (_draggableScrollableController.size < .85) {
        setState(() {
          /// 将状态栏恢复为深色主题
          /// Brightness.dark 表示状态栏内容为白色（适配黑色背景）
          SystemChrome.setSystemUIOverlayStyle(
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
          );

          /// 恢复标题文字颜色为白色，以适应黑色背景
          /// 确保在深色背景下文字清晰可见
          headerMainDarkColor = Colors.white;
          headerSecondaryDarkColor = Colors.white70;
          
          /// 减少拖拽手柄的垂直偏移，让它回到正常位置
          /// 较小的偏移量让手柄重新出现在可视区域内
          dragHandleVerticalOffset = 6;

          /// 重新显示拖拽手柄
          /// 这会触发透明度动画，让手柄逐渐显现
          shouldShowDragHandle = true;
        });

        /// 当面板完全收缩到最小尺寸时，取消展开状态
        /// 这会停止某些只在展开状态才播放的动画
        if (_draggableScrollableController.size <= minimumDragSize) {
          setState(() {
            /// 检查当前是否为展开状态，避免重复设置
            if (isExpanded) {
              isExpanded = false;
            }
          });
        }
      }
    });
    /// 调用父类的initState方法，确保正确的初始化流程
    super.initState();
  }

/// 处理任务完成状态变化的回调方法
/// 当用户点击checkbox时会被调用
/// [index] 任务在列表中的索引
/// [completed] 新的完成状态
void _onTaskCompleted(int index, bool? completed) {
  setState(() {
    /// 更新对应任务的完成状态
    taskCompletionStates[index] = completed ?? false;
  });
}

/// 计算已完成的任务数量
/// 用于更新TasksSummary中显示的统计信息
int get completedTaskCount {
  return taskCompletionStates.where((completed) => completed).length;
}

/// 计算未完成的任务数量
int get remainingTaskCount {
  return taskCompletionStates.where((completed) => !completed).length;
}

/// 构建现代化的添加按钮
/// 采用简约扁平的设计风格，支持交互动画
Widget _ModernAddButton() {
  return const _AddButtonWidget();
}

@override
  Widget build(BuildContext context) {
    /// 返回主界面的Scaffold结构
    /// Scaffold提供了基本的Material Design布局结构
    return Scaffold(
      /// 设置深色背景，营造现代感的设计风格
      backgroundColor: Colors.black,
      
      /// 使用Stack布局实现多层UI结构
      /// Stack允许子组件重叠放置，是实现复杂UI的关键
      body: Stack(
        children: [
          /// 第一层：背景内容区域（带模糊效果的任务摘要和健康统计）
          /// 使用TweenAnimationBuilder实现动态模糊效果
          TweenAnimationBuilder<double>(
            /// 定义模糊程度的变化范围
            /// 当面板展开超过最小尺寸的1.5倍时，应用10像素的模糊效果
            tween: Tween(
              begin: 0.0, // 开始时无模糊
              end: draggableSheetSize > minimumDragSize * 1.5 ? 10.0 : 0.0, // 根据面板尺寸动态设置模糊程度
            ),
            /// 模糊动画持续时间（350微秒，应该是毫秒的笔误）
            duration: const Duration(microseconds: 350),
            /// 使用线性到缓出的动画曲线，让过渡更自然
            curve: Curves.linearToEaseOut,
            /// 构建器函数：根据当前动画值应用模糊滤镜
            builder: (context, sigma, child) => ImageFiltered(
              /// 使用高斯模糊滤镜，sigma值控制模糊程度
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: child,
            ),
            /// 背景内容：任务摘要和健康统计的垂直布局
            child: Column(
              /// 子组件左对齐
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 任务摘要组件 - 显示今日任务统计信息
                TasksSummary(
                  taskCount: remainingTaskCount.toDouble(), // 使用动态计算的剩余任务数量
                  meetingCount: 2, // 今日会议数量
                  habitCount: 1, // 今日习惯数量
                  /// 动画控制逻辑：只有在面板完全展开且尺寸足够时才播放数字计数动画
                  /// 这样确保动画在合适的时机播放，提升用户体验
                  shouldAnimate: isExpanded && draggableSheetSize >= minimumDragSize,
                ),
                /// 添加24像素的垂直间距，分隔不同的内容区域
                const SizedBox(height: 5),
                /// 健康统计组件 - 显示步数、睡眠时间、运动时间等信息
                /// 使用Padding添加水平内边距，与任务摘要保持视觉一致性
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: const HealthSummary(),
                ),
              ],
            ),
          ),

          /// 第二层：可拖拽的任务列表面板
          /// DraggableScrollableSheet是实现可拖拽面板的核心组件
          DraggableScrollableSheet(
            /// 启用吸附效果，面板会自动吸附到特定位置
            /// 这提供了更好的用户体验，避免面板停留在中间位置
            snap: true,
            /// 设置控制器以监听面板尺寸变化
            /// 这个控制器在initState中设置了监听器
            controller: _draggableScrollableController,
            /// 设置面板的初始尺寸为最小拖拽尺寸
            /// 应用启动时面板处于最小化状态
            initialChildSize: minimumDragSize,
            /// 设置面板可以收缩到的最小尺寸
            minChildSize: minimumDragSize,
            /// 设置面板可以展开到的最大尺寸
            maxChildSize: maximumDragSize,
            /// 构建器函数：创建面板的内容
            /// scrollController用于控制面板内容的滚动
            builder: (context, scrollController) => Stack(
              children: [
                /// 主容器：包含任务列表的白色面板
                Container(
                  /// 设置面板的视觉样式
                  decoration: const BoxDecoration(
                    color: Colors.white, // 白色背景，与深色主背景形成对比
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30), // 顶部30像素圆角，营造现代感
                    ),
                  ),
                  /// 使用AnimatedList显示任务列表
                  /// AnimatedList支持项目的插入和删除动画
                  child: AnimatedList(
                    /// 使用弹跳物理效果，提供iOS风格的滚动体验
                    physics: const BouncingScrollPhysics(),
                    /// 设置列表的全局键，用于从外部控制动画
                    key: _listKey,
                    /// 连接滚动控制器，使列表可以与面板的拖拽行为同步
                    controller: scrollController,
                    /// 初始项目数量：任务数量 + 1（拖拽手柄占用一个位置）
                    initialItemCount: tasks.length + 1,
                    /// 项目构建器：根据索引构建不同类型的列表项
                    itemBuilder: (context, index, animation) {
                      /// 第一个项目（索引0）：拖拽手柄
                      if (index == 0) {
                        return SizeTransition(
                          /// sizeFactor控制项目的尺寸过渡动画
                          /// 当项目被添加或删除时会有平滑的尺寸变化
                          sizeFactor: animation,
                          child: DragHandle(
                            /// 传递垂直偏移量，控制手柄的位置
                            verticalOffset: dragHandleVerticalOffset,
                            /// 传递可见性状态，控制手柄的显示/隐藏
                            isVisible: shouldShowDragHandle,
                          ),
                        );
                      }
                      /// 其他项目：任务列表项
                      return SizeTransition(
                        /// 同样的尺寸过渡动画
                        sizeFactor: animation,
                        /// 从任务数组中获取对应的任务项，并添加状态管理
                        /// index-1是因为索引0被拖拽手柄占用了
                        child: TaskTile(
                          title: tasks[index - 1].title,
                          time: tasks[index - 1].time,
                          leading: tasks[index - 1].leading,
                          completed: taskCompletionStates[index - 1],
                          onChanged: (completed) => _onTaskCompleted(index - 1, completed),
                        ),
                      );
                    },
                  ),
                ),
                /// 浮动操作按钮 - 用于添加新任务
                /// 使用AnimatedPositioned实现位置动画
                AnimatedPositioned(
                  /// 位置变化的动画持续时间
                  duration: const Duration(milliseconds: 300),
                  /// 使用线性到缓出的动画曲线
                  curve: Curves.linearToEaseOut,
                  /// 右边距：屏幕宽度的1/3，确保按钮居中
                  right: MediaQuery.of(context).size.width / 3,
                  /// 底部位置：根据拖拽手柄的可见性动态调整
                  /// 当手柄隐藏时显示按钮，当手柄显示时隐藏按钮
                  bottom: shouldShowDragHandle ? -200 : 24, // -200将按钮移到屏幕外，24是正常显示位置
                  /// 左边距：屏幕宽度的1/3，与右边距配合实现居中
                  left: MediaQuery.of(context).size.width / 3,
                  child: _ModernAddButton(),
                ),
              ],
            ),
          ),

          /// 第三层：顶部标题组件 - 显示时间、日期和状态指示器
          /// 这个组件始终保持在最顶层，不受面板拖拽影响
          TopHeader(
            /// 传递主要文本颜色，会根据面板展开状态动态变化
            headerMainColor: headerMainDarkColor,
            /// 传递次要文本颜色，用于显示日期等信息
            headerSecondaryColor: headerSecondaryDarkColor,
          ),
        ],
      ),
    );
  }
}

/// 现代化的添加按钮组件
/// 采用简约扁平的设计风格，支持交互动画效果
class _AddButtonWidget extends StatefulWidget {
  const _AddButtonWidget({super.key});

  @override
  State<_AddButtonWidget> createState() => _AddButtonWidgetState();
}

/// 添加按钮的状态管理类
/// 负责管理按压动画和交互效果
class _AddButtonWidgetState extends State<_AddButtonWidget>
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
      end: 0.92,
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
      onTap: () {
        // TODO: 实现添加任务功能
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              /// 按钮尺寸
              width: 56,
              height: 56,
              /// 按钮装饰
              decoration: BoxDecoration(
                /// 现代化的渐变背景
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF667eea), // 优雅的蓝紫色
                    Color(0xFF764ba2), // 深紫色
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                /// 完美圆形
                borderRadius: BorderRadius.circular(28),
                /// 动态阴影效果
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(_isPressed ? 0.3 : 0.4),
                    blurRadius: _isPressed ? 6 : 12,
                    offset: Offset(0, _isPressed ? 2 : 6),
                    spreadRadius: _isPressed ? 0 : 1,
                  ),
                ],
              ),
              /// 图标居中
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}
