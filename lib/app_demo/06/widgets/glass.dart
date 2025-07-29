// Copyright (c) 2025, Renan Araujo
// Use of this source code is governed by a MPL-2.0 license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:flutter_x_widgets/app_demo/06/widgets/glass_options.dart';
import 'package:flutter_x_widgets/app_demo/06/widgets/glass_render_object_widget.dart';

/// Shader资源路径常量
/// 指向Liquido玻璃效果的Fragment Shader文件
/// 该Shader实现了复杂的玻璃视觉效果算法
const String _kGlassShaderAssetKey =
    'shaders/impeller.frag';

/// 玻璃效果Widget的抽象基类
///
/// 这是Liquido包的核心API，提供了创建各种玻璃效果的统一接口。
/// 通过工厂构造函数模式，为不同的使用场景提供专门的实现：
/// - [Glass] - 基础容器玻璃效果
/// - [Glass.text] - 文本玻璃效果
/// - [Glass.custom] - 自定义遮罩玻璃效果
///
/// 设计特点：
/// - 实现了Widget接口，可以直接在Widget树中使用
/// - 继承GlassOptionsInterface，确保参数配置的一致性
/// - 使用工厂模式，根据不同场景返回相应的具体实现
///
/// 参考文档：
/// - [GlassOptionsInterface] 玻璃效果参数配置接口
/// - [GlassOptions.defaultOptions] 默认参数配置
abstract class Glass implements Widget, GlassOptionsInterface {
  /// 创建基础容器玻璃效果
  ///
  /// 这是最常用的玻璃效果构造函数，用于为任意Widget添加玻璃材质效果。
  ///
  /// 参数说明：
  /// - [child] 子Widget，如果不提供则行为类似于空的Container
  /// - [shape] 玻璃形状，定义玻璃效果的边界和外观
  ///
  /// 形状支持：
  /// 虽然支持任何ShapeBorder子类，但推荐使用以下形状以获得最佳效果：
  /// - [RoundedSuperellipseBorder] - 超椭圆边框（推荐，现代感强）
  /// - [RoundedRectangleBorder] - 圆角矩形边框
  /// - [CircleBorder] - 圆形边框
  /// - [StadiumBorder] - 胶囊形边框
  /// - [BeveledRectangleBorder] - 斜角矩形边框
  /// - [ContinuousRectangleBorder] - 连续曲线矩形边框
  ///
  /// 默认形状：
  /// 如果未指定shape，将使用半径为30的RoundedSuperellipseBorder
  ///
  /// 玻璃效果参数：
  /// {@macro glass_options}
  ///
  /// 使用示例：
  /// ```dart
  /// Glass(
  ///   blurSigma: 20,
  ///   refractionBorder: 2,
  ///   shape: RoundedSuperellipseBorder(
  ///     borderRadius: BorderRadius.circular(30),
  ///   ),
  ///   child: Container(width: 200, height: 100),
  /// )
  /// ```
  ///
  /// 参考文档：
  /// - [GlassOptionsInterface] 玻璃效果参数详解
  /// - [GlassOptions.defaultOptions] 默认参数值
  /// - [Glass.text] 文本玻璃效果构造函数
  /// - [Glass.custom] 自定义遮罩玻璃效果构造函数
  const factory Glass({
    Key? key,
    ShapeBorder? shape,                    // 玻璃形状边框

    // 玻璃效果参数
    double? blurSigma,                     // 模糊强度 (0-40)
    double? contrastBoost,                 // 对比度增强 (1-1.3)
    double? saturationBoost,               // 饱和度增强 (1-1.3)
    double? grainIntensity,                // 噪声强度 (0-1)
    double? brightnessCompensation,        // 亮度补偿 (-1.0到1.0)
    double? centerScale,                   // 中心缩放 (0.1-1.5)
    double? edgeScale,                     // 边缘缩放 (0.1-1.5)
    Color? glassTint,                      // 玻璃着色
    double? refractionBorder,              // 折射边界宽度
    BoxShadow? boxShadow,                  // 阴影效果
    Widget? child,                         // 子Widget
  }) = _GlassContainer;

