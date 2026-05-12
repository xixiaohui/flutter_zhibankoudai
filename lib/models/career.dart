import 'dart:convert';
import 'package:flutter/services.dart';

class Career {
  final String id;
  final String name;
  final String nameEn;
  final String nameZh;
  final String description;
  final String descriptionZh;
  final String vibe;
  final String vibeZh;
  final String emoji;
  final String color;
  final String category;
  final String categoryName;
  final String categoryNameEn;
  final String categoryIcon;
  final List<String> coreMission;
  final List<String> technicalDeliverables;
  final List<String> workflow;
  final List<String> communicationStyle;
  final List<String> successMetrics;
  final List<String> tools;
  final List<String> personality;
  final List<String> background;
  final List<String> expertise;
  final List<String> criticalRules;
  final List<String> advancedCapabilities;
  final List<String> researchDeliverables;
  final List<String> learningMemory;
  final List<String> additionalNotes;

  const Career({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameZh,
    required this.description,
    required this.descriptionZh,
    required this.vibe,
    required this.vibeZh,
    required this.emoji,
    required this.color,
    required this.category,
    required this.categoryName,
    required this.categoryNameEn,
    required this.categoryIcon,
    this.coreMission = const [],
    this.technicalDeliverables = const [],
    this.workflow = const [],
    this.communicationStyle = const [],
    this.successMetrics = const [],
    this.tools = const [],
    this.personality = const [],
    this.background = const [],
    this.expertise = const [],
    this.criticalRules = const [],
    this.advancedCapabilities = const [],
    this.researchDeliverables = const [],
    this.learningMemory = const [],
    this.additionalNotes = const [],
  });

  factory Career.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

