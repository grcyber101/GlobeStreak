import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService(this._preferences);

  final SharedPreferences _preferences;

  static Future<LocalStorageService> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalStorageService(preferences);
  }

  int getInt(String key, {int fallback = 0}) =>
      _preferences.getInt(key) ?? fallback;

  double getDouble(String key, {double fallback = 0}) =>
      _preferences.getDouble(key) ?? fallback;

  bool getBool(String key, {bool fallback = false}) =>
      _preferences.getBool(key) ?? fallback;

  Future<void> setInt(String key, int value) => _preferences.setInt(key, value);

  Future<void> setDouble(String key, double value) =>
      _preferences.setDouble(key, value);

  Future<void> setBool(String key, bool value) =>
      _preferences.setBool(key, value);
}
