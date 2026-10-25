import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferencesService {
  Future<String?> getString(String key);
  Future<bool> setString(String key, String value);
}

class SharedPreferencesService implements PreferencesService {
  const SharedPreferencesService();

  @override
  Future<String?> getString(String key) async => (await SharedPreferences.getInstance()).getString(key);

  @override
  Future<bool> setString(String key, String value) async => (await SharedPreferences.getInstance()).setString(key, value);
}
