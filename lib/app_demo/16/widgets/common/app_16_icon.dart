import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_x_widgets/app_demo/16/data/asset_manifest.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';

class App16Icon extends StatelessWidget {
  const App16Icon({
    super.key,
    required this.name,
    this.size = 24,
    this.color = App16Colors.ink,
  });

  final String name;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      App16Assets.icon(name),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

class App16Svg extends StatelessWidget {
  const App16Svg({
    super.key,
    required this.src,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String src;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      App16Assets.resolve(src),
      width: width,
      height: height,
      fit: fit,
    );
  }
}

class App16Image extends StatelessWidget {
  const App16Image({
    super.key,
    required this.src,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String src;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final resolved = App16Assets.resolve(src);
    if (App16Assets.isAsset(resolved)) {
      return Image.asset(
        resolved,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: _fallback,
      );
    }
    return Image.file(
      File(resolved),
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: _fallback,
    );
  }

  Widget _fallback(BuildContext context, Object error, StackTrace? stack) {
    return Container(
      width: width,
      height: height,
      color: App16Colors.pink,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: App16Colors.berry,
        size: 18,
      ),
    );
  }
}
