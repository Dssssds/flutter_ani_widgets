// Copyright (c) 2025, Renan Araujo
// Use of this source code is governed by a MPL-2.0 license that can be
// found in the LICENSE file.

// 玻璃效果渲染对象实现
// 这个文件包含了Liquido玻璃效果的核心渲染逻辑，包括：
// - 自定义RenderObjectWidget
// - 自定义RenderBox
// - 自定义Layer
// - GPU Shader集成
// - 多重遮罩系统
// - 性能优化机制

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';   // Flutter渲染系统
import 'package:flutter/widgets.dart';     // Flutter Widget系统
import 'package:flutter_shaders/flutter_shaders.dart'; // Shader集成
import 'package:flutter_x_widgets/app_demo/06/widgets/glass.dart';   // Glass Widget定义
import 'package:flutter_x_widgets/app_demo/06/widgets/glass_options.dart'; // 参数配置系统

/// 玻璃效果的自定义渲染对象Widget
///
/// 这是[Glass]用来实现玻璃效果的核心渲染Widget。它继承自
/// [MultiChildRenderObjectWidget]，管理两个子Widget：遮罩和内容。
///
/// 主要职责：
/// - 管理Fragment Shader的生命周期
/// - 处理设备像素比例适配
/// - 传递玻璃效果参数到渲染层
/// - 协调遮罩和内容的渲染
///
/// 注意：大多数开发者不需要直接使用这个类，应该使用[Glass]的
/// 工厂构造函数。这个类主要用于内部实现。
class GlassRenderObjectWidget extends MultiChildRenderObjectWidget {
  /// 创建玻璃效果渲染对象Widget
  ///
  /// 参数说明：
  /// - [shader] 编译后的Fragment Shader实例
  /// - [mask] 遮罩Widget，定义玻璃效果的形状
  /// - [child] 内容Widget，通过玻璃显示的内容
  /// - [options] 玻璃效果参数配置
  /// - [pixelRatio] 设备像素比例，默认为1.0
  GlassRenderObjectWidget({
    required this.shader,                  // Fragment Shader实例
    required Widget mask,                  // 遮罩Widget
    required Widget child,                 // 内容Widget
    required this.options,                 // 玻璃效果参数
    super.key,
    this.pixelRatio = 1.0,                // 设备像素比例
  }) : super(children: [mask, child]);     // 传递两个子Widget

  /// 编译后的Fragment Shader实例
  /// 用于在GPU上执行玻璃效果的视觉算法
  final ui.FragmentShader shader;

  /// 设备像素比例
  /// 用于确保在不同密度的屏幕上正确渲染
  final double pixelRatio;

  /// 玻璃效果参数配置
  /// 包含所有视觉效果的参数设置
  final GlassOptions options;

