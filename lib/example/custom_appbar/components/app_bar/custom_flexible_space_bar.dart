import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_x_widgets/example/custom_appbar/components/clippers/square_to_circle_clipper.dart';

/// Flutter FlexibleSpaceBar 的自定义实现
class CustomFlexibleSpaceBar extends StatefulWidget {
  const CustomFlexibleSpaceBar({
    super.key,
    this.title,
    this.background,
    this.titlePadding,
    this.stretchModes = const <StretchMode>[
      StretchMode.blurBackground,
      StretchMode.zoomBackground,
    ],
    this.expandedTitleScale = 1.5,
  }) : assert(expandedTitleScale >= 1, 'expandedTitleScale 必须大于等于 1');

  /// 展开时灵活空间栏的主要内容
  final Widget? title;

  /// 应用栏的背景
  final Widget? background;

  /// 过度滚动时的拉伸效果
  ///
  /// 默认包含 [StretchMode.zoomBackground]
  final List<StretchMode> stretchModes;

  /// 折叠时标题周围的内边距
  final EdgeInsetsGeometry? titlePadding;

  /// 展开时标题的缩放效果
  final double expandedTitleScale;

  @override
  State<CustomFlexibleSpaceBar> createState() => _CustomFlexibleSpaceBarState();
}

class _CustomFlexibleSpaceBarState extends State<CustomFlexibleSpaceBar> {
  /// 根据文本方向从 Alignment.bottomRight 或
  /// Alignment.bottomLeft 到 Alignment.center 进行插值计算
  Alignment _getTitleAlignment(double t) {
    return switch (Directionality.of(context)) {
      //TODO: 根据裁剪器计算对齐方式
      TextDirection.rtl =>
        Alignment.lerp(Alignment.bottomRight, const Alignment(0.1, 1.0), t)!,
      TextDirection.ltr =>
        Alignment.lerp(Alignment.bottomLeft, const Alignment(-0.1, 1.0), t)!,
    };
  }

