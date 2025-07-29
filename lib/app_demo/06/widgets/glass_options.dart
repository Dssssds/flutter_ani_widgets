// Copyright (c) 2025, Renan Araujo
// Use of this source code is governed by a MPL-2.0 license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:equatable/equatable.dart'; // 用于值比较和相等性判断
import 'package:flutter/rendering.dart';   // 提供BoxShadow等渲染相关类

/// 玻璃效果参数的通用接口
///
/// 这个接口定义了所有可用于自定义玻璃效果的属性参数，包括：
/// - 视觉效果参数：模糊、对比度、饱和度、噪声强度等
/// - 几何变换参数：中心缩放、边缘缩放、折射边界等
/// - 装饰效果参数：玻璃着色、阴影效果等
///
/// 设计特点：
/// - 使用可选类型（nullable），支持部分配置
/// - 提供推荐的参数取值范围
/// - 支持动画插值（通过lerp方法）
/// - 类型安全的参数传递
///
/// 常用参数：
/// {@template glass_options}
/// 最常需要调整的参数包括：
/// [blurSigma]（模糊强度）、[refractionBorder]（折射边界）、
/// [brightnessCompensation]（亮度补偿）、[glassTint]（玻璃着色）
/// 和 [boxShadow]（阴影效果）。
/// {@endtemplate}
///
/// 参考文档：
/// - [GlassOptions.defaultOptions] 默认参数值配置
/// - [GlassOptions] 具体实现类，支持插值动画
abstract interface class GlassOptionsInterface {
  /// 玻璃效果的模糊强度
  ///
  /// 控制背景内容的模糊程度，是玻璃效果最重要的参数之一。
  /// - 推荐值范围：0-40
  /// - 0 表示无模糊（清晰透明）
  /// - 值越大模糊越强，但过高可能产生视觉瑕疵
  /// - 典型值：10-25 适合大多数场景
  ///
  /// 参考默认值：[GlassOptions.defaultOptions]
  double? get blurSigma;

  /// 玻璃效果的对比度增强
  ///
  /// 增强通过玻璃看到的内容的对比度，让效果更加鲜明。
  /// - 推荐值范围：1.0-1.3
  /// - 1.0 表示无对比度增强（原始对比度）
  /// - 值越大对比度越强，但过高可能产生过曝效果
  /// - 典型值：1.0-1.1 提供微妙的增强
  ///
  /// 参考默认值：[GlassOptions.defaultOptions]
  double? get contrastBoost;

  /// 玻璃效果的饱和度增强
  ///
  /// 增强通过玻璃看到的内容的颜色饱和度，让色彩更加鲜艳。
  /// - 推荐值范围：1.0-1.3
  /// - 1.0 表示无饱和度增强（原始饱和度）
  /// - 值越大颜色越鲜艳，但过高可能产生不自然的效果
  /// - 典型值：1.0-1.1 提供微妙的色彩增强
  ///
  /// 参考默认值：[GlassOptions.defaultOptions]
  double? get saturationBoost;

  /// 玻璃效果的噪声强度
  ///
  /// 添加程序化噪声来模拟真实玻璃的纹理质感。
  /// - 推荐值范围：0-1
  /// - 0 表示无噪声（完全光滑）
  /// - 值越大噪声越明显，增加玻璃的真实感
  /// - 典型值：0.1-0.3 提供微妙的纹理
  ///
  /// 参考默认值：[GlassOptions.defaultOptions]
  double? get grainIntensity;

  /// 玻璃效果的亮度补偿
  ///
  /// 调整通过玻璃看到的内容的整体亮度。
  /// - 推荐值范围：-1.0 到 1.0
  /// - 0 表示无亮度调整（原始亮度）
  /// - 负值使玻璃变暗（深色玻璃效果）
  /// - 正值使玻璃变亮（浅色玻璃效果）
  /// - 极值可能产生过暗或过亮的瑕疵
  ///
  /// 参考默认值：[GlassOptions.defaultOptions]
  double? get brightnessCompensation;

