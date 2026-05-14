import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/design/colors.dart';
import 'package:flutter_application_zhiban/design/elevation.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Message {
  final String role;
  final String content;

  Message({required this.role, required this.content});

  Map<String, dynamic> toJson() => {"role": role, "content": content};

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json["role"] ?? "assistant",
      content: json["content"] ?? "",
    );
  }
}

Future<void> saveSession(List<Message> messages) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    "current_chat_session",
    jsonEncode(messages.map((e) => e.toJson()).toList()),
  );
}

Future<List<Message>> loadSession() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getString("current_chat_session");
  if (data == null) return [];
  final list = jsonDecode(data) as List;
  return list.map((e) => Message.fromJson(e)).toList();
}

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
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final history = await loadSession();
    if (!mounted) return;
    setState(() => messages = history);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), () {
      saveSession(messages);
    });
  }

  Future<void> sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty || loading) return;

    setState(() {
      messages.add(Message(role: "user", content: query));
      messages.add(Message(role: "assistant", content: ""));
      loading = true;
    });
    scheduleSave();
    _controller.clear();
    _scrollToBottom();

    final assistantIndex = messages.length - 1;
    try {
      final request = http.Request(
        "POST",
        Uri.parse("https://www.xclaw.living/api/hunyuan/ai-stream"),
      );
      request.headers["Content-Type"] = "application/json";
      request.body = jsonEncode({"query": query});

      final response = await request.send();
      String buffer = "";
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;
        if (!mounted) return;
        setState(() {
          messages[assistantIndex] = Message(role: "assistant", content: buffer);
        });
        scheduleSave();
        _scrollToBottom();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        messages[assistantIndex] = Message(role: "assistant", content: "请求失败，请稍后再试。");
      });
    }

    if (!mounted) return;
    setState(() => loading = false);
    scheduleSave();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        foregroundColor: AppColors.clayBlack,
        title: const Text("AI材料助手"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.oatBorder),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      "输入材料问题，开始分析",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.warmCharcoal),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                    itemCount: messages.length,
                    itemBuilder: (_, i) => ChatBubble(message: messages[i]),
                  ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: const BoxDecoration(
                color: AppColors.pureWhite,
                border: Border(top: BorderSide(color: AppColors.oatBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: "输入材料问题...",
                        filled: true,
                        fillColor: AppColors.pureWhite,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.oatBorder, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.oatBorder, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.focusRing, width: 2),
                        ),
                      ),
                      onSubmitted: sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    color: AppColors.pureWhite,
                    style: IconButton.styleFrom(backgroundColor: AppColors.blueberry800),
                    onPressed: loading ? null : () => sendMessage(_controller.text),
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

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == "user";
    final maxWidth = MediaQuery.sizeOf(context).width * 0.84;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: BoxConstraints(maxWidth: maxWidth.clamp(260, 640).toDouble()),
        decoration: BoxDecoration(
          color: isUser ? AppColors.slushie500 : AppColors.pureWhite,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 20),
          ),
          border: Border.all(color: AppColors.oatBorder, width: 1),
          boxShadow: AppElevation.card,
        ),
        child: isUser
            ? Text(
                message.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.pureWhite, height: 1.55),
              )
            : MarkdownBody(data: message.content),
      ),
    );
  }
}
