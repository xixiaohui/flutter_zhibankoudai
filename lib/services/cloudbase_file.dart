import 'dart:convert';

import 'package:http/http.dart' as http;

import 'cloudbase_client.dart';

const String aiPromptsCloudbaseObjectId =
    "cloud://zhiban-4g34epre1ce6ce1c.7a68-zhiban-4g34epre1ce6ce1c-1415458762/cloudData/prompts/aiPrompts.json";

AiPromptsConfig? _aiPromptsCache;

class AiPromptsConfig {
  final String version;
  final String updated;
  final AiPromptSystemConfig system;
  final Map<String, AiPromptItem> prompts;

  const AiPromptsConfig({
    required this.version,
    required this.updated,
    required this.system,
    required this.prompts,
  });

  factory AiPromptsConfig.fromJson(Map<String, dynamic> json) {
    final rawPrompts = json['prompts'] as Map<String, dynamic>? ?? {};

    return AiPromptsConfig(
      version: json['version']?.toString() ?? '',
      updated: json['updated']?.toString() ?? '',
      system: AiPromptSystemConfig.fromJson(
        Map<String, dynamic>.from(json['system'] as Map? ?? {}),
      ),
      prompts: rawPrompts.map(
        (key, value) => MapEntry(
          key,
          AiPromptItem.fromJson(Map<String, dynamic>.from(value as Map)),
        ),
      ),
    );
  }

  AiPromptItem? operator [](String key) => prompts[key];
}

class AiPromptSystemConfig {
  final double temperature;
  final int maxTokens;
  final double topP;
  final double frequencyPenalty;
  final double presencePenalty;

  const AiPromptSystemConfig({
    required this.temperature,
    required this.maxTokens,
    required this.topP,
    required this.frequencyPenalty,
    required this.presencePenalty,
  });

  factory AiPromptSystemConfig.fromJson(Map<String, dynamic> json) {
    return AiPromptSystemConfig(
      temperature: _toDouble(json['temperature'], 0.7),
      maxTokens: _toInt(json['maxTokens'], 800),
      topP: _toDouble(json['topP'], 0.9),
      frequencyPenalty: _toDouble(json['frequencyPenalty'], 0.3),
      presencePenalty: _toDouble(json['presencePenalty'], 0.2),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'maxTokens': maxTokens,
      'topP': topP,
      'frequencyPenalty': frequencyPenalty,
      'presencePenalty': presencePenalty,
    };
  }
}

class AiPromptItem {
  final String generate;
  final String share;

  const AiPromptItem({
    required this.generate,
    required this.share,
  });

  factory AiPromptItem.fromJson(Map<String, dynamic> json) {
    return AiPromptItem(
      generate: json['generate']?.toString() ?? '',
      share: json['share']?.toString() ?? '',
    );
  }
}

Future<String?> getFileUrl(String cloudObjectId) async {
  final result = await cloudbase.request(
    'POST',
    '/v1/storages/get-objects-download-info',
    body: [
      {'cloudObjectId': cloudObjectId},
    ],
  );

  if (result != null && result.isNotEmpty) {
    final downloadUrl = result[0]['downloadUrl'];
    return downloadUrl?.toString();
  }
  return null;
}

Future<AiPromptsConfig?> getAiPromptsConfig({bool forceRefresh = false}) async {
  if (!forceRefresh && _aiPromptsCache != null) {
    return _aiPromptsCache;
  }

  final fileUrl = await getFileUrl(aiPromptsCloudbaseObjectId);
  if (fileUrl == null || fileUrl.isEmpty) return null;

  final response = await http.get(Uri.parse(fileUrl));
  if (response.statusCode < 200 || response.statusCode >= 300) {
    return null;
  }

  final decoded = jsonDecode(utf8.decode(response.bodyBytes));
  final config = AiPromptsConfig.fromJson(Map<String, dynamic>.from(decoded));
  _aiPromptsCache = config;
  return config;
}

Future<AiPromptItem?> getAiPrompt(
  String promptKey, {
  bool forceRefresh = false,
}) async {
  final config = await getAiPromptsConfig(forceRefresh: forceRefresh);
  return config?[promptKey];
}

Future<String?> getGeneratePrompt(
  String promptKey, {
  bool forceRefresh = false,
}) async {
  final prompt = await getAiPrompt(promptKey, forceRefresh: forceRefresh);
  final generate = prompt?.generate.trim();
  return generate == null || generate.isEmpty ? null : generate;
}

double _toDouble(dynamic value, double fallback) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int _toInt(dynamic value, int fallback) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}
