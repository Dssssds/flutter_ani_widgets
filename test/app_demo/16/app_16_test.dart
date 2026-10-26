import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/16/app_16.dart';
import 'package:flutter_x_widgets/app_demo/16/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/16/models/app_screen.dart';
import 'package:flutter_x_widgets/app_demo/16/models/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/view_models/diary_controller.dart';
import 'package:flutter_x_widgets/app_demo/16/screens/journal_screen.dart';
import 'package:flutter_x_widgets/app_demo/16/screens/material_drawer_screen.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_bottom_nav.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/journal/editor_toolbar.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/journal/paper_canvas.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/journal/placed_item_view.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';
import 'package:flutter_x_widgets/main.dart';

import 'support/fakes.dart';

void main() {
  late SeedData seed;

  setUpAll(() async {
    seed = await loadSeedData();
  });

  Future<_Harness> pumpApp(
    WidgetTester tester, {
    MemoryDiaryRepository? repository,
    FakePhotoService? photos,
    Size size = const Size(390, 844),
    double textScale = 1,
    bool reduceMotion = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    if (reduceMotion) {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
    }

    final resolvedRepository = repository ?? MemoryDiaryRepository();
    final controller = buildController(
      seed: seed,
      repository: resolvedRepository,
      photos: photos,
    );
    addTearDown(controller.dispose);
    addTearDown(() => tester.pumpWidget(const SizedBox()));

    await tester.pumpWidget(App16(controller: controller));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    return _Harness(controller, resolvedRepository);
  }

  Finder navItem(String label) => find.descendant(
    of: find.byType(App16BottomNav),
    matching: find.text(label),
  );

  Finder drawerText(String text) => find.descendant(
    of: find.byType(MaterialDrawerScreen),
    matching: find.text(text),
  );

  Future<void> flushToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  group('首屏', () {
    testWidgets('显示日期、标题、两张拍立得与心情', (tester) async {
      await pumpApp(tester);

      expect(find.text('有风的下午'), findsOneWidget);
      expect(find.text('巷子里的慢时光'), findsOneWidget);
      expect(find.text('偶遇一位小朋友'), findsOneWidget);
      expect(find.text('10 月 · 星期日'), findsOneWidget);
      expect(find.text('2026 年 · 秋日手账'), findsOneWidget);
      expect(find.text('好心情'), findsOneWidget);
      expect(find.text('10.04'), findsOneWidget);
      expect(find.text('保存'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('844 高度下纸面与工具栏无需滚动即可见', (tester) async {
      await pumpApp(tester);

      final navTop = tester.getRect(find.byType(App16BottomNav)).top;
      final toolbarRect = tester.getRect(find.byType(EditorToolbar));
      expect(toolbarRect.bottom, lessThanOrEqualTo(navTop));

      final paperRect = tester.getRect(find.byType(PaperCanvas));
      expect(paperRect.bottom, lessThanOrEqualTo(toolbarRect.top));

      final scroll = find.descendant(
        of: find.byType(JournalScreen),
        matching: find.byType(Scrollable),
      );
      expect(tester.state<ScrollableState>(scroll).position.maxScrollExtent, 0);
    });

    testWidgets('窄屏 320×700 与 1.2 倍字号下可滚动且无溢出', (tester) async {
      await pumpApp(tester, size: const Size(320, 700), textScale: 1.2);

      expect(tester.takeException(), isNull);
      expect(find.text('有风的下午'), findsOneWidget);

      await tester.tap(navItem('素材'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(drawerText('秋日小事'), findsOneWidget);

      await tester.tap(navItem('翻看'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('翻翻手账'), findsOneWidget);
    });
  });

  group('心情与撤销', () {
    testWidgets('切换心情后文案与图标同步，撤销可恢复', (tester) async {
      final harness = await pumpApp(tester);

      await tester.tap(find.byKey(const ValueKey<String>('app16-mood')));
      await tester.pump();
      expect(find.text('被治愈了'), findsOneWidget);
      expect(harness.controller.entry.mood, '被治愈了');

      await tester.tap(find.byKey(const ValueKey<String>('app16-undo')));
      await tester.pump();
      expect(find.text('好心情'), findsOneWidget);
      expect(harness.controller.entry.mood, '好心情');

      await flushToast(tester);
    });

    testWidgets('无历史时撤销不改变内容', (tester) async {
      final harness = await pumpApp(tester);
      expect(harness.controller.history, isEmpty);

      await tester.tap(find.byKey(const ValueKey<String>('app16-undo')));
      await tester.pump();
      expect(harness.controller.history, isEmpty);
      expect(harness.controller.entry.mood, '好心情');
      expect(find.text('好心情'), findsOneWidget);
    });
  });

  group('素材抽屉', () {
    testWidgets('选贴纸贴到手账后回到纸面，撤销移除', (tester) async {
      final harness = await pumpApp(tester);

      await tester.tap(navItem('素材'));
      await tester.pumpAndSettle();
      expect(find.text('素材抽屉'), findsOneWidget);
      expect(drawerText('秋日小事'), findsOneWidget);
      expect(drawerText('秋日贴纸'), findsOneWidget);
      expect(drawerText('6 枚'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('flower')));
      await tester.pump();
      expect(harness.controller.selectedMaterial?.id, 'flower');

      await tester.tap(find.byKey(const ValueKey<String>('app16-paste')));
      await tester.pumpAndSettle();

      expect(harness.controller.screen, AppScreen.journal);
      expect(harness.controller.entry.items.length, 1);
      expect(harness.controller.entry.items.single.kind, MaterialKind.sticker);
      expect(find.byType(PlacedItemView), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('app16-undo')));
      await tester.pump();
      expect(harness.controller.entry.items, isEmpty);
      expect(find.byType(PlacedItemView), findsNothing);

      await flushToast(tester);
    });

    testWidgets('四类素材的标题、数量与素材数量正确', (tester) async {
      await pumpApp(tester);
      await tester.tap(navItem('素材'));
      await tester.pumpAndSettle();

      expect(drawerText('秋日小事'), findsOneWidget);
      expect(drawerText('秋日贴纸'), findsOneWidget);
      expect(drawerText('6 枚'), findsOneWidget);
      expect(drawerText('小花开了'), findsWidgets);

      await tester.tap(drawerText('胶带'));
      await tester.pumpAndSettle();
      expect(drawerText('纸上的温柔'), findsOneWidget);
      expect(drawerText('把喜欢固定住'), findsOneWidget);
      expect(drawerText('6 枚'), findsOneWidget);
      expect(drawerText('莓果条纹'), findsWidgets);

      await tester.tap(drawerText('便签'));
      await tester.pumpAndSettle();
      expect(drawerText('随手写写'), findsOneWidget);
      expect(drawerText('留一张小纸条'), findsOneWidget);
      expect(drawerText('6 枚'), findsOneWidget);

      await tester.tap(drawerText('照片'));
      await tester.pumpAndSettle();
      expect(drawerText('今天的光'), findsOneWidget);
      expect(drawerText('镜头里的日常'), findsOneWidget);
      expect(drawerText('4 张'), findsOneWidget);
      expect(drawerText('买了一束花'), findsWidgets);
    });

    testWidgets('宽屏居中时飞入起点与素材缩略图对齐', (tester) async {
      final harness = await pumpApp(tester, size: const Size(900, 900));

      await tester.tap(navItem('素材'));
      await tester.pumpAndSettle();
      final tileRect = tester.getRect(
        find.byKey(const ValueKey<String>('flower')),
      );

      await tester.tap(find.byKey(const ValueKey<String>('flower')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('app16-paste')));
      await tester.pump();

      expect(harness.controller.flyingRequest, isNotNull);
      final flyingRect = tester.getRect(
        find.byKey(const ValueKey<String>('app16-flying-sticker')),
      );
      expect((flyingRect.center.dx - tileRect.center.dx).abs(), lessThan(1));

      await tester.pump(const Duration(milliseconds: 700));
      expect(harness.controller.flyingId, isNull);
      await flushToast(tester);
    });

    testWidgets('减少动态时贴纸直接出现且不创建飞入状态', (tester) async {
      final harness = await pumpApp(tester, reduceMotion: true);
      expect(harness.controller.reduceMotion, isTrue);

      await tester.tap(navItem('素材'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('flower')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('app16-paste')));
      await tester.pumpAndSettle();

      expect(harness.controller.flyingRequest, isNull);
      expect(harness.controller.flyingId, isNull);
      expect(harness.controller.entry.items.length, 1);
      expect(find.byType(PlacedItemView), findsOneWidget);

      await flushToast(tester);
    });
  });

  group('文字弹窗', () {
    testWidgets('空标题与空正文不可提交', (tester) async {
      final harness = await pumpApp(tester);

      await tester.tap(find.text('文字'));
      await tester.pumpAndSettle();
      expect(find.text('写一点今天'), findsOneWidget);

      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(2));
      await tester.enterText(fields.at(0), '');
      await tester.enterText(fields.at(1), '');
      await tester.pump();

      await tester.tap(find.text('写到纸上'));
      await tester.pump();
      expect(find.text('写一点今天'), findsOneWidget);
      expect(harness.controller.entry.title, '有风的下午');
      expect(harness.controller.history, isEmpty);
    });

    testWidgets('合法输入应用后纸面更新并关闭弹窗', (tester) async {
      final harness = await pumpApp(tester);

      await tester.tap(find.text('文字'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '新的标题');
      await tester.enterText(fields.at(1), '今天也有好好生活。');
      await tester.pump();
      await tester.tap(find.text('写到纸上'));
      await tester.pumpAndSettle();

      expect(find.text('写一点今天'), findsNothing);
      expect(harness.controller.entry.title, '新的标题');
      expect(harness.controller.entry.note, '今天也有好好生活。');
      expect(find.text('新的标题'), findsOneWidget);
      expect(find.text('今天也有好好生活。'), findsOneWidget);
      expect(harness.controller.history.length, 1);
    });
  });

  group('翻看页', () {
    testWidgets('九月默认选中 27 日并显示 17 天', (tester) async {
      final harness = await pumpApp(tester);

      await tester.tap(navItem('翻看'));
      await tester.pumpAndSettle();

      expect(find.text('翻翻手账'), findsOneWidget);
      expect(find.text('2026 年'), findsOneWidget);
      expect(find.text('九月'), findsOneWidget);
      expect(find.text('写下了 17 天'), findsOneWidget);
      expect(harness.controller.selectedDay, 27);
      expect(find.text('09.27'), findsOneWidget);
    });

    testWidgets('十月未来日期不可选，下月按钮禁用', (tester) async {
      final harness = await pumpApp(tester);
      await tester.tap(navItem('翻看'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey<String>('app16-next-month')));
      await tester.pumpAndSettle();
      expect(find.text('十月'), findsOneWidget);
      expect(find.text('写下了 4 天'), findsOneWidget);
      expect(harness.controller.canGoNextMonth(), isFalse);

      final selected = harness.controller.selectedDay;
      await tester.tap(find.byKey(const ValueKey<String>('app16-day-5')));
      await tester.pump();
      expect(harness.controller.selectedDay, selected);
    });

    testWidgets('点击 9 月 27 日打开正确手账', (tester) async {
      final harness = await pumpApp(tester);
      await tester.tap(navItem('翻看'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('09.27'));
      await tester.pumpAndSettle();

      expect(harness.controller.screen, AppScreen.journal);
      expect(harness.controller.entry.title, '周末，去河边走走');
      expect(find.text('周末，去河边走走'), findsOneWidget);
      expect(find.text('巷子里的慢时光'), findsNothing);
    });
  });

  group('保存', () {
    testWidgets('保存后显示已保存，修改后回到保存', (tester) async {
      final harness = await pumpApp(tester);

      await tester.tap(find.byKey(const ValueKey<String>('app16-save')));
      await tester.pumpAndSettle();
      expect(find.text('已保存'), findsOneWidget);
      expect(harness.repository.saveCount, 1);
      expect(harness.repository.entries['2026-10-04'], isNotNull);

      await tester.tap(find.byKey(const ValueKey<String>('app16-mood')));
      await tester.pump();
      expect(find.text('保存'), findsOneWidget);

      await flushToast(tester);
    });

    testWidgets('保存失败显示错误提示且内容保留', (tester) async {
      final repository = MemoryDiaryRepository()..fail = true;
      final harness = await pumpApp(tester, repository: repository);

      await tester.tap(find.byKey(const ValueKey<String>('app16-save')));
      await tester.pumpAndSettle();

      expect(harness.controller.saveError, isNotEmpty);
      expect(find.textContaining('这一页没能保存'), findsOneWidget);
      expect(find.text('有风的下午'), findsOneWidget);
      expect(find.text('保存'), findsOneWidget);
    });
  });

  group('底部导航', () {
    testWidgets('导航贴底，选中项为实心莓色胶囊且切换时滑动', (tester) async {
      await pumpApp(tester);

      final navRect = tester.getRect(find.byType(App16BottomNav));
      expect(navRect.bottom, 844);
      expect(navRect.top, 844 - 64);

      final indicator = find.byKey(
        const ValueKey<String>('app16-nav-indicator'),
      );
      final pill = tester.widget<DecoratedBox>(
        find.descendant(of: indicator, matching: find.byType(DecoratedBox)),
      );
      expect((pill.decoration as BoxDecoration).color, App16Colors.berry);
      final firstLeft = tester.getRect(indicator).left;

      await tester.tap(navItem('翻看'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      final midLeft = tester.getRect(indicator).left;

      await tester.pumpAndSettle();
      final lastLeft = tester.getRect(indicator).left;

      expect(midLeft, greaterThan(firstLeft));
      expect(lastLeft, greaterThan(midLeft));
      expect(find.text('翻翻手账'), findsOneWidget);
    });

    testWidgets('高于设计稿的屏幕铺满画布，导航仍贴底', (tester) async {
      await pumpApp(tester, size: const Size(390, 932));

      final navRect = tester.getRect(find.byType(App16BottomNav));
      expect(navRect.bottom, 932);
      expect(navRect.top, 932 - 64);
    });
  });

  test('APP-16 已注册为全屏演示', () {
    final entry = HomeScreen().demoApps.singleWhere(
      (example) => example.title == 'APP-16(拾页)',
    );
    expect(entry.isFullScreen, isTrue);
    expect(entry.builder, isNotNull);
  });
}

class _Harness {
  const _Harness(this.controller, this.repository);

  final DiaryController controller;
  final MemoryDiaryRepository repository;
}
