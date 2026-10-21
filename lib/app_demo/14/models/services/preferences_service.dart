import 'package:shared_preferences/shared_preferences.dart';

/// 存储边界可替换，测试不需要平台插件。
abstract class PreferencesService {
  Future<String?> getString(String key);
  Future<bool> setString(String key, String value);
}

/// 使用 legacy API，保留写入是否成功的返回值。
class SharedPreferencesService implements PreferencesService {
  const SharedPreferencesService();

  @override
  Future<String?> getString(String key) async => (await SharedPreferences.getInstance()).getString(key);

  @override
  Future<bool> setString(String key, String value) async => (await SharedPreferences.getInstance()).setString(key, value);
}