  /// 玻璃效果中心区域的缩放系数
  ///
  /// 控制玻璃中心区域的放大或缩小效果，模拟玻璃的光学特性。
  /// - 推荐值范围：0.1-1.5
  /// - 1.0 表示无缩放（原始大小）
  /// - 小于1.0 缩小中心区域（凹透镜效果）
  /// - 大于1.0 放大中心区域（凸透镜效果）
  /// - 典型值：0.8-1.2 提供微妙的光学效果
  ///
  /// 参考默认值：[GlassOptions.defaultOptions]
  double? get centerScale;

  /// 玻璃效果边缘区域的缩放系数
  ///
  /// 控制玻璃边缘区域的放大或缩小效果，与centerScale配合使用。
  /// - 推荐值范围：0.1-1.5
  /// - 1.0 表示无缩放（原始大小）
  /// - 小于1.0 缩小边缘区域
  /// - 大于1.0 放大边缘区域
  /// - 与centerScale的差值决定了玻璃的曲率效果
  ///
  /// 参考默认值：[GlassOptions.defaultOptions]
  double? get edgeScale;

  /// 玻璃效果的颜色着色
  ///
  /// 为玻璃添加颜色滤镜，模拟有色玻璃的效果。
  /// - 推荐使用带透明度的颜色
  /// - alpha值控制着色强度：0表示无着色，1表示完全着色
  /// - 可以使用任何颜色，常见的有蓝色、绿色等
  /// - null 表示无颜色着色（透明玻璃）
  ///
  /// 使用示例：Colors.blue.withOpacity(0.1)
  /// 参考默认值：[GlassOptions.defaultOptions]
  Color? get glassTint;

  /// 玻璃效果边缘的折射边界宽度（像素）
  ///
  /// 控制玻璃边缘的光线折射效果宽度，增强玻璃的真实感。
  /// - 推荐值：不要超过玻璃表面尺寸（宽度或高度）的一半
  /// - 0 表示无折射边界（平滑边缘）
  /// - 值越大折射效果越明显，但过大可能产生瑕疵
  /// - 典型值：2-10 像素，根据玻璃大小调整
  ///
  /// 参考默认值：[GlassOptions.defaultOptions]
  double? get refractionBorder;

  /// 玻璃效果周围的阴影
  ///
  /// 为玻璃添加投影效果，增强立体感和层次感。
  /// - null 表示无阴影
  /// - 使用BoxShadow定义阴影的颜色、模糊半径、偏移等
  /// - 可以创建多层阴影效果
  /// - 建议使用半透明的黑色或灰色
  ///
  /// 使用示例：BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
  /// 参考默认值：[GlassOptions.defaultOptions]
  BoxShadow? get boxShadow;
}

/// 玻璃效果参数的具体实现类
///
/// 这是[GlassOptionsInterface]的完整实现，提供了：
/// - 所有玻璃效果参数的默认值
/// - 完整的插值动画支持（lerp功能）
/// - 值相等性比较（通过EquatableMixin）
/// - 类型安全的参数管理
///
/// 主要特性：
/// - 不可变对象设计，确保线程安全
/// - 支持动画过渡效果
/// - 提供工厂方法从接口创建实例
/// - 完整的参数验证和默认值处理
///
/// 参考文档：
/// - [GlassOptionsInterface] 参数接口详细说明
/// - [GlassOptions.defaultOptions] 推荐的默认参数配置
class GlassOptions with EquatableMixin implements GlassOptionsInterface {
  /// 创建新的玻璃效果参数实例
  ///
  /// 所有参数都是必需的，以确保玻璃效果的完整配置。
  /// 如需默认值，请参考 [GlassOptions.defaultOptions]。
  ///
  /// 使用示例：
  /// ```dart
  /// final customGlass = GlassOptions(
  ///   blurSigma: 15.0,                    // 模糊强度
  ///   contrastBoost: 1.1,                 // 对比度增强
  ///   saturationBoost: 1.1,               // 饱和度增强
  ///   grainIntensity: 0.2,                // 噪声强度
  ///   brightnessCompensation: 0.5,        // 亮度补偿
  ///   centerScale: 1.0,                   // 中心缩放
  ///   edgeScale: 1.0,                     // 边缘缩放
  ///   glassTint: Colors.blue.withOpacity(0.1), // 蓝色着色
  ///   refractionBorder: 10.0,             // 折射边界
  ///   boxShadow: BoxShadow(               // 阴影效果
  ///     color: Colors.black.withOpacity(0.2),
  ///     blurRadius: 10,
  ///     spreadRadius: 2,
  ///   ),
  /// );
  /// ```
  const GlassOptions({
    required this.blurSigma,               // 模糊强度
    required this.contrastBoost,           // 对比度增强
    required this.saturationBoost,         // 饱和度增强
    required this.grainIntensity,          // 噪声强度
    required this.brightnessCompensation,  // 亮度补偿
    required this.centerScale,             // 中心缩放
    required this.edgeScale,               // 边缘缩放
    required this.glassTint,               // 玻璃着色
    required this.refractionBorder,        // 折射边界宽度
    required this.boxShadow,               // 阴影效果
  });