  @override
  RenderObject createRenderObject(BuildContext context) {
    // 创建自定义的RenderGlass实例
    // 将所有参数传递给渲染对象
    return RenderGlass(
      shader: shader,                      // Fragment Shader
      pixelRatio: pixelRatio,              // 设备像素比例
      blurSigma: options.blurSigma,        // 模糊强度
      contrastBoost: options.contrastBoost, // 对比度增强
      saturationBoost: options.saturationBoost, // 饱和度增强
      grainIntensity: options.grainIntensity, // 噪声强度
      brightnessCompensation: options.brightnessCompensation, // 亮度补偿
      edgeScale: options.edgeScale,        // 边缘缩放
      centerScale: options.centerScale,    // 中心缩放
      glassTint: options.glassTint,        // 玻璃着色
      refractionBorder: options.refractionBorder, // 折射边界
      boxShadow: options.boxShadow,        // 阴影效果
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderGlass renderObject) {
    // 当参数发生变化时，更新渲染对象的属性
    // 使用级联操作符进行批量更新
    renderObject
      ..shader = shader                    // 更新Shader
      ..pixelRatio = pixelRatio            // 更新像素比例
      ..blurSigma = options.blurSigma      // 更新模糊强度
      ..contrastBoost = options.contrastBoost // 更新对比度
      ..saturationBoost = options.saturationBoost // 更新饱和度
      ..grainIntensity = options.grainIntensity // 更新噪声强度
      ..brightnessCompensation = options.brightnessCompensation // 更新亮度补偿
      ..edgeScale = options.edgeScale      // 更新边缘缩放
      ..centerScale = options.centerScale  // 更新中心缩放
      ..glassTint = options.glassTint      // 更新玻璃着色
      ..refractionBorder = options.refractionBorder // 更新折射边界
      ..boxShadow = options.boxShadow;     // 更新阴影效果
  }
}

/// 玻璃效果渲染对象的父数据类
///
/// 继承自[ContainerBoxParentData]，用于存储子RenderBox的布局信息。
/// 这个类目前没有添加额外的属性，使用默认的容器父数据功能。
class GlassRenderObjectParentData extends ContainerBoxParentData<RenderBox> {}

/// 玻璃效果的自定义渲染对象
///
/// 这是整个玻璃效果系统的核心渲染类，负责：
/// - 管理两个子RenderBox：遮罩和内容
/// - 处理布局计算和约束传递
/// - 执行自定义绘制逻辑
/// - 管理合成层和性能优化
/// - 处理用户交互和命中测试
///
/// 设计特点：
/// - 继承自RenderBox，实现自定义渲染
/// - 使用Mixin添加容器功能
/// - 强制启用合成层以利用GPU加速
/// - 设置重绘边界以优化性能
/// - 智能属性更新机制
class RenderGlass extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, GlassRenderObjectParentData>,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          GlassRenderObjectParentData
        > {
  /// 创建玻璃效果渲染对象
  ///
  /// 所有参数都是必需的，确保渲染对象有完整的配置信息。
  /// 参数会被存储为私有字段，通过getter/setter进行访问和更新。
  RenderGlass({
    required ui.FragmentShader shader,    // Fragment Shader实例
    required double pixelRatio,           // 设备像素比例
    required double blurSigma,            // 模糊强度
    required double contrastBoost,        // 对比度增强
    required double saturationBoost,      // 饱和度增强
    required double grainIntensity,       // 噪声强度
    required double brightnessCompensation, // 亮度补偿
    required double edgeScale,            // 边缘缩放
    required double centerScale,          // 中心缩放
    required Color? glassTint,            // 玻璃着色
    required double refractionBorder,     // 折射边界
    required BoxShadow? boxShadow,        // 阴影效果
  }) : _shader = shader,
       _pixelRatio = pixelRatio,
       _blurSigma = blurSigma,
       _contrastBoost = contrastBoost,
       _saturationBoost = saturationBoost,
       _grainIntensity = grainIntensity,
       _brightnessCompensation = brightnessCompensation,
       _edgeScale = edgeScale,
       _centerScale = centerScale,
       _glassTint = glassTint,
       _refractionBorder = refractionBorder,
       _boxShadow = boxShadow;

  // ==================== 属性访问器 ====================
  // 以下是所有玻璃效果参数的getter/setter实现
  // 每个setter都包含智能更新逻辑：只在值真正改变时才触发重绘
  // 这种设计避免了不必要的性能开销

  /// Fragment Shader实例
  /// 用于在GPU上执行玻璃效果算法
  ui.FragmentShader get shader => _shader;
  ui.FragmentShader _shader;
  set shader(ui.FragmentShader value) {
    if (_shader == value) return;           // 避免不必要的更新
    _shader = value;
    markNeedsPaint();                       // 标记需要重绘
  }

  /// 设备像素比例
  /// 确保在不同密度屏幕上的正确渲染
  double get pixelRatio => _pixelRatio;
  double _pixelRatio;
  set pixelRatio(double value) {
    if (_pixelRatio == value) return;
    _pixelRatio = value;
    markNeedsPaint();
  }

  /// 模糊强度参数
  /// 控制背景内容的模糊程度
  double get blurSigma => _blurSigma;
  double _blurSigma;
  set blurSigma(double value) {
    if (_blurSigma == value) return;
    _blurSigma = value;
    markNeedsPaint();
  }

  double get contrastBoost => _contrastBoost;
  double _contrastBoost;
  set contrastBoost(double value) {
    if (_contrastBoost == value) return;
    _contrastBoost = value;
    markNeedsPaint();
  }

  double get saturationBoost => _saturationBoost;
  double _saturationBoost;
  set saturationBoost(double value) {
    if (_saturationBoost == value) return;
    _saturationBoost = value;
    markNeedsPaint();
  }

  double get grainIntensity => _grainIntensity;
  double _grainIntensity;
  set grainIntensity(double value) {
    if (_grainIntensity == value) return;
    _grainIntensity = value;
    markNeedsPaint();
  }

  double get brightnessCompensation => _brightnessCompensation;
  double _brightnessCompensation;
  set brightnessCompensation(double value) {
    if (_brightnessCompensation == value) return;
    _brightnessCompensation = value;
    markNeedsPaint();
  }

  double get edgeScale => _edgeScale;
  double _edgeScale;
  set edgeScale(double value) {
    if (_edgeScale == value) return;
    _edgeScale = value;
    markNeedsPaint();
  }

  double get centerScale => _centerScale;
  double _centerScale;
  set centerScale(double value) {
    if (_centerScale == value) return;
    _centerScale = value;
    markNeedsPaint();
  }

  Color? get glassTint => _glassTint;
  Color? _glassTint;
  set glassTint(Color? value) {
    if (_glassTint == value) return;
    _glassTint = value;
    markNeedsPaint();
  }

  double get refractionBorder => _refractionBorder;
  double _refractionBorder;
  set refractionBorder(double value) {
    if (_refractionBorder == value) return;
    _refractionBorder = value;
    markNeedsPaint();
  }

  BoxShadow? get boxShadow => _boxShadow;
  BoxShadow? _boxShadow;
  set boxShadow(BoxShadow? value) {
    if (_boxShadow == value) return;
    _boxShadow = value;
    markNeedsPaint();
  }

  @override
  void setupParentData(RenderBox child) {
    // 为子RenderBox设置正确的父数据类型
    // 确保每个子对象都有GlassRenderObjectParentData实例
    if (child.parentData is! GlassRenderObjectParentData) {
      child.parentData = GlassRenderObjectParentData();
    }
  }

  /// 获取遮罩RenderBox（第一个子对象）
  /// 遮罩定义了玻璃效果的形状和区域
  RenderBox? get mask => firstChild;

  /// 获取实际内容RenderBox（第二个子对象）
  /// 这是通过玻璃显示的实际内容
  RenderBox? get actualChild => lastChild;

  /// 强制启用合成层
  ///
  /// 返回true确保这个RenderBox总是在独立的合成层上渲染，
  /// 这样可以利用GPU加速，提高玻璃效果的性能。
  @override
  bool get alwaysNeedsCompositing => true;

  /// 设置重绘边界
  ///
  /// 返回true将此RenderBox标记为重绘边界，这意味着：
  /// - 当此对象需要重绘时，不会影响父对象
  /// - 可以独立进行重绘优化
  /// - 减少不必要的重绘范围
  @override
  bool get isRepaintBoundary => true;

  @override
  void performLayout() {
    // 处理无子对象的情况
    if (childCount == 0) {
      size = constraints.biggest;           // 使用最大可用尺寸
      return;
    }

    final maskBox = mask;                   // 遮罩RenderBox
    final childBox = actualChild;           // 内容RenderBox

    // 首先布局内容子对象，它决定了整体尺寸
    if (childBox != null) {
      // 传递约束给子对象，并使用其尺寸
      childBox.layout(constraints, parentUsesSize: true);
      size = childBox.size;                 // 使用子对象的尺寸作为自身尺寸
      // 将子对象定位在原点
      (childBox.parentData! as GlassRenderObjectParentData).offset = Offset.zero;
    } else {
      // 如果没有内容子对象，使用最小尺寸
      size = constraints.smallest;
    }

    // 然后布局遮罩，强制其与内容尺寸一致
    if (maskBox != null) {
      // 遮罩必须与内容尺寸完全一致
      maskBox.layout(BoxConstraints.tight(size));
      // 将遮罩定位在原点，与内容重叠
      (maskBox.parentData! as GlassRenderObjectParentData).offset = Offset.zero;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // 处理用户交互的命中测试
    // 只有实际内容子对象参与命中测试，遮罩不参与
    final childBox = actualChild;

    if (childBox != null) {
      // 获取子对象的父数据，包含位置偏移信息
      final childParentData =
          childBox.parentData! as GlassRenderObjectParentData;

      // 使用Flutter的标准命中测试机制
      return result.addWithPaintOffset(
        offset: childParentData.offset,     // 子对象的偏移
        position: position,                 // 测试位置
        hitTest: (BoxHitTestResult result, Offset transformed) {
          // 调试断言：确保位置变换正确
          assert(
            transformed == position - childParentData.offset,
            'Hit test position does not match expected offset: '
            '$transformed != ${position - childParentData.offset}',
          );
          // 将命中测试传递给实际的子对象
          return childBox.hitTest(result, position: transformed);
        },
      );
    }

    // 如果没有子对象，返回false（不处理命中测试）
    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (childCount == 0 || size.isEmpty) return;
    assert(offset == Offset.zero, 'RenderGlass should not be offset');
    context
      // Add mask to the composited layer tree, it will be the first child
      ..pushLayer(
        ContainerLayer(),
        (PaintingContext context, Offset offset) {
          if (size.isEmpty) return;

          final maskBox = mask;
          if (maskBox != null) {
            final childParentData =
                maskBox.parentData! as GlassRenderObjectParentData;
            context.paintChild(maskBox, offset + childParentData.offset);
          }
        },
        offset,
      )
      // Add the actual child to the composited layer tree, it will be the
      // second child
      ..pushLayer(
        ContainerLayer(),
        (PaintingContext context, Offset offset) {
          if (size.isEmpty) return;

          final childBox = actualChild;
          if (childBox != null) {
            final childParentData =
                childBox.parentData! as GlassRenderObjectParentData;
            context.paintChild(childBox, offset + childParentData.offset);

            final shadow = _boxShadow;
            if (shadow != null) {
              context.canvas.saveLayer(
                null,
                Paint()..blendMode = BlendMode.dstIn,
              );
              context.paintChild(mask!, offset + childParentData.offset);
              context.canvas.restore();

              context.canvas.saveLayer(null, Paint());

              context.canvas.saveLayer(
                null,
                Paint()
                  ..imageFilter = ui.ImageFilter.blur(
                    sigmaX: shadow.blurRadius,
                    sigmaY: shadow.blurRadius,
                  ),
              );

              context.canvas.translate(shadow.offset.dx, shadow.offset.dy);
              context.paintChild(mask!, offset + childParentData.offset);

              context.canvas.saveLayer(
                null,
                Paint()..blendMode = BlendMode.srcIn,
              );
              context.canvas.drawRect(
                Rect.fromLTWH(
                  offset.dx + childParentData.offset.dx,
                  offset.dy + childParentData.offset.dy,
                  size.width,
                  size.height,
                ),
                Paint()..color = shadow.color,
              );
              context.canvas.restore();
              context.canvas.restore();

              context.canvas.saveLayer(
                null,
                Paint()..blendMode = BlendMode.dstOut,
              );
              context.paintChild(mask!, offset + childParentData.offset);
              context.canvas.restore();
            }
          }
        },
        offset,
      );
  }

  @override
  OffsetLayer updateCompositedLayer({OffsetLayer? oldLayer}) {
    _GlassFilterLayer layer;

    if (oldLayer is _GlassFilterLayer) {
      layer = oldLayer
        ..shader = _shader
        ..pixelRatio = _pixelRatio
        ..size = size
        ..blurSigma = _blurSigma
        ..contrastBoost = _contrastBoost
        ..saturationBoost = _saturationBoost
        ..grainIntensity = _grainIntensity
        ..brightnessCompensation = _brightnessCompensation
        ..edgeScale = _edgeScale
        ..centerScale = _centerScale
        ..glassTint = _glassTint
        ..refractionBorder = _refractionBorder;
    } else {
      layer = _GlassFilterLayer(
        shader: _shader,
        pixelRatio: _pixelRatio,
        size: size,
        blurSigma: _blurSigma,
        contrastBoost: _contrastBoost,
        saturationBoost: _saturationBoost,
        grainIntensity: _grainIntensity,
        brightnessCompensation: _brightnessCompensation,
        edgeScale: _edgeScale,
        centerScale: _centerScale,
        glassTint: _glassTint,
        refractionBorder: _refractionBorder,
      );
    }

    return layer;
  }

  @override
  void dispose() {
    // 清理资源，释放Shader
    _shader.dispose();                      // 释放Fragment Shader资源
    super.dispose();
  }
}

/// 玻璃效果的自定义合成层
///
/// 这是整个玻璃效果系统最核心的类，负责：
/// - 管理Fragment Shader的执行
/// - 构建和缓存多重遮罩图像
/// - 处理GPU渲染管线
/// - 优化性能和内存使用
/// - 实现复杂的视觉算法
///
/// 技术特点：
/// - 继承自OffsetLayer，集成到Flutter的合成系统
/// - 使用BackdropFilter实现背景滤镜效果
/// - 三重遮罩系统：原始、模糊、二级模糊
/// - 智能图像缓存和内存管理
/// - 实时参数传递到GPU Shader
///
/// 渲染流程：
/// 1. 设置Shader参数
/// 2. 构建三种遮罩图像
/// 3. 绑定遮罩到Shader采样器
/// 4. 应用BackdropFilter
/// 5. 渲染子内容
class _GlassFilterLayer extends OffsetLayer {
  /// 创建玻璃滤镜层
  ///
  /// 初始化所有必需的参数，这些参数将用于GPU Shader计算。
  /// 所有参数都存储为私有字段，通过setter进行更新。
  _GlassFilterLayer({
    required ui.FragmentShader shader,    // Fragment Shader实例
    required double pixelRatio,           // 设备像素比例
    required Size size,                   // 渲染尺寸
    required double blurSigma,            // 模糊强度
    required double contrastBoost,        // 对比度增强
    required double saturationBoost,      // 饱和度增强
    required double grainIntensity,       // 噪声强度
    required double brightnessCompensation, // 亮度补偿
    required double edgeScale,            // 边缘缩放
    required double centerScale,          // 中心缩放
    required Color? glassTint,            // 玻璃着色
    required double refractionBorder,     // 折射边界
  }) : _shader = shader,
       _pixelRatio = pixelRatio,
       _size = size,
       _blurSigma = blurSigma,
       _contrastBoost = contrastBoost,
       _saturationBoost = saturationBoost,
       _grainIntensity = grainIntensity,
       _brightnessCompensation = brightnessCompensation,
       _edgeScale = edgeScale,
       _centerScale = centerScale,
       _glassTint = glassTint,
       _refractionBorder = refractionBorder,
       super();

  ui.FragmentShader _shader;
  set shader(ui.FragmentShader value) {
    if (_shader == value) return;
    _shader = value;
    _clearLastImages();
    markNeedsAddToScene();
  }

  double _pixelRatio;
  set pixelRatio(double value) {
    if (_pixelRatio == value) return;
    _pixelRatio = value;
    _clearLastImages();
    markNeedsAddToScene();
  }

  Size _size;
  set size(Size value) {
    if (value == _size) return;
    _size = value;
    _clearLastImages();
    markNeedsAddToScene();
  }

  double _blurSigma;
  set blurSigma(double value) {
    if (_blurSigma == value) return;
    _blurSigma = value;
    markNeedsAddToScene();
  }

  double _contrastBoost;
  set contrastBoost(double value) {
    if (_contrastBoost == value) return;
    _contrastBoost = value;
    markNeedsAddToScene();
  }

  double _saturationBoost;
  set saturationBoost(double value) {
    if (_saturationBoost == value) return;
    _saturationBoost = value;
    markNeedsAddToScene();
  }

  double _grainIntensity;
  set grainIntensity(double value) {
    if (_grainIntensity == value) return;
    _grainIntensity = value;
    markNeedsAddToScene();
  }

  double _brightnessCompensation;
  set brightnessCompensation(double value) {
    if (_brightnessCompensation == value) return;
    _brightnessCompensation = value;
    markNeedsAddToScene();
  }

  double _edgeScale;
  set edgeScale(double value) {
    if (_edgeScale == value) return;
    _edgeScale = value;
    markNeedsAddToScene();
  }

  double _centerScale;
  set centerScale(double value) {
    if (_centerScale == value) return;
    _centerScale = value;
    markNeedsAddToScene();
  }

  Color? _glassTint;
  set glassTint(Color? value) {
    if (_glassTint == value) return;
    _glassTint = value;
    markNeedsAddToScene();
  }

  double _refractionBorder;
  set refractionBorder(double value) {
    if (_refractionBorder == value) return;
    _refractionBorder = value;
    markNeedsAddToScene();
  }

  // ==================== 渲染层和图像缓存 ====================

  /// 背景滤镜引擎层，用于应用玻璃效果
  ui.BackdropFilterEngineLayer? _backdropFilterLayer;

  /// 图像滤镜引擎层，用于处理图像效果
  ui.ImageFilterEngineLayer? _imageFilterLayer;

  /// 缓存的遮罩图像（原始）
  ui.Image? _lastMaskImage;

  /// 缓存的模糊遮罩图像（用于折射边界）
  ui.Image? _lastBlurredMaskImage;

  /// 缓存的二级模糊遮罩图像（用于增强效果）
  ui.Image? _lastSecondaryBlurredMaskImage;

  /// 清理缓存的图像资源
  ///
  /// 这个方法在参数变化时被调用，确保：
  /// - 及时释放GPU内存
  /// - 避免内存泄漏
  /// - 强制重新生成遮罩图像
  void _clearLastImages() {
    _lastMaskImage?.dispose();              // 释放原始遮罩
    _lastMaskImage = null;

    _lastBlurredMaskImage?.dispose();       // 释放模糊遮罩
    _lastBlurredMaskImage = null;

    _lastSecondaryBlurredMaskImage?.dispose(); // 释放二级模糊遮罩
    _lastSecondaryBlurredMaskImage = null;
  }

  @override
  void addToScene(ui.SceneBuilder builder) {
    // 1. 创建偏移层，处理位置变换
    final offsetLayer = builder.pushOffset(
      offset.dx,                            // X轴偏移
      offset.dy,                            // Y轴偏移
      oldLayer: engineLayer as ui.OffsetEngineLayer?, // 复用旧层优化性能
    );
    engineLayer = offsetLayer;

    {
      // 2. 设置Fragment Shader的uniform参数
      _shader.setFloatUniforms(initialIndex: 2, (uniforms) {
        // 计算渲染矩形区域
        final rect = Rect.fromLTWH(
          offset.dx,                        // 左边界
          offset.dy,                        // 上边界
          _size.width,                      // 宽度
          _size.height,                     // 高度
        );

        // 传递所有参数到GPU Shader
        uniforms
          ..setFloat(rect.left * _pixelRatio)    // 左边界（像素坐标）
          ..setFloat(rect.top * _pixelRatio)     // 上边界（像素坐标）
          ..setFloat(rect.width * _pixelRatio)   // 宽度（像素坐标）
          ..setFloat(rect.height * _pixelRatio)  // 高度（像素坐标）
          ..setFloat(_blurSigma)                 // 模糊强度
          ..setFloat(_contrastBoost)             // 对比度增强
          ..setFloat(_saturationBoost)           // 饱和度增强
          ..setFloat(_grainIntensity)            // 噪声强度
          ..setFloat(_brightnessCompensation)    // 亮度补偿
          ..setFloat(_edgeScale)                 // 边缘缩放
          ..setFloat(_centerScale)               // 中心缩放
          ..setColor(_glassTint ?? const ui.Color(0x00000000)); // 玻璃着色
      });

      // 3. 构建三重遮罩系统

      // 原始遮罩：定义玻璃的基本形状
      final mask = _buildMaskImage();
      _lastMaskImage?.dispose();            // 释放旧的图像资源
      _lastMaskImage = mask;

      // 模糊遮罩：用于折射边界效果
      final blurMask = _buildMaskImage(_refractionBorder);
      _lastBlurredMaskImage?.dispose();
      _lastBlurredMaskImage = blurMask;

      // 二级模糊遮罩：用于增强边缘效果
      final secondaryBlurMask = _buildMaskImage(5);
      _lastSecondaryBlurredMaskImage?.dispose();
      _lastSecondaryBlurredMaskImage = secondaryBlurMask;

      // 4. 将遮罩绑定到Shader采样器
      _shader
        ..setImageSampler(1, mask)          // 采样器1：原始遮罩
        ..setImageSampler(2, blurMask)      // 采样器2：模糊遮罩
        ..setImageSampler(3, secondaryBlurMask); // 采样器3：二级模糊遮罩

      // 5. 应用背景滤镜，这是玻璃效果的核心
      _backdropFilterLayer = builder.pushBackdropFilter(
        ui.ImageFilter.shader(_shader),     // 使用自定义Shader作为滤镜
        oldLayer: _backdropFilterLayer,     // 复用旧层优化性能
      );
      {
        // 6. 渲染实际的子内容
        addActualChildToScene(builder);
      }
      builder.pop();                        // 弹出背景滤镜层
    }
    builder.pop();                          // 弹出偏移层
  }

  /// 构建遮罩图像
  ///
  /// 这个方法创建用于Shader的遮罩图像。根据refractionBorder参数，
  /// 可以生成不同模糊程度的遮罩：
  /// - null: 原始清晰遮罩
  /// - 数值: 应用指定模糊半径的遮罩
  ///
  /// 参数：
  /// - [refractionBorder] 可选的模糊半径，用于创建折射边界效果
  ///
  /// 返回：
  /// 生成的遮罩图像，用于Shader采样
  ui.Image _buildMaskImage([double? refractionBorder]) {
    final builder = ui.SceneBuilder();      // 创建场景构建器
    // 创建像素比例变换矩阵
    final transform = Matrix4.diagonal3Values(_pixelRatio, _pixelRatio, 1);
    final bounds = offset & _size;          // 计算边界矩形

    // 应用变换并添加遮罩到场景
    builder.pushTransform(transform.storage);
    addMaskToScene(builder, refractionBorder);
    builder.pop();

    // 构建场景并转换为图像
    return builder.build().toImageSync(
      (_pixelRatio * bounds.width).floor(),  // 图像宽度（像素）
      (_pixelRatio * bounds.height).floor(), // 图像高度（像素）
    );
  }

  /// 将遮罩添加到场景中
  ///
  /// 这个方法负责渲染遮罩Widget到场景构建器中。
  /// 如果指定了refractionBorder，会应用模糊滤镜。
  ///
  /// 参数：
  /// - [builder] 场景构建器
  /// - [refractionBorder] 可选的模糊半径，用于创建折射边界效果
  void addMaskToScene(ui.SceneBuilder builder, [double? refractionBorder]) {
    final mask = firstChild;               // 获取遮罩子对象

    // 如果需要折射边界效果，应用模糊滤镜
    if (refractionBorder != null) {
      _imageFilterLayer = builder.pushImageFilter(
        ui.ImageFilter.blur(
          sigmaX: refractionBorder,         // X轴模糊半径
          sigmaY: refractionBorder          // Y轴模糊半径
        ),
        oldLayer: _imageFilterLayer,        // 复用旧层优化性能
      );
    }

    // 将遮罩添加到场景中
    mask?.addToScene(builder);

    // 如果应用了模糊滤镜，需要弹出滤镜层
    if (refractionBorder != null) {
      builder.pop();
    }
  }

  /// 将实际子内容添加到场景中
  ///
  /// 这个方法渲染实际的内容Widget（第二个子对象）。
  /// 内容会通过玻璃效果显示。
  void addActualChildToScene(ui.SceneBuilder builder) {
    firstChild?.nextSibling?.addToScene(builder); // 渲染第二个子对象
  }

  @override
  void detach() {
    // 当层从渲染树中分离时，清理图像资源
    _clearLastImages();
    super.detach();
  }

  @override
  void dispose() {
    // 释放所有资源
    _clearLastImages();                     // 清理缓存的图像
    _backdropFilterLayer = null;            // 清理背景滤镜层引用
    _imageFilterLayer = null;               // 清理图像滤镜层引用
    super.dispose();
  }
}
