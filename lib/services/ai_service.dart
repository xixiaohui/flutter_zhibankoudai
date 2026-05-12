import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/services/cloudbase_db.dart';
import 'package:flutter_application_zhiban/xui/utils/module.dart';
import 'package:logger/logger.dart';

import '../models/daily_content.dart';
import '../models/module_config.dart';
import 'cloudbase_ai.dart';
import 'data_service.dart';

class AiService {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  

  Future<DailyContent> generateContent({
    required String moduleId,
    required String prompt,
    required List<FallbackContent> fallback,
  }) async {
    try {
      _logger.d('AI generating content for module: $moduleId');
      final response = await _callHunyuanModel(moduleId, prompt);


      _logger.d('AI response for module $moduleId: ${response != null ? "Received" : "No response"}');
      _logger.d('AI response content for module $moduleId: ${response?['content']?.toString() ?? "null"}');

      if (response != null) {
        final content = DailyContent(
          id: '${moduleId}_${DateTime.now().millisecondsSinceEpoch}',
          moduleId: moduleId,
          content: response['content']?.toString() ?? '',
          title: response['title']?.toString() ?? '',
          subtitle:
              response['subtitle']?.toString() ??
              response['source']?.toString() ??
              '',
          category:
              response['category']?.toString() ??
              response['era']?.toString() ??
              '',
          categoryIcon:
              response['categoryIcon']?.toString() ??
              response['region']?.toString() ??
              '',
          date: DateTime.now(),
          isAiGenerated: true,
        );

        final dataService = DataService();
        await dataService.saveDailyContent(moduleId, content.toJson());
        _logger.d('AI content generated and cached for module: $moduleId');


        //同步上传到云数据库
        final Module? module = findModuleById(moduleId);
        if(module != null){
          debugPrint(module.collection);
          debugPrint(response.toString());

          final result = await addModelData(module.collection, response);
          _logger.d('db result id $result');
        }

        return content;
      }
    } catch (e) {
      _logger.e('AI generation failed for module $moduleId: $e');
    }

    return _useFallback(moduleId, fallback);
  }

  Future<Map<String, dynamic>?> _callHunyuanModel(
    String moduleId,
    String prompt,
  ) async {
    try {
      // Use xclaw API (non-streaming) as primary
      final contentStr =
          await generateTextXclaw(
            model: 'hunyuan-exp',
            subModel: 'hunyuan-turbos-latest',
            messages: [
              {'role': 'system', 'content': prompt},
              {'role': 'user', 'content': '生成今日内容'},
            ],
          ) ??
          await generateTextWithLocalPrompt(moduleId, userPrompt: '生成今日内容') ??
          await streamTextWithCloudPrompt(moduleId, userPrompt: '生成今日内容') ??
          await streamTextWithSystemPrompt(prompt, userPrompt: '生成今日内容');

      if (contentStr == null || contentStr.trim().isEmpty) {
        return null;
      }

      return _parseAiContent(contentStr);
    } catch (e) {
      _logger.e('Hunyuan model call failed: $e');
    }
    return null;
  }


  Map<String, dynamic>? _parseAiContent(String contentStr) {
    try {
      final json = _tryParseJson(contentStr);

      if (json != null){

        debugPrint('解析AI 内容为JSON Parsed AI content as JSON: $json');
        return json;
      }
      debugPrint('没有解析AI 内容为JSON Parsed AI content as JSON: $json');
      return {
        'content': contentStr,
        'title': '',
        'subtitle': '',
        'category': '',
        'categoryIcon': '',
      };
    } catch (e) {
      _logger.e('Parse AI content failed: $e');
      return null;
    }
  }


  String sanitizeJsonString(String input) {
  final buffer = StringBuffer();
  bool inString = false;

  for (int i = 0; i < input.length; i++) {
    final char = input[i];

    // 判断字符串开始/结束
    if (char == '"') {
      final isEscaped = i > 0 && input[i - 1] == '\\';
      if (!isEscaped) {
        inString = !inString;
      }
      buffer.write(char);
      continue;
    }

    if (inString) {
      // ⭐ 修复换行
      if (char == '\n') {
        buffer.write(r'\n');
        continue;
      }
      if (char == '\r') {
        buffer.write(r'\r');
        continue;
      }

      // ⭐ 修复未转义引号（核心🔥）
      if (char == '"' && (i == 0 || input[i - 1] != '\\')) {
        buffer.write(r'\"');
        continue;
      }
    }

    buffer.write(char);
  }

  return buffer.toString();
}
  Map<String, dynamic>? _tryParseJson(String str) {
    debugPrint('尝试解析AI内容为JSON: $str');

    try {
      // 1️⃣ 去掉 markdown 包裹
      var cleaned = str
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // 2️⃣ 提取 JSON 主体
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        cleaned = cleaned.substring(start, end + 1);
      }

      // 3️⃣ ⭐ 修复非法换行（关键）
      cleaned = sanitizeJsonString(cleaned);

      // 4️⃣ 解析
      return Map<String, dynamic>.from(jsonDecode(cleaned));
    } catch (e) {
      debugPrint('JSON解析失败: $e');
      return null;
    }
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

    final lastModule = findModuleById(moduleId);

    return DailyContent(
      id: '${moduleId}_default_${DateTime.now().millisecondsSinceEpoch}',
      moduleId: moduleId,
      title: lastModule?.slogan ?? '暂无内容',
      content: lastModule?.placeholderText ?? '暂无内容，请稍后再试',
      date: DateTime.now(),
      isAiGenerated: false,
    );
  }
}