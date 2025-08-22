import 'package:chat_app/api/api_functions.dart';
import 'package:chat_app/screens/chat_screen/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;
  const UserProfilePage({super.key, required this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isLoading = false;

  String _formatLastSeen(String? lastSeenString) {
    if (lastSeenString == null) return "Last seen recently";
    try {
      final lastSeen = DateTime.parse(lastSeenString);
      final now = DateTime.now();
      final diff = now.difference(lastSeen);

      if (diff.inMinutes < 60) {
        return "Last seen ${diff.inMinutes} min ago";
      } else if (diff.inHours < 24) {
        return "Last seen ${diff.inHours} hr ago";
      } else if (diff.inDays == 1) {
        return "Last seen yesterday";
      } else {
        return "Last seen on ${DateFormat.yMMMd().format(lastSeen)}";
      }
    } catch (e) {
      return "Last seen recently";
    }
  }

  Future<void> goToChatWithUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await currentUser.getIdToken();
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final result = await initializeChat(otherUserId: widget.user['id'], token: token);

      if (result['status'] == InitializeChatResponseType.success || 
          result['status'] == InitializeChatResponseType.alreadyPresent) {
        final chatId = result['chatId'];
        if (chatId != null && context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: chatId,
                user: widget.user,
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? "Failed to start chat. Try again.")),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = widget.user['display_name'];
    final username = widget.user['username'] ?? "Unknown";
    final profileUrl = widget.user['profile_picture_url'];
    final status = widget.user['status'] ?? "Offline";
    final lastSeen = widget.user['last_seen'];
    final createdAt = widget.user['created_at'];

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundImage:
                          profileUrl != null ? NetworkImage(profileUrl) : null,
                      backgroundColor:
                          theme.colorScheme.secondaryContainer.withOpacity(0.6),
                      child: profileUrl == null
                          ? Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : "?",
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName ?? username,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (displayName != null)
                      Text(
                        "@$username",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle,
                            size: 12,
                            color: status == "Online"
                                ? Colors.green
                                : Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          status == "Online"
                              ? "Online"
                              : _formatLastSeen(lastSeen),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Actions
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : goToChatWithUser,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.message_outlined),
                        label: Text(_isLoading ? "Loading..." : "Message"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                        shape: const CircleBorder(),
                        side: BorderSide(color: theme.dividerColor, width: 1),
                      ),
                      child: const Icon(Icons.more_vert, size: 20),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Details
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text("Joined"),
                subtitle: Text(
                  createdAt != null
                      ? DateFormat.yMMMd().format(DateTime.parse(createdAt))
                      : "Unknown",
                ),
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, top: 4),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 24,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
