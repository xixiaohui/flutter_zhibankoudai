import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/services/cloudbase_db.dart';
import 'package:flutter_application_zhiban/services/local_config.dart';
import 'package:flutter_application_zhiban/xui/utils/module.dart';
import 'package:logger/logger.dart';

import '../models/daily_content.dart';
import '../models/module_config.dart';
import 'cloudbase_ai.dart';
import 'data_service.dart';

const Map<String, List<String>> _domainConcepts = {
  'quote': ['修辞手法', '对仗', '比兴', '用典', '文学流派', '唐诗宋词', '先秦诸子', '唐宋八大家', '浪漫主义', '现实主义', '山水田园', '边塞诗', '婉约派', '豪放派', '托物言志', '借景抒情'],
  'joke': ['包袱', '抖包袱', '反转', '谐音梗', '冷幽默', '黑色幽默', '脱口秀', '相声', '小品', '段子结构', '铺垫', '笑点', '荒诞', '自嘲', '双关'],
  'psychology': ['认知偏差', '确认偏误', '锚定效应', '从众心理', '沉没成本', '心理防御机制', '潜意识', '正念', '认知行为疗法', '积极心理学', '马斯洛需求层次', '依恋理论', '情绪智力', '心流', '共情'],
  'finance': ['复利', '资产配置', '风险管理', '流动性', '通胀', '定投', '分散投资', '被动收入', '财务自由', '预算管理', '负债率', '紧急基金', '指数基金', '股息', '估值'],
  'love': ['情诗', '十四行诗', '情书', '古典爱情', '柏拉图式', '灵魂伴侣', '相思', '一见钟情', '海誓山盟', '执子之手', '比翼鸟', '连理枝', '红豆', '鹊桥', '天长地久'],
  'movie': ['镜头语言', '蒙太奇', '长镜头', '景深', '场面调度', '叙事结构', '类型片', '作者电影', '新浪潮', '表现主义', '纪实风格', '配乐', '剪辑节奏', '表演流派', '剧本结构'],
  'music': ['旋律', '和声', '节奏', '编曲', '曲式', '调性', '音色', '交响乐', '协奏曲', '奏鸣曲', '爵士', '蓝调', '摇滚', '民谣', '电子', '古典乐派', '浪漫乐派', '复调'],
  'tech': ['人工智能', '机器学习', '量子计算', '区块链', '5G', '物联网', '边缘计算', '云计算', 'AR/VR', '脑机接口', '基因编辑', '可控核聚变', '自动驾驶', '芯片制程', '新材料'],
  'tcm': ['阴阳', '五行', '经络', '穴位', '气血', '脏腑', '辨证论治', '四诊合参', '药食同源', '君臣佐使', '性味归经', '子午流注', '八纲辨证', '治未病', '膏方', '艾灸', '推拿'],
  'travel': ['世界遗产', '国家公园', '古镇', '博物馆', '美食之旅', '深度游', '自由行', '背包客', '民宿', '签证', '时差', '文化差异', '攻略', '打卡', '秘境'],
  'literature': ['叙事视角', '意识流', '魔幻现实主义', '象征主义', '存在主义', '后现代', '互文性', '人物弧光', '冲突', '意象', '隐喻', '反讽', '悲剧', '喜剧', '史诗'],
  'foreignTrade': ['FOB', 'CIF', '信用证', '报关', '退税', '跨境支付', '贸易术语', '关税壁垒', '反倾销', '原产地证', '自贸区', 'RCEP', '供应链', '海外仓', 'B2B'],
  'ecommerce': ['转化率', '客单价', '复购率', '私域流量', '直播带货', '社交电商', '内容电商', 'SKU', 'GMV', 'ROI', '千人千面', '推荐算法', '用户画像', 'A/B测试', '漏斗模型'],
  'math': ['公理', '定理', '猜想', '悖论', '几何', '代数', '微积分', '概率论', '数论', '拓扑', '群论', '混沌理论', '博弈论', '黄金分割', '斐波那契', '无穷', '对称'],
  'english': ['语法', '词汇', '发音', '时态', '语态', '习语', '俚语', '词根', '词缀', '连读', '语调', '口语', '写作', '听力', '阅读策略'],
  'programming': ['算法', '设计模式', '数据结构', '递归', '迭代', '抽象', '封装', '继承', '多态', '时间复杂度', '空间复杂度', '链表', '栈', '队列', '树', '图', '哈希', '排序', '搜索'],
  'photography': ['光圈', '快门', 'ISO', '白平衡', '景深', '构图', '三分法', '黄金分割', '逆光', '侧光', 'RAW', '后期', '色彩理论', 'HDR', '长曝光', '微距', '广角', '人像'],
  'beauty': ['保湿', '防晒', '抗氧化', '胶原蛋白', '角质层', '皮脂膜', '精华', '面霜', '面膜', '清洁', '卸妆', '肤质', '敏感肌', '成分', '玻尿酸', '烟酰胺', '视黄醇'],
  'investment': ['价值投资', '成长投资', '指数投资', '定投策略', 'PE', 'PB', 'ROE', '安全边际', '护城河', '股息率', '资产配置', '再平衡', '市场周期', '行为金融', '风险溢价'],
  'fishing': ['钓点', '钓饵', '钓组', '调漂', '鱼情', '气压', '水温', '溶氧', '台钓', '路亚', '海钓', '矶钓', '夜钓', '打窝', '遛鱼', '爆护', '切线'],
  'fitness': ['有氧', '无氧', '力量训练', 'HIIT', '核心', '肌群', '组数', '次数', 'RM', '蛋白质', '碳水', '补剂', '拉伸', '恢复', '体脂率', '代谢', '超量恢复', '平台期'],
  'pet': ['品种', '疫苗', '驱虫', '绝育', '社会化', '正向训练', '营养', '毛发护理', '行为问题', '分离焦虑', '老年护理', '急救', '体检', '保险', '寄养'],
  'fashion': ['高定', '成衣', '快时尚', '可持续时尚', '极简主义', '复古', '街头风格', '色彩搭配', '面料', '剪裁', '廓形', '配饰', '流行趋势', '时装周', '设计师品牌'],
  'outfit': ['色彩搭配', '体型分析', '场合着装', '胶囊衣橱', '基础款', '叠穿', '比例', '配饰点缀', '季节穿搭', '风格定位', '梨形', '苹果型', '沙漏型', '直筒型', '混搭'],
  'decoration': ['硬装', '软装', '收纳', '动线', '采光', '通风', '配色', '材料', '北欧风', '日式', '极简', '工业风', '新中式', '智能家居', '预算', '水电改造', '环保等级'],
  'glassFiber': ['玻璃纤维', '复合材料', '拉丝工艺', '浸润剂', '玻纤布', '短切毡', '直接纱', '合股纱', 'SMC', 'BMC', 'FRP', '热固性', '热塑性', '强度', '模量'],
  'resin': ['环氧树脂', '不饱和聚酯', '乙烯基酯', '酚醛树脂', '固化剂', '促进剂', '凝胶时间', '放热峰', '粘度', '玻纤增强', '浇铸', '层压', 'RTM', '拉挤', 'SMC'],
  'tax': ['增值税', '所得税', '个税', '专项扣除', '汇算清缴', '税负率', '进项', '销项', '小规模', '一般纳税人', '税收优惠', '税务筹划', '发票', '申报', '稽查'],
  'law': ['侵权', '合同', '物权', '债权', '婚姻家庭', '继承', '劳动法', '知识产权', '诉讼时效', '举证责任', '仲裁', '调解', '法律援助', '诚信原则', '公序良俗'],
  'stock': ['K线', '均线', 'MACD', 'KDJ', '成交量', '换手率', '涨停', '跌停', '盘口', '多头', '空头', '趋势', '震荡', '突破', '支撑', '压力', '仓位', '止损', '止盈'],
  'economics': ['GDP', 'CPI', 'PMI', 'M2', '利率', '汇率', '供给侧', '需求侧', '边际效用', '机会成本', '比较优势', '市场失灵', '外部性', '博弈论', '凯恩斯', '货币主义'],
  'business': ['商业模式', '核心竞争力', '护城河', '蓝海战略', '精益创业', 'MVP', 'PMF', '增长黑客', 'SWOT', '波特五力', '价值链', '品牌资产', '客户终身价值', '净推荐值'],
  'news': ['头条', '深度报道', '评论', '独家', '快讯', '通讯社', '调查报道', '数据新闻', '媒体融合', '议程设置', '信息茧房', '事实核查', '假新闻', '公信力', '舆论'],
  'fortune': ['易经', '六十四卦', '爻辞', '卦象', '阴阳', '五行', '天干地支', '紫微斗数', '风水', '命理', '相生相克', '变卦', '本卦', '互卦', '综卦', '错卦'],
  'history': ['朝代', '年号', '制度', '变法', '战争', '人物', '文明', '考古', '文献', '断代', '编年', '纪传', '通史', '断代史', '一手史料', '史学理论'],
  'military': ['战略', '战术', '战役', '兵种', '装备', '制空权', '制海权', '信息战', '电子战', '特种作战', '孙子兵法', '克劳塞维茨', '地缘政治', '威慑', '非对称'],
  'wisdomBag': ['格言', '谚语', '俗语', '处世哲学', '人生智慧', '情商', '逆商', '格局', '认知升级', '思维模型', '批判性思维', '系统思考', '复盘', '元认知', '成长型思维'],
  'robotAi': ['大语言模型', '神经网络', '深度学习', '强化学习', 'Transformer', 'GPT', '提示工程', '微调', '嵌入', 'Token', '注意力机制', '扩散模型', 'AGI', '对齐', '可解释性'],
  'americanExpert': ['宪法', '联邦制', '三权分立', '选举人团', '移民', '多元文化', '硅谷', '华尔街', '好莱坞', '常春藤', '美国梦', '民权运动', '爵士乐', '棒球', '感恩节'],
  'apple': ['通识教育', '博雅教育', '跨学科', '学习方法', '费曼技巧', '间隔重复', '主动 recall', '思维导图', '知识体系', '认知负荷', '刻意练习', '一万小时', '终身学习', '好奇心'],
  'growth': ['AARRR', '北极星指标', '留存', '激活', '推荐', '病毒系数', 'LTV', 'CAC', '漏斗', '转化', 'AB测试', '用户分层', 'RFM', '增长飞轮', 'PMF'],
  'uiDesigner': ['设计系统', '组件库', '网格', '间距', '字体层级', '色彩系统', '无障碍', '响应式', '微交互', '动效', 'Figma', '原型', '用户研究', '信息架构', '可用性测试'],
  'futures': ['保证金', '杠杆', '多头', '空头', '套期保值', '基差', '交割', '主力合约', '移仓换月', 'CTA', '趋势跟踪', '套利', '波动率', '持仓量', '涨跌停板'],
  'freud': ['潜意识', '本我', '自我', '超我', '力比多', '俄狄浦斯', '梦的解析', '自由联想', '移情', '防御机制', '压抑', '投射', '升华', '口欲期', '肛欲期'],
  'fashionBrand': ['奢侈品牌', '百年工坊', '设计师', '限量款', '经典款', '高定', '皮具', '腕表', '珠宝', '香氛', '品牌故事', '工艺传承', '时尚遗产', '旗舰店', '时装周'],
  'xinStudy': ['致良知', '知行合一', '心即理', '格物', '良知', '本心', '四句教', '事上磨练', '省察克治', '万物一体', '岩中花树', '王阳明', '陆九渊', '心外无物', '诚意'],
  'liStudy': ['格物致知', '正心诚意', '天理', '理一分殊', '主敬', '存天理灭人欲', '太极', '理气', '心统性情', '朱熹', '程颢', '程颐', '周敦颐', '四书集注', '白鹿洞书院'],
  'anthropologist': ['文化相对主义', '民族志', '田野调查', '仪式', '亲属制度', '图腾', '交换', '文化适应', '文化进化', '结构主义', '功能主义', '象征', '他者', '全球化'],
  'geographer': ['板块构造', '气候带', '地貌', '水文', '生态系统', '人口分布', '城市化', 'GIS', '遥感', '可持续发展', '资源', '自然灾害', '人文地理', '自然地理'],
  'historian': ['一手史料', '二手文献', '考据', '断代', '年鉴学派', '微观史', '全球史', '口述史', '考古', '档案', '史学方法', '历史解释', '因果关系', '长时段', '记忆研究'],
  'narratologist': ['叙事者', '隐含作者', '受述者', '聚焦', '故事', '话语', '时间', '顺序', '时长', '频率', '不可靠叙述', '元叙事', '叙事层', '人物', '情节'],
  'psychologist': ['认知', '行为', '情绪', '动机', '人格', '发展', '社会认知', '归因', '刻板印象', '服从', '从众', '认知失调', '自我效能', '习得性无助', '正念', '依恋'],
  'softwareArchitect': ['微服务', '单体', 'SOA', 'DDD', 'CQRS', '事件溯源', '六边形架构', '整洁架构', 'CAP', '分布式', '高可用', '容错', '扩展性', '耦合', '内聚'],
  'solidityEngineer': ['智能合约', 'EVM', 'Gas', 'ERC20', 'ERC721', 'DeFi', 'DAO', '预言机', '闪电贷', 'AMM', '流动性挖矿', '重入攻击', '审计', '代理模式', '多签'],
  'xiaohongshuExpert': ['种草', '笔记', '封面', '标题', '标签', '互动率', '涨粉', '品牌合作', '薯条', '薯店', '内容种草', '素人', 'KOL', 'KOC', '蒲公英', '聚光'],
  'seoExpert': ['关键词', '外链', '内链', '锚文本', '爬虫', '索引', '排名因素', 'EAT', '核心网页指标', '移动优先', '结构化数据', 'SERP', '白帽', '灰帽', '黑帽', '站内优化'],
  'idiom': ['歇后语', '谚语', '俗语', '成语', '俚语', '谜语', '绕口令', '双关', '谐音', '民间故事', '典故', '口头禅', '俏皮话', '地方话', '智慧结晶'],
  'official': ['向上管理', '向下沟通', '时间管理', '目标管理', 'OKR', 'KPI', '复盘', '跨部门协作', '领导力', '执行力', '演讲', '谈判', '职场礼仪', '职业规划', '人脉'],
  'handling': ['人情世故', '察言观色', '换位思考', '边界感', '沟通艺术', '冲突化解', '情绪管理', '进退有度', '分寸感', '同理心', '包容', '圆融', '厚道', '格局', '智慧'],
  'floral': ['花材', '花器', '花型', '配色', '比例', '插花流派', '池坊', '小原流', '草月流', '欧式', '韩式', '保鲜', '花语', '季节花', '架构'],
  'career': ['简历', '面试', '职业规划', '跳槽', '薪资谈判', '行业选择', '技能树', '人脉', 'Networking', '个人品牌', '终身学习', '职业倦怠', '副业', '自由职业', '远程办公'],
};