  /// 从现有的[GlassOptionsInterface]创建新的[GlassOptions]实例
  ///
  /// 这个构造函数提供了一种便捷的方式，将任何[GlassOptionsInterface]的实现
  /// 转换为具体的[GlassOptions]实例。它会用[defaultOptions]中的对应值
  /// 填充任何为null的属性。
  ///
  /// 使用场景：
  /// - 确保所有属性都有非null值
  /// - 将部分配置转换为完整配置
  /// - 在渲染系统中统一参数格式
  /// - 提供默认值回退机制
  ///
  /// 使用示例：
  /// ```dart
  /// // 某个部分实现的GlassOptionsInterface
  /// final partialOptions = MyCustomGlassOptions();
  ///
  /// // 转换为完整的GlassOptions实例
  /// final completeOptions = GlassOptions.fromInterface(partialOptions);
  /// ```
  ///
  /// 转换规则：
  /// - 如果接口中的属性不为null，使用该值
  /// - 如果接口中的属性为null，使用defaultOptions中的默认值
  /// - 确保最终所有属性都有确定的值
  GlassOptions.fromInterface(
    GlassOptionsInterface options,        // 源参数接口
  ) : this(
        // 使用null-aware操作符提供默认值回退
        blurSigma: options.blurSigma ?? defaultOptions.blurSigma,
        contrastBoost: options.contrastBoost ?? defaultOptions.contrastBoost,
        saturationBoost: options.saturationBoost ?? defaultOptions.saturationBoost,
        grainIntensity: options.grainIntensity ?? defaultOptions.grainIntensity,
        brightnessCompensation: options.brightnessCompensation ??
            defaultOptions.brightnessCompensation,
        centerScale: options.centerScale ?? defaultOptions.centerScale,
        edgeScale: options.edgeScale ?? defaultOptions.edgeScale,
        glassTint: options.glassTint ?? defaultOptions.glassTint,
        refractionBorder: options.refractionBorder ?? defaultOptions.refractionBorder,
        boxShadow: options.boxShadow ?? defaultOptions.boxShadow,
      );

  /// 玻璃效果的默认参数配置
  ///
  /// 这些数值经过精心调试，适用于大多数使用场景，为自定义玻璃效果
  /// 提供了良好的起始点。
  ///
  /// 默认配置特点：
  /// - 中等强度的模糊效果（blurSigma: 10）
  /// - 无额外的视觉增强（对比度和饱和度保持原始）
  /// - 无噪声纹理（grainIntensity: 0）
  /// - 无光学变形（centerScale和edgeScale均为1）
  /// - 无颜色着色和阴影效果
  /// - 无折射边界效果
  ///
  /// 常用自定义参数：
  /// 最常需要调整的参数包括：
  /// [blurSigma]（模糊强度）、[refractionBorder]（折射边界）、
  /// [brightnessCompensation]（亮度补偿）、[glassTint]（玻璃着色）
  /// 和 [boxShadow]（阴影效果）。
  static const GlassOptions defaultOptions = GlassOptions(
    blurSigma: 10,                         // 中等模糊强度
    contrastBoost: 1,                      // 无对比度增强
    saturationBoost: 1,                    // 无饱和度增强
    grainIntensity: 0,                     // 无噪声纹理
    brightnessCompensation: 0,             // 无亮度补偿
    centerScale: 1,                        // 中心无缩放
    edgeScale: 1,                          // 边缘无缩放
    glassTint: null,                       // 无颜色着色
    refractionBorder: 0,                   // 无折射边界
    boxShadow: null,                       // 无阴影效果
  );

