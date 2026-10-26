import 'dart:ui' show Color;

enum MiniPageKind { photo, sticker, note, blank }

class MiniPageData {
  const MiniPageData({
    required this.kind,
    this.src,
    this.text,
    this.rotation = -7,
    this.backgroundColor = const Color(0xFFFFF7EC),
    this.tapeColor = const Color(0xBFDBA3B5),
  });

  final MiniPageKind kind;
  final String? src;
  final String? text;
  final double rotation;
  final Color backgroundColor;
  final Color tapeColor;
}
