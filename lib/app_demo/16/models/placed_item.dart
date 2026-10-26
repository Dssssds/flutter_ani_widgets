import 'package:flutter_x_widgets/app_demo/16/models/material.dart';

class PlacedItem {
  const PlacedItem({
    required this.id,
    required this.kind,
    required this.name,
    required this.x,
    required this.y,
    required this.rotation,
    this.src,
    this.tapeStyle,
    this.text,
    this.color,
  });

  final String id;
  final MaterialKind kind;
  final String name;
  final String? src;
  final String? tapeStyle;
  final String? text;
  final String? color;
  final double x;
  final double y;
  final double rotation;

  PlacedItem copyWith({double? x, double? y}) {
    return PlacedItem(
      id: id,
      kind: kind,
      name: name,
      src: src,
      tapeStyle: tapeStyle,
      text: text,
      color: color,
      x: x ?? this.x,
      y: y ?? this.y,
      rotation: rotation,
    );
  }

  factory PlacedItem.fromJson(Map<String, dynamic> json) {
    return PlacedItem(
      id: json['id'] as String? ?? 'item',
      kind: materialKindFromName(json['kind'] as String?),
      name: json['name'] as String? ?? '素材',
      src: json['src'] as String?,
      tapeStyle: json['tapeStyle'] as String? ?? json['style'] as String?,
      text: json['text'] as String?,
      color: json['color'] as String?,
      x: (json['x'] as num?)?.toDouble() ?? 0.5,
      y: (json['y'] as num?)?.toDouble() ?? 0.5,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'kind': kind.name,
      'name': name,
      if (src != null) 'src': src,
      if (tapeStyle != null) 'tapeStyle': tapeStyle,
      if (text != null) 'text': text,
      if (color != null) 'color': color,
      'x': x,
      'y': y,
      'rotation': rotation,
    };
  }
}
