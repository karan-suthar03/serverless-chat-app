import '../api/api_functions.dart' as api_functions;
import '../models/chat_model.dart';
import '../models/pagination_model.dart';
import '../models/chat_response_model.dart';

class ChatRepository {

  static final ChatRepository _instance = ChatRepository._internal();
  factory ChatRepository() => _instance;
  ChatRepository._internal();

  Future<ChatRepositoryResult<List<ChatModel>>> getAllChats({
    required String token,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await api_functions.getAllChats(
        token: token,
        page: page,
        limit: limit,
      );

      if (result['status'] == api_functions.GetAllChatsResponseType.success) {
        final chatResponse = result['chatResponse'] as ChatResponseModel;
        final chats = chatResponse.chats;
        final pagination = chatResponse.pagination;

        final sortedChats = ChatModel.sortByTimestamp(chats);
        return ChatRepositoryResult.success(
          data: sortedChats,
          pagination: pagination,
        );
      } else {
        return ChatRepositoryResult.failure(
          error: result['message'] as String,
        );
      }
    } catch (error) {
      return ChatRepositoryResult.failure(
        error: 'Repository error: ${error.toString()}',
      );
    }
  }

  Future<ChatRepositoryResult<List<ChatModel>>> refreshChats({
    required String token,
    int page = 1,
    int limit = 20,
  }) async {
    return this.getAllChats(token: token, page: page, limit: limit);
  }

  bool validateNewChat(ChatModel newChat) {
    return newChat.id.isNotEmpty && 
           newChat.otherUser.id.isNotEmpty &&
           newChat.type.isNotEmpty;
  }

  bool validateMessageUpdate(String chatId, dynamic messageData) {
    return chatId.isNotEmpty && messageData != null;
  }

  List<ChatModel> mergeChats(List<ChatModel> existingChats, List<ChatModel> newChats) {
    final Map<String, ChatModel> chatMap = {};
    
    for (final chat in existingChats) {
      chatMap[chat.id] = chat;
    }
    
    for (final chat in newChats) {
      chatMap[chat.id] = chat;
    }
    
    return ChatModel.sortByTimestamp(chatMap.values.toList());
  }
}

class ChatRepositoryResult<T> {
  final T? data;
  final String? error;
  final PaginationModel? pagination;
  final bool isSuccess;

  const ChatRepositoryResult._({
    this.data,
    this.error,
    this.pagination,
    required this.isSuccess,
  });

  factory ChatRepositoryResult.success({
    required T data,
    PaginationModel? pagination,
  }) {
    return ChatRepositoryResult._(
      data: data,
      pagination: pagination,
      isSuccess: true,
    );
  }

  factory ChatRepositoryResult.failure({
    required String error,
  }) {
    return ChatRepositoryResult._(
      error: error,
      isSuccess: false,
    );
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ChatRepositoryResult.success(data: $data)';
    } else {
      return 'ChatRepositoryResult.failure(error: $error)';
    }
  }
}