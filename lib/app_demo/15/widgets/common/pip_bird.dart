import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_x_widgets/app_demo/15/data/asset_manifest.dart';

class PipBird extends StatelessWidget {
  final String asset;
  final double width;
  final double height;
  final double rotationDegrees;
  final String? semanticsLabel;

  const PipBird({
    super.key,
    this.asset = PipAssets.birdWave,
    required this.width,
    required this.height,
    this.rotationDegrees = 0,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final image = Transform.rotate(
      angle: rotationDegrees * math.pi / 180,
      child: SvgPicture.asset(asset, width: width, height: height, excludeFromSemantics: true),
    );

    if (semanticsLabel == null) return ExcludeSemantics(child: image);
    return Semantics(image: true, label: semanticsLabel, child: ExcludeSemantics(child: image));
  }
}