  /// 创建文本玻璃效果
  ///
  /// 这个构造函数专门用于创建具有玻璃效果的文本显示。
  /// 它支持Text widget的所有标准参数，提供精确的文本样式和布局控制。
  ///
  /// 工作原理：
  /// - 文本会自动用作玻璃形状的遮罩和内容
  /// - 玻璃效果会完美贴合文本的形状
  /// - 创建出透过文本形状看到背景的玻璃材质效果
  ///
  /// 使用示例：
  /// ```dart
  /// Glass.text(
  ///   'Hello World',
  ///   style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
  ///   blurSigma: 15.0,
  ///   glassTint: Colors.blue.withOpacity(0.1),
  /// )
  /// ```
  ///
  /// 重要提示：
  /// 为了确保玻璃效果的正确显示，以下文本样式属性会被自动覆盖：
  /// - color: 强制设为黑色（用于遮罩生成）
  /// - backgroundColor: 强制设为透明
  /// - decorationColor: 强制设为透明
  /// - shadows: 清空阴影列表
  ///
  /// 玻璃效果参数：
  /// {@macro glass_options}
  ///
  /// 参考文档：
  /// - [Glass] 基础容器玻璃效果
  /// - [Glass.custom] 自定义遮罩玻璃效果
  /// - [GlassOptionsInterface] 玻璃效果参数详解
  const factory Glass.text(
    String data, {                         // 显示的文本内容
    Key? key,

    // Text widget的标准参数
    TextStyle? style,                      // 文本样式
    StrutStyle? strutStyle,                // 支撑样式
    TextAlign? textAlign,                  // 文本对齐方式
    TextDirection? textDirection,          // 文本方向
    Locale? locale,                        // 本地化设置
    bool? softWrap,                        // 软换行
    TextOverflow? overflow,                // 溢出处理
    TextScaler? textScaler,                // 文本缩放
    int? maxLines,                         // 最大行数
    String? semanticsLabel,                // 语义标签
    String? semanticsIdentifier,           // 语义标识符
    TextWidthBasis? textWidthBasis,        // 文本宽度基准
    ui.TextHeightBehavior? textHeightBehavior, // 文本高度行为

    // 玻璃效果参数
    double? blurSigma,                     // 模糊强度 (0-40)
    double? contrastBoost,                 // 对比度增强 (1-1.3)
    double? saturationBoost,               // 饱和度增强 (1-1.3)
    double? grainIntensity,                // 噪声强度 (0-1)
    double? brightnessCompensation,        // 亮度补偿 (-1.0到1.0)
    double? centerScale,                   // 中心缩放 (0.1-1.5)
    double? edgeScale,                     // 边缘缩放 (0.1-1.5)
    Color? glassTint,                      // 玻璃着色
    double? refractionBorder,              // 折射边界宽度
    BoxShadow? boxShadow,                  // 阴影效果
  }) = _GlassText;

  /// 创建自定义遮罩玻璃效果
  ///
  /// 这个构造函数提供了最大的灵活性，允许你同时指定：
  /// - [mask] 遮罩Widget：定义玻璃效果的形状和区域
  /// - [child] 子Widget：通过玻璃显示的内容
  ///
  /// 遮罩要求：
  /// [mask] Widget必须使用纯色（alpha通道只能是1.0或0.0）：
  /// - 不透明区域（alpha=1.0）：应用玻璃效果的区域
  /// - 透明区域（alpha=0.0）：不应用玻璃效果的区域
  ///
  /// ⚠️ 重要警告！
  /// 不要在遮罩Widget中使用以下效果，否则可能导致意外结果：
  /// - 阴影（shadows）
  /// - 模糊（blurs）
  /// - 半透明像素（semi-transparent pixels）
  /// - 渐变透明度
  ///
  /// 遮罩必须是纯色的实体形状，没有任何透明度变化。
  ///
  /// 应用场景：
  /// 这种方式适用于创建复杂的玻璃效果，例如：
  /// - 自定义形状的玻璃窗口
  /// - 不规则的玻璃切口
  /// - 对Widget特定区域应用玻璃效果
  /// - 复杂的组合玻璃形状
  ///
  /// 使用示例：
  /// ```dart
  /// Glass.custom(
  ///   mask: Container(
  ///     decoration: BoxDecoration(
  ///       color: Colors.black, // 纯黑色，alpha=1.0
  ///       shape: BoxShape.circle,
  ///     ),
  ///   ),
  ///   child: YourContentWidget(),
  ///   blurSigma: 15,
  ///   glassTint: Colors.blue.withOpacity(0.1),
  /// )
  /// ```
  ///
  /// 玻璃效果参数：
  /// {@macro glass_options}
  ///
  /// 参考文档：
  /// - [Glass] 基础容器玻璃效果
  /// - [Glass.text] 文本玻璃效果
  /// - [GlassOptionsInterface] 玻璃效果参数详解
  const factory Glass.custom({
    required Widget mask,                  // 遮罩Widget（定义玻璃形状）
    required Widget child,                 // 子Widget（显示内容）
    Key? key,

    // 玻璃效果参数
    double? blurSigma,                     // 模糊强度 (0-40)
    double? contrastBoost,                 // 对比度增强 (1-1.3)
    double? saturationBoost,               // 饱和度增强 (1-1.3)
    double? grainIntensity,                // 噪声强度 (0-1)
    double? brightnessCompensation,        // 亮度补偿 (-1.0到1.0)
    double? centerScale,                   // 中心缩放 (0.1-1.5)
    double? edgeScale,                     // 边缘缩放 (0.1-1.5)
    Color? glassTint,                      // 玻璃着色
    double? refractionBorder,              // 折射边界宽度
    BoxShadow? boxShadow,                  // 阴影效果
  }) = _CustomGlass;
}

