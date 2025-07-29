import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/06/widgets/glass.dart';

class GlassScreen extends StatefulWidget {
  const GlassScreen({super.key});

  @override
  State<GlassScreen> createState() => _GlassScreenState();
}

class _GlassScreenState extends State<GlassScreen> {
  // 玻璃效果参数配置
  double _blurSigma = 20.0;
  double _refractionBorder = 5.0;
  double _saturationBoost = 1.1;
  double _centerScale = 0.9;
  double _brightnessCompensation = -0.1;
  double _borderRadius = 30.0;

  // 远端图片地址
  static const List<String> imagePaths = [
    'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-01.jpg',
    'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-02.jpg',
    'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-03.jpg',
    'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-04.jpg',
  ];

  // 显示底部设置弹窗
  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许自定义高度
      backgroundColor: Colors.transparent, // 透明背景，便于自定义样式
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.35, // 占屏幕35%高度
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15), // 白色透明背景
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20), // 顶部圆角
            ),
            // 添加阴影效果增强层次感
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // 添加模糊效果
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1), // 模糊层上的透明白色
                ),
                child: Column(
                  children: [
                    // 顶部拖拽指示器
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // 标题
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        '设置',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // 设置选项列表
                    Expanded(
                      child: StatefulBuilder(
                        builder: (context, setModalState) {
                          return ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              // 模糊强度调整
                              _buildSliderTile(
                                icon: Icons.blur_on,
                                title: '模糊强度',
                                subtitle: '调整玻璃模糊效果',
                                value: _blurSigma,
                                min: 0,
                                max: 30,
                                onChanged: (value) {
                                  setModalState(() {
                                    _blurSigma = value;
                                  });
                                  setState(() {});
                                },
                              ),
                              // 折射边界调整
                              _buildSliderTile(
                                icon: Icons.crop_square,
                                title: '折射边界',
                                subtitle: '调整玻璃边界效果',
                                value: _refractionBorder,
                                min: 0,
                                max: 20,
                                onChanged: (value) {
                                  setModalState(() {
                                    _refractionBorder = value;
                                  });
                                  setState(() {});
                                },
                              ),
                              // 饱和度增强调整
                              _buildSliderTile(
                                icon: Icons.color_lens,
                                title: '饱和度增强',
                                subtitle: '调整颜色饱和度',
                                value: _saturationBoost,
                                min: 0.5,
                                max: 2.0,
                                onChanged: (value) {
                                  setModalState(() {
                                    _saturationBoost = value;
                                  });
                                  setState(() {});
                                },
                              ),
                              // 中心缩放调整
                              _buildSliderTile(
                                icon: Icons.zoom_in,
                                title: '中心缩放',
                                subtitle: '调整中心区域缩放',
                                value: _centerScale,
                                min: 0.1,
                                max: 1.0,
                                onChanged: (value) {
                                  setModalState(() {
                                    _centerScale = value;
                                  });
                                  setState(() {});
                                },
                              ),
                              // 亮度补偿调整
                              _buildSliderTile(
                                icon: Icons.brightness_6,
                                title: '亮度补偿',
                                subtitle: '调整整体亮度',
                                value: _brightnessCompensation,
                                min: -1.0,
                                max: 1.0,
                                onChanged: (value) {
                                  setModalState(() {
                                    _brightnessCompensation = value;
                                  });
                                  setState(() {});
                                },
                              ),
                              // 圆角半径调整
                              _buildSliderTile(
                                icon: Icons.rounded_corner,
                                title: '圆角半径',
                                subtitle: '调整玻璃圆角',
                                value: _borderRadius,
                                min: 0,
                                max: 100,
                                onChanged: (value) {
                                  setModalState(() {
                                    _borderRadius = value;
                                  });
                                  setState(() {});
                                },
                              ),
                              const SizedBox(height: 16),
                              // 重置按钮
                              ElevatedButton(
                                onPressed: () {
                                  setModalState(() {
                                    _blurSigma = 20.0;
                                    _refractionBorder = 5.0;
                                    _saturationBoost = 1.1;
                                    _centerScale = 0.9;
                                    _brightnessCompensation = -0.1;
                                    _borderRadius = 30.0;
                                  });
                                  setState(() {});
                                },
                                child: const Text('重置为默认值'),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 构建滑动条设置项
  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // 显示当前值
                Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 滑动条
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.blue,
                inactiveTrackColor: Colors.grey[300],
                thumbColor: Colors.blue,
                overlayColor: Colors.blue.withValues(alpha: 0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IOS26-玻璃效果'),
        actions: [
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsBottomSheet(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. 添加一个可滚动的图片列表作为背景
          ListView.builder(
            itemCount: _GlassScreenState.imagePaths.length, // 创建图片列表项用于演示
            itemBuilder: (context, index) {
              // 2. 从预设的远端图片列表中循环选择图片
              final imagePath = _GlassScreenState.imagePaths[index % _GlassScreenState.imagePaths.length];

              // 3. 每个列表项都是一个填满空间的图片
              return SizedBox(
                height: 300, // 固定每个列表项的高度
                width: double.infinity,
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover, // 图片铺满整个SizedBox
                ),
              );
            },
          ),
          // 4. 将原有的玻璃效果组件放在列表之上, 并居中显示
          Center(
            child: SuperellipseGlassPage(
              rotationAngle: 1.1,
              blurSigma: _blurSigma,
              refractionBorder: _refractionBorder,
              saturationBoost: _saturationBoost,
              centerScale: _centerScale,
              brightnessCompensation: _brightnessCompensation,
              borderRadius: _borderRadius,
            ), // 显示超椭圆玻璃效果
          ),
        ],
      ),
    );
  }
}

/// 超椭圆玻璃效果演示页面
/// 展示使用RoundedSuperellipseBorder形状的玻璃效果
/// 这种形状介于矩形和椭圆之间，提供更加现代的视觉效果
class SuperellipseGlassPage extends StatelessWidget {
  /// 旋转角度参数（虽然在此页面中未使用，但保持接口一致性）
  final double rotationAngle;
  final double blurSigma;
  final double refractionBorder;
  final double saturationBoost;
  final double centerScale;
  final double brightnessCompensation;
  final double borderRadius;

  const SuperellipseGlassPage({
    super.key,
    required this.rotationAngle,
    required this.blurSigma,
    required this.refractionBorder,
    required this.saturationBoost,
    required this.centerScale,
    required this.brightnessCompensation,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Glass(
            key: const Key('liquido-glass-superellipse'), // 用于测试和调试的唯一标识
            blurSigma: blurSigma, // 动态模糊效果
            refractionBorder: refractionBorder, // 动态折射边界
            saturationBoost: saturationBoost, // 动态饱和度增强
            centerScale: centerScale, // 动态中心区域缩放
            brightnessCompensation: brightnessCompensation, // 动态亮度补偿
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(borderRadius), // 动态圆角半径
              ),
            ),
            child: const SizedBox(
              width: 150, // 固定宽度
              height: 150, // 固定高度，创建横向矩形
            ),
          );
        },
      ),
    );
  }
}
