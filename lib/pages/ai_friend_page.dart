import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/chat_message.dart';
import '../services/cloudbase_ai.dart';
import '../widgets/chat_bubble.dart';

// ============================================================================
// 1. 可配置的 Prompt 模板 — 不写死，全部通过 AIFriendConfig 注入
// ============================================================================

class AIFriendConfig {
  final String systemPrompt;
  final String safetyPrompt;
  final Map<String, ScenePromptConfig> scenePrompts;
  final int memoryRounds;
  final String model;
  final String subModel;

  const AIFriendConfig({
    required this.systemPrompt,
    required this.safetyPrompt,
    required this.scenePrompts,
    this.memoryRounds = 5,
    this.model = AppConstants.defaultModel,
    this.subModel = AppConstants.defaultSubModel,
  });

  factory AIFriendConfig.fromJson(Map<String, dynamic> json) {
    return AIFriendConfig(
      systemPrompt: json['systemPrompt'] ?? '',
      safetyPrompt: json['safetyPrompt'] ?? '',
      scenePrompts: (json['scenePrompts'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, ScenePromptConfig.fromJson(v)),
      ) ?? {},
      memoryRounds: json['memoryRounds'] ?? 5,
      model: json['model'] ?? AppConstants.defaultModel,
      subModel: json['subModel'] ?? AppConstants.defaultSubModel,
    );
  }

  Map<String, dynamic> toJson() => {
    'systemPrompt': systemPrompt,
    'safetyPrompt': safetyPrompt,
    'scenePrompts': scenePrompts.map((k, v) => MapEntry(k, v.toJson())),
    'memoryRounds': memoryRounds,
    'model': model,
    'subModel': subModel,
  };

