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


Future<String?> generateText(
  String model,
  String subModel,
  List<Map<String, String>> messages,
) async {
  final payload = {
    'model': subModel,
    'messages': messages,
    'stream': false, // ⭐ 关键
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