import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/career.dart';
import '../models/chat_message.dart';
import '../services/cloudbase_ai.dart';
import '../widgets/chat_bubble.dart';

class AICareerDetailPage extends StatefulWidget {
  final Career career;

  const AICareerDetailPage({super.key, required this.career});

  @override
  State<AICareerDetailPage> createState() => _AICareerDetailPageState();
}

class _AICareerDetailPageState extends State<AICareerDetailPage> {
  late final Career _career;
  late final String _storageKey;
  SharedPreferences? _prefs;
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <ChatMessage>[];
  final _history = <Map<String, String>>[];
  bool _isThinking = false;

  @override
  void initState() {
    super.initState();
    _career = widget.career;
    _storageKey = 'career_chat_${_career.id}';
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadMessages();
  }

  void _loadMessages() {
    final raw = _prefs?.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      _addGreeting();
      setState(() {});
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
        for (int i = 0; i < loaded.length - 1; i += 2) {
          if (!loaded[i].isUser && i > 0) {
            _history.add({'user': loaded[i - 1].text, 'assistant': loaded[i].text});
          }
        }
      }
    } catch (_) {
      _addGreeting();
    }
  }

  void _addGreeting() {
    _messages.add(ChatMessage(
      text: '你好！我是${_career.nameZh}专家。${_career.vibeZh}',
      isUser: false,
    ));
    _persistMessages();
  }

  Future<void> _persistMessages() async {
    if (_prefs == null) return;
    final list = _messages.map((m) => m.toJson()).toList();
    await _prefs!.setString(_storageKey, jsonEncode(list));
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除聊天记录'),
        content: const Text('确定要删除所有聊天记录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: Color(0xFFC62828))),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _prefs?.remove(_storageKey);
    _history.clear();
    setState(() => _messages.clear());
    _addGreeting();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isThinking) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _messages.add(ChatMessage(text: '', isUser: false));
      _isThinking = true;
    });

    _textCtrl.clear();
    _scrollToBottom();
    _persistMessages();

    try {
      final systemPrompt = _buildSystemPrompt();
      final response = await streamTextXclaw(
        model: AppConstants.defaultModel,
        subModel: AppConstants.defaultSubModel,
        messages: [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': text},
        ],
      );

      if (!mounted) return;

      setState(() {
        _isThinking = false;
        if (response != null && response.isNotEmpty) {
          _messages.last = ChatMessage(text: response, isUser: false);
          _history.add({'user': text, 'assistant': response});
        } else {
          _messages.last = ChatMessage(text: '抱歉，我暂时无法回复。请稍后再试。', isUser: false);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isThinking = false;
        _messages.last = ChatMessage(text: '出错了：$e', isUser: false);
      });
    }

    _scrollToBottom();
    _persistMessages();
  }

  String _buildSystemPrompt() {
    final buf = StringBuffer();
    buf.writeln(_career.buildSystemPrompt());

    if (_history.isNotEmpty) {
      buf.writeln('\n【最近的对话记忆】');
      final recent = _history.length > 5 ? _history.sublist(_history.length - 5) : _history;
      for (final round in recent) {
        buf.writeln('用户: ${round['user']}');
        buf.writeln('${_career.name}: ${round['assistant']}');
      }
      buf.writeln('请基于以上对话记忆继续交流，保持上下文连贯。');
    }

    return buf.toString();
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

  Color get _accentColor {
    final c = _career.color;
    if (c.startsWith('#')) {
      final hex = c.substring(1);
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    }
    switch (c.toLowerCase()) {
      case 'purple': return Colors.purple;
      case 'cyan': return Colors.cyan;
      case 'blue': return Colors.blue;
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'orange': return Colors.orange;
      case 'pink': return Colors.pink;
      case 'teal': return Colors.teal;
      case 'amber': return Colors.amber;
      case 'indigo': return Colors.indigo;
      default: return Colors.grey;
    }
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(_career.emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _career.nameZh.isNotEmpty ? _career.nameZh : _career.name,
                    style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface),
                  ),
                  Text(_career.name, style: textTheme.labelSmall?.copyWith(color: colorScheme.secondary)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_messages.length > 1)
            IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: '删除聊天记录',
            ),
        ],
      ),
      body: Column(
        children: [
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
                    label: msg.isUser ? '我' : _career.emoji,
                    backgroundColor: msg.isUser
                        ? const Color(0xFFfbbd41)
                        : _accentColor.withValues(alpha: 0.2),
                    textColor: Colors.white,
                  ),
                );
              },
            ),
          ),
          ChatInputBar(
            controller: _textCtrl,
            hintText: '向${_career.nameZh}提问...',
            isThinking: _isThinking,
            sendButtonColor: _accentColor.withValues(alpha: 0.3),
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
