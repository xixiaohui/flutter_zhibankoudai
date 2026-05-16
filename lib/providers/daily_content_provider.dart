import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/utils/module.dart' as utils show Module, defaultModuleConfig;

import '../models/module_config.dart';
import '../models/daily_content.dart';
import '../services/data_service.dart';
import '../services/ai_service.dart';

/// 每日内容状态管理
class DailyContentProvider extends ChangeNotifier {
  final DataService _dataService = DataService();
  final AiService _aiService = AiService();

  /// 各模块的内容缓存 moduleId -> DailyContent
  final Map<String, DailyContent> _contents = {};
  Map<String, DailyContent> get contents => _contents;

  /// 各模块加载状态 moduleId -> isLoading
  final Map<String, bool> _loadingMap = {};
  bool isLoading(String moduleId) => _loadingMap[moduleId] ?? false;

  /// 各模块AI生成状态
  final Map<String, bool> _generatingMap = {};
  bool isGenerating(String moduleId) => _generatingMap[moduleId] ?? false;

  /// 获取指定模块的每日内容
  DailyContent? getContent(String moduleId) => _contents[moduleId];

  /// 加载模块内容
  /// 流程：检查内存缓存 → 本地缓存 → 云端数据库 → AI生成 → 兜底数据
  Future<void> loadContent(ModuleConfig module) async {
    // 内存缓存命中
    if (_contents.containsKey(module.id)) return;

    _loadingMap[module.id] = true;
    notifyListeners();

    try {
      // 1. 使用兜底数据
      _contents[module.id] = _useFallback(module);

      if (module.generatePrompt != null && module.generatePrompt!.isNotEmpty) {
        // 2. 尝试从本地缓存/云端获取
        final cachedData = await _dataService.getDailyContent(module.id);
        if (cachedData != null) {
          _contents[module.id] = DailyContent.fromJson(cachedData);
          _loadingMap[module.id] = false;
          notifyListeners();

          return;
        }
      } else {
        // 3. 尝试AI生成
        final aiContent = await _aiService.generateContent(
          moduleId: module.id,
          prompt: module.generatePrompt!,
          fallback: module.fallback,
        );
        _contents[module.id] = aiContent;
      }
    } catch (e) {
      // 出错时使用兜底数据
      _contents[module.id] = _useFallback(module);
    }

    _loadingMap[module.id] = false;
    notifyListeners();
  }

  /// AI刷新内容（用户手动触发）
  Future<void> refreshWithAi(ModuleConfig module, {String locale = 'zh'}) async {
    _generatingMap[module.id] = true;
    notifyListeners();

    try {
      if (module.generatePrompt != null && module.generatePrompt!.isNotEmpty) {
        final aiContent = await _aiService.generateContent(
          moduleId: module.id,
          prompt: module.generatePrompt!,
          fallback: module.fallback,
          locale: locale,
        );
        _contents[module.id] = aiContent;
      }
    } catch (e) {
      // 保持原有内容
    }

    _generatingMap[module.id] = false;
    notifyListeners();
  }

  /// 使用兜底数据
  DailyContent _useFallback(ModuleConfig module) {
    if (module.fallback.isNotEmpty) {
      final index = DateTime.now().day % module.fallback.length;
      final fb = module.fallback[index];
      return DailyContent(
        id: '${module.id}_fallback_${DateTime.now().millisecondsSinceEpoch}',
        moduleId: module.id,
        content: fb.content,
        title: fb.title,
        subtitle: fb.subtitle,
        category: fb.category,
        categoryIcon: fb.categoryIcon,
        date: DateTime.now(),
        isAiGenerated: false,
      );
    }

    final lastModule = findModuleById(module.id);

    return DailyContent(
      id: '${module.id}_default_${DateTime.now().millisecondsSinceEpoch}',
      moduleId: module.id,
      title: lastModule?.slogan ?? '暂无内容',
      content: lastModule?.placeholderText ?? '暂无内容,点击AI生成',
      date: DateTime.now(),
    );
  }

  /// 清除指定模块缓存内容（强制刷新时使用）
  void clearContent(String moduleId) {
    _contents.remove(moduleId);
    notifyListeners();
  }

  /// 清除所有内容
  void clearAll() {
    _contents.clear();
    _loadingMap.clear();
    _generatingMap.clear();
    notifyListeners();
  }
}


utils.Module? findModuleById(String id) {
  try {
    return utils.defaultModuleConfig.modules.firstWhere((m) => m.id == id);
  } catch (_) {
    return null;
  }
}