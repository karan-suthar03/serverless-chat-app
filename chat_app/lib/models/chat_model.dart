import 'user_model.dart';
import 'message_model.dart';

class ChatModel {
  final String id;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt; // Key for WebSocket sorting
  final String? lastMessageId;
  final UserModel otherUser;
  final MessageModel? lastMessage;

  const ChatModel({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageId,
    required this.otherUser,
    this.lastMessage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'private',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastMessageId: json['last_message_id']?.toString(),
      otherUser: UserModel.fromJson(json['other_user'] as Map<String, dynamic>? ?? {}),
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_message_id': lastMessageId,
      'other_user': otherUser.toJson(),
      'last_message': lastMessage?.toJson(),
    };
  }

  // 🚀 WebSocket-compatible method for updating with new message
  ChatModel copyWithNewMessage(MessageModel newMessage) {
    return copyWith(
      lastMessage: newMessage,
      lastMessageId: newMessage.id,
      updatedAt: newMessage.createdAt, //  Update timestamp for sorting
    );
  }

  ChatModel copyWith({
    String? id,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessageId,
    UserModel? otherUser,
    MessageModel? lastMessage,
  }) {
    return ChatModel(
      id: id ?? this.id,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      otherUser: otherUser ?? this.otherUser,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  // 🔑 Helper methods for UI display
  String get displayName => otherUser.displayName;
  String get lastMessageText => lastMessage?.textContent ?? '';
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // 🔑 Static method for sorting chats by timestamp (most recent first)
  static List<ChatModel> sortByTimestamp(List<ChatModel> chats) {
    final sortedChats = [...chats];
    sortedChats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sortedChats;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatModel &&
        other.id == id &&
        other.type == type &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.lastMessageId == lastMessageId &&
        other.otherUser == otherUser &&
        other.lastMessage == lastMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      createdAt,
      updatedAt,
      lastMessageId,
      otherUser,
      lastMessage,
    );
  }

  @override
  String toString() {
    return 'ChatModel(id: $id, type: $type, otherUser: ${otherUser.displayName}, updatedAt: $updatedAt)';
  }
}