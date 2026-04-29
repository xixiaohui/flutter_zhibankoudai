import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/x_design.dart' as xui;
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
      backgroundColor: xui.XuiTheme.warmCream,
      appBar: AppBar(
        backgroundColor: xui.XuiTheme.pureWhite,
        elevation: 0,
        foregroundColor: xui.XuiTheme.clayBlack,
        title: const Text("AI材料助手"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: xui.XuiTheme.oatBorder),
        ),
      ),
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
                      decoration: xui.XuiTheme.inputDecoration(
                        hintText: "输入材料问题...",
                      ).copyWith(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: xui.XuiTheme.oatBorder, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: xui.XuiTheme.oatBorder, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFF146EF5), width: 2),
                        ),
                      ),
                      onSubmitted: sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: xui.XuiTheme.blueberry800,
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
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: isUser
              ? xui.XuiTheme.slushie500
              : xui.XuiTheme.pureWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: xui.XuiTheme.oatBorder, width: 1),
          boxShadow: xui.XuiTheme.clayShadow,
        ),
        child: isUser
            ? Text(
                message.content,
                style: xui.XuiTheme.body().copyWith(color: xui.XuiTheme.pureWhite),
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

