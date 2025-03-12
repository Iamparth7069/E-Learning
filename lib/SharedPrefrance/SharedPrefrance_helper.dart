import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static final SharedPrefHelper _instance = SharedPrefHelper._internal();
  static SharedPreferences? _preferences;

  factory SharedPrefHelper() {
    return _instance;
  }

  SharedPrefHelper._internal();

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  /// Define static keys
  static const String token = "token";
  static const String userEmail = "userEmail";
  static const String userPassword = "userPassword";


  /// Save String value
  Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  /// Get String value
  String? getString(String key) {
    return _preferences?.getString(key);
  }

  /// Save Boolean value
  Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  /// Get Boolean value
  bool getBool(String key) {
    return _preferences?.getBool(key) ?? false;
  }

  /// Save Integer value
  Future<void> setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  /// Get Integer value
  int getInt(String key) {
    return _preferences?.getInt(key) ?? 0;
  }

  /// Save Double value
  Future<void> setDouble(String key, double value) async {
    await _preferences?.setDouble(key, value);
  }

  /// Get Double value
  double getDouble(String key) {
    return _preferences?.getDouble(key) ?? 0.0;
  }

  /// Remove a specific key
  Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  /// Clear all preferences
  Future<void> clear() async {
    await _preferences?.clear();
  }
}
