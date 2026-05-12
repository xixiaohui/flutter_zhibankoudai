import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/config/constants.dart';
import 'package:flutter_application_zhiban/services/local_config.dart';
import 'package:http/http.dart' as http;

import 'cloudbase_client.dart';
import 'cloudbase_file.dart';

Future<String?> streamText(
  String model,
  String subModel,
  List<Map<String, String>> messages,
) async {
  final payload = {
    'model': subModel,
    'messages': messages,
    'stream': true,
  };

  final url = '${cloudbase.baseUrl}/v1/ai/$model/chat/completions';
  final headers = Map<String, String>.from(cloudbase.headers);
  headers['Accept'] = 'text/event-stream';

  try {
    final request = http.Request('POST', Uri.parse(url));
    request.headers.addAll(headers);
    request.body = jsonEncode(payload);

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode >= 200 &&
        streamedResponse.statusCode < 300) {
      debugPrint('AI 流式响应:');
      String fullContent = '';

      await for (final chunk
          in streamedResponse.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (!line.startsWith('data: ')) continue;

          final dataStr = line.substring(6);
          if (dataStr.trim() == '[DONE]') continue;

          try {
            final chunkData = jsonDecode(dataStr);
            final content =
                chunkData['choices']?[0]?['delta']?['content'] ?? '';
            if (content.isNotEmpty) {
              debugPrint(content);
              fullContent += content.toString();
            }
          } catch (_) {
            // Ignore incomplete SSE JSON fragments.
          }
        }
      }

      return fullContent;
    }

    debugPrint('AI 调用失败: ${streamedResponse.statusCode}');
    return null;
  } catch (e) {
    debugPrint('AI 调用失败: $e');
    return null;
  }
}

Future<String?> streamTextWithSystemPrompt(
  String systemPrompt, {
  String userPrompt = '春天',
  String model = AppConstants.defaultModel,
  String subModel = AppConstants.defaultSubModel,
}) {
  return streamText(
    model,
    subModel,
    [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userPrompt},
    ],
  );
}

Future<String?> streamTextWithCloudPrompt(
  String promptKey, {
  String userPrompt = '生成今日内容',
  String model = AppConstants.defaultModel,
  String subModel = AppConstants.defaultSubModel,
  bool forceRefreshPrompt = false,
}) async {
  final systemPrompt = await getGeneratePrompt(
    promptKey,
    forceRefresh: forceRefreshPrompt,
  );

  if (systemPrompt == null) {
    debugPrint('未找到 AI Prompt: $promptKey');
    return null;
  }

  return streamTextWithSystemPrompt(
    systemPrompt,
    userPrompt: userPrompt,
    model: model,
    subModel: subModel,
  );
}


Future<String?> streamTextWithLocalPrompt(
  String promptKey, {
  String userPrompt = '生成今日内容',
  String model = AppConstants.defaultModel,
  String subModel = AppConstants.defaultSubModel,
  bool forceRefreshPrompt = false,
}) async {

  final systemPrompt = await getLocalGeneratePrompt(promptKey, forceRefresh: forceRefreshPrompt);

  if (systemPrompt == null) {
    debugPrint('未找到 AI Prompt: $promptKey');
    return null;
  }

  return streamTextWithSystemPrompt(
    systemPrompt,
    userPrompt: userPrompt,
    model: model,
    subModel: subModel,
  );
}


const _variationHints = [
  '请换一个角度来阐述',
  '请用不同的例子来说明',
  '请从一个新颖的视角来分析',
  '请结合实际案例来讲解',
  '请用比喻的方式来呈现',
  '请从历史发展的角度来解读',
  '请关注细节层面',
  '请从宏观层面来概括',
  '请用对比的方式来分析',
  '请给出不同的观点',
  '请深入探讨核心概念',
  '请用通俗易懂的方式来解释',
  '请从跨界融合的角度来思考',
  '请关注最新趋势',
  '请从实用技巧的角度来分享',
];

List<Map<String, String>> _withSeedVariation(List<Map<String, String>> messages) {
  final seed = DateTime.now().minute;
  final hint = _variationHints[seed % _variationHints.length];
  final modified = List<Map<String, String>>.from(messages);
  for (int i = modified.length - 1; i >= 0; i--) {
    if (modified[i]['role'] == 'user') {
      modified[i] = {
        'role': 'user',
        'content': '${modified[i]['content']}\n\n[$hint]',
      };
      break;
    }
  }
  return modified;
}