/// 基础容器玻璃效果的具体实现类
///
/// 这是Glass()工厂构造函数的具体实现，用于创建容器类型的玻璃效果。
/// 主要特点：
/// - 使用ShapeBorder定义玻璃的形状
/// - 支持任意子Widget作为内容
/// - 提供完整的玻璃效果参数配置
class _GlassContainer extends StatelessWidget implements Glass {
  const _GlassContainer({
    super.key,
    this.shape,                            // 玻璃形状边框
    this.child,                            // 子Widget内容

    // 玻璃效果参数
    this.blurSigma,                        // 模糊强度
    this.contrastBoost,                    // 对比度增强
    this.saturationBoost,                  // 饱和度增强
    this.grainIntensity,                   // 噪声强度
    this.brightnessCompensation,           // 亮度补偿
    this.centerScale,                      // 中心缩放
    this.edgeScale,                        // 边缘缩放
    this.glassTint,                        // 玻璃着色
    this.refractionBorder,                 // 折射边界宽度
    this.boxShadow,                        // 阴影效果
  });

  /// 子Widget内容
  final Widget? child;

  /// 玻璃形状边框，如果为null则使用默认的超椭圆形状
  final ShapeBorder? shape;

  // 实现GlassOptionsInterface接口的所有参数
  @override
  final double? blurSigma;
  @override
  final BoxShadow? boxShadow;
  @override
  final double? brightnessCompensation;
  @override
  final double? centerScale;
  @override
  final double? contrastBoost;
  @override
  final double? edgeScale;
  @override
  final ui.Color? glassTint;
  @override
  final double? grainIntensity;
  @override
  final double? refractionBorder;
  @override
  final double? saturationBoost;

  @override
  Widget build(BuildContext context) {
    return _Glass(
      options: this,                       // 传递当前实例作为参数配置
      // 创建遮罩：使用DecoratedBox和ShapeDecoration定义玻璃形状
      mask: DecoratedBox(
        decoration: ShapeDecoration(
          color: const Color(0xFF000000),   // 纯黑色用于遮罩生成
          shape: shape ??                  // 使用指定形状或默认形状
              RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(30), // 默认30像素圆角的超椭圆
              ),
        ),
      ),
      // 子内容：包装在Container中确保正确的布局行为
      child: Container(child: child),
    );
  }
}

