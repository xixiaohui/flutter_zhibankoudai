import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import '../config/constants.dart';
import '../models/module_config.dart';
import '../services/cache_service.dart';

class DataService {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  /// ✅ 单例
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;

  DataService._internal() {
    _cacheFuture = CacheService.instance;
  }

  /// ✅ 用 Future 缓存，避免重复初始化
  late final Future<CacheService> _cacheFuture;

  /// ✅ 获取缓存实例（统一入口）
  Future<CacheService> get _cache async => await _cacheFuture;

  // ================================
  // 模块配置
  // ================================
  Future<List<ModuleConfig>> getModuleConfigs({String locale = 'zh'}) async {
    final cache = await _cache;
    final cacheKey = '${AppConstants.keyModuleConfig}_$locale';

    final cached = cache.getWithExpiry(cacheKey);
    if (cached != null) {
      try {
        final list = jsonDecode(cached) as List<dynamic>;
        _logger.d('Module configs loaded from cache for locale $locale');
        return list
            .map((e) => ModuleConfig.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _logger.e('Cache parse error: $e');
      }
    }

    try {
      final cloudConfigs = await _fetchModuleConfigsFromCloud();
      if (cloudConfigs.isNotEmpty) {
        await cache.setWithExpiry(
          cacheKey,
          jsonEncode(cloudConfigs.map((e) => e.toJson()).toList()),
          const Duration(hours: AppConstants.cacheExpireHours),
        );
        _logger.d('Module configs loaded from cloud');
        return cloudConfigs;
      }
    } catch (e) {
      _logger.e('Cloud fetch error: $e');
    }

    // Try loading from assets
    final assetModules = await _loadModulesFromAssets(locale);
    if (assetModules.isNotEmpty) {
      await cache.setWithExpiry(
        cacheKey,
        jsonEncode(assetModules.map((e) => e.toJson()).toList()),
        const Duration(hours: AppConstants.cacheExpireHours),
      );
      return assetModules;
    }

    // Fallback to zh if locale is not zh
    if (locale != 'zh') {
      _logger.d('Falling back to zh modules for locale $locale');
      return getModuleConfigs(locale: 'zh');
    }

    // Final safety net
    _logger.d('Using empty module fallback');
    return AppConstants.defaultModules
        .map((e) => ModuleConfig.fromJson(e))
        .toList();
  }

  Future<List<ModuleConfig>> _loadModulesFromAssets(String locale) async {
    final path = 'assets/cloudData/modules/modules_$locale.json';
    try {
      final jsonStr = await rootBundle.loadString(path);
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => ModuleConfig.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.w('Failed to load modules from $path: $e');
      return [];
    }
  }

  Future<List<ModuleConfig>> _fetchModuleConfigsFromCloud() async {
    // TODO: 接 CloudBase / API
    return [];
  }

  // ================================
  // 每日内容
  // ================================
  Future<Map<String, dynamic>?> getDailyContent(String moduleId) async {
    final cache = await _cache;

    final cacheKey = '${AppConstants.keyDailyContentPrefix}$moduleId';
    final cached = cache.getWithExpiry(cacheKey);

    if (cached != null) {
      try {
        _logger.d('Daily content for $moduleId from cache');
        return jsonDecode(cached) as Map<String, dynamic>;
      } catch (e) {
        _logger.e('Cache parse error for $moduleId: $e');
      }
    }

    try {
      final cloudContent = await _fetchDailyContentFromCloud(moduleId);
      if (cloudContent != null) {
        await cache.setWithExpiry(
          cacheKey,
          jsonEncode(cloudContent),
          const Duration(hours: AppConstants.cacheExpireHours),
        );
        _logger.d('Daily content for $moduleId from cloud');
        return cloudContent;
      }
    } catch (e) {
      _logger.e('Cloud fetch error for $moduleId: $e');
    }

    return null;
  }

  Future<Map<String, dynamic>?> _fetchDailyContentFromCloud(
    String moduleId,
  ) async {
    // TODO: 接 CloudBase / API
    return null;
  }

  // ================================
  // 保存内容
  // ================================
  Future<void> saveDailyContent(
    String moduleId,
    Map<String, dynamic> content,
  ) async {
    final cache = await _cache;

    final cacheKey = '${AppConstants.keyDailyContentPrefix}$moduleId';

    await cache.setWithExpiry(
      cacheKey,
      jsonEncode(content),
      const Duration(hours: AppConstants.cacheExpireHours),
    );

    // Save to content history for deduplication
    await _addToContentHistory(moduleId, content);

    _logger.d('Daily content saved for $moduleId');
  }

  // ================================
  // 内容历史（用于AI去重）
  // ================================
  static const int _maxHistoryCount = 10;
  static const String _keyContentHistoryPrefix = 'content_history_';

  Future<void> _addToContentHistory(
    String moduleId,
    Map<String, dynamic> content,
  ) async {
    final cache = await _cache;
    final historyKey = '$_keyContentHistoryPrefix$moduleId';
    final history = cache.getJsonList(historyKey) ?? [];

    final entry = {
      'title': content['title']?.toString() ?? '',
      'subtitle': content['subtitle']?.toString() ?? '',
      'category': content['category']?.toString() ?? '',
      'date': DateTime.now().toIso8601String(),
    };

    // Remove existing entry with same title to avoid duplicates in history
    history.removeWhere((e) => e['title'] == entry['title']);

    history.insert(0, entry);

    // Keep only recent history
    if (history.length > _maxHistoryCount) {
      history.removeRange(_maxHistoryCount, history.length);
    }

    await cache.setJsonList(historyKey, history);
    _logger.d('Content history updated for $moduleId (${history.length} entries)');
  }

  Future<List<Map<String, dynamic>>> getRecentContentHistory(String moduleId) async {
    final cache = await _cache;
    final historyKey = '$_keyContentHistoryPrefix$moduleId';
    return cache.getJsonList(historyKey) ?? [];
  }
}