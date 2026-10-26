import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/16/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/16/models/diary_entry.dart';
import 'package:flutter_x_widgets/app_demo/16/models/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/rules/diary_rules.dart';

import 'support/fakes.dart';

void main() {
  group('日期规则', () {
    test('key 补零到 YYYY-MM-DD', () {
      expect(entryKey(2026, 9, 7), '2026-09-07');
      expect(entryKey(2026, 10, 4), '2026-10-04');
    });

    test('2026 年 9 月从周二开始，共 31 个格子', () {
      expect(DiaryRules.leadingEmptyDays(2026, 9), 1);
      expect(DiaryRules.daysInMonth(2026, 9), 30);
      expect(DiaryRules.calendarCellCount(2026, 9), 31);
    });

    test('未来日期判断忽略时分秒', () {
      final today = DateTime(2026, 10, 4);
      expect(DiaryRules.isFuture(DateTime(2026, 10, 4), today), isFalse);
      expect(
        DiaryRules.isFuture(DateTime(2026, 10, 4, 23, 59), today),
        isFalse,
      );
      expect(DiaryRules.isFuture(DateTime(2026, 10, 5), today), isTrue);
      expect(DiaryRules.isFuture(DateTime(2026, 9, 30), today), isFalse);
    });

    test('默认条目与规格 5.3 一致', () {
      final date = DateTime(2026, 10, 7);
      final entry = DiaryRules.defaultEntry(date);
      expect(entry.key, '2026-10-07');
      expect(entry.weekday, '星期三');
      expect(entry.mood, '好心情');
      expect(entry.title, '我的小小日常');
      expect(entry.note, '今天，想留下一点喜欢。');
      expect(entry.basePhotos, isFalse);
      expect(entry.mainSrc, 'assets/photos/cafe.webp');
      expect(entry.mainCaption, '留下一点喜欢');
      expect(entry.sideSrc, 'assets/photos/dog.webp');
      expect(entry.sideCaption, '偶遇一位小朋友');
      expect(entry.mainX, closeTo(0.0714, 1e-9));
      expect(entry.mainY, closeTo(0.1588, 1e-9));
      expect(entry.sideX, closeTo(0.5657, 1e-9));
      expect(entry.sideY, closeTo(0.5431, 1e-9));
      expect(entry.items, isEmpty);
      expect(entry.type, 'blank');
      expect(entry.coverText, isNull);
    });

    test('长正文判断使用字数与换行数', () {
      expect(DiaryRules.isLongNote('短句'), isFalse);
      expect(DiaryRules.isLongNote('一' * 30), isFalse);
      expect(DiaryRules.isLongNote('一' * 31), isTrue);
      expect(DiaryRules.isLongNote('一\n二\n三\n四'), isFalse);
      expect(DiaryRules.isLongNote('一\n二\n三\n四\n五'), isTrue);
    });
  });

  group('拖动边界', () {
    test('右侧最大 x 使用未旋转尺寸', () {
      final x = DiaryRules.clampPosition(
        origin: 0.9,
        deltaPx: 100,
        paperExtent: 350,
        itemExtent: 124,
      );
      expect(x, closeTo(1 - 124 / 350, 1e-9));
    });

    test('不会超出左边界', () {
      final x = DiaryRules.clampPosition(
        origin: 0.1,
        deltaPx: -100,
        paperExtent: 350,
        itemExtent: 124,
      );
      expect(x, 0);
    });

    test('纸张宽度无效时保持原位', () {
      final x = DiaryRules.clampPosition(
        origin: 0.4,
        deltaPx: 10,
        paperExtent: 0,
        itemExtent: 124,
      );
      expect(x, 0.4);
    });
  });

  group('种子数据', () {
    late SeedData seed;

    setUpAll(() async {
      seed = await loadSeedData();
    });

    test('共 21 条：九月 17 条、十月 4 条', () {
      expect(seed.entries.length, 21);
      final september = seed.entries.keys.where(
        (key) => key.startsWith('2026-09-'),
      );
      final october = seed.entries.keys.where(
        (key) => key.startsWith('2026-10-'),
      );
      expect(september.length, 17);
      expect(october.length, 4);
    });

    test('素材目录数量与规格一致', () {
      final catalog = seed.catalog;
      expect(catalog.itemsFor(MaterialCategory.sticker).length, 6);
      expect(catalog.itemsFor(MaterialCategory.tape).length, 6);
      expect(catalog.itemsFor(MaterialCategory.note).length, 6);
      expect(catalog.itemsFor(MaterialCategory.photo).length, 4);
      expect(catalog.noteTrayColor, '#F3DEB2');
      expect(catalog.infoFor(MaterialCategory.note).unit, '枚');
      expect(catalog.infoFor(MaterialCategory.photo).unit, '张');
    });

    test('便签显示文字保留换行', () {
      final notes = seed.catalog.itemsFor(MaterialCategory.note);
      final texts = <String, String?>{
        for (final note in notes) note.name: note.text,
      };
      expect(texts['好喜欢'], '好喜欢');
      expect(texts['慢慢来'], '慢慢来');
      expect(texts['今日份开心'], '今日份\n开心');
      expect(texts['给自己放个假'], '给自己\n放个假');
      expect(texts['天气很好'], '天气\n很好');
      expect(texts['记得这一天'], '记得\n这一天');
    });

    test('上传照片的粘贴默认值与抽屉照片分开', () {
      final catalog = seed.catalog;
      final drawerPhoto = catalog.defaultFor(MaterialKind.photo);
      expect(drawerPhoto.x, closeTo(0.52, 1e-9));
      expect(drawerPhoto.y, closeTo(0.49, 1e-9));
      expect(drawerPhoto.rotation, -9);
      expect(catalog.uploadedPhotoDefault.x, closeTo(0.45, 1e-9));
      expect(catalog.uploadedPhotoDefault.y, closeTo(0.45, 1e-9));
      expect(catalog.uploadedPhotoDefault.rotation, 5);
    });
  });

  group('DiaryEntry JSON', () {
    test('往返保留上传照片、素材、位置与角度', () {
      final source = <String, dynamic>{
        'year': 2026,
        'month': 10,
        'day': 4,
        'weekday': '星期日',
        'mood': '被治愈了',
        'title': '有风的下午',
        'note': '咖啡慢慢喝。\n阳光和小狗，\n都刚刚好。',
        'basePhotos': true,
        'mainSrc': 'assets/photos/cafe.webp',
        'mainCaption': '巷子里的慢时光',
        'sideSrc': 'assets/photos/dog.webp',
        'sideCaption': '偶遇一位小朋友',
        'mainPosition': <String, dynamic>{'x': 0.12, 'y': 0.2},
        'sidePosition': <String, dynamic>{'x': 0.61, 'y': 0.57},
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'photo-1',
            'kind': 'photo',
            'name': '新照片',
            'src': '/data/user/0/app/files/photos/abc.jpg',
            'x': 0.45,
            'y': 0.45,
            'rotation': 5.0,
          },
          <String, dynamic>{
            'id': 'note-1',
            'kind': 'note',
            'name': '天气很好',
            'text': '天气\n很好',
            'color': '#DCE2E8',
            'x': 0.57,
            'y': 0.61,
            'rotation': -9.0,
          },
        ],
        'type': 'cafe',
        'coverText': '慢慢来',
      };

      final entry = DiaryEntry.fromJson(roundTrip(source));
      expect(entry.key, '2026-10-04');
      expect(entry.mood, '被治愈了');
      expect(entry.mainX, 0.12);
      expect(entry.sideY, 0.57);
      expect(entry.items.length, 2);
      expect(entry.items.first.kind, MaterialKind.photo);
      expect(entry.items.first.src, '/data/user/0/app/files/photos/abc.jpg');
      expect(entry.items.first.rotation, 5);
      expect(entry.items.last.text, '天气\n很好');
      expect(entry.items.last.color, '#DCE2E8');
      expect(entry.coverText, '慢慢来');
      expect(roundTrip(entry.toJson()), roundTrip(source));
    });

    test('缺失字段使用默认值，未知字段被忽略', () {
      final entry = DiaryEntry.fromJson(<String, dynamic>{
        'year': 2026,
        'month': 11,
        'day': 2,
        'unexpected': <String, dynamic>{'anything': true},
        'mainPosition': <String, dynamic>{'x': 0.3},
      });
      expect(entry.weekday, '星期一');
      expect(entry.mood, '好心情');
      expect(entry.title, '我的小小日常');
      expect(entry.basePhotos, isFalse);
      expect(entry.mainX, 0.3);
      expect(entry.mainY, closeTo(0.1588, 1e-9));
      expect(entry.items, isEmpty);
      expect(entry.type, 'blank');
    });

    test('deepCopy 允许独立修改素材列表', () {
      final entry = DiaryRules.defaultEntry(DateTime(2026, 10, 4));
      final copy = entry.deepCopy();
      expect(copy.key, entry.key);
      expect(copy.items, isEmpty);
      expect(identical(copy.items, entry.items), isFalse);
    });
  });
}