/// 文本玻璃效果的具体实现类
///
/// 这是Glass.text()工厂构造函数的具体实现，专门用于创建文本类型的玻璃效果。
/// 主要特点：
/// - 文本既作为遮罩又作为内容
/// - 自动处理文本样式以确保玻璃效果正确显示
/// - 支持Text widget的所有标准参数
/// - 智能清理可能干扰玻璃效果的样式属性
class _GlassText extends StatelessWidget implements Glass {
  const _GlassText(
    this.data, {                           // 显示的文本内容
    super.key,

    // Text widget的标准参数
    this.style,                            // 文本样式
    this.strutStyle,                       // 支撑样式
    this.textAlign,                        // 文本对齐
    this.textDirection,                    // 文本方向
    this.locale,                           // 本地化
    this.softWrap,                         // 软换行
    this.overflow,                         // 溢出处理
    this.textScaler,                       // 文本缩放
    this.maxLines,                         // 最大行数
    this.semanticsLabel,                   // 语义标签
    this.semanticsIdentifier,              // 语义标识符
    this.textWidthBasis,                   // 文本宽度基准
    this.textHeightBehavior,               // 文本高度行为

    // 玻璃效果参数
    this.blurSigma,                        // 模糊强度
    this.contrastBoost,                    // 对比度增强
    this.saturationBoost,                  // 饱和度增强
    this.grainIntensity,                   // 噪声强度
    this.brightnessCompensation,           // 亮度补偿
    this.centerScale,                      // 中心缩放
    this.edgeScale,                        // 边缘缩放
    this.glassTint,                        // 玻璃着色
    this.refractionBorder,                 // 折射边界宽度
    this.boxShadow,                        // 阴影效果
  });

  // 实现GlassOptionsInterface接口的所有参数
  @override
  final double? blurSigma;
  @override
  final BoxShadow? boxShadow;
  @override
  final double? brightnessCompensation;
  @override
  final double? centerScale;
  @override
  final double? contrastBoost;
  @override
  final double? edgeScale;
  @override
  final ui.Color? glassTint;
  @override
  final double? grainIntensity;
  @override
  final double? refractionBorder;
  @override
  final double? saturationBoost;

  /// 显示的文本内容
  final String data;

  /// 文本样式（会被自动处理以确保玻璃效果正确）
  final TextStyle? style;

  /// 支撑样式，用于控制文本的垂直布局
  final StrutStyle? strutStyle;

  /// 文本对齐方式
  final TextAlign? textAlign;

  /// 文本方向（从左到右或从右到左）
  final TextDirection? textDirection;

  /// 本地化设置
  final Locale? locale;

  /// 是否允许软换行
  final bool? softWrap;

  /// 文本溢出时的处理方式
  final TextOverflow? overflow;

  /// 文本缩放器
  final TextScaler? textScaler;

  /// 最大显示行数
  final int? maxLines;

  /// 语义标签，用于无障碍访问
  final String? semanticsLabel;

  /// 语义标识符，用于无障碍访问
  final String? semanticsIdentifier;

  /// 文本宽度计算基准
  final TextWidthBasis? textWidthBasis;

  /// 文本高度行为控制
  final ui.TextHeightBehavior? textHeightBehavior;

  @override
  Widget build(BuildContext context) {
    // 1. 获取默认文本样式并进行合并处理
    final defaultTextStyle = DefaultTextStyle.of(context);
    var effectiveTextStyle = style;

    // 如果没有指定样式或样式需要继承，则与默认样式合并
    if (style == null || style!.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(style);
    }

    // 如果系统设置了粗体文本（无障碍功能），则应用粗体
    if (MediaQuery.boldTextOf(context)) {
      effectiveTextStyle = effectiveTextStyle!.merge(
        const TextStyle(fontWeight: FontWeight.bold),
      );
    }

    // 2. 强制覆盖可能干扰玻璃效果的样式属性
    // 这是关键步骤：确保文本能正确用作遮罩
    effectiveTextStyle = effectiveTextStyle!.copyWith(
      color: const Color(0xFF000000),           // 强制黑色，用于生成遮罩
      decorationColor: const Color(0x00000000), // 移除装饰颜色
      backgroundColor: const Color(0x00000000), // 移除背景色
      shadows: [],                              // 清空阴影列表
    );

    // 3. 创建Text widget实例
    final text = Text(
      data,                                     // 文本内容
      style: effectiveTextStyle,                // 处理后的样式
      // strutStyle: strutStyle,                // 支撑样式（已注释）
      textAlign: textAlign,                     // 文本对齐
      textDirection: textDirection,             // 文本方向
      locale: locale,                           // 本地化
      softWrap: softWrap,                       // 软换行
      overflow: overflow,                       // 溢出处理
      textScaler: textScaler,                   // 文本缩放
      maxLines: maxLines,                       // 最大行数
      semanticsLabel: semanticsLabel,           // 语义标签
      semanticsIdentifier: semanticsIdentifier, // 语义标识符
      textWidthBasis: textWidthBasis,           // 文本宽度基准
      textHeightBehavior: textHeightBehavior,   // 文本高度行为
      selectionColor: const Color(0x00000000),  // 移除选择颜色
    );

    // 4. 构建玻璃效果
    return _Glass(
      options: this,                            // 传递当前实例作为参数配置
      mask: text,                               // 文本作为遮罩
      child: Opacity(
        opacity: 0,                             // 完全透明的占位内容
        child: text,                            // 相同的文本用于布局计算
      ),
    );
  }
}