Future<String?> generateText(
  String model,
  String subModel,
  List<Map<String, String>> messages,
) async {
  final varied = _withSeedVariation(messages);
  final payload = {
    'model': subModel,
    'messages': varied,
    'stream': false,
  };

  final url = '${cloudbase.baseUrl}/v1/ai/$model/chat/completions';
  final headers = Map<String, String>.from(cloudbase.headers);
  headers['Content-Type'] = 'application/json';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);

      final content =
          data['choices']?[0]?['message']?['content']?.toString();

      debugPrint('AI 返回: $content');

      return content;
    }

    debugPrint('AI 调用失败: ${response.statusCode}');
    debugPrint(response.body);
    return null;
  } catch (e) {
    debugPrint('AI 调用异常: $e');
    return null;
  }
}

Future<String?> generateWithSystemPrompt(
  String systemPrompt, {
  String userPrompt = '春天',
  String model = AppConstants.defaultModel,
  String subModel = AppConstants.defaultSubModel,
}) {
  return generateText(
    model,
    subModel,
    [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userPrompt},
    ],
  );
}

/// Non-streaming version of the xclaw.living API.
Future<String?> generateTextXclaw({
  required String model,
  required List<Map<String, String>> messages,
  String subModel = 'hunyuan-turbos-latest',
}) async {
  final url = 'https://www.xclaw.living/api/hunyuan/$model/ai-generate';

  try {
    final request = http.Request('POST', Uri.parse(url));
    request.headers.addAll({
      'Content-Type': 'application/json',
    });
    request.body = jsonEncode({
      'messages': messages,
      'subModel': subModel,
      'stream': false,
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content']?.toString();
      return content;
    }

    debugPrint('xclaw generateText failed: ${response.statusCode}');
    return null;
  } catch (e) {
    debugPrint('xclaw generateText error: $e');
    return null;
  }
}

/// Calls the xclaw.living API (OpenAI-compatible SSE stream).
/// Used by ai_friend_page and ai_career_detail_page.
Future<String?> streamTextXclaw({
  required String model,
  required List<Map<String, String>> messages,
  String subModel = 'hunyuan-turbos-latest',
}) async {
  final url = 'https://www.xclaw.living/api/hunyuan/$model/ai-generate';

  try {
    final request = http.Request('POST', Uri.parse(url));
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
    });
    request.body = jsonEncode({
      'messages': messages,
      'subModel': subModel,
      'stream': true,
    });

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
      String fullContent = '';

      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (!line.startsWith('data: ')) continue;

          final dataStr = line.substring(6);
          if (dataStr.trim() == '[DONE]') continue;

          try {
            final chunkData = jsonDecode(dataStr);
            // Check for error in stream
            if (chunkData['error'] != null) {
              debugPrint('AI stream error: ${chunkData['error']['message']}');
              return fullContent.isEmpty ? null : fullContent;
            }
            final content = chunkData['choices']?[0]?['delta']?['content'] ?? '';
            if (content.isNotEmpty) {
              fullContent += content.toString();
            }
          } catch (_) {
            // Ignore incomplete SSE JSON fragments.
          }
        }
      }

      return fullContent;
    }

    debugPrint('xclaw AI call failed: ${streamedResponse.statusCode}');
    return null;
  } catch (e) {
    debugPrint('xclaw AI call error: $e');
    return null;
  }
}

Future<String?> generateTextWithLocalPrompt(
  String promptKey, {
  String userPrompt = '生成今日内容',
  String model = AppConstants.defaultModel,
  String subModel = AppConstants.defaultSubModel,
  bool forceRefreshPrompt = false,
}) async {

  final systemPrompt = await getLocalGeneratePrompt(promptKey, forceRefresh: forceRefreshPrompt);

  if (systemPrompt == null) {
    debugPrint('未找到 AI Prompt: $promptKey');
    return null;
  }

  return generateWithSystemPrompt(
    systemPrompt,
    userPrompt: userPrompt,
    model: model,
    subModel: subModel,
  );
}