  /// 默认配置 — 可通过 JSON 文件覆盖
  static const AIFriendConfig defaultConfig = AIFriendConfig(
    systemPrompt: '''
你是"小智"，一位温暖、善解人意的情感陪伴助手。
- 你的语气温柔、真诚，像一位知心朋友。
- 你会认真倾听用户的情绪和感受，给予共情和支持。
- 你不会说教，而是以陪伴者的姿态与用户交流。
- 你的回答简洁有力，通常在 2-5 句话之间。
- 适当使用表情符号来传递温暖。
- 当用户情绪低落时，你会给予安慰和鼓励。
- 当用户开心时，你会一起分享喜悦。
- 你始终尊重用户，保护用户的隐私和感受。
- 【危机响应准则】当用户表达自残、轻生、极端绝望或明确求助时：
  1. 首先给予强烈的共情（"你现在的感受真的很沉重，我很在意你"）
  2. 不提供任何解决方案，不走说教路线，不轻描淡写
  3. 引导向现实中的专业帮助（"如果可以的话，考虑联系身边信任的人，或者专业心理热线"）
  4. 告诉用户"你不需要一个人扛，这个世界上有人在乎你"''',

    safetyPrompt: '''
【安全规则 — 必须遵守】

⚠️ 危机响应协议（最高优先级）：
当用户表达以下任一情况时必须触发：
  - 自残倾向 / 不想活
  - 极端绝望（"活不下去了""没意义了""一切都完了"）
  - 明确求助（"救救我""帮帮我""撑不住了"）

触发后严格执行：
  1. 强共情（最重要）：先接纳情绪，让用户感到被理解，不评判、不说教。
     参考话术：
     · "你现在的感受真的很沉重，我很在意你。"
     · "谢谢你告诉我这些，我知道这很不容易。"
     · "这段时间你一定过得很辛苦，我在这里陪着你。"
  2. 不提供解决方案：不要建议"去散散心""多运动""看开点"，这会让对方感到被轻视。
  3. 引导现实帮助：
     参考话术：
     · "如果可以的话，考虑联系身边信任的人，或者专业心理热线。"
     · "你不需要一个人扛，这个世界上有人在乎你。"
     · "全国心理援助热线：12355；希望24热线：400-161-9995。"
  4. 表达希望：在上述步骤之后，才能简短表达"感受会变化，痛苦会过去"。

通用安全规则：
- 不提供医疗、法律、金融等专业建议，建议咨询相关专业人士。
- 不对用户的重大人生决策给出确定性建议。
- 不鼓励任何违法行为或伤害行为。
- 如遇到超出能力范围的问题，诚实说明并建议寻求专业渠道。''',

    scenePrompts: {
      'greeting': ScenePromptConfig(
        name: '初次问候',
        prompt: '用户刚刚打开对话，这是今天第一次交流。请主动打招呼，用温暖的方式开启今天的对话，可以问问用户今天过得怎么样。',
        triggerKeywords: ['你好', '嗨', 'hi', 'hello', '在吗', '早上好', '下午好', '晚上好'],
      ),
      'crisis': ScenePromptConfig(
        name: '危机干预',
        prompt: '''
⚠️ 用户正在表达强烈的痛苦或危机信号（自残/轻生/极端绝望/明确求助）。
你必须严格执行以下步骤，不得跳过或颠倒顺序：

1. 强共情 — 这是最关键的一步：
   - "你现在的感受真的很沉重，我很在意你。"
   - "谢谢你告诉我这些，我知道这很不容易。"
   - "这段时间你一定过得很辛苦，我在这里陪着你。"
2. 不提供解决方案 — 绝对不要说"出去走走""看开点""多运动"之类的话。
3. 引导现实帮助 — 在共情充分建立之后：
   - "如果可以的话，考虑联系身边信任的人，或者专业心理热线。"
   - "你不需要一个人扛，这个世界上有人在乎你。"
   - "全国心理援助热线：12355；希望24热线：400-161-9995。"
4. 表达希望 — 最后简短表达"感受会变化，痛苦会过去"。
''',
        triggerKeywords: ['不想活', '想死', '自杀', '自残', '活不下去', '没意义了', '一切都完了', '救救我', '帮帮我', '撑不住了', '结束一切', '离开这个世界', '解脱', '绝望', '崩溃', '走投无路', '活着好累', '没有希望', '活下去'],
      ),
      'comfort': ScenePromptConfig(
        name: '情绪安抚',
        prompt: '用户看起来情绪低落，需要安慰和陪伴。请以共情的方式回应，先接纳用户的情绪，再温柔地给予支持。不要急于给出建议或解决方案。',
        triggerKeywords: ['难过', '伤心', '哭', '不开心', '郁闷', '焦虑', '压力', '累', '烦', '失落', '痛苦', '失眠'],
      ),
      'celebration': ScenePromptConfig(
        name: '分享喜悦',
        prompt: '用户有好消息要分享！请由衷地为用户感到高兴，用热情但不夸张的方式回应，鼓励用户多分享细节。',
        triggerKeywords: ['开心', '高兴', '太好了', '好消息', '成功', '通过', '拿到', '升职', '加薪', '表白', '恋爱', '幸福'],
      ),
      'daily_chat': ScenePromptConfig(
        name: '日常闲聊',
        prompt: '这是一段轻松的日常对话。请以自然、放松的方式回应，可以适当分享一些有趣的小知识或温暖的观察。',
        triggerKeywords: [],
      ),
      'deep_talk': ScenePromptConfig(
        name: '深度交流',
        prompt: '用户想要进行更有深度的交流，可能探讨人生、情感、成长等话题。请认真思考后再回应，展现出你的洞察力和理解力。',
        triggerKeywords: ['人生', '意义', '成长', '未来', '梦想', '孤独', '迷茫', '选择', '改变', '为什么', '怎么办'],
      ),
      'companion': ScenePromptConfig(
        name: '安静陪伴',
        prompt: '用户可能只是想要有人陪着，不需要太多的建议或分析。请以安静、温柔的方式陪伴，回应简短而温暖。',
        triggerKeywords: ['无聊', '没事', '随便聊聊', '陪我', '一个人'],
      ),
    },
  );

  /// 从 JSON 字符串加载配置
  factory AIFriendConfig.fromJsonString(String jsonStr) {
    return AIFriendConfig.fromJson(jsonDecode(jsonStr));
  }
}

class ScenePromptConfig {
  final String name;
  final String prompt;
  final List<String> triggerKeywords;

  const ScenePromptConfig({
    required this.name,
    required this.prompt,
    required this.triggerKeywords,
  });

