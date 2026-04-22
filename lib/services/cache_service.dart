import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class CacheService {
  static CacheService? _instance;
  static SharedPreferences? _prefs;
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  CacheService._();

  static Future<CacheService> get instance async {
    if (_instance != null) return _instance!;
    _instance = CacheService._();
    _prefs = await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<bool> setString(String key, String value) async {
    _logger.d('Cache SET: $key');
    return _prefs!.setString(key, value);
  }

  String? getString(String key) {
    return _prefs!.getString(key);
  }

  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final str = getString(key);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Cache JSON parse error: $key, $e');
      return null;
    }
  }

  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    return setString(key, jsonEncode(value));
  }

  List<Map<String, dynamic>>? getJsonList(String key) {
    final str = getString(key);
    if (str == null) return null;
    try {
      final list = jsonDecode(str) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      _logger.e('Cache JSON List parse error: $key, $e');
      return null;
    }
  }

  Future<bool> setWithExpiry(String key, String value, Duration expiry) async {
    final expireAt = DateTime.now().add(expiry).millisecondsSinceEpoch;
    await _prefs!.setString('${key}_expire', expireAt.toString());
    return setString(key, value);
  }

  String? getWithExpiry(String key) {
    final expireStr = _prefs!.getString('${key}_expire');
    if (expireStr == null) return getString(key);
    final expireAt = int.tryParse(expireStr) ?? 0;
    if (DateTime.now().millisecondsSinceEpoch > expireAt) {
      remove(key);
      remove('${key}_expire');
      return null;
    }
    return getString(key);
  }

  bool hasValid(String key) {
    return getWithExpiry(key) != null;
  }

  Future<bool> remove(String key) async {
    _logger.d('Cache REMOVE: $key');
    return _prefs!.remove(key);
  }

  Future<bool> clear() async {
    _logger.d('Cache CLEAR ALL');
    return _prefs!.clear();
  }
}