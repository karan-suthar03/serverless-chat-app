import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_model.dart';
import 'user_search_page.dart';
import 'widgets/chat_item.dart';
import 'widgets/top_bar_search.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchChats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchChats() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return;
      }

      final token = await currentUser.getIdToken(true);
      if (token == null) {
        return;
      }

      await ref.read(chatNotifierProvider.notifier).fetchChats(token);
    } catch (error) {
      // Error handling is done in the provider
    }
  }

  void _onBackPressed() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchFocusNode.unfocus();
    });
  }

  Future<void> _onRefresh() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // User not logged in, handle accordingly
        return;
      }

      final token = await currentUser.getIdToken();
      if (token == null) {
        return;
      }

      await ref.read(chatNotifierProvider.notifier).refresh(token);
    } catch (error) {
      // Error handling is done in the provider
    }
  }

  List<ChatModel> _filterChats(List<ChatModel> chats) {
    if (searchQuery.isEmpty) {
      return chats;
    }

    final queryLower = searchQuery.toLowerCase();
    return chats.where((chat) {
      final nameLower = chat.displayName.toLowerCase();
      final messageLower = chat.lastMessageText.toLowerCase();
      return nameLower.contains(queryLower) || messageLower.contains(queryLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              TopBarSearch(
                isSearching: _isSearching,
                controller: _searchController,
                focusNode: _searchFocusNode,
                onBack: _onBackPressed,
                onSearchTap: () {
                  setState(() {
                    _isSearching = true;
                    _searchFocusNode.requestFocus();
                  });
                },
              ),
              Expanded(
                child: chatState.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => _buildErrorState(error),
                  data: (chats) => _buildChatList(chats),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: 'new-message-hero',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const UserSearchPage(),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load chats',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchChats,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(List<ChatModel> chats) {
    final filteredChats = _filterChats(chats);

    if (chats.isEmpty) {
      return _buildEmptyState();
    }

    if (filteredChats.isEmpty && searchQuery.isNotEmpty) {
      return _buildNoSearchResults();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        itemCount: filteredChats.length,
        itemBuilder: (context, index) {
          final chat = filteredChats[index];
          return ChatItem(chat: chat);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No chats yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation by tapping the + button',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}