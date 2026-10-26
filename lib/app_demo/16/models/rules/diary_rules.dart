import 'dart:math' as math;
import 'dart:ui' show Color;
import 'package:flutter_x_widgets/app_demo/16/models/diary_entry.dart';
import 'package:flutter_x_widgets/app_demo/16/models/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/mini_page.dart';
import 'package:flutter_x_widgets/app_demo/16/models/placed_item.dart';

abstract final class DiaryRules {
  static const maxTitleLength = 10;
  static const maxNoteLength = 75;
  static const undoLimit = 15;

  static double clampPosition({
    required double origin,
    required double deltaPx,
    required double paperExtent,
    required double itemExtent,
  }) {
    if (paperExtent <= 0) {
      return origin;
    }
    final maxValue = math.max(0.0, 1 - itemExtent / paperExtent);
    return (origin + deltaPx / paperExtent).clamp(0.0, maxValue);
  }

  static bool isFuture(DateTime day, DateTime today) {
    final target = DateTime(day.year, day.month, day.day);
    final current = DateTime(today.year, today.month, today.day);
    return target.isAfter(current);
  }

  static String monthLabel(int month) {
    const labels = [
      '一月',
      '二月',
      '三月',
      '四月',
      '五月',
      '六月',
      '七月',
      '八月',
      '九月',
      '十月',
      '十一月',
      '十二月',
    ];
    return labels[month - 1];
  }

  static int leadingEmptyDays(int year, int month) {
    return DateTime(year, month, 1).weekday - 1;
  }

  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static int calendarCellCount(int year, int month) {
    return leadingEmptyDays(year, month) + daysInMonth(year, month);
  }

  static DiaryEntry defaultEntry(DateTime date) {
    return DiaryEntry(
      year: date.year,
      month: date.month,
      day: date.day,
      weekday: weekdayLabel(date),
      mood: '好心情',
      title: '我的小小日常',
      note: '今天，想留下一点喜欢。',
      basePhotos: false,
      mainSrc: 'assets/photos/cafe.webp',
      mainCaption: '留下一点喜欢',
      sideSrc: 'assets/photos/dog.webp',
      sideCaption: '偶遇一位小朋友',
      mainX: 0.0714,
      mainY: 0.1588,
      sideX: 0.5657,
      sideY: 0.5431,
      items: const <PlacedItem>[],
      type: 'blank',
    );
  }

  static bool isLongNote(String note) {
    return note.length > 30 || '\n'.allMatches(note).length > 3;
  }

  static MiniPageData deriveMiniPage(DiaryEntry entry) {
    final photo = entry.items.where((item) => item.kind == MaterialKind.photo);
    if (photo.isNotEmpty) {
      return MiniPageData(
        kind: MiniPageKind.photo,
        src: photo.first.src,
        rotation: -7,
        tapeColor: const Color(0xFFDBA3B5),
      );
    }
    if (entry.basePhotos) {
      return MiniPageData(
        kind: MiniPageKind.photo,
        src: entry.mainSrc,
        rotation: _photoRotation(entry.type),
        tapeColor:
            entry.type == 'dog'
                ? const Color(0xD9AEBECD)
                : const Color(0xBFDBA3B5),
      );
    }
    final note = entry.items.where((item) => item.kind == MaterialKind.note);
    if (note.isNotEmpty) {
      return MiniPageData(
        kind: MiniPageKind.note,
        text: note.first.text ?? note.first.name,
        rotation: -4,
        backgroundColor: const Color(0xFFEFD4E1),
        tapeColor: const Color(0xFFB2C2D7),
      );
    }
    final sticker = entry.items.where(
      (item) => item.kind == MaterialKind.sticker,
    );
    if (sticker.isNotEmpty) {
      return MiniPageData(
        kind: MiniPageKind.sticker,
        src: sticker.first.src,
        rotation: 5,
        backgroundColor: const Color(0xFFF4E3CB),
        tapeColor: const Color(0xBFDBA3B5),
      );
    }
    if (entry.type == 'note') {
      final text =
          (entry.coverText?.trim().isNotEmpty ?? false)
              ? entry.coverText!
              : '慢慢来';
      return MiniPageData(
        kind: MiniPageKind.note,
        text: text,
        rotation: -4,
        backgroundColor: const Color(0xFFEFD4E1),
        tapeColor: const Color(0xFFB2C2D7),
      );
    }
    if (entry.type == 'sticker') {
      return MiniPageData(
        kind: MiniPageKind.sticker,
        src: entry.mainSrc,
        rotation: 5,
        backgroundColor: const Color(0xFFF4E3CB),
        tapeColor: const Color(0xBFDBA3B5),
      );
    }
    return const MiniPageData(kind: MiniPageKind.blank);
  }

  static double _photoRotation(String type) {
    switch (type) {
      case 'dog':
        return 8;
      case 'picnic':
        return 4;
      case 'flowers':
        return -4;
      default:
        return -7;
    }
  }
}
