import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'user_search_page.dart';
import 'widgets/chat_item.dart';
import 'widgets/top_bar_search.dart';

class Chat {
  final String name;
  final String lastMessage;
  final String time;

  Chat({required this.name, required this.lastMessage, required this.time});
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String searchQuery = '';

  final List<Chat> chats = [
    Chat(name: 'Alice', lastMessage: 'Hey, how are you?', time: '3:45 PM'),
    Chat(name: 'Bob', lastMessage: 'See you tomorrow!', time: '1:20 PM'),
    Chat(
      name: 'Charlie',
      lastMessage: 'Thanks for the help.',
      time: '11:11 AM',
    ),
    Chat(name: 'Diana', lastMessage: 'Flutter is amazing!', time: 'Yesterday'),
    Chat(
      name: 'Eve',
      lastMessage: 'Can you send me the file?',
      time: 'Yesterday',
    ),
  ];
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onBackPressed() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchFocusNode.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredChats = searchQuery.isEmpty
        ? chats
        : chats.where((chat) {
            final nameLower = chat.name.toLowerCase();
            final messageLower = chat.lastMessage.toLowerCase();
            final queryLower = searchQuery.toLowerCase();
            return nameLower.contains(queryLower) ||
                messageLower.contains(queryLower);
          }).toList();

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
                child: ListView.builder(
                  itemCount: filteredChats.length,
                  itemBuilder: (context, index) {
                    final chat = filteredChats[index];
                    return ChatItem(chat: chat);
                  },
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
}