  // 实现GlassOptionsInterface接口的所有属性
  // 这些属性都是final的，确保对象的不可变性

  @override
  final double blurSigma;                  // 模糊强度
  @override
  final double contrastBoost;              // 对比度增强
  @override
  final double saturationBoost;            // 饱和度增强
  @override
  final double grainIntensity;             // 噪声强度
  @override
  final double brightnessCompensation;     // 亮度补偿
  @override
  final double centerScale;                // 中心缩放
  @override
  final double edgeScale;                  // 边缘缩放
  @override
  final Color? glassTint;                  // 玻璃着色
  @override
  final double refractionBorder;           // 折射边界宽度
  @override
  final BoxShadow? boxShadow;              // 阴影效果

  /// 在两个玻璃效果参数实例之间进行线性插值
  ///
  /// 这个方法是动画系统的核心，支持玻璃效果参数的平滑过渡。
  /// 所有数值参数都会进行精确的线性插值计算。
  ///
  /// 参数说明：
  /// - [a] 起始参数实例
  /// - [b] 结束参数实例
  /// - [t] 插值位置，范围0.0-1.0
  ///
  /// 插值规则：
  /// - 如果a和b都为null，返回null
  /// - 如果只有一个为null，返回非null的实例
  /// - t=0.0 返回a，t=1.0 返回b
  /// - 0.0<t<1.0 返回插值结果
  ///
  /// 使用场景：
  /// - 动画过渡效果
  /// - 状态切换的平滑变化
  /// - 交互式参数调整
  /// - 主题切换动画
  ///
  /// 使用示例：
  /// ```dart
  /// final startOptions = GlassOptions.defaultOptions;
  /// final endOptions = GlassOptions(blurSigma: 30, ...);
  /// final midOptions = GlassOptions.lerp(startOptions, endOptions, 0.5);
  /// ```
  static GlassOptionsInterface? lerp(
    GlassOptionsInterface? a,              // 起始参数
    GlassOptionsInterface? b,              // 结束参数
    double t,                              // 插值位置 (0.0-1.0)
  ) {
    // 处理null值情况
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;
    if (t == 0.0) return a;
    if (t == 1.0) return b;

    // 对所有参数进行线性插值
    return GlassOptions(
      // 数值参数使用ui.lerpDouble进行插值
      blurSigma: ui.lerpDouble(a.blurSigma, b.blurSigma, t)!,
      contrastBoost: ui.lerpDouble(a.contrastBoost, b.contrastBoost, t)!,
      saturationBoost: ui.lerpDouble(a.saturationBoost, b.saturationBoost, t)!,
      grainIntensity: ui.lerpDouble(a.grainIntensity, b.grainIntensity, t)!,
      brightnessCompensation: ui.lerpDouble(
        a.brightnessCompensation,
        b.brightnessCompensation,
        t,
      )!,
      centerScale: ui.lerpDouble(a.centerScale, b.centerScale, t)!,
      edgeScale: ui.lerpDouble(a.edgeScale, b.edgeScale, t)!,

      // 颜色参数使用Color.lerp进行插值
      glassTint: Color.lerp(a.glassTint, b.glassTint, t),

      // 其他复杂参数的插值
      refractionBorder: ui.lerpDouble(
        a.refractionBorder,
        b.refractionBorder,
        t,
      )!,
      boxShadow: BoxShadow.lerp(a.boxShadow, b.boxShadow, t),
    );
  }

