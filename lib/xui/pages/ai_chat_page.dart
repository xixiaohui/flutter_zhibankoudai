import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:shared_preferences/shared_preferences.dart';

////////////////////////////////////////////////////////////
/// 🧠 Message Model
////////////////////////////////////////////////////////////
class Message {
  final String role;
  final String content;

  Message({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        "role": role,
        "content": content,
      };

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json["role"],
      content: json["content"],
    );
  }
}

////////////////////////////////////////////////////////////
/// 💾 存储
////////////////////////////////////////////////////////////
Future<void> saveSession(List<Message> messages) async {
  final prefs = await SharedPreferences.getInstance();

  final jsonList = messages.map((e) => e.toJson()).toList();

  await prefs.setString(
    "current_chat_session",
    jsonEncode(jsonList),
  );
}

Future<List<Message>> loadSession() async {
  final prefs = await SharedPreferences.getInstance();

  final data = prefs.getString("current_chat_session");

  if (data == null) return [];

  final list = jsonDecode(data) as List;

  return list.map((e) => Message.fromJson(e)).toList();
}

////////////////////////////////////////////////////////////
/// 🚀 Page
////////////////////////////////////////////////////////////
class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> messages = [];

  bool loading = false;

  ////////////////////////////////////////////////////////////
  /// 🚀 初始化加载历史
  ////////////////////////////////////////////////////////////
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final history = await loadSession();
    setState(() {
      messages = history;
    });
  }

  ////////////////////////////////////////////////////////////
  /// 🚀 保存（节流版）
  ////////////////////////////////////////////////////////////
  Timer? _saveTimer;

  void scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 1), () {
      saveSession(messages);
    });
  }


  ////////////////////////////////////////////////////////////
  /// 🚀 流式请求
  ////////////////////////////////////////////////////////////
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(Message(role: "user", content: text));
      messages.add(Message(role: "assistant", content: "")); // 占位
      loading = true;
    });

    _controller.clear();
    _scrollToBottom();

    final request = http.Request(
      "POST",
      Uri.parse("https://www.xclaw.living/api/hunyuan/ai-stream"),
    );

    request.headers["Content-Type"] = "application/json";
    request.body = jsonEncode({"query": text});

    final response = await request.send();

    String buffer = "";
    int assistantIndex = messages.length - 1;

    response.stream.transform(utf8.decoder).listen(
      (chunk) {
        buffer += chunk;

        _typewriterUpdate(buffer, assistantIndex);
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
      onError: (e) {
        setState(() {
          messages[assistantIndex] =
              Message(role: "assistant", content: "❌ 请求失败");
          loading = false;
        });
      },
    );
  }

  ////////////////////////////////////////////////////////////
  /// ✨ 打字动画（核心）
  ////////////////////////////////////////////////////////////
  void _typewriterUpdate(String fullText, int index) {
    const speed = 10; // 数值越小越快

    Timer.periodic(const Duration(milliseconds: speed), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final current = messages[index].content;

      if (current.length >= fullText.length) {
        timer.cancel();
      } else {
        setState(() {
          messages[index] = Message(
            role: "assistant",
            content: fullText.substring(0, current.length + 1),
          );
        });

        _scrollToBottom();
      }
    });
  }

  ////////////////////////////////////////////////////////////
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  ////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI材料助手")),
      body: Column(
        children: [
          //////////////////////////////////////////////////////
          /// 聊天区
          //////////////////////////////////////////////////////
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                return ChatBubble(message: messages[i]);
              },
            ),
          ),

          //////////////////////////////////////////////////////
          /// 输入区
          //////////////////////////////////////////////////////
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "输入材料问题...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onSubmitted: sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => sendMessage(_controller.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


////////////////////////////////////////////////////////////
/// 💬 气泡
////////////////////////////////////////////////////////////
class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == "user";

    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.blue
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: isUser
            ? Text(
                message.content,
                style: const TextStyle(color: Colors.white),
              )
            : _MarkdownWithCursor(text: message.content),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ✨ Markdown + 光标闪动
////////////////////////////////////////////////////////////
class _MarkdownWithCursor extends StatefulWidget {
  final String text;

  const _MarkdownWithCursor({required this.text});

  @override
  State<_MarkdownWithCursor> createState() =>
      _MarkdownWithCursorState();
}

class _MarkdownWithCursorState extends State<_MarkdownWithCursor> {
  bool showCursor = true;

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        showCursor = !showCursor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: widget.text + (showCursor ? "▍" : ""),
    );
  }
}

