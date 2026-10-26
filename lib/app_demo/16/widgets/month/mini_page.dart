import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/diary_entry.dart';
import 'package:flutter_x_widgets/app_demo/16/models/mini_page.dart';
import 'package:flutter_x_widgets/app_demo/16/models/rules/diary_rules.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_icon.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';

class MiniPage extends StatelessWidget {
  const MiniPage({
    super.key,
    required this.data,
    this.width = 28,
    this.height = 31,
  });

  final MiniPageData data;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final padding = switch (data.kind) {
      MiniPageKind.note => const EdgeInsets.fromLTRB(2, 7, 2, 2),
      MiniPageKind.photo => const EdgeInsets.fromLTRB(3, 3, 3, 5),
      MiniPageKind.sticker => const EdgeInsets.all(2),
      MiniPageKind.blank => EdgeInsets.zero,
    };
    return Transform.rotate(
      angle: data.rotation * 3.141592653589793 / 180,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned.fill(
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: data.backgroundColor,
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x146B4A5C),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: _content(),
              ),
            ),
            Positioned(
              top: -2,
              left: width * 0.25,
              child: Container(
                width: width * 0.54,
                height: 5,
                color: data.tapeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    switch (data.kind) {
      case MiniPageKind.photo:
        return SizedBox.expand(
          child: App16Image(
            src: data.src ?? 'assets/photos/cafe.webp',
            fit: BoxFit.cover,
          ),
        );
      case MiniPageKind.sticker:
        return App16Svg(src: data.src ?? 'assets/stickers/flower.svg');
      case MiniPageKind.note:
        return Center(
          child: Text(
            data.text ?? '慢慢来',
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: App16Typography.hand(
              fontSize: 7,
              height: 1.25,
              fontWeight: FontWeight.w400,
              color: App16Colors.noteText,
            ),
          ),
        );
      case MiniPageKind.blank:
        return const SizedBox.shrink();
    }
  }
}

class EntryThumbnail extends StatelessWidget {
  const EntryThumbnail({super.key, required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final data = DiaryRules.deriveMiniPage(entry);
    return Transform.rotate(
      angle: -4 * 3.141592653589793 / 180,
      child: SizedBox(
        width: 78,
        height: 100,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: App16Colors.paper,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0x1F624A40),
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: ClipRect(child: _content(data)),
              ),
            ),
            Positioned(
              top: -4,
              left: 21,
              child: Container(
                width: 35,
                height: 12,
                color: const Color(0xBFDBA3B5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(MiniPageData data) {
    switch (data.kind) {
      case MiniPageKind.photo:
        return SizedBox.expand(
          child: App16Image(
            src: data.src ?? 'assets/photos/cafe.webp',
            fit: BoxFit.cover,
          ),
        );
      case MiniPageKind.sticker:
        return ColoredBox(
          color: data.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: App16Svg(src: data.src ?? 'assets/stickers/flower.svg'),
          ),
        );
      case MiniPageKind.note:
        return ColoredBox(
          color: data.backgroundColor,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                data.text ?? '慢慢来',
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: App16Typography.hand(
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w400,
                  color: App16Colors.noteText,
                ),
              ),
            ),
          ),
        );
      case MiniPageKind.blank:
        return const ColoredBox(color: Color(0xFFFFF7EC));
    }
  }
}
