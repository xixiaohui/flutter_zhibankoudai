import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import 'cloudbase_file.dart';

/// 本地配置文件路径
const String _aiPromptsLocalPath = 'assets/cloudData/prompts/aiPrompts.json';

/// 本地 AI Prompts 缓存
AiPromptsConfig? _localAiPromptsCache;

/// 从本地文件读取并解析 aiPrompts.json
///
/// 优先从本地 assets 加载，也支持从文件系统直接读取。
/// 如果 [forceRefresh] 为 true，则强制重新读取文件。
Future<AiPromptsConfig?> getLocalAiPromptsConfig({
  bool forceRefresh = false,
}) async {
  if (!forceRefresh && _localAiPromptsCache != null) {
    return _localAiPromptsCache;
  }

  debugPrint('正在加载本地 AI Prompts 配置...');
  try {
    String jsonStr;

    // 尝试从 assets 加载（打包后推荐方式）
    try {
      jsonStr = await rootBundle.loadString(_aiPromptsLocalPath);
    } catch (_) {
      // assets 加载失败时，尝试直接从文件系统读取（开发环境备用）
      final file = File(_aiPromptsLocalPath);
      if (await file.exists()) {
        jsonStr = await file.readAsString();
      } else {
        Logger(printer: PrettyPrinter(methodCount: 0))
            .e('本地 aiPrompts.json 文件不存在: $_aiPromptsLocalPath');
        return null;
      }
    }

    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    final config = AiPromptsConfig.fromJson(decoded);
    _localAiPromptsCache = config;
    return config;
  } catch (e) {
    Logger(printer: PrettyPrinter(methodCount: 0))
        .e('读取本地 aiPrompts.json 失败: $e');
    return null;
  }
}

/// 从本地文件获取指定 promptKey 的 AI Prompt Item
Future<AiPromptItem?> getLocalAiPrompt(
  String promptKey, {
  bool forceRefresh = false,
}) async {
  final config = await getLocalAiPromptsConfig(forceRefresh: forceRefresh);
  return config?.prompts[promptKey];
}

/// 从本地文件获取指定 promptKey 的 generate prompt 字符串
Future<String?> getLocalGeneratePrompt(
  String promptKey, {
  bool forceRefresh = false,
}) async {
  final prompt = await getLocalAiPrompt(promptKey, forceRefresh: forceRefresh);

  debugPrint('获取本地生成提示: promptKey="$promptKey", found=${prompt != null}');
  debugPrint('生成提示内容: ${prompt?.generate ?? "null"}');
  
  final generate = prompt?.generate.trim();
  return generate == null || generate.isEmpty ? null : generate;
}

/// 从本地文件获取指定 promptKey 的 share prompt 字符串
Future<String?> getLocalSharePrompt(
  String promptKey, {
  bool forceRefresh = false,
}) async {
  final prompt = await getLocalAiPrompt(promptKey, forceRefresh: forceRefresh);
  final share = prompt?.share.trim();
  return share == null || share.isEmpty ? null : share;
}

/// 获取本地 AI Prompts 的所有 prompt key 列表
Future<List<String>> getLocalPromptKeys({
  bool forceRefresh = false,
}) async {
  final config = await getLocalAiPromptsConfig(forceRefresh: forceRefresh);
  if (config == null) return [];
  return config.prompts.keys.toList();
}

/// 获取本地 AI Prompts 的版本信息
Future<Map<String, String>> getLocalPromptsMeta({
  bool forceRefresh = false,
}) async {
  final config = await getLocalAiPromptsConfig(forceRefresh: forceRefresh);
  if (config == null) return {};
  return {
    'version': config.version,
    'updated': config.updated,
  };
}

/// 清除本地 AI Prompts 缓存
void clearLocalAiPromptsCache() {
  _localAiPromptsCache = null;
}