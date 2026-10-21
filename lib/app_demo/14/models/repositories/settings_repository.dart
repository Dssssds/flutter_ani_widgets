import 'dart:convert';

import 'package:flutter_x_widgets/app_demo/14/models/services/preferences_service.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';

class SettingsLoadResult {
  final SettingsState state;
  final String? warning;

  const SettingsLoadResult({required this.state, this.warning});
}

/// 独立命名空间与版本号避免干扰其他 Demo 的设置。
class SettingsRepository {
  static const storageKey = 'party_box.demo14.settings';
  static const schemaVersion = 1;
  final PreferencesService _preferences;

  SettingsRepository({PreferencesService? preferencesService}) : _preferences = preferencesService ?? const SharedPreferencesService();

  Future<SettingsLoadResult> load() async {
    try {
      final raw = await _preferences.getString(storageKey);
      if (raw == null) return const SettingsLoadResult(state: SettingsState());
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic> || json['schema'] != schemaVersion || json['settings'] is! Map<String, dynamic>) {
        throw const FormatException('Unsupported settings schema');
      }
      return SettingsLoadResult(state: SettingsState.fromJson(json['settings'] as Map<String, dynamic>));
    } catch (_) {
      return const SettingsLoadResult(state: SettingsState(), warning: '无法读取已保存的设置，已使用默认值。可重试保存当前设置。');
    }
  }

  /// false 与异常同样视为失败，由调用方展示重试入口。
  Future<void> save(SettingsState state) async {
    final success = await _preferences.setString(storageKey, jsonEncode({'schema': schemaVersion, 'settings': state.toJson()}));
    if (!success) throw StateError('Settings were not saved');
  }
}
