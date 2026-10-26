import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/material.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_icon.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_pressable.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/note_paper.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/tape_strip.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';

class MaterialPreview extends StatelessWidget {
  const MaterialPreview({
    super.key,
    required this.item,
    required this.width,
    required this.height,
    this.noteColor,
    this.photoPadding = 4,
  });

  final MaterialItem item;
  final double width;
  final double height;
  final Color? noteColor;
  final double photoPadding;

  @override
  Widget build(BuildContext context) {
    switch (item.kind) {
      case MaterialKind.sticker:
        return SizedBox(
          width: width,
          height: height,
          child: App16Svg(src: item.src ?? 'assets/stickers/flower.svg'),
        );
      case MaterialKind.tape:
        return SizedBox(
          width: width,
          height: height,
          child: Center(
            child: TapeStrip(
              style: item.tapeStyle ?? 'rose',
              width: width,
              height: height * 0.36,
              rotation: -9,
            ),
          ),
        );
      case MaterialKind.note:
        return NotePaper(
          text: item.text ?? item.name,
          color: noteColor ?? app16Color(item.color, const Color(0xFFF3DEB2)),
          width: width,
          height: height,
          rotation: -6,
          fontSize: width > 60 ? 17 : 10,
          listItem: true,
        );
      case MaterialKind.photo:
        return Transform.rotate(
          angle: -5 * 3.141592653589793 / 180,
          child: Container(
            width: width,
            height: height,
            padding: EdgeInsets.all(photoPadding),
            color: App16Colors.paper,
            child: App16Image(
              src: item.src ?? 'assets/photos/cafe.webp',
              width: width - photoPadding * 2,
              height: height - photoPadding * 2,
            ),
          ),
        );
    }
  }
}

class MaterialTile extends StatefulWidget {
  const MaterialTile({
    super.key,
    required this.item,
    required this.selected,
    required this.imageHeight,
    required this.onSelect,
  });

  final MaterialItem item;
  final bool selected;
  final double imageHeight;
  final void Function(MaterialItem item, Rect imageRect) onSelect;

  @override
  State<MaterialTile> createState() => _MaterialTileState();
}

class _MaterialTileState extends State<MaterialTile> {
  final GlobalKey _imageKey = GlobalKey();

  void _tap() {
    final context = _imageKey.currentContext;
    final box = context?.findRenderObject() as RenderBox?;
    if (box == null) {
      widget.onSelect(widget.item, Rect.zero);
      return;
    }
    widget.onSelect(widget.item, box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return Semantics(
      selected: selected,
      child: App16Pressable(
        onTap: _tap,
        semanticLabel: '选择${widget.item.name}',
        minSize: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              key: _imageKey,
              height: widget.imageHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? App16Colors.selected : App16Colors.surface,
                border: Border.all(
                  color: selected ? App16Colors.berry : App16Colors.line,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: MaterialPreview(
                        item: widget.item,
                        width: widget.item.kind == MaterialKind.photo ? 78 : 88,
                        height:
                            widget.item.kind == MaterialKind.photo ? 91 : 88,
                      ),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: App16Colors.berry,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: App16Icon(
                            name: 'i-check',
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.15,
                color: selected ? App16Colors.berry : App16Colors.muted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
