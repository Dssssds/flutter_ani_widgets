import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_x_widgets/app_demo/06/widgets/glass.dart';

class DesktopScreen extends StatefulWidget {
  const DesktopScreen({super.key});

  @override
  State<DesktopScreen> createState() => _DesktopScreenState();
}

class _DesktopScreenState extends State<DesktopScreen> {
  // Stock桌面背景图片地址
  static const String desktopImagePath =
      'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/ios26-bg.png';

  // 玻璃效果参数配置
  // 玻璃效果模糊强度 - 控制背景模糊程度，数值越大越模糊
  final double _blurSigma = 3.0;
  
  // 玻璃效果折射边框宽度 - 控制玻璃边缘的折射效果范围
  final double _refractionBorder = 10.0;
  
  // 饱和度增强系数 - 控制玻璃内容的色彩饱和度，1.0为原始，>1.0增强
  final double _saturationBoost = 1.1;
  
  // 中心缩放比例 - 控制玻璃中心区域的缩放效果，<1.0为缩小
  final double _centerScale = 0.9;
  
  // 亮度补偿值 - 调整玻璃效果的整体亮度，负值变暗，正值变亮
  final double _brightnessCompensation = -0.1;
  
  // 玻璃组件的圆角半径 - 控制玻璃形状的圆角程度
  final double _borderRadius = 80.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Stock桌面背景图片 - 填满整个屏幕
          Positioned.fill(
            child: Image.network(
              desktopImagePath,
              fit: BoxFit.cover, // 图片铺满整个屏幕，保持比例
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '背景图片加载失败',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 具备内置拖拽功能的玻璃效果组件
          SuperellipseGlassPage(
            rotationAngle: 1.1,
            blurSigma: _blurSigma,
            refractionBorder: _refractionBorder,
            saturationBoost: _saturationBoost,
            centerScale: _centerScale,
            brightnessCompensation: _brightnessCompensation,
            borderRadius: _borderRadius,
          ),
        ],
      ),
    );
  }
}

/// 超椭圆玻璃效果演示页面
/// 展示使用RoundedSuperellipseBorder形状的玻璃效果
/// 这种形状介于矩形和椭圆之间，提供更加现代的视觉效果
/// 现在支持长按拖拽功能，可以在屏幕上自由移动位置
class SuperellipseGlassPage extends StatefulWidget {
  /// 旋转角度参数（虽然在此页面中未使用，但保持接口一致性）
  final double rotationAngle;
  final double blurSigma;
  final double refractionBorder;
  final double saturationBoost;
  final double centerScale;
  final double brightnessCompensation;
  final double borderRadius;
  
  /// 初始X坐标位置（可选，默认为屏幕中心）
  final double? initialX;
  
  /// 初始Y坐标位置（可选，默认为屏幕中心）
  final double? initialY;

  const SuperellipseGlassPage({
    super.key,
    required this.rotationAngle,
    required this.blurSigma,
    required this.refractionBorder,
    required this.saturationBoost,
    required this.centerScale,
    required this.brightnessCompensation,
    required this.borderRadius,
    this.initialX,
    this.initialY,
  });

  @override
  State<SuperellipseGlassPage> createState() => _SuperellipseGlassPageState();
}

/// SuperellipseGlassPage 的状态管理类
/// 负责管理组件的位置状态和拖拽交互逻辑
class _SuperellipseGlassPageState extends State<SuperellipseGlassPage> {
  /// 玻璃组件的X坐标位置
  double _x = 0.0;
  
  /// 玻璃组件的Y坐标位置
  double _y = 0.0;
  
  /// 玻璃组件的固定宽度
  static const double _glassWidth = 100.0;
  
  /// 玻璃组件的固定高度
  static const double _glassHeight = 100.0;
  
  /// 是否正在拖拽状态
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    // 在组件构建完成后设置初始位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialPosition();
    });
  }

  /// 设置组件的初始位置
  /// 如果提供了初始坐标则使用，否则默认居中显示
  void _setInitialPosition() {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      // 使用提供的初始位置，或默认居中位置
      _x = widget.initialX ?? (screenSize.width / 2 - _glassWidth / 2);
      _y = widget.initialY ?? (screenSize.height / 2 - _glassHeight / 2);
      
      // 确保初始位置在屏幕范围内
      _x = _x.clamp(0, screenSize.width - _glassWidth);
      _y = _y.clamp(0, screenSize.height - _glassHeight);
    });
  }

  /// 处理拖拽结束事件
  /// 更新组件位置并确保不超出屏幕边界
  void _onDragEnd(DraggableDetails details) {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      // 更新位置并限制在屏幕范围内
      _x = details.offset.dx.clamp(0, screenSize.width - _glassWidth);
      _y = details.offset.dy.clamp(0, screenSize.height - _glassHeight);
    });
  }

  /// 构建玻璃效果组件
  Widget _buildGlassWidget() {
    return Glass(
      key: const Key('liquido-glass-superellipse'), // 用于测试和调试的唯一标识
      blurSigma: widget.blurSigma, // 动态模糊效果
      refractionBorder: widget.refractionBorder, // 动态折射边界
      saturationBoost: widget.saturationBoost, // 动态饱和度增强
      centerScale: widget.centerScale, // 动态中心区域缩放
      brightnessCompensation: widget.brightnessCompensation, // 动态亮度补偿
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(widget.borderRadius), // 动态圆角半径
        ),
      ),
      child: const SizedBox(
        width: _glassWidth, // 固定宽度
        height: _glassHeight, // 固定高度
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _x, // 使用状态管理的X坐标
      top: _y,  // 使用状态管理的Y坐标
      child: GestureDetector(
        // 长按开始时启用拖拽模式
        onLongPressStart: (details) {
          setState(() {
            _isDragging = true;
          });
          // 提供触觉反馈
          HapticFeedback.mediumImpact();
          print('长按开始，进入拖拽模式');
        },
        
        // 长按移动时更新位置（这是长按拖拽的核心）
        onLongPressMoveUpdate: (details) {
          if (_isDragging) {
            final screenSize = MediaQuery.of(context).size;
            setState(() {
              // 使用全局位置计算新的坐标
              _x = (details.globalPosition.dx - _glassWidth / 2).clamp(0, screenSize.width - _glassWidth);
              _y = (details.globalPosition.dy - _glassHeight / 2).clamp(0, screenSize.height - _glassHeight);
            });
          }
        },
        
        // 长按结束时退出拖拽模式
        onLongPressEnd: (details) {
          setState(() {
            _isDragging = false;
          });
          print('长按结束，退出拖拽模式，最终位置: ($_x, $_y)');
        },
        
        // 使用Stack来叠加一个透明的手势检测层
        child: Stack(
          children: [
            // 玻璃组件
            _buildGlassWidget(),
            
            // 透明的手势检测层，确保手势能被正确识别
            Container(
              width: _glassWidth,
              height: _glassHeight,
              color: Colors.transparent, // 完全透明但能接收手势
            ),
          ],
        ),
      ),
    );
  }
}
