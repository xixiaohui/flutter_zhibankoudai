import 'package:flutter/material.dart';
import '../design/radius.dart';

/// 聊天气泡组件 — ai_friend_page / ai_career_detail_page 共享

/// 消息气泡
class ChatBubbleWidget extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isLoading;
  final Widget avatar;

  const ChatBubbleWidget({
    super.key,
    required this.text,
    required this.isUser,
    required this.avatar,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            avatar,
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: isUser ? [_userBubble(context), const SizedBox(width: 8), avatar] : [avatar, const SizedBox(width: 8), _aiBubble(context)],
      ),
    );
  }

  Widget _userBubble(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFf8cc65).withValues(alpha: 0.35),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
      ),
    );
  }

  Widget _aiBubble(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: colorScheme.outline, width: 0.5),
        ),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
      ),
    );
  }
}

/// 聊天输入栏
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isThinking;
  final Color sendButtonColor;
  final ValueChanged<String> onSend;
  final Widget? leading;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isThinking,
    required this.sendButtonColor,
    required this.onSend,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outline, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Expanded(
              child: TextField(
                controller: controller,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: hintText,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.standard),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.standard),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.standard),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: onSend,
                maxLines: 3,
                minLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onSend(controller.text),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isThinking ? colorScheme.outlineVariant : sendButtonColor,
                  borderRadius: BorderRadius.circular(AppRadius.standard),
                ),
                child: Icon(
                  Icons.send_rounded,
                  size: 20,
                  color: isThinking ? colorScheme.secondary : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 聊天头像
class ChatAvatar extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const ChatAvatar({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
