import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PipIcon extends StatelessWidget {
  final String asset;
  final double size;
  final double? height;
  final Color? color;
  final BlendMode blendMode;
  final bool grayscale;
  final String? semanticLabel;

  const PipIcon({
    super.key,
    required this.asset,
    this.size = 24,
    this.height,
    this.color,
    this.blendMode = BlendMode.srcIn,
    this.grayscale = false,
    this.semanticLabel,
  });

  static const _grayscaleFilter = ColorFilter.matrix(<double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  @override
  Widget build(BuildContext context) {
    final ColorFilter? filter =
        color != null
            ? ColorFilter.mode(color!, blendMode)
            : grayscale
            ? _grayscaleFilter
            : null;

    return SvgPicture.asset(
      asset,
      width: size,
      height: height ?? size,
      colorFilter: filter,
      excludeFromSemantics: semanticLabel == null,
      semanticsLabel: semanticLabel,
    );
  }
}
