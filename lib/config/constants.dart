/// 全局常量配置
library;

class AppConstants {
  AppConstants._();

  // 应用信息
  static const String appName = '智伴口袋';
  static const String appNameEn = 'PocketMind';
  static const String appVersion = '1.2.1';

  // 缓存Key
  static const String keyModuleConfig = 'moduleConfig';
  static const String keyDailyContentPrefix = 'daily_';
  static const String keyUserInfo = 'userInfo';
  static const String keyLastSyncTime = 'lastSyncTime';

  // 缓存过期时间（小时）
  static const int cacheExpireHours = 24;

  // 腾讯云CloudBase配置
  static const String cloudbaseEnvId = 'YOUR_ENVID'; // TODO: 替换为实际环境ID

  //默认模型
  static const String defaultModel = 'hunyuan-exp';
  static const String defaultSubModel = 'hunyuan-turbos-latest';

    // 模块类型枚举
  static const Map<String, String> moduleTypes = {
    'quote': '每日名言',
    'joke': '幽默笑话',
    'psychology': '心理学',
    'finance': '财经',
    'love': '爱情语录',
    'movie': '电影推荐',
    'music': '音乐分享',
    'tech': '科技前沿',
    'tcm': '中医养生',
    'travel': '旅行攻略',
    'fortune': '每日运势',
    'literature': '文学赏析',
    'foreignTrade': '外贸资讯',
    'ecommerce': '电商动态',
    'math': '数学趣题',
    'english': '英语学习',
    'programming': '编程技巧',
    'photography': '摄影技巧',
    'beauty': '美容护肤',
    'investment': '投资理财',
    'fishing': '钓鱼技巧',
    'fitness': '健身指导',
    'pet': '宠物养护',
    'fashion': '时尚穿搭',
    'outfit': '穿搭推荐',
    'decoration': '家居装饰',
    'glassFiber': '玻璃纤维',
    'resin': '树脂工艺',
    'tax': '税务筹划',
    'law': '法律常识',
    'official': '政务服务',
    'handling': '办事指南',
    'floral': '花卉养护',
    'history': '历史故事',
    'military': '军事动态',
    'stock': '股市行情',
    'economics': '经济观察',
    'business': '商业洞察',
    'news': '每日资讯',
    'apple': '果核学堂',
    'growth': '市场品牌增长专家',
    'uiDesigner': 'UI设计师专家',
    'futures': '大宗贸易期货专家',
    'freud': '弗洛伊德学术专家',
    'fashionBrand': '世界服装品牌大师',
    'robotAi': '机器人AI专家',
    'americanExpert': '美国通',
    'xinStudy': '心学大师',
    'liStudy': '理学大师',
    'wisdomBag': '智慧锦囊',
    'anthropologist': '人类学家',
    'geographer': '地理学家',
    'historian': '历史学家',
    'narratologist': '叙事学家',
    'psychologist': '心理学家',
    'softwareArchitect': '软件架构师助手',
    'solidityEngineer': 'Solidity智能合约工程师',
    'xiaohongshuExpert': '小红书专家',
    'seoExpert': 'SEO专家',
  };

    // 默认模块配置（兜底数据）
  static const List<Map<String, dynamic>> defaultModules = [];
}