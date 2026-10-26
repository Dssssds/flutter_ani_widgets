import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_icon.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/tape_strip.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';

class Polaroid extends StatelessWidget {
  const Polaroid({
    super.key,
    required this.width,
    required this.imageHeight,
    required this.src,
    required this.caption,
    required this.captionStyle,
    this.padding = const EdgeInsets.fromLTRB(8, 8, 8, 5),
    this.tapeStyle = 'rose',
    this.tapeWidth = 87,
    this.tapeHeight = 28,
    this.tapeLeft = 59,
    this.tapeRotation = 3,
  });

  final double width;
  final double imageHeight;
  final String src;
  final String caption;
  final TextStyle captionStyle;
  final EdgeInsets padding;
  final String tapeStyle;
  final double tapeWidth;
  final double tapeHeight;
  final double tapeLeft;
  final double tapeRotation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          width: width,
          padding: padding,
          decoration: const BoxDecoration(
            color: App16Colors.photoPaper,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0x30624A40),
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
              BoxShadow(
                color: Color(0x17624A40),
                offset: Offset(2, 5),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipRect(
                child: SizedBox(
                  width: width - padding.horizontal,
                  height: imageHeight,
                  child: App16Image(src: src),
                ),
              ),
              SizedBox(
                height: captionStyle.fontSize! * (captionStyle.height ?? 1.9),
                child: Center(
                  child: Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: captionStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: tapeLeft,
          top: -10,
          child: TapeStrip(
            style: tapeStyle,
            width: tapeWidth,
            height: tapeHeight,
            rotation: tapeRotation,
          ),
        ),
      ],
    );
  }
}

class PlacedPhoto extends StatelessWidget {
  const PlacedPhoto({
    super.key,
    required this.width,
    required this.height,
    required this.src,
  });

  final double width;
  final double height;
  final String src;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: App16Colors.photoPaper,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x21624A40),
            offset: Offset(1, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: ClipRect(
        child: App16Image(src: src, width: width - 10, height: height - 10),
      ),
    );
  }
}

class PlacedSticker extends StatelessWidget {
  const PlacedSticker({
    super.key,
    required this.width,
    required this.height,
    required this.src,
  });

  final double width;
  final double height;
  final String src;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height, child: App16Svg(src: src));
  }
}

class PlacedNote extends StatelessWidget {
  const PlacedNote({
    super.key,
    required this.width,
    required this.height,
    required this.text,
    required this.color,
  });

  final double width;
  final double height;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12674C37),
            offset: Offset(1, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: App16Typography.hand(
          fontSize: 17,
          height: 1.4,
          color: App16Colors.noteText,
        ),
      ),
    );
  }
}
