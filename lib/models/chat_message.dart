/// 聊天消息模型 — ai_friend_page / ai_career_detail_page 共享
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final String? emotionType;
  final int? emotionConfidence;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? time,
    this.emotionType,
    this.emotionConfidence,
  }) : time = time ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      time: DateTime.fromMillisecondsSinceEpoch(json['time'] ?? 0),
      emotionType: json['emotionType'],
      emotionConfidence: json['emotionConfidence'],
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'time': time.millisecondsSinceEpoch,
        if (emotionType != null) 'emotionType': emotionType,
        if (emotionConfidence != null) 'emotionConfidence': emotionConfidence,
      };
}
