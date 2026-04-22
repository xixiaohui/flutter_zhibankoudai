import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/daily_content.dart';
import '../models/module_config.dart';
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
            {'role': 'system', 'content': 'You are a professional content generation assistant. Generate content in JSON format: {"content":"...","title":"...","subtitle":"...","category":"...","categoryIcon":"..."}'},
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
      content: 'No content available, please try again later',
      date: DateTime.now(),
      isAiGenerated: false,
    );
  }
}