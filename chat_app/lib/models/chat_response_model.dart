import 'chat_model.dart';
import 'pagination_model.dart';

class ChatResponseModel {
  final int type;
  final PaginationModel pagination;
  final List<ChatModel> chats;

  const ChatResponseModel({
    required this.type,
    required this.pagination,
    required this.chats,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      type: json['type'] as int,
      pagination: PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>),
      chats: (json['chats'] as List<dynamic>)
          .map((chatJson) => ChatModel.fromJson(chatJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'pagination': pagination.toJson(),
      'chats': chats.map((chat) => chat.toJson()).toList(),
    };
  }

  // Helper method to check if the response is successful
  bool get isSuccess => type == 1;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatResponseModel &&
        other.type == type &&
        other.pagination == pagination &&
        other.chats.length == chats.length &&
        other.chats.every((chat) => chats.contains(chat));
  }

  @override
  int get hashCode {
    return Object.hash(type, pagination, chats);
  }

  @override
  String toString() {
    return 'ChatResponseModel(type: $type, pagination: $pagination, chats: ${chats.length} items)';
  }
}