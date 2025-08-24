import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../main_page.dart';

class ChatItem extends StatelessWidget {
  final Chat chat;
  final bool unread;

  const ChatItem({super.key, required this.chat, this.unread = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    return InkWell(
      onTap: () {},
      splashColor: Colors.black12,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: customColors?.avatarBackground ?? Colors.grey.withOpacity(0.1),
              child: Text(
                chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                if (unread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