    return Career(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['nameEn'] ?? '',
      nameZh: json['nameZh'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      descriptionZh: json['descriptionZh'] ?? json['description'] ?? '',
      vibe: json['vibe'] ?? '',
      vibeZh: json['vibeZh'] ?? json['vibe'] ?? '',
      emoji: json['emoji'] ?? '',
      color: json['color'] ?? '',
      category: json['category'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryNameEn: json['categoryNameEn'] ?? '',
      categoryIcon: json['categoryIcon'] ?? '',
      coreMission: parseList(json['coreMission']),
      technicalDeliverables: parseList(json['technicalDeliverables']),
      workflow: parseList(json['workflow']),
      communicationStyle: parseList(json['communicationStyle']),
      successMetrics: parseList(json['successMetrics']),
      tools: parseList(json['tools']),
      personality: parseList(json['personality']),
      background: parseList(json['background']),
      expertise: parseList(json['expertise']),
      criticalRules: parseList(json['criticalRules']),
      advancedCapabilities: parseList(json['advancedCapabilities']),
      researchDeliverables: parseList(json['researchDeliverables']),
      learningMemory: parseList(json['learningMemory']),
      additionalNotes: parseList(json['additionalNotes']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'nameEn': nameEn, 'nameZh': nameZh,
    'description': description, 'descriptionZh': descriptionZh,
    'vibe': vibe, 'vibeZh': vibeZh, 'emoji': emoji, 'color': color,
    'category': category, 'categoryName': categoryName,
    'categoryNameEn': categoryNameEn, 'categoryIcon': categoryIcon,
    'coreMission': coreMission, 'technicalDeliverables': technicalDeliverables,
    'workflow': workflow, 'communicationStyle': communicationStyle,
    'successMetrics': successMetrics, 'tools': tools,
    'personality': personality, 'background': background,
    'expertise': expertise, 'criticalRules': criticalRules,
    'advancedCapabilities': advancedCapabilities,
    'researchDeliverables': researchDeliverables,
    'learningMemory': learningMemory, 'additionalNotes': additionalNotes,
  };

  static Future<Career> load(String id) async {
    final raw = await rootBundle.loadString('assets/career/$id.json');
    return Career.fromJson(jsonDecode(raw));
  }

  static Future<List<Career>> loadAll() async {
    final futures = careerIds.map((id) => load(id));
    final results = await Future.wait(futures);
    return results.toList();
  }

  /// Build a system prompt for AI role-play from career persona fields
  String buildSystemPrompt() {
    final buf = StringBuffer();
    buf.writeln('你是「$nameZh」($name)，一位$descriptionZh');
    buf.writeln();

    if (background.isNotEmpty) {
      buf.writeln('【背景设定】');
      for (final line in background) {
        if (line.trim().isNotEmpty) buf.writeln(line.trim());
      }
      buf.writeln();
    }

    if (personality.isNotEmpty) {
      buf.writeln('【性格特质】');
      for (final line in personality) {
        if (line.trim().isNotEmpty) buf.writeln(line.trim());
      }
      buf.writeln();
    }

    if (coreMission.isNotEmpty) {
      buf.writeln('【核心使命】');
      for (final line in coreMission) {
        if (line.trim().isNotEmpty) buf.writeln(line.trim());
      }
      buf.writeln();
    }

    if (criticalRules.isNotEmpty) {
      buf.writeln('【关键规则 - 必须遵守】');
      for (final line in criticalRules) {
        if (line.trim().isNotEmpty) buf.writeln(line.trim());
      }
      buf.writeln();
    }

    if (communicationStyle.isNotEmpty) {
      buf.writeln('【沟通风格】');
      for (final line in communicationStyle) {
        if (line.trim().isNotEmpty) buf.writeln(line.trim());
      }
      buf.writeln();
    }

    if (workflow.isNotEmpty) {
      buf.writeln('【工作流程】');
      for (final line in workflow) {
        if (line.trim().isNotEmpty) buf.writeln(line.trim());
      }
      buf.writeln();
    }

    buf.writeln('请始终以上述专家身份与用户交流。用中文回复，保持专业、深度、实用的风格。');

    return buf.toString();
  }

  /// All career IDs registered in assets/career/
  static const List<String> careerIds = [
    'abroad-advisor', 'accessibility-auditor', 'account-strategist',
    'agentic-search-optimizer', 'ai-citation-strategist', 'ai-data-remediation-engineer',
    'ai-engineer', 'analytics-reporter', 'anthropologist', 'api-tester',
    'app-store-optimizer', 'artist', 'audio-engineer', 'auditor',
    'autonomous-optimization-architect', 'backend-architect', 'baidu-seo-specialist',
    'behavioral-nudge-engine', 'bilibili-content-strategist', 'billing-time-tracking',
    'book-co-author', 'bookkeeper-controller', 'brand-guardian', 'carousel-growth-engine',
    'chain-strategist', 'chief-of-staff', 'china-ecommerce-operator',
    'china-market-localization-strategist', 'civil-engineer', 'client-intake',
    'cms-developer', 'coach', 'cockpit-interaction-specialist', 'code-reviewer',
    'codebase-onboarding-engineer', 'consolidation-agent', 'content-creator',
    'cross-border-ecommerce', 'cultural-intelligence-strategist', 'customer-returns',
    'customer-service', 'data-engineer', 'data-extraction-agent', 'database-optimizer',
    'deal-strategist', 'designer', 'developer-advocate', 'devops-automator',
    'digital-presales-consultant', 'discovery-coach', 'distribution-agent',
    'document-generator', 'document-review', 'douyin-strategist',
    'email-intelligence-engineer', 'embedded-firmware-engineer', 'engineer',
    'estate-buyer-seller', 'evidence-collector', 'executive-summary-generator',
    'feedback-synthesizer', 'feishu-integration-developer',
    'filament-optimization-specialist', 'finance-tracker', 'financial-analyst',
    'fpa-analyst', 'french-consulting-market', 'frontend-developer', 'geographer',
    'git-workflow-master', 'governance-architect', 'graph-operator', 'growth-hacker',
    'guest-services', 'historian', 'identity-trust', 'image-prompt-engineer',
    'immersive-developer', 'incident-response-commander',
    'inclusive-visuals-specialist', 'index-engineer', 'index',
    'infrastructure-maintainer', 'instagram-curator', 'integration-specialist',
    'interface-architect', 'investment-researcher', 'korean-business-navigator',
    'kuaishou-strategist', 'legal-compliance-checker', 'linkedin-content-creator',
    'livestream-commerce-coach', 'management-experiment-tracker',
    'management-jira-workflow-steward', 'management-project-shepherd',
    'management-studio-operations', 'management-studio-producer', 'manager-senior',
    'manager', 'marketing-compliance', 'mcp-builder', 'media-auditor',
    'media-creative-strategist', 'media-paid-social-strategist', 'media-ppc-strategist',
    'media-programmatic-buyer', 'media-search-query-analyst', 'media-tracking-specialist',
    'minimal-change-engineer', 'mobile-app-builder', 'model-qa', 'narratologist',
    'officer-assistant', 'onboarding', 'orchestrator', 'outbound-strategist', 'outreach',
    'payable-agent', 'performance-benchmarker', 'pipeline-analyst', 'podcast-strategist',
    'private-domain-operator', 'proposal-strategist', 'psychologist', 'rapid-prototyper',
    'reality-checker', 'reddit-community-builder', 'salesforce-architect',
    'security-auditor', 'security-engineer', 'senior-developer', 'seo-specialist',
    'service', 'short-video-editing-coach', 'social-media-strategist',
    'software-architect', 'solidity-smart-contract-engineer', 'spatial-engineer',
    'spatial-metal-engineer', 'specialist', 'sprint-prioritizer', 'sre', 'steward',
    'support-responder', 'tax-strategist', 'technical-writer', 'test-results-analyzer',
    'threat-detection-engineer', 'tiktok-strategist', 'tool-evaluator',
    'training-designer', 'translator', 'trend-researcher', 'twitter-engager',
    'ui-designer', 'ux-architect', 'ux-researcher', 'video-optimization-specialist',
    'visual-storyteller', 'voice-ai-integration-engineer',
    'wechat-mini-program-developer', 'wechat-official-account', 'weibo-strategist',
    'whimsy-injector', 'workflow-architect', 'workflow-optimizer',
    'xiaohongshu-specialist', 'zhihu-strategist',
  ];
}
