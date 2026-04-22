import 'dart:convert';
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