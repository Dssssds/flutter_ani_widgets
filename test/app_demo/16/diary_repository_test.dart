import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/16/models/diary_entry.dart';
import 'package:flutter_x_widgets/app_demo/16/models/repositories/diary_repository.dart';
import 'package:flutter_x_widgets/app_demo/16/models/rules/diary_rules.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('损坏的存储内容回退空表', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      SharedPreferencesDiaryRepository.storageKey: '{not-json',
    });

    final loaded = await const SharedPreferencesDiaryRepository().load();
    expect(loaded, isEmpty);
  });

  test('跳过格式错误的条目并保留合法手账', () async {
    final entry = DiaryRules.defaultEntry(DateTime(2026, 9, 27));
    SharedPreferences.setMockInitialValues(<String, Object>{
      SharedPreferencesDiaryRepository.storageKey: jsonEncode(<String, Object>{
        '2026-09-27': entry.toJson(),
        'bad-key': <String, Object>{'title': 'x'},
        '2026-09-28': 'not a map',
        '2026-13-01': <String, Object>{'title': 'bad date'},
      }),
    });

    final loaded = await const SharedPreferencesDiaryRepository().load();
    expect(loaded.keys, <String>['2026-09-27']);
    expect(loaded['2026-09-27']!.title, '我的小小日常');
  });

  test('保存后可重新读取', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    const store = SharedPreferencesDiaryRepository();
    final entry = DiaryRules.defaultEntry(
      DateTime(2026, 10, 4),
    ).copyWith(title: '保存过的');

    await store.save(<String, DiaryEntry>{'2026-10-04': entry});
    final loaded = await const SharedPreferencesDiaryRepository().load();
    expect(loaded['2026-10-04']!.title, '保存过的');
  });
}
