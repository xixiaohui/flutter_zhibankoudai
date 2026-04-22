"import os

# ========= cache_service.dart =========
cache_service = r\"\"\"import 'dart:convert';
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
\"\"\"

# ========= data_service.dart =========
data_service = r\"\"\"import 'dart:convert';
import 'package:logger/logger.dart';
import '../config/constants.dart';
import '../models/module_config.dart';
import '../services/cache_service.dart';

class DataService {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  late final CacheService _cache;

  DataService() {
    _initCache();
  }

  Future<void> _initCache() async {
    _cache = await CacheService.instance;
  }

  Future<List<ModuleConfig>> getModuleConfigs() async {
    await _initCache();
    final cached = _cache.getWithExpiry(AppConstants.keyModuleConfig);
    if (cached != null) {
      try {
        final list = jsonDecode(cached) as List<dynamic>;
        _logger.d('Module configs loaded from cache');
        return list.map((e) => ModuleConfig.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        _logger.e('Cache parse error: $e');
      }
    }
    try {
      final cloudConfigs = await _fetchModuleConfigsFromCloud();
      if (cloudConfigs.isNotEmpty) {
        await _cache.setWithExpiry(
          AppConstants.keyModuleConfig,
          jsonEncode(cloudConfigs.map((e) => e.toJson()).toList()),
          const Duration(hours: AppConstants.cacheExpireHours),
        );
        _logger.d('Module configs loaded from cloud');
        return cloudConfigs;
      }
    } catch (e) {
      _logger.e('Cloud fetch error: $e');
    }
    _logger.d('Module configs loaded from fallback defaults');
    return AppConstants.defaultModules.map((e) => ModuleConfig.fromJson(e)).toList();
  }

  Future<List<ModuleConfig>> _fetchModuleConfigsFromCloud() async {
    // TODO: 对接腾讯云CloudBase数据库
    return [];
  }

  Future<Map<String, dynamic>?> getDailyContent(String moduleId) async {
    await _initCache();
    final cacheKey = '${AppConstants.keyDailyContentPrefix}$moduleId';
    final cached = _cache.getWithExpiry(cacheKey);
    if (cached != null) {
      try {
        _logger.d('Daily content for $moduleId loaded from cache');
        return jsonDecode(cached) as Map<String, dynamic>;
      } catch (e) {
        _logger.e('Cache parse error for $moduleId: $e');
      }
    }
    try {
      final cloudContent = await _fetchDailyContentFromCloud(moduleId);
      if (cloudContent != null) {
        await _cache.setWithExpiry(cacheKey, jsonEncode(cloudContent), const Duration(hours: AppConstants.cacheExpireHours));
        _logger.d('Daily content for $moduleId loaded from cloud');
        return cloudContent;
      }
    } catch (e) {
      _logger.e('Cloud fetch error for $moduleId: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchDailyContentFromCloud(String moduleId) async {
    // TODO: 对接腾讯云CloudBase数据库
    return null;
  }

  Future<void> saveDailyContent(String moduleId, Map<String, dynamic> content) async {
    await _initCache();
    final cacheKey = '${AppConstants.keyDailyContentPrefix}$moduleId';
    await _cache.setWithExpiry(cacheKey, jsonEncode(content), const Duration(hours: AppConstants.cacheExpireHours));
    _logger.d('Daily content saved for $moduleId');
  }
}
\"\"\"

# ========= ai_service.dart =========
ai_service = r\"\"\"import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/constants.dart';
import '../models/daily_content.dart';
import '../models/module_config.dart';
import 'cache_service.dart';
import 'data_service.dart';

class AiService {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  final Dio _dio = Dio();

  static const String _baseUrl = 'https://tcb-api.tencentcloudapi.com';
  static const String _aiPath = '/web/hunyuan/chat';

  Future<DailyContent> generateContent({
    required String moduleId,
    required String prompt,
    required List<FallbackContent> fallback,
  }) async {
    try {
      _logger.d('AI generating content for module: $moduleId');
      final response = await _callHunyuanModel(prompt);
      if (response != null) {
        final content = DailyContent(
          id: '${moduleId}_${DateTime.now().millisecondsSinceEpoch}',
          moduleId: moduleId,
          content: response['content'] ?? '',
          title: response['title'] ?? '',
          subtitle: response['subtitle'] ?? '',
          category: response['category'] ?? '',
          categoryIcon: response['categoryIcon'] ?? '',
          date: DateTime.now(),
          isAiGenerated: true,
        );
        final dataService = DataService();
        await dataService.saveDailyContent(moduleId, content.toJson());
        _logger.d('AI content generated and cached for module: $moduleId');
        return content;
      }
    } catch (e) {
      _logger.e('AI generation failed for module $moduleId: $e');
    }
    return _useFallback(moduleId, fallback);
  }

  Future<Map<String, dynamic>?> _callHunyuanModel(String prompt) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$_aiPath',
        data: {
          'model': 'hunyuan-lite',
          'messages': [
            {'role': 'system', 'content': '你是一个专业内容生成助手，请根据用户的需求生成高质量的内容。返回JSON格式：{\"content\":\"内容\",\"title\":\"标题\",\"subtitle\":\"副标题\",\"category\":\"分类\",\"categoryIcon\":\"图标\"}'},
            {'role': 'user', 'content': prompt},
          ],
          'stream': false,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>?;
          if (message != null) {
            final contentStr = message['content'] as String? ?? '';
            return _parseAiContent(contentStr);
          }
        }
      }
    } catch (e) {
      _logger.e('Hunyuan model call failed: $e');
    }
    return null;
  }

  Map<String, dynamic>? _parseAiContent(String contentStr) {
    try {
      final json = _tryParseJson(contentStr);
      if (json != null) return json;
      return {'content': contentStr, 'title': '', 'subtitle': '', 'category': '', 'categoryIcon': ''};
    } catch (e) {
      _logger.e('Parse AI content failed: $e');
      return null;
    }
  }

  Map<String, dynamic>? _tryParseJson(String str) {
    try {
      return Map<String, dynamic>.from(jsonDecode(str) as Map);
    } catch (_) {
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(str);
      if (jsonMatch != null) {
        try {
          return Map<String, dynamic>.from(jsonDecode(jsonMatch.group(0)!) as Map);
        } catch (_) {}
      }
    }
    return null;
  }

  DailyContent _useFallback(String moduleId, List<FallbackContent> fallback) {
    _logger.d('Using fallback data for module: $moduleId');
    if (fallback.isNotEmpty) {
      final index = DateTime.now().day % fallback.length;
      final fb = fallback[index];
      return DailyContent(
        id: '${moduleId}_fallback_${DateTime.now().millisecondsSinceEpoch}',
        moduleId: moduleId,
        content: fb.content,
        title: fb.title,
        subtitle: fb.subtitle,
        category: fb.category,
        categoryIcon: fb.categoryIcon,
        date: DateTime.now(),
        isAiGenerated: false,
      );
    }
    return DailyContent(
      id: '${moduleId}_default_${DateTime.now().millisecondsSinceEpoch}',
      moduleId: moduleId,
      content: '暂无内容，请稍后再试',
      date: DateTime.now(),
      isAiGenerated: false,
    );
  }
}
\"\"\"

# ========= Write all files =========
files = {
    'lib/services/cache_service.dart': cache_service,
    'lib/services/data_service.dart': data_service,
    'lib/services/ai_service.dart': ai_service,
}

for path, content in files.items():
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: {path}')

print('All service files fixed!')"