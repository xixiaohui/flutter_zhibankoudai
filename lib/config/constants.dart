/// 全局常量配置
library;

class AppConstants {
  AppConstants._();

  // 应用信息
  static const String appName = '智伴口袋';
  static const String appNameEn = 'ZhiBanKouDai';
  static const String appVersion = '1.0.0';

  // 缓存Key
  static const String keyModuleConfig = 'moduleConfig';
  static const String keyDailyContentPrefix = 'daily_';
  static const String keyUserInfo = 'userInfo';
  static const String keyLastSyncTime = 'lastSyncTime';

  // 缓存过期时间（小时）
  static const int cacheExpireHours = 24;

  // 腾讯云CloudBase配置
  static const String cloudbaseEnvId = 'YOUR_ENVID'; // TODO: 替换为实际环境ID

  // 模块类型枚举
  static const Map<String, String> moduleTypes = {
    'quote': '每日名言',
    'joke': '幽默笑话',
    'psychology': '心理学',
    'finance': '财经',
    'idiom': '歇后语俗语',
    'seoExpert': 'SEO专家',
  };

  // 默认模块配置（兜底数据）
  static const List<Map<String, dynamic>> defaultModules = [
    {
      'id': 'quote',
      'name': '每日名言',
      'icon': '📜',
      'color': '#FF6B6B',
      'description': '名言警句，每日一句，点亮你的一天',
      'generate': '请生成一句经典名言，包含作者和出处',
    },
    {
      'id': 'joke',
      'name': '幽默笑话',
      'icon': '😄',
      'color': '#4ECDC4',
      'description': '轻松一刻，快乐每一天',
      'generate': '请生成一个简短有趣的笑话',
    },
    {
      'id': 'psychology',
      'name': '心理学',
      'icon': '🧠',
      'color': '#45B7D1',
      'description': '心理小知识，了解自己了解他人',
      'generate': '请生成一个实用的心理学小知识',
    },
    {
      'id': 'finance',
      'name': '财经',
      'icon': '💰',
      'color': '#96CEB4',
      'description': '投资理财，财富增长',
      'generate': '请生成一条实用的理财小知识',
    },
    {
      'id': 'idiom',
      'name': '歇后语俗语',
      'icon': '📝',
      'color': '#FFEAA7',
      'description': '民间智慧，传承文化',
      'generate': '请生成一个有趣的歇后语并解释',
    },
    {
      'id': 'seoExpert',
      'name': 'SEO专家',
      'icon': '🔍',
      'color': '#DDA0DD',
      'description': '搜索引擎优化，让内容被更多人看到',
      'generate': '请生成一条SEO优化技巧',
    },
  ];
}