import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatNotifierProvider = AsyncNotifierProvider<ChatNotifier, List<ChatModel>>(() {
  return ChatNotifier();
});

class ChatNotifier extends AsyncNotifier<List<ChatModel>> {
  late ChatRepository _repository;

  @override
  Future<List<ChatModel>> build() async {
    _repository = ref.read(chatRepositoryProvider);
    
    return [];
  }

  Future<void> fetchChats(String token, {int page = 1, int limit = 20}) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _repository.getAllChats(
        token: token,
        page: page,
        limit: limit,
      );
      
      if (result.isSuccess && result.data != null) {
        state = AsyncValue.data(result.data!);
      } else {
        state = AsyncValue.error(
          result.error ?? 'Failed to fetch chats',
          StackTrace.current,
        );
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh(String token) async {
    try {
      final result = await _repository.refreshChats(token: token);
      
      if (result.isSuccess && result.data != null) {
        state = AsyncValue.data(result.data!);
      } else {
        state = AsyncValue.error(
          result.error ?? 'Failed to refresh chats',
          StackTrace.current,
        );
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void addNewChat(ChatModel newChat) {
    final currentChats = state.value ?? [];
    
    if (!_repository.validateNewChat(newChat)) {
      return;
    }
    
    final existingChatIndex = currentChats.indexWhere((chat) => chat.id == newChat.id);
    if (existingChatIndex != -1) {
      updateExistingChat(newChat);
      return;
    }
    
    final updatedChats = [...currentChats, newChat];
    final sortedChats = ChatModel.sortByTimestamp(updatedChats);
    
    state = AsyncValue.data(sortedChats);
  }

  void updateChatWithNewMessage(String chatId, MessageModel newMessage) {
    final currentChats = state.value ?? [];
    
    if (!_repository.validateMessageUpdate(chatId, newMessage)) {
      return;
    }
    
    final updatedChats = currentChats.map((chat) {
      if (chat.id == chatId) {
        return chat.copyWithNewMessage(newMessage);
      }
      return chat;
    }).toList();
    
    final sortedChats = ChatModel.sortByTimestamp(updatedChats);
    
    state = AsyncValue.data(sortedChats);
  }

  void updateExistingChat(ChatModel updatedChat) {
    final currentChats = state.value ?? [];
    
    final updatedChats = currentChats.map((chat) {
      if (chat.id == updatedChat.id) {
        return updatedChat;
      }
      return chat;
    }).toList();
    
    final sortedChats = ChatModel.sortByTimestamp(updatedChats);
    
    state = AsyncValue.data(sortedChats);
  }

  void removeChat(String chatId) {
    final currentChats = state.value ?? [];
    
    final updatedChats = currentChats.where((chat) => chat.id != chatId).toList();
    
    state = AsyncValue.data(updatedChats);
  }

  void sortChatsByTimestamp() {
    final currentChats = state.value ?? [];
    final sortedChats = ChatModel.sortByTimestamp(currentChats);
    
    state = AsyncValue.data(sortedChats);
  }

  ChatModel? getChatById(String chatId) {
    final currentChats = state.value ?? [];
    try {
      return currentChats.firstWhere((chat) => chat.id == chatId);
    } catch (e) {
      return null;
    }
  }

  bool chatExists(String chatId) {
    final currentChats = state.value ?? [];
    return currentChats.any((chat) => chat.id == chatId);
  }

  int get chatCount => state.value?.length ?? 0;

  bool get isEmpty => chatCount == 0;

  bool get isLoading => state.isLoading;

  bool get hasError => state.hasError;

  String? get errorMessage => state.hasError ? state.error.toString() : null;
}

final chatsLoadingProvider = Provider<bool>((ref) {
  final chatState = ref.watch(chatNotifierProvider);
  return chatState.isLoading;
});

final chatsErrorProvider = Provider<String?>((ref) {
  final chatState = ref.watch(chatNotifierProvider);
  return chatState.hasError ? chatState.error.toString() : null;
});

final chatCountProvider = Provider<int>((ref) {
  final chatState = ref.watch(chatNotifierProvider);
  return chatState.value?.length ?? 0;
});

final chatsEmptyProvider = Provider<bool>((ref) {
  final chatState = ref.watch(chatNotifierProvider);
  return chatState.value?.isEmpty ?? true;
});