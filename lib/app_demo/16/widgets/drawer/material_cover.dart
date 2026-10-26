import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/data/asset_manifest.dart';
import 'package:flutter_x_widgets/app_demo/16/models/material.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_icon.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/note_paper.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/tape_strip.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/drawer/material_tile.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/design_tokens.dart';

class MaterialCover extends StatelessWidget {
  const MaterialCover({
    super.key,
    required this.category,
    required this.catalog,
    required this.height,
  });

  final MaterialCategory category;
  final MaterialCatalog catalog;
  final double height;

  MaterialItem? _find(MaterialCategory category, String id) {
    for (final item in catalog.itemsFor(category)) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final info = catalog.infoFor(category);
    final narrow = App16Metrics.of(context).narrow;
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                const Positioned.fill(
                  child: ColoredBox(color: App16Colors.materialCover),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(App16Assets.paperGrain),
                        repeat: ImageRepeat.repeat,
                        fit: BoxFit.none,
                        alignment: Alignment.topLeft,
                        opacity: 0.16,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 19,
                  bottom: 23,
                  child: Text(
                    info.coverTitle,
                    style: App16Typography.hand(
                      fontSize: narrow ? 28 : 31,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF753553),
                    ),
                  ),
                ),
                ..._decoration(width, narrow),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _decoration(double width, bool narrow) {
    switch (category) {
      case MaterialCategory.sticker:
        final flower = _find(MaterialCategory.sticker, 'flower');
        final coffee = _find(MaterialCategory.sticker, 'coffee');
        final flowerSize = narrow ? 115.0 : 85.0;
        return <Widget>[
          Positioned(
            left: narrow ? width * 0.45 : width * 0.56,
            top: 8,
            child: Transform.rotate(
              angle: 8 * math.pi / 180,
              child: SizedBox(
                width: flowerSize,
                height: flowerSize,
                child: App16Svg(
                  src: flower?.src ?? 'assets/stickers/flower.svg',
                ),
              ),
            ),
          ),
          Positioned(
            right: 7,
            bottom: 7,
            child: Transform.rotate(
              angle: 8 * math.pi / 180,
              child: SizedBox(
                width: 74,
                height: 74,
                child: App16Svg(
                  src: coffee?.src ?? 'assets/stickers/coffee.svg',
                ),
              ),
            ),
          ),
        ];
      case MaterialCategory.tape:
        return <Widget>[
          const Positioned(
            right: 20,
            top: 14,
            child: TapeStrip(
              style: 'check',
              width: 150,
              height: 32,
              rotation: 8,
            ),
          ),
        ];
      case MaterialCategory.note:
        final note = _find(MaterialCategory.note, 'note-1');
        return <Widget>[
          Positioned(
            right: 20,
            top: 14,
            child: Transform.rotate(
              angle: 8 * math.pi / 180,
              child: NotePaper(
                text: note?.text ?? '慢慢来',
                color: app16Color(note?.color, const Color(0xFFDCE2E8)),
                width: 68,
                height: 69,
                rotation: 0,
                fontSize: 15,
                listItem: true,
              ),
            ),
          ),
        ];
      case MaterialCategory.photo:
        final photos = catalog.itemsFor(MaterialCategory.photo);
        final first =
            photos.isNotEmpty
                ? photos.first
                : const MaterialItem(
                  id: 'cafe',
                  name: '巷子里的面包店',
                  kind: MaterialKind.photo,
                  src: 'assets/photos/cafe.webp',
                );
        final second =
            photos.length > 1
                ? photos[1]
                : const MaterialItem(
                  id: 'dog',
                  name: '路过的小朋友',
                  kind: MaterialKind.photo,
                  src: 'assets/photos/dog.webp',
                );
        return <Widget>[
          Positioned(
            right: 48,
            top: 18,
            child: Transform.rotate(
              angle: -8 * math.pi / 180,
              child: MaterialPreview(
                item: first,
                width: 60,
                height: 74,
                photoPadding: 4,
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 18,
            child: Transform.rotate(
              angle: 5 * math.pi / 180,
              child: MaterialPreview(
                item: second,
                width: 60,
                height: 74,
                photoPadding: 4,
              ),
            ),
          ),
        ];
    }
  }
}
