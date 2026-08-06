import 'attachment_model.dart';

class ChatMessageModel {
  final String id;
  final String conversationId;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  final bool isPending;
  final List<AttachmentModel>? attachments;

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.isPending = false,
    this.attachments,
  });

  ChatMessageModel copyWith({
    String? id,
    String? conversationId,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    bool? isError,
    bool? isPending,
    List<AttachmentModel>? attachments,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      isPending: isPending ?? this.isPending,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
      'isPending': isPending,
      'attachments': attachments?.map((a) => a.toJson()).toList(),
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isError: json['isError'] as bool? ?? false,
      isPending: json['isPending'] as bool? ?? false,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((a) => AttachmentModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}