/// 自定义遮罩玻璃效果的具体实现类
///
/// 这是Glass.custom()工厂构造函数的具体实现，用于创建自定义遮罩的玻璃效果。
/// 主要特点：
/// - 完全自定义的遮罩Widget
/// - 独立的子内容Widget
/// - 最大的灵活性和控制力
/// - 适用于复杂的玻璃效果需求
class _CustomGlass extends StatelessWidget implements Glass {
  const _CustomGlass({
    required this.mask,                    // 必需：遮罩Widget
    required this.child,                   // 必需：子内容Widget
    super.key,

    // 玻璃效果参数
    this.blurSigma,                        // 模糊强度
    this.contrastBoost,                    // 对比度增强
    this.saturationBoost,                  // 饱和度增强
    this.grainIntensity,                   // 噪声强度
    this.brightnessCompensation,           // 亮度补偿
    this.centerScale,                      // 中心缩放
    this.edgeScale,                        // 边缘缩放
    this.glassTint,                        // 玻璃着色
    this.refractionBorder,                 // 折射边界宽度
    this.boxShadow,                        // 阴影效果
  });

  // 实现GlassOptionsInterface接口的所有参数
  @override
  final double? blurSigma;
  @override
  final BoxShadow? boxShadow;
  @override
  final double? brightnessCompensation;
  @override
  final double? centerScale;
  @override
  final double? contrastBoost;
  @override
  final double? edgeScale;
  @override
  final ui.Color? glassTint;
  @override
  final double? grainIntensity;
  @override
  final double? refractionBorder;
  @override
  final double? saturationBoost;

  /// 子内容Widget，通过玻璃显示的内容
  final Widget child;

  /// 遮罩Widget，定义玻璃效果的形状和区域
  final Widget mask;

  @override
  Widget build(BuildContext context) {
    // 直接传递遮罩和子内容给通用的_Glass实现
    return _Glass(
      options: this,                       // 传递当前实例作为参数配置
      mask: mask,                          // 使用自定义遮罩
      child: child,                        // 使用自定义子内容
    );
  }
}

/// 通用玻璃效果实现类
///
/// 这是所有Glass变体的最终实现类，负责：
/// - 加载和管理Fragment Shader
/// - 创建自定义渲染对象
/// - 处理设备像素比例
/// - 统一的渲染流程
///
/// 这个类是整个玻璃效果系统的核心，所有具体实现最终都会调用这个类。
class _Glass extends StatelessWidget {
  const _Glass({
    required this.options,                 // 玻璃效果参数配置
    required this.child,                   // 子内容Widget
    required this.mask,                    // 遮罩Widget
  });

  /// 玻璃效果参数配置接口
  final GlassOptionsInterface options;

  /// 子内容Widget，通过玻璃显示的内容
  final Widget child;

  /// 遮罩Widget，定义玻璃效果的形状
  final Widget mask;

  @override
  Widget build(BuildContext context) {
    // 使用ShaderBuilder加载和管理Fragment Shader
    return ShaderBuilder(
      assetKey: _kGlassShaderAssetKey,     // Shader资源路径
      (context, shader, childWidget) {
        // 创建自定义渲染对象Widget
        return GlassRenderObjectWidget(
          shader: shader,                  // 编译后的Fragment Shader
          pixelRatio: MediaQuery.of(context).devicePixelRatio, // 设备像素比例
          mask: mask,                      // 遮罩Widget
          options: GlassOptions.fromInterface(options), // 转换为具体的参数对象
          child: childWidget!,             // 子内容Widget
        );
      },
      child: child,                        // 传递给ShaderBuilder的子Widget
    );
  }
}