  /// Equatable属性列表
  ///
  /// 定义了用于相等性比较的所有属性。当两个GlassOptions实例的
  /// 所有这些属性都相等时，实例被认为是相等的。
  ///
  /// 这对于以下场景很重要：
  /// - 避免不必要的重建和重绘
  /// - 缓存和优化
  /// - 状态管理
  /// - 测试和调试
  @override
  List<Object?> get props => [
    blurSigma,                             // 模糊强度
    contrastBoost,                         // 对比度增强
    saturationBoost,                       // 饱和度增强
    grainIntensity,                        // 噪声强度
    brightnessCompensation,                // 亮度补偿
    centerScale,                           // 中心缩放
    edgeScale,                             // 边缘缩放
    glassTint,                             // 玻璃着色
    refractionBorder,                      // 折射边界宽度
    boxShadow,                             // 阴影效果
  ];
}

/// 为[GlassOptionsInterface]实例提供便捷线性插值方法的扩展
///
/// 这个扩展为[GlassOptionsInterface]添加了插值方法，使得在不同的
/// 玻璃效果配置之间创建动画或过渡变得更加容易。
///
/// 主要功能：
/// - 提供实例方法形式的插值操作
/// - 简化动画代码的编写
/// - 支持链式调用
/// - 增强代码可读性
///
/// 使用场景：
/// - 创建平滑的参数过渡动画
/// - 实现交互式效果调整
/// - 状态之间的渐变切换
///
/// 参考文档：
/// - [GlassOptionsInterface] 此扩展应用的接口
/// - [GlassOptions.lerp] 扩展内部使用的静态方法
extension GlassOptionsLerp on GlassOptionsInterface {
  /// 从当前实例向另一个实例进行插值
  ///
  /// 创建一个新的[GlassOptions]实例，其属性值是当前实例和目标实例
  /// 之间的插值结果。
  ///
  /// 参数说明：
  /// - [other] 目标参数实例
  /// - [t] 插值位置，范围0.0-1.0
  ///   - 0.0 返回当前实例（this）
  ///   - 1.0 返回目标实例（other）
  ///   - 0.0<t<1.0 返回插值结果
  ///
  /// 使用示例：
  /// ```dart
  /// final currentOptions = GlassOptions.defaultOptions;
  /// final targetOptions = GlassOptions(blurSigma: 30, ...);
  /// final animatedOptions = currentOptions.lerpTo(targetOptions, 0.5);
  /// ```
  ///
  /// 返回值：
  /// - 如果other为null，返回当前实例
  /// - 否则返回插值结果
  GlassOptionsInterface? lerpTo(GlassOptionsInterface? other, double t) {
    if (other == null) return this;
    return GlassOptions.lerp(this, other, t);
  }

  /// 从另一个实例向当前实例进行插值
  ///
  /// 创建一个新的[GlassOptions]实例，其属性值是源实例和当前实例
  /// 之间的插值结果。这是lerpTo的反向操作。
  ///
  /// 参数说明：
  /// - [other] 源参数实例
  /// - [t] 插值位置，范围0.0-1.0
  ///   - 0.0 返回源实例（other）
  ///   - 1.0 返回当前实例（this）
  ///   - 0.0<t<1.0 返回插值结果
  ///
  /// 使用示例：
  /// ```dart
  /// final targetOptions = GlassOptions(blurSigma: 30, ...);
  /// final sourceOptions = GlassOptions.defaultOptions;
  /// final animatedOptions = targetOptions.lerpFrom(sourceOptions, 0.5);
  /// ```
  ///
  /// 返回值：
  /// - 如果other为null，返回当前实例
  /// - 否则返回插值结果
  GlassOptionsInterface? lerpFrom(GlassOptionsInterface? other, double t) {
    if (other == null) return this;
    return GlassOptions.lerp(other, this, t);
  }
}
