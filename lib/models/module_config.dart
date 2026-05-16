/// 模块配置模型
/// 对应 cloudData/moduleConfig.json 和 cloudData/modules/*.json
class ModuleConfig {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String description;
  final String? generatePrompt;
  final List<FallbackContent> fallback;
  final ShareConfig? share;
  final String refreshText;

  const ModuleConfig({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    this.generatePrompt,
    this.fallback = const [],
    this.share,
    this.refreshText = 'Refresh',
  });

  factory ModuleConfig.fromJson(Map<String, dynamic> json) {
    return ModuleConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      description: json['description'] as String? ?? '',
      generatePrompt: json['generate'] as String?,
      fallback: (json['fallback'] as List<dynamic>?)
              ?.map((e) => FallbackContent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      share: json['share'] != null
          ? ShareConfig.fromJson(json['share'] as Map<String, dynamic>)
          : null,
      refreshText: json['refreshText'] as String? ?? 'Refresh',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'description': description,
      'generate': generatePrompt,
      'fallback': fallback.map((e) => e.toJson()).toList(),
      'share': share?.toJson(),
    };
  }
}

/// 兜底内容
class FallbackContent {
  final String content;
  final String title;
  final String subtitle;
  final String category;
  final String categoryIcon;

  const FallbackContent({
    required this.content,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.categoryIcon,
  });

  factory FallbackContent.fromJson(Map<String, dynamic> json) {
    return FallbackContent(
      content: json['content'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      category: json['category'] as String? ?? '',
      categoryIcon: json['categoryIcon'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'categoryIcon': categoryIcon,
    };
  }
}

/// 分享配置
class ShareConfig {
  final String title;
  final String? imageUrl;
  final String? path;

  const ShareConfig({
    required this.title,
    this.imageUrl,
    this.path,
  });

  factory ShareConfig.fromJson(Map<String, dynamic> json) {
    return ShareConfig(
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
      path: json['path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'path': path,
    };
  }
}