  double _getCollapsePadding(double t, FlexibleSpaceBarSettings settings) {
    final double deltaExtent = settings.maxExtent - settings.minExtent;
    return -Tween<double>(begin: 0.0, end: deltaExtent / 2.6).transform(t);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final FlexibleSpaceBarSettings settings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;

        final List<Widget> children = <Widget>[];

        final double deltaExtent = settings.maxExtent - settings.minExtent;

        // 0.0 -> 展开状态
        // 1.0 -> 折叠到工具栏状态
        final double t = clampDouble(
            1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent,
            0.0,
            1.0);

        // 背景部分
        if (widget.background != null) {
          final double fadeStart =
              math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
          const double fadeEnd = 1.0;
          assert(fadeStart <= fadeEnd);

          double height = settings.maxExtent;

          // StretchMode.zoomBackground 模式
          if (widget.stretchModes.contains(StretchMode.zoomBackground) &&
              constraints.maxHeight > height) {
            height = constraints.maxHeight;
          }
          final double topPadding = _getCollapsePadding(t, settings);
          children.add(Positioned(
            top: topPadding,
            left: -20.0,
            right: 0.0,
            height: height,
            child: _FlexibleSpaceHeaderOpacity(
              // iOS 依赖于这个语义节点来正确地遍历 app bar 当它折叠时
              alwaysIncludeSemantics: true,

              /// 总是显示小部件
              opacity: 1,
              child: Transform.translate(
                offset: Offset(
                  //TODO: 根据裁剪器计算偏移量
                  ui.lerpDouble(
                      0,
                      // 检查文本方向性
                      Directionality.of(context) == ui.TextDirection.ltr
                          //TODO: 移除硬编码数字
                          ? -100
                          : 120,
                      t)!,
                  0,
                ),
                child: Transform.scale(
                  scale: 1 - (t * 0.87),
                  child: ClipPath(
                    clipper: MorphingClipper(t),
                    child: widget.background,
                  ),
                ),
              ),
            ),
          ));

          /// StretchMode.blurBackground
          if (widget.stretchModes.contains(StretchMode.blurBackground) &&
              constraints.maxHeight > settings.maxExtent) {
            final double blurAmount =
                (constraints.maxHeight - settings.maxExtent) / 10;
            children.add(Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: blurAmount,
                  sigmaY: blurAmount,
                ),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ));
          }
        }

        // title
        if (widget.title != null) {
          final ThemeData theme = Theme.of(context);

          Widget? title;
          switch (theme.platform) {
            case TargetPlatform.iOS:
            case TargetPlatform.macOS:
              title = widget.title;
            case TargetPlatform.android:
            case TargetPlatform.fuchsia:
            case TargetPlatform.linux:
            case TargetPlatform.windows:
              title = Semantics(
                namesRoute: true,
                child: widget.title,
              );
          }

          // StretchMode.fadeTitle
          if (widget.stretchModes.contains(StretchMode.fadeTitle) &&
              constraints.maxHeight > settings.maxExtent) {
            final double stretchOpacity = 1 -
                clampDouble((constraints.maxHeight - settings.maxExtent) / 100,
                    0.0, 1.0);
            title = Opacity(
              opacity: stretchOpacity,
              child: title,
            );
          }

          final double opacity = settings.toolbarOpacity;
          if (opacity > 0.0) {
            TextStyle titleStyle = theme.useMaterial3
                ? theme.textTheme.titleLarge!
                : theme.primaryTextTheme.titleLarge!;
            titleStyle = titleStyle.copyWith(
              color: titleStyle.color!.withOpacity(opacity),
            );
            final double leadingPadding =
                (settings.hasLeading ?? true) ? 72.0 : 0.0;
            final EdgeInsetsGeometry padding = widget.titlePadding ??
                EdgeInsetsDirectional.only(
                  start: leadingPadding,
                  bottom: 16.0,
                );
            final double scaleValue =
                Tween<double>(begin: widget.expandedTitleScale, end: 1.0)
                    .transform(t);
            final Matrix4 scaleTransform = Matrix4.identity()
              ..scale(scaleValue, scaleValue, 1.0);

            final Alignment titleAlignment = _getTitleAlignment(t);
            children.add(
              Container(
                padding: padding,
                child: Transform(
                  alignment: titleAlignment,
                  transform: scaleTransform,
                  child: Align(
                    alignment: titleAlignment,
                    child: DefaultTextStyle(
                      style: titleStyle,
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Container(
                            width: constraints.maxWidth / scaleValue,
                            alignment: titleAlignment,
                            child: title,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }

        return ClipRect(child: Stack(children: children));
      },
    );
  }
}

/// 从 Flutter 源代码复制的 Flexible Space Bar 实现
///
/// 参考 Flutter 源代码中的 FlexibleSpaceBar
class _FlexibleSpaceHeaderOpacity extends SingleChildRenderObjectWidget {
  const _FlexibleSpaceHeaderOpacity(
      {required this.opacity,
      required super.child,
      required this.alwaysIncludeSemantics});

  final double opacity;
  final bool alwaysIncludeSemantics;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderFlexibleSpaceHeaderOpacity(
        opacity: opacity, alwaysIncludeSemantics: alwaysIncludeSemantics);
  }

  @override
  void updateRenderObject(BuildContext context,
      covariant _RenderFlexibleSpaceHeaderOpacity renderObject) {
    renderObject
      ..alwaysIncludeSemantics = alwaysIncludeSemantics
      ..opacity = opacity;
  }
}

/// 从 Flutter 源代码复制的 Flexible Space Bar 实现
///
/// 参考 Flutter 源代码中的 FlexibleSpaceBar
class _RenderFlexibleSpaceHeaderOpacity extends RenderOpacity {
  _RenderFlexibleSpaceHeaderOpacity(
      {super.opacity, super.alwaysIncludeSemantics});

  @override
  bool get isRepaintBoundary => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      return;
    }
    if ((opacity * 255).roundToDouble() <= 0) {
      layer = null;
      return;
    }
    assert(needsCompositing);
    layer = context.pushOpacity(offset, (opacity * 255).round(), super.paint,
        oldLayer: layer as OpacityLayer?);
    assert(() {
      layer!.debugCreator = debugCreator;
      return true;
    }());
  }
}
