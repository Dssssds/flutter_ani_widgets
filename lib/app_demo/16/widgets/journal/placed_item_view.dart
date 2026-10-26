import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/placed_item.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/tape_strip.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/journal/polaroid.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';

class PlacedItemView extends StatelessWidget {
  const PlacedItemView({
    super.key,
    required this.item,
    required this.width,
    required this.height,
  });

  final PlacedItem item;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    switch (item.kind) {
      case MaterialKind.sticker:
        return PlacedSticker(
          width: width,
          height: height,
          src: item.src ?? 'assets/stickers/flower.svg',
        );
      case MaterialKind.photo:
        return PlacedPhoto(
          width: width,
          height: height,
          src: item.src ?? 'assets/photos/cafe.webp',
        );
      case MaterialKind.tape:
        return TapeStrip(
          style: item.tapeStyle ?? 'rose',
          width: width,
          height: height,
        );
      case MaterialKind.note:
        return PlacedNote(
          width: width,
          height: height,
          text: item.text ?? item.name,
          color: app16Color(item.color, const Color(0xFFF3DEB2)),
        );
    }
  }
}
