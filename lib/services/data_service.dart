import 'dart:convert';
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
  Future<List<ModuleConfig>> getModuleConfigs() async {
    final cache = await _cache;

    final cached = cache.getWithExpiry(AppConstants.keyModuleConfig);
    if (cached != null) {
      try {
        final list = jsonDecode(cached) as List<dynamic>;
        _logger.d('Module configs loaded from cache');
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

    _logger.d('Module configs loaded from fallback');
    return AppConstants.defaultModules
        .map((e) => ModuleConfig.fromJson(e))
        .toList();
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

    _logger.d('Daily content saved for $moduleId');
  }
}