class AiService {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));


  Future<DailyContent> generateContent({
    required String moduleId,
    required String prompt,
    required List<FallbackContent> fallback,
  }) async {
    try {
      _logger.d('AI generating content for module: $moduleId');
      _logger.d('Prompt for module $moduleId: $prompt');

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
          extra: response,
        );

        final dataService = DataService();
        await dataService.saveDailyContent(moduleId, content.toJson());
        _logger.d('AI content generated and cached for module: $moduleId');


        //同步上传到云数据库
        final Module? module = findModuleById(moduleId);
        if(module != null){
          debugPrint(module.collection);
          debugPrint(response.toString());

          final result = await addModelData(module.collection, response);
          _logger.d('db result id $result');
        }

        return content;
      }
    } catch (e) {
      _logger.e('AI generation failed for module $moduleId: $e');
    }

    return _useFallback(moduleId, fallback);
  }

  String _buildDomainEnrichment(String moduleId) {
    final module = findModuleById(moduleId);
    if (module == null) return '';

    final concepts = _domainConcepts[moduleId];
    final tags = module.aiTags.join('、');
    final name = module.name;
    final slogan = module.slogan;

    final buf = StringBuffer();
    buf.writeln();
    buf.writeln('【领域知识增强】');
    buf.writeln('你是「$name」领域的资深专家，该领域的核心标签为：$tags。');
    buf.writeln('请确保生成的内容体现该领域的专业深度：');
    buf.writeln('1. 自然融入该领域的专业术语和核心概念，让内容具有权威感');
    buf.writeln('2. 体现该领域的思维方式和分析框架：$slogan');
    if (concepts != null && concepts.isNotEmpty) {
      buf.writeln('3. 以下是该领域的重要概念和术语，请在内容中自然地融入其中若干个：${concepts.join('、')}');
      buf.writeln('4. 可以引用该领域公认的经典理论、重要人物、里程碑事件或行业常识');
      buf.writeln('5. 让读者在阅读中不仅获得新知，还能感受到该领域的知识体系和脉络');
    } else {
      buf.writeln('3. 引用该领域公认的经典理论、重要人物、里程碑事件或行业常识');
      buf.writeln('4. 让读者在阅读中不仅获得新知，还能感受到该领域的知识体系和脉络');
    }
    buf.writeln('6. 内容要有深度但不晦涩，让非专业人士也能理解并产生兴趣');

    return buf.toString();
  }

  String _buildDedupPrompt(List<Map<String, dynamic>> recentHistory) {
    if (recentHistory.isEmpty) return '';

    final buf = StringBuffer();
    buf.writeln();
    buf.writeln('【内容去重指令 ★重要★】');
    buf.writeln('以下是近期已生成过的内容，必须严格避免重复：');

    for (int i = 0; i < recentHistory.length; i++) {
      final entry = recentHistory[i];
      final title = entry['title']?.toString() ?? '';
      final subtitle = entry['subtitle']?.toString() ?? '';
      final category = entry['category']?.toString() ?? '';
      if (title.isNotEmpty) {
        buf.writeln('${i + 1}. 标题:「$title」${subtitle.isNotEmpty ? ' 副标题:「$subtitle」' : ''}${category.isNotEmpty ? ' 分类:「$category」' : ''}');
      }
    }

    buf.writeln();
    buf.writeln('请严格遵守以下去重规则：');
    buf.writeln('1. 新生成内容的标题必须与上述所有历史标题完全不同，不能只是换了一种说法');
    buf.writeln('2. 选择与上述历史内容不同的角度、概念或切入点');
    buf.writeln('3. 如果该领域有多个分支/流派，优先选择近期未涉及的方向');
    buf.writeln('4. 即使是相同主题，也要从全新视角或更深层次进行解读');

    return buf.toString();
  }

  Future<Map<String, dynamic>?> _callHunyuanModel(
    String moduleId,
    String prompt,
  ) async {
    try {

      var systemPrompt = await getLocalGeneratePrompt(moduleId, forceRefresh:false);

      if (systemPrompt == null) {
        debugPrint('未找到 AI Prompt: $moduleId');
        systemPrompt=prompt;
      }

      // 注入领域知识增强
      final enrichment = _buildDomainEnrichment(moduleId);
      if (enrichment.isNotEmpty) {
        systemPrompt = '$systemPrompt\n$enrichment';
        _logger.d('Domain enrichment injected for module: $moduleId');
      }

      // 注入内容去重指令（基于近期已生成的内容）
      final recentHistory = await DataService().getRecentContentHistory(moduleId);
      final dedupPrompt = _buildDedupPrompt(recentHistory);
      if (dedupPrompt.isNotEmpty) {
        systemPrompt = '$systemPrompt\n$dedupPrompt';
        _logger.d('Dedup prompt injected for module: $moduleId (${recentHistory.length} recent entries)');
      }

      // 构建用户提示词，包含去重要求
      var userMessage = '生成今日内容';
      if (recentHistory.isNotEmpty) {
        final recentTitles = recentHistory
            .map((e) => e['title']?.toString() ?? '')
            .where((t) => t.isNotEmpty)
            .take(5)
            .join('」、「');
        if (recentTitles.isNotEmpty) {
          userMessage = '请生成今日内容，注意避免与以下近期内容重复：「$recentTitles」';
        }
      }

      // Use xclaw API (non-streaming) as primary
      final contentStr =
          await generateTextXclaw(
            model: 'hunyuan-exp',
            subModel: 'hunyuan-turbos-latest',
            messages: [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userMessage},
            ],
          ) ??
          await generateTextWithLocalPrompt(moduleId, userPrompt: userMessage) ??
          await streamTextWithCloudPrompt(moduleId, userPrompt: userMessage) ??
          await streamTextWithSystemPrompt(prompt, userPrompt: userMessage);

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

      if (json != null){

        debugPrint('解析AI 内容为JSON Parsed AI content as JSON: $json');
        return json;
      }
      debugPrint('没有解析AI 内容为JSON Parsed AI content as JSON: $json');
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


  String sanitizeJsonString(String input) {
  final buffer = StringBuffer();
  bool inString = false;

  for (int i = 0; i < input.length; i++) {
    final char = input[i];

    // 判断字符串开始/结束
    if (char == '"') {
      final isEscaped = i > 0 && input[i - 1] == '\\';
      if (!isEscaped) {
        inString = !inString;
      }
      buffer.write(char);
      continue;
    }

    if (inString) {
      // ⭐ 修复换行
      if (char == '\n') {
        buffer.write(r'\n');
        continue;
      }
      if (char == '\r') {
        buffer.write(r'\r');
        continue;
      }

      // ⭐ 修复未转义引号（核心🔥）
      if (char == '"' && (i == 0 || input[i - 1] != '\\')) {
        buffer.write(r'\"');
        continue;
      }
    }

    buffer.write(char);
  }

  return buffer.toString();
}
  Map<String, dynamic>? _tryParseJson(String str) {
    debugPrint('尝试解析AI内容为JSON: $str');

    try {
      // 1️⃣ 去掉 markdown 包裹
      var cleaned = str
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // 2️⃣ 提取 JSON 主体
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        cleaned = cleaned.substring(start, end + 1);
      }

      // 3️⃣ ⭐ 修复非法换行（关键）
      cleaned = sanitizeJsonString(cleaned);

      // 4️⃣ 解析
      return Map<String, dynamic>.from(jsonDecode(cleaned));
    } catch (e) {
      debugPrint('JSON解析失败: $e');
      return null;
    }
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

    final lastModule = findModuleById(moduleId);

    return DailyContent(
      id: '${moduleId}_default_${DateTime.now().millisecondsSinceEpoch}',
      moduleId: moduleId,
      title: lastModule?.slogan ?? '暂无内容',
      content: lastModule?.placeholderText ?? '暂无内容，请稍后再试',
      date: DateTime.now(),
      isAiGenerated: false,
    );
  }
}