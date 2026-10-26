import 'dart:convert';

import 'package:flutter_x_widgets/app_demo/16/models/diary_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class DiaryRepository {
  Future<Map<String, DiaryEntry>> load();

  Future<void> save(Map<String, DiaryEntry> entries);
}

class SharedPreferencesDiaryRepository implements DiaryRepository {
  const SharedPreferencesDiaryRepository();

  static const storageKey = 'shiye-entries-v1';

  @override
  Future<Map<String, DiaryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return <String, DiaryEntry>{};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return <String, DiaryEntry>{};
      }
      final entries = <String, DiaryEntry>{};
      for (final item in decoded.entries) {
        if (item.value is! Map<String, dynamic>) {
          continue;
        }
        final date = _parseKey(item.key);
        if (date == null) {
          continue;
        }
        try {
          entries[item.key] = DiaryEntry.fromJson(
            item.value as Map<String, dynamic>,
            fallback: date,
          );
        } on Object {
          continue;
        }
      }
      return entries;
    } on Object {
      return <String, DiaryEntry>{};
    }
  }

  @override
  Future<void> save(Map<String, DiaryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      for (final entry in entries.entries) entry.key: entry.value.toJson(),
    };
    await prefs.setString(storageKey, jsonEncode(payload));
  }

  static DateTime? _parseKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) {
      return null;
    }
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }
    return DateTime(year, month, day);
  }
}
