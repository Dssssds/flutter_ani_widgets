import 'dart:ui' show Rect;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/16/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/16/models/app_screen.dart';
import 'package:flutter_x_widgets/app_demo/16/models/diary_entry.dart';
import 'package:flutter_x_widgets/app_demo/16/models/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/rules/diary_rules.dart';
import 'package:flutter_x_widgets/app_demo/16/models/view_models/diary_controller.dart';

import 'support/fakes.dart';

void main() {
  late SeedData seed;

  setUpAll(() async {
    seed = await loadSeedData();
  });

  Future<DiaryController> ready({
    MemoryDiaryRepository? repository,
    FakePhotoService? photos,
  }) async {
    final controller = buildController(
      seed: seed,
      repository: repository,
      photos: photos,
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    return controller;
  }

  group('初始化', () {
    test('默认进入 2026-10-04 有风的下午', () async {
      final controller = await ready();
      expect(controller.ready, isTrue);
      expect(controller.screen, AppScreen.journal);
      expect(controller.entry.key, '2026-10-04');
      expect(controller.entry.title, '有风的下午');
      expect(controller.entry.mood, '好心情');
      expect(controller.entry.basePhotos, isTrue);
      expect(controller.saved, isFalse);
      expect(controller.viewYear, 2026);
      expect(controller.viewMonth, 9);
      expect(controller.selectedDay, 27);
      expect(controller.selectedMaterial?.id, 'flower');
    });

    test('读取已存条目并标记为已保存', () async {
      final stored = DiaryRules.defaultEntry(DateTime(2026, 10, 4));
      final repository = MemoryDiaryRepository(<String, DiaryEntry>{
        '2026-10-04': stored.copyWith(title: '存过的标题'),
      });
      final controller = await ready(repository: repository);
      expect(controller.entry.title, '存过的标题');
      expect(controller.saved, isTrue);
    });

    test('无种子日期使用默认空白页', () async {
      final controller = await ready();
      controller.loadEntry(2026, 9, 7);
      expect(controller.entry.key, '2026-09-07');
      expect(controller.entry.type, 'blank');
      expect(controller.entry.basePhotos, isFalse);
      expect(controller.entry.title, '我的小小日常');
      expect(controller.history, isEmpty);
      expect(controller.saved, isFalse);
    });
  });

  group('月份数据', () {
    test('九月 17 天、十月 4 天、其他月份 0 天', () async {
      final controller = await ready();
      expect(controller.entryCountForMonth(2026, 9), 17);
      expect(controller.entryCountForMonth(2026, 10), 4);
      expect(controller.entryCountForMonth(2026, 11), 0);
    });

    test('保存覆盖同日期种子但不重复计数', () async {
      final repository = MemoryDiaryRepository();
      final controller = await ready(repository: repository);
      controller.loadEntry(2026, 9, 27);
      expect(controller.applyText('新的标题', '新的正文。'), isTrue);
      await controller.saveEntry();

      expect(controller.saved, isTrue);
      expect(repository.saveCount, 1);
      expect(repository.entries.containsKey('2026-09-27'), isTrue);
      expect(controller.entryCountForMonth(2026, 9), 17);
      expect(controller.entryForDate(2026, 9, 27)?.title, '新的标题');
      expect(controller.selectedEntry?.title, '新的标题');
    });

    test('月份切换会选中当月最后一个有记录日', () async {
      final controller = await ready();
      controller.nextMonth();
      expect(controller.viewMonth, 10);
      expect(controller.selectedDay, 4);
      expect(controller.canGoNextMonth(), isFalse);

      controller.nextMonth();
      expect(controller.viewMonth, 10);

      controller.previousMonth();
      expect(controller.viewMonth, 9);
      expect(controller.selectedDay, 30);
    });

    test('未来日期不可选，过去日期可选', () async {
      final controller = await ready();
      controller.nextMonth();
      final selected = controller.selectedDay;
      controller.selectDay(5);
      expect(controller.selectedDay, selected);
      expect(controller.isFutureDay(5), isTrue);
      expect(controller.isFutureDay(4), isFalse);

      controller.selectDay(2);
      expect(controller.selectedDay, 2);
    });
  });

  group('撤销与保存', () {
    test('撤销栈最多保留 15 步并丢弃最早记录', () async {
      final controller = await ready();
      for (var index = 0; index < 20; index++) {
        controller.toggleMood();
      }
      expect(controller.history.length, DiaryRules.undoLimit);
      expect(controller.entry.mood, '好心情');
      expect(controller.history.first.mood, '被治愈了');
      expect(controller.history.last.mood, '被治愈了');
    });

    test('撤销后 saved 回到 false', () async {
      final controller = await ready();
      await controller.saveEntry();
      expect(controller.saved, isTrue);
      controller.toggleMood();
      expect(controller.saved, isFalse);
      controller.undo();
      expect(controller.saved, isFalse);
      expect(controller.entry.mood, '好心情');
      expect(controller.toast, '已撤销上一次修改');
    });

    test('保存失败保留内容并给出提示', () async {
      final repository = MemoryDiaryRepository()..fail = true;
      final controller = await ready(repository: repository);
      await controller.saveEntry();
      expect(controller.saving, isFalse);
      expect(controller.saved, isFalse);
      expect(controller.saveError, isNotEmpty);
      expect(controller.entry.title, '有风的下午');
    });

    test('连续点击保存只写入一次', () async {
      final repository = MemoryDiaryRepository();
      final controller = await ready(repository: repository);
      final first = controller.saveEntry();
      final second = controller.saveEntry();
      await Future.wait(<Future<void>>[first, second]);
      expect(repository.saveCount, 1);
    });

    test('重启后可从存储恢复', () async {
      final repository = MemoryDiaryRepository();
      final controller = await ready(repository: repository);
      expect(controller.applyText('重启标题', '重启后还在这里。'), isTrue);
      await controller.saveEntry();

      final restarted = await ready(repository: repository);
      expect(restarted.entry.title, '重启标题');
      expect(restarted.entry.note, '重启后还在这里。');
      expect(restarted.saved, isTrue);
    });
  });

  group('素材与照片', () {
    test('贴入胶带使用默认位置并回到手账，撤销可移除', () async {
      final controller = await ready();
      controller.openDrawer(MaterialCategory.tape);
      expect(controller.screen, AppScreen.drawer);
      final tape = controller.catalog.itemsFor(MaterialCategory.tape).first;
      controller.selectMaterial(tape, Rect.zero);
      controller.pasteMaterial(tape, fromRect: Rect.zero);

      expect(controller.screen, AppScreen.journal);
      expect(controller.entry.items.length, 1);
      final item = controller.entry.items.single;
      expect(item.kind, MaterialKind.tape);
      expect(item.id, isNotEmpty);
      expect(item.x, closeTo(0.35, 1e-9));
      expect(item.y, closeTo(0.59, 1e-9));
      expect(item.rotation, -9);

      controller.undo();
      expect(controller.entry.items, isEmpty);
    });

    test('贴纸飞入仅在减少动态关闭且有起点时触发', () async {
      final controller = await ready();
      controller.reduceMotion = false;
      controller.paperRectProvider =
          () => const Rect.fromLTWH(20, 100, 350, 510);
      final sticker =
          controller.catalog.itemsFor(MaterialCategory.sticker).first;
      controller.pasteMaterial(
        sticker,
        fromRect: const Rect.fromLTWH(30, 500, 83, 83),
      );
      expect(controller.flyingRequest, isNotNull);
      expect(controller.flyingId, controller.entry.items.single.id);
      expect(controller.toast, isEmpty);

      controller.finishFlying();
      expect(controller.flyingRequest, isNull);
      expect(controller.flyingId, isNull);
      expect(controller.toast, '已贴上，按住可以移动');
    });

    test('减少动态时贴纸直接出现', () async {
      final controller = await ready();
      controller.reduceMotion = true;
      controller.paperRectProvider =
          () => const Rect.fromLTWH(20, 100, 350, 510);
      final sticker =
          controller.catalog.itemsFor(MaterialCategory.sticker).first;
      controller.pasteMaterial(
        sticker,
        fromRect: const Rect.fromLTWH(30, 500, 83, 83),
      );
      expect(controller.flyingRequest, isNull);
      expect(controller.flyingId, isNull);
      expect(controller.entry.items.length, 1);
      expect(controller.toast, '已贴上，按住可以移动');
    });

    test('上传照片使用应用目录路径与独立默认位置', () async {
      final photos = FakePhotoService(
        nextPath: '/documents/photos/uploaded.jpg',
      );
      final controller = await ready(photos: photos);
      await controller.uploadPhoto();
      final item = controller.entry.items.single;
      expect(photos.calls, 1);
      expect(item.kind, MaterialKind.photo);
      expect(item.src, '/documents/photos/uploaded.jpg');
      expect(item.x, closeTo(0.45, 1e-9));
      expect(item.y, closeTo(0.45, 1e-9));
      expect(item.rotation, 5);
      expect(controller.toast, '照片已放好，按住可以移动');

      controller.undo();
      expect(controller.entry.items, isEmpty);
    });

    test('上传失败给出 Toast 且不改动纸面', () async {
      final photos = FakePhotoService(failure: true);
      final controller = await ready(photos: photos);
      await controller.uploadPhoto();
      expect(controller.entry.items, isEmpty);
      expect(controller.toast, '这张照片没有读出来，换一张试试');
    });

    test('取消选择不改动纸面', () async {
      final photos = FakePhotoService();
      final controller = await ready(photos: photos);
      await controller.uploadPhoto();
      expect(photos.calls, 1);
      expect(controller.entry.items, isEmpty);
    });
  });

  group('文字与心情', () {
    test('空标题或空正文不可提交', () async {
      final controller = await ready();
      expect(controller.applyText('   ', '有正文'), isFalse);
      expect(controller.applyText('有标题', '  '), isFalse);
      expect(controller.entry.title, '有风的下午');
      expect(controller.history, isEmpty);
    });

    test('提交后去除首尾空白并记录历史', () async {
      final controller = await ready();
      expect(controller.applyText('  新的标题  ', '  新的正文。  '), isTrue);
      expect(controller.entry.title, '新的标题');
      expect(controller.entry.note, '新的正文。');
      expect(controller.history.length, 1);
      expect(controller.saved, isFalse);
    });

    test('心情在好心情与被治愈了之间切换', () async {
      final controller = await ready();
      controller.toggleMood();
      expect(controller.entry.mood, '被治愈了');
      controller.toggleMood();
      expect(controller.entry.mood, '好心情');
      expect(controller.history.length, 2);
    });
  });

  group('切换日期', () {
    test('切回今天恢复原条目并清空历史', () async {
      final controller = await ready();
      controller.toggleMood();
      expect(controller.history, isNotEmpty);
      controller.loadEntry(2026, 9, 27);
      expect(controller.entry.title, '周末，去河边走走');
      expect(controller.history, isEmpty);

      controller.goToday();
      expect(controller.entry.key, '2026-10-04');
      expect(controller.entry.mood, '被治愈了');
    });

    test('切换日期保留内存草稿', () async {
      final controller = await ready();
      controller.toggleMood();
      controller.loadEntry(2026, 9, 27);
      controller.goToday();
      expect(controller.entry.mood, '被治愈了');
      expect(controller.saved, isFalse);
    });

    test('拖动素材只更新对应条目位置', () async {
      final controller = await ready();
      final tape = controller.catalog.itemsFor(MaterialCategory.tape).first;
      controller.pasteMaterial(tape);
      final id = controller.entry.items.single.id;
      controller.movePlaced(id, 0.2, 0.3);
      expect(controller.entry.items.single.x, 0.2);
      expect(controller.entry.items.single.y, 0.3);
    });

    test('拍立得位置可独立更新', () async {
      final controller = await ready();
      controller.movePhoto(PhotoSlot.main, 0.15, 0.25);
      controller.movePhoto(PhotoSlot.side, 0.6, 0.62);
      expect(controller.entry.mainX, 0.15);
      expect(controller.entry.mainY, 0.25);
      expect(controller.entry.sideX, 0.6);
      expect(controller.entry.sideY, 0.62);
    });
  });
}
