import 'package:flutter_x_widgets/app_demo/16/models/placed_item.dart';

enum PhotoSlot { none, main, side }

class DiaryEntry {
  const DiaryEntry({
    required this.year,
    required this.month,
    required this.day,
    required this.weekday,
    required this.mood,
    required this.title,
    required this.note,
    required this.basePhotos,
    required this.mainSrc,
    required this.mainCaption,
    required this.sideSrc,
    required this.sideCaption,
    required this.mainX,
    required this.mainY,
    required this.sideX,
    required this.sideY,
    required this.items,
    required this.type,
    this.coverText,
  });

  final int year;
  final int month;
  final int day;
  final String weekday;
  final String mood;
  final String title;
  final String note;
  final bool basePhotos;
  final String mainSrc;
  final String mainCaption;
  final String sideSrc;
  final String sideCaption;
  final double mainX;
  final double mainY;
  final double sideX;
  final double sideY;
  final List<PlacedItem> items;
  final String type;
  final String? coverText;

  DateTime get date => DateTime(year, month, day);

  String get key => entryKey(year, month, day);

  DiaryEntry deepCopy() {
    return DiaryEntry(
      year: year,
      month: month,
      day: day,
      weekday: weekday,
      mood: mood,
      title: title,
      note: note,
      basePhotos: basePhotos,
      mainSrc: mainSrc,
      mainCaption: mainCaption,
      sideSrc: sideSrc,
      sideCaption: sideCaption,
      mainX: mainX,
      mainY: mainY,
      sideX: sideX,
      sideY: sideY,
      items: List<PlacedItem>.unmodifiable(items),
      type: type,
      coverText: coverText,
    );
  }

  DiaryEntry copyWith({
    String? mood,
    String? title,
    String? note,
    bool? basePhotos,
    double? mainX,
    double? mainY,
    double? sideX,
    double? sideY,
    List<PlacedItem>? items,
    String? coverText,
  }) {
    return DiaryEntry(
      year: year,
      month: month,
      day: day,
      weekday: weekday,
      mood: mood ?? this.mood,
      title: title ?? this.title,
      note: note ?? this.note,
      basePhotos: basePhotos ?? this.basePhotos,
      mainSrc: mainSrc,
      mainCaption: mainCaption,
      sideSrc: sideSrc,
      sideCaption: sideCaption,
      mainX: mainX ?? this.mainX,
      mainY: mainY ?? this.mainY,
      sideX: sideX ?? this.sideX,
      sideY: sideY ?? this.sideY,
      items: items ?? this.items,
      type: type,
      coverText: coverText ?? this.coverText,
    );
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json, {DateTime? fallback}) {
    final now = fallback ?? DateTime(2026, 10, 4);
    final year = (json['year'] as num?)?.toInt() ?? now.year;
    final month = (json['month'] as num?)?.toInt() ?? now.month;
    final day = (json['day'] as num?)?.toInt() ?? now.day;
    final mainPosition = json['mainPosition'] as Map<String, dynamic>?;
    final sidePosition = json['sidePosition'] as Map<String, dynamic>?;
    final rawItems = json['items'];

    return DiaryEntry(
      year: year,
      month: month,
      day: day,
      weekday:
          json['weekday'] as String? ??
          weekdayLabel(DateTime(year, month, day)),
      mood: json['mood'] as String? ?? '好心情',
      title: json['title'] as String? ?? '我的小小日常',
      note: json['note'] as String? ?? '今天，想留下一点喜欢。',
      basePhotos: json['basePhotos'] as bool? ?? false,
      mainSrc: json['mainSrc'] as String? ?? 'assets/photos/cafe.webp',
      mainCaption: json['mainCaption'] as String? ?? '留下一点喜欢',
      sideSrc: json['sideSrc'] as String? ?? 'assets/photos/dog.webp',
      sideCaption: json['sideCaption'] as String? ?? '偶遇一位小朋友',
      mainX: (mainPosition?['x'] as num?)?.toDouble() ?? 0.0714,
      mainY: (mainPosition?['y'] as num?)?.toDouble() ?? 0.1588,
      sideX: (sidePosition?['x'] as num?)?.toDouble() ?? 0.5657,
      sideY: (sidePosition?['y'] as num?)?.toDouble() ?? 0.5431,
      items:
          rawItems is List
              ? rawItems
                  .whereType<Map<String, dynamic>>()
                  .map(PlacedItem.fromJson)
                  .toList(growable: false)
              : const <PlacedItem>[],
      type: json['type'] as String? ?? 'blank',
      coverText: json['coverText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'year': year,
      'month': month,
      'day': day,
      'weekday': weekday,
      'mood': mood,
      'title': title,
      'note': note,
      'basePhotos': basePhotos,
      'mainSrc': mainSrc,
      'mainCaption': mainCaption,
      'sideSrc': sideSrc,
      'sideCaption': sideCaption,
      'mainPosition': <String, dynamic>{'x': mainX, 'y': mainY},
      'sidePosition': <String, dynamic>{'x': sideX, 'y': sideY},
      'items': items.map((item) => item.toJson()).toList(growable: false),
      'type': type,
      if (coverText != null) 'coverText': coverText,
    };
  }
}

String entryKey(int year, int month, int day) {
  return '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}

String weekdayLabel(DateTime date) {
  const labels = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
  return labels[date.weekday - 1];
}

String formatMonthDay(DiaryEntry entry) {
  return '${entry.month.toString().padLeft(2, '0')}.'
      '${entry.day.toString().padLeft(2, '0')}';
}

String formatShortDate(int month, int day) {
  return '${month.toString().padLeft(2, '0')}.${day.toString().padLeft(2, '0')}';
}
