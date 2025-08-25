import 'user_model.dart';

class MessageModel {
  final String id;
  final String textContent;
  final String? mediaUrl;
  final String type;
  final String chatId;
  final String senderId;
  final DateTime createdAt;
  final UserModel sender;

  const MessageModel({
    required this.id,
    required this.textContent,
    this.mediaUrl,
    required this.type,
    required this.chatId,
    required this.senderId,
    required this.createdAt,
    required this.sender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      textContent: json['text_content']?.toString() ?? '',
      mediaUrl: json['media_url']?.toString(),
      type: json['type']?.toString() ?? 'text',
      chatId: json['chat_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      sender: UserModel.fromJson(json['sender'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text_content': textContent,
      'media_url': mediaUrl,
      'type': type,
      'chat_id': chatId,
      'sender_id': senderId,
      'created_at': createdAt.toIso8601String(),
      'sender': sender.toJson(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? textContent,
    String? mediaUrl,
    String? type,
    String? chatId,
    String? senderId,
    DateTime? createdAt,
    UserModel? sender,
  }) {
    return MessageModel(
      id: id ?? this.id,
      textContent: textContent ?? this.textContent,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      type: type ?? this.type,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel &&
        other.id == id &&
        other.textContent == textContent &&
        other.mediaUrl == mediaUrl &&
        other.type == type &&
        other.chatId == chatId &&
        other.senderId == senderId &&
        other.createdAt == createdAt &&
        other.sender == sender;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      textContent,
      mediaUrl,
      type,
      chatId,
      senderId,
      createdAt,
      sender,
    );
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, textContent: $textContent, type: $type, createdAt: $createdAt)';
  }
}