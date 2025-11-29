/// Lightweight reply info for a chat message (used when replying to another
/// message in the thread).
class ChatReplyInfo {
  final String id;
  final String sender;
  final String message;

  const ChatReplyInfo({
    required this.id,
    required this.sender,
    required this.message,
  });

  factory ChatReplyInfo.fromJson(Map<String, dynamic> json) {
    return ChatReplyInfo(
      id: json['id'] as String,
      sender: json['sender'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'message': message,
    };
  }
}

/// Single chat message for a given live event.
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isVendor;
  final ChatReplyInfo? replyTo;
  final List<String> reactions;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isVendor,
    this.replyTo,
    required this.reactions,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isVendor: json['isVendor'] as bool,
      replyTo: json['replyTo'] != null
          ? ChatReplyInfo.fromJson(json['replyTo'] as Map<String, dynamic>)
          : null,
      reactions: (json['reactions'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'isVendor': isVendor,
      'replyTo': replyTo?.toJson(),
      'reactions': reactions,
    };
  }
}


