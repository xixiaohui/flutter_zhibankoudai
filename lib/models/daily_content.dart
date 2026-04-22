/// 每日内容模型
class DailyContent {
  final String id;
  final String moduleId;
  final String content;
  final String title;
  final String subtitle;
  final String category;
  final String categoryIcon;
  final DateTime? date;
  final bool isAiGenerated;

  const DailyContent({
    required this.id,
    required this.moduleId,
    required this.content,
    this.title = '',
    this.subtitle = '',
    this.category = '',
    this.categoryIcon = '',
    this.date,
    this.isAiGenerated = false,
  });

  factory DailyContent.fromJson(Map<String, dynamic> json) {
    return DailyContent(
      id: json['id'] as String? ?? '',
      moduleId: json['moduleId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      category: json['category'] as String? ?? '',
      categoryIcon: json['categoryIcon'] as String? ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date'] as String) : null,
      isAiGenerated: json['isAiGenerated'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'content': content,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'categoryIcon': categoryIcon,
      'date': date?.toIso8601String(),
      'isAiGenerated': isAiGenerated,
    };
  }

  /// 从兜底内容创建
  factory DailyContent.fromFallback(String moduleId, FallbackContentData fallback) {
    return DailyContent(
      id: '${moduleId}_${DateTime.now().millisecondsSinceEpoch}',
      moduleId: moduleId,
      content: fallback.content,
      title: fallback.title,
      subtitle: fallback.subtitle,
      category: fallback.category,
      categoryIcon: fallback.categoryIcon,
      date: DateTime.now(),
      isAiGenerated: false,
    );
  }
}

/// 兜底内容数据（简化版，用于 fromFallback 工厂方法）
class FallbackContentData {
  final String content;
  final String title;
  final String subtitle;
  final String category;
  final String categoryIcon;

  const FallbackContentData({
    required this.content,
    this.title = '',
    this.subtitle = '',
    this.category = '',
    this.categoryIcon = '',
  });
}