import 'dart:convert';

import 'package:flutter/material.dart';
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
      debugPrint('Calling Hunyuan model for module: $moduleId with prompt: $prompt');
      final contentStr =
          await streamTextWithLocalPrompt(moduleId, userPrompt: '生成今日内容') ??
          await streamTextWithCloudPrompt(moduleId, userPrompt: '生成今日内容') ??
          await streamTextWithSystemPrompt(prompt, userPrompt: '生成今日内容');

      debugPrint('Raw AI response for module $moduleId: ${contentStr ?? "null"}');

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
      if (json != null) return json;

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

  Map<String, dynamic>? _tryParseJson(String str) {
    try {
      return Map<String, dynamic>.from(jsonDecode(str) as Map);
    } catch (_) {
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(str);
      if (jsonMatch != null) {
        try {
          return Map<String, dynamic>.from(
            jsonDecode(jsonMatch.group(0)!) as Map,
          );
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
