import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/profile/user_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../api/api_functions.dart';
import 'package:chat_app/theme/app_theme.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  TextEditingController? _searchController;
  Timer? _debounce;

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasInitiatedSearch = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController!.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController?.removeListener(_onSearchChanged);
    _searchController?.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = _searchController?.text.trim() ?? '';
      if (query.length > 1) {
        _performSearch(query);
      } else {
        setState(() {
          _users = [];
          _hasInitiatedSearch = query.isNotEmpty;
          _errorMessage = null;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasInitiatedSearch = true;
    });

    try {
      final token = await currentUser.getIdToken();
      if (token == null) {
        if (!mounted) return;
        _showErrorSnackBar("Authentication error. Please try again.");
        return;
      }

      final response = await searchUsers(query: query, token: token);
      if (!mounted) return;

      if (response['status'] == GenericResponseType.success) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(response['users'] ?? []);
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'An unknown error occurred';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Network error. Please check your connection.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                Expanded(child: _buildContent()),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Text(
            "New Message",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onSurface,
              size: 28,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

Widget _buildSearchBar() {
  final theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: Hero(
      tag: 'new-message-hero',
      flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final color = Color.lerp(
              theme.colorScheme.primary,  
              theme.colorScheme.surface,      
              animation.value,           
            );
            return Material(
              type: MaterialType.transparency,
              child: _buildSearchField(theme, color!),
            );
          },
        );
      },
      child: Material(
        type: MaterialType.transparency,
        child: _buildSearchField(theme, theme.colorScheme.surface),
      ),
    ),
  );
}

Widget _buildSearchField(ThemeData theme, Color fillColor) {
  return TextField(
    controller: _searchController,
    style: theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurface,
    ),
    decoration: InputDecoration(
      hintText: "Search by name or username",
      hintStyle: TextStyle(color: theme.hintColor),
      prefixIcon: Icon(
        Icons.search,
        color: theme.colorScheme.onSurfaceVariant,
        size: 24,
      ),
      filled: true,
      fillColor: fillColor, // <-- dynamic color
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
          color: theme.colorScheme.surfaceContainerHighest,
          width: 1,
        ),
      ),
    ),
  );
}


  Widget _buildContent() {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (_errorMessage != null) {
      return _buildInfoWidget(
        Icons.error_outline,
        _errorMessage!,
        theme.colorScheme.error,
      );
    }

    if (!_hasInitiatedSearch) {
      return _buildInfoWidget(
        Icons.search_off_rounded,
        "Search for friends or colleagues to start a new conversation.",
        theme.colorScheme.onSurfaceVariant,
      );
    }

    if (_users.isEmpty) {
      return _buildInfoWidget(
        Icons.sentiment_dissatisfied_outlined,
        "No users found. Try a different search term.",
        theme.colorScheme.onSurfaceVariant,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildUserTile(_users[index]),
    );
  }

  Widget _buildInfoWidget(IconData icon, String message, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildUserTile(Map<String, dynamic> user) {
  final theme = Theme.of(context);
  final name = user['display_name'] ?? user['username'] ?? 'N/A';
  final username = user['username'] ?? 'N/A';
  final profileUrl = user['profile_picture_url'];

  return Material(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      splashColor: theme.colorScheme.primary.withOpacity(0.1),
      highlightColor: theme.colorScheme.primary.withOpacity(0.05),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfilePage(user: user),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Hero(
              tag: '${user['id']}avatar',
              child: _buildMinimalAvatar(profileUrl, name),
            ),
            const SizedBox(width: 12),
            _buildMinimalUserText(name, username),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildMinimalAvatar(String? url, String name) {
  final theme = Theme.of(context);
  final avatarColor = Theme.of(context).extension<CustomColors>()?.avatarBackground;
  return CircleAvatar(
    radius: 26,
    backgroundColor: avatarColor,
    backgroundImage: url != null ? NetworkImage(url) : null,
    child: url == null
        ? Text(
            name.isNotEmpty ? name[0].toUpperCase() : '',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          )
        : null,
  );
}

Widget _buildMinimalUserText(String name, String username) {
  final theme = Theme.of(context);
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "@$username",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

}