  factory ScenePromptConfig.fromJson(Map<String, dynamic> json) {
    return ScenePromptConfig(
      name: json['name'] ?? '',
      prompt: json['prompt'] ?? '',
      triggerKeywords: (json['triggerKeywords'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'prompt': prompt,
    'triggerKeywords': triggerKeywords,
  };
}

// ============================================================================
// 2. 情绪识别 — 简单关键词分类
// ============================================================================

enum EmotionType {
  crisis('🆘', '危机信号'),
  happy('😊', '开心'),
  sad('😢', '难过'),
  anxious('😰', '焦虑'),
  angry('😤', '生气'),
  calm('😌', '平静'),
  neutral('💭', '中性'),
  excited('🎉', '兴奋'),
  tired('😴', '疲惫');

  final String emoji;
  final String label;
  const EmotionType(this.emoji, this.label);
}

class EmotionClassifier {
  static const Map<EmotionType, List<String>> _emotionKeywords = {
    EmotionType.crisis: ['不想活', '想死', '自杀', '自残', '活不下去', '没意义了', '一切都完了',
      '救救我', '帮帮我', '撑不住了', '结束一切', '离开这个世界', '解脱',
      '走投无路', '活着好累', '没有希望', '活下去', '求求你'],
    EmotionType.happy: ['开心', '高兴', '快乐', '幸福', '美好', '棒', '赞', '哈哈', '嘻嘻', '嘿嘿', '太好了', '不错', '喜欢', '满足', '感恩'],
    EmotionType.sad: ['难过', '伤心', '哭', '泪', '失落', '心碎', '心痛', '委屈', '遗憾', '可惜', '不开心'],
    EmotionType.anxious: ['焦虑', '紧张', '担心', '害怕', '不安', '慌', '压力', '烦', '愁', '失眠', '睡不着', '纠结'],
    EmotionType.angry: ['生气', '愤怒', '讨厌', '烦死了', '无语', '气', '怒', '恨', '可恶', '不爽', '受不了'],
    EmotionType.tired: ['累', '困', '疲惫', '没精神', '不想动', '懒得', '无力', '乏', '倦'],
    EmotionType.excited: ['太棒了', '太好了', '激动', '期待', '终于', '成功了', '拿到了', '通过了', '惊喜'],
    EmotionType.calm: ['没事', '还好', '随便', '都可以', '平平淡淡', '日常', '一般', '无所谓', '算了'],
  };

  static EmotionResult classify(String text) {
    final scores = <EmotionType, int>{};

    for (final entry in _emotionKeywords.entries) {
      int count = 0;
      for (final kw in entry.value) {
        if (text.contains(kw)) count++;
      }
      // 危机信号加权，确保优先识别
      if (entry.key == EmotionType.crisis && count > 0) count *= 10;
      if (count > 0) scores[entry.key] = count;
    }

    if (scores.isEmpty) return EmotionResult(EmotionType.neutral, 0);

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return EmotionResult(sorted.first.key, sorted.first.value);
  }
}

class EmotionResult {
  final EmotionType type;
  final int confidence;
  const EmotionResult(this.type, this.confidence);
}

// ============================================================================
// 3. 场景匹配
// ============================================================================

class SceneMatcher {
  /// 根据用户输入匹配最合适的场景，keyword 匹配不到时回退到 daily_chat
  static String matchScene(String userInput, Map<String, ScenePromptConfig> scenePrompts) {
    String? bestMatch;
    int bestScore = 0;

    for (final entry in scenePrompts.entries) {
      if (entry.value.triggerKeywords.isEmpty) continue;
      int score = 0;
      for (final kw in entry.value.triggerKeywords) {
        if (userInput.contains(kw)) score++;
      }
      // 危机信号加权，确保最高优先级
      if (entry.key == 'crisis' && score > 0) score *= 10;
      if (score > bestScore) {
        bestScore = score;
        bestMatch = entry.key;
      }
    }

    return bestMatch ?? 'daily_chat';
  }
}

// ============================================================================
// 4. Memory 管理
// ============================================================================

class ConversationMemory {
  final int maxRounds;
  final List<Map<String, String>> _history = [];

  ConversationMemory({this.maxRounds = 5});

  void add(String userMsg, String assistantMsg) {
    _history.add({'user': userMsg, 'assistant': assistantMsg});
    while (_history.length > maxRounds) {
      _history.removeAt(0);
    }
  }

  /// 将记忆格式化为可注入 prompt 的文本
  String formatForPrompt(AppLocalizations l10n) {
    if (_history.isEmpty) return '';
    final buf = StringBuffer();
    buf.writeln('\n${l10n.recentMemory}');
    for (int i = 0; i < _history.length; i++) {
      final round = _history[i];
      buf.writeln('${l10n.memoryUser}: ${round['user']}');
      buf.writeln('${l10n.memoryBot}: ${round['assistant']}');
    }
    buf.writeln(l10n.memoryContinue + '\n');
    return buf.toString();
  }

  void clear() => _history.clear();

  List<Map<String, String>> get history => List.unmodifiable(_history);
}

// ============================================================================
// 5. Prompt 构建器 — 三层 Prompt 组装
// ============================================================================

class PromptBuilder {
  final AIFriendConfig config;
  final ConversationMemory memory;
  String currentScene;

  PromptBuilder({
    required this.config,
    required this.memory,
    this.currentScene = 'greeting',
  });

  /// 组装完整系统 Prompt: system + scene + safety + memory
  String buildSystemPrompt(String userInput, AppLocalizations l10n) {
    currentScene = SceneMatcher.matchScene(userInput, config.scenePrompts);
    final scenePrompt = config.scenePrompts[currentScene]?.prompt ?? '';

    final buf = StringBuffer();
    buf.writeln(config.systemPrompt);
    buf.writeln('\n【当前场景】$currentScene');
    if (scenePrompt.isNotEmpty) {
      buf.writeln('【场景指引】$scenePrompt');
    }
    buf.writeln('\n${config.safetyPrompt}');

    final memText = memory.formatForPrompt(l10n);
    if (memText.isNotEmpty) buf.write(memText);

    return buf.toString();
  }

  /// 构建发送给 AI 的完整 messages 数组
  List<Map<String, String>> buildMessages(String userInput, AppLocalizations l10n) {
    return [
      {'role': 'system', 'content': buildSystemPrompt(userInput, l10n)},
      {'role': 'user', 'content': userInput},
    ];
  }
}

// ============================================================================
// 6. 聊天消息模型 — 见 lib/models/chat_message.dart
// ============================================================================

// ============================================================================
// 7. AI 好友聊天页面
// ============================================================================

class AIFriendPage extends StatefulWidget {
  final AIFriendConfig config;

  const AIFriendPage({super.key, this.config = AIFriendConfig.defaultConfig});

  @override
  State<AIFriendPage> createState() => _AIFriendPageState();
}

class _AIFriendPageState extends State<AIFriendPage> {
  static const _chatStorageKey = 'ai_friend_chat_history';

  late final AIFriendConfig _config;
  late final ConversationMemory _memory;
  late final PromptBuilder _promptBuilder;
  SharedPreferences? _prefs;
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <ChatMessage>[];
  bool _isThinking = false;
  String _currentScene = 'greeting';
  EmotionResult? _currentEmotion;

  @override
  void initState() {
    super.initState();
    _config = widget.config;
    _memory = ConversationMemory(maxRounds: _config.memoryRounds);
    _promptBuilder = PromptBuilder(config: _config, memory: _memory);
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadMessages();
  }

  void _loadMessages() {
    final raw = _prefs?.getString(_chatStorageKey);
    if (raw == null || raw.isEmpty) {
      _addGreeting();
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final loaded = list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      if (loaded.isEmpty) {
        _addGreeting();
      } else {
        setState(() => _messages.addAll(loaded));
        // 从历史消息恢复 memory
        for (int i = 0; i < loaded.length - 1; i += 2) {
          if (!loaded[i].isUser && i > 0) {
            _memory.add(loaded[i - 1].text, loaded[i].text);
          }
        }
      }
    } catch (_) {
      _addGreeting();
    }
  }

  void _addGreeting() {
    _messages.add(ChatMessage(
      text: AppLocalizations.of(context)!.aiFriendGreeting,
      isUser: false,
    ));
    _persistMessages();
  }

  Future<void> _persistMessages() async {
    if (_prefs == null) return;
    final list = _messages.map((m) => m.toJson()).toList();
    await _prefs!.setString(_chatStorageKey, jsonEncode(list));
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteChatHistory),
        content: Text(AppLocalizations.of(context)!.deleteChatConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Color(0xFFC62828))),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _prefs?.remove(_chatStorageKey);
    _memory.clear();
    setState(() {
      _messages.clear();
      _currentEmotion = null;
      _currentScene = 'greeting';
    });
    _addGreeting();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isThinking) return;

    final emotion = EmotionClassifier.classify(text);
    setState(() {
      _currentEmotion = emotion;
      _messages.add(ChatMessage(text: text, isUser: true, emotionType: emotion.type.name, emotionConfidence: emotion.confidence));
      _messages.add(ChatMessage(text: '', isUser: false));
      _isThinking = true;
      _currentScene = _promptBuilder.currentScene;
    });

    _textCtrl.clear();
    _scrollToBottom();
    _persistMessages();

    final messages = _promptBuilder.buildMessages(text, AppLocalizations.of(context)!);

    final response = await streamTextXclaw(
      model: _config.model,
      subModel: _config.subModel,
      messages: messages,
    );

    if (!mounted) return;

    setState(() {
      _isThinking = false;
      if (response != null && response.isNotEmpty) {
        _messages.last = ChatMessage(text: response, isUser: false);
        _memory.add(text, response);
      } else {
        _messages.last = ChatMessage(
          text: AppLocalizations.of(context)!.sorryCannotReply,
          isUser: false,
        );
      }
    });

    _scrollToBottom();
    _persistMessages();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('🧸', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.memoryBot, style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface)),
          ],
        ),
        actions: [
          if (_messages.length > 1)
            IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: AppLocalizations.of(context)!.deleteChatHistory,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _sceneChip(textTheme),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_currentEmotion != null && !_isThinking) _emotionBar(textTheme),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final isLoading = msg.text.isEmpty && !msg.isUser;
                return ChatBubbleWidget(
                  text: msg.text,
                  isUser: msg.isUser,
                  isLoading: isLoading,
                  avatar: ChatAvatar(
                    label: msg.isUser ? AppLocalizations.of(context)!.chatMe : AppLocalizations.of(context)!.chatBot,
                    backgroundColor: msg.isUser ? null : null,
                    textColor: Colors.white,
                  ),
                );
              },
            ),
          ),
          ChatInputBar(
            controller: _textCtrl,
            hintText: AppLocalizations.of(context)!.typeHint,
            isThinking: _isThinking,
            sendButtonColor: const Color(0xFFfbbd41),
            onSend: _sendMessage,
            leading: _sceneQuickButton(textTheme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _sceneChip(TextTheme textTheme) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (_currentScene) {
      'greeting' => l10n.sceneFirstGreeting,
      'crisis' => l10n.sceneCrisisIntervention,
      'comfort' => l10n.sceneEmotionalComfort,
      'celebration' => l10n.sceneShareJoy,
      'daily_chat' => l10n.sceneDailyChat,
      'deep_talk' => l10n.sceneDeepTalk,
      'companion' => l10n.sceneSilentCompany,
      _ => _currentScene,
    };
    final isCrisis = _currentScene == 'crisis';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCrisis ? const Color(0x33E53935) : Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(999),
        border: isCrisis ? Border.all(color: const Color(0x66E53935)) : null,
      ),
      child: Text(label, style: isCrisis
        ? textTheme.labelSmall?.copyWith(color: const Color(0xFFC62828))
        : textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
    );
  }

  Widget _emotionBar(TextTheme textTheme) {
    final e = _currentEmotion!;
    final isCrisis = e.type == EmotionType.crisis;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final emotionLabel = switch (e.type) {
      EmotionType.crisis => l10n.emotionCrisis,
      EmotionType.happy => l10n.emotionHappy,
      EmotionType.sad => l10n.emotionSad,
      EmotionType.anxious => l10n.emotionAnxious,
      EmotionType.angry => l10n.emotionAngry,
      EmotionType.calm => l10n.emotionCalm,
      EmotionType.neutral => l10n.emotionNeutral,
      EmotionType.excited => l10n.emotionExcited,
      EmotionType.tired => l10n.emotionTired,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: isCrisis ? const Color(0x1AE53935) : colorScheme.outlineVariant.withValues(alpha: 0.5),
      child: Row(
        children: [
          Text(e.type.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text('${l10n.identifyEmotion}: $emotionLabel',
            style: isCrisis
              ? textTheme.bodySmall?.copyWith(color: const Color(0xFFC62828), fontWeight: FontWeight.w600)
              : textTheme.bodySmall?.copyWith(color: colorScheme.onSurface)),
          if (!isCrisis) ...[
            const Spacer(),
            Text('${l10n.confidence}: ${e.confidence}', style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary)),
          ],
        ],
      ),
    );
  }

  Widget _sceneQuickButton(TextTheme textTheme, ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      offset: const Offset(0, -300),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.auto_awesome, size: 20, color: colorScheme.onSurfaceVariant),
      ),
      onSelected: (scene) {
        setState(() {
          _promptBuilder.currentScene = scene;
          _currentScene = scene;
        });
      },
      itemBuilder: (_) => _config.scenePrompts.entries.map((e) {
        final l10n = AppLocalizations.of(context)!;
        final label = switch (e.key) {
          'greeting' => l10n.sceneFirstGreeting,
          'crisis' => l10n.sceneCrisisIntervention,
          'comfort' => l10n.sceneEmotionalComfort,
          'celebration' => l10n.sceneShareJoy,
          'daily_chat' => l10n.sceneDailyChat,
          'deep_talk' => l10n.sceneDeepTalk,
          'companion' => l10n.sceneSilentCompany,
          _ => e.value.name,
        };
        return PopupMenuItem<String>(
          value: e.key,
          child: Text(label, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
        );
      }).toList(),
    );
  }
}
