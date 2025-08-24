import 'package:flutter/material.dart';

class TopBarSearch extends StatelessWidget {
  final bool isSearching;
  final TextEditingController controller;
  final FocusNode focusNode; // <--- new
  final VoidCallback onBack;
  final VoidCallback onSearchTap;

  const TopBarSearch({
    super.key,
    required this.isSearching,
    required this.controller,
    required this.focusNode,
    required this.onBack,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          height: isSearching ? 0 : 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Chat App",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.more_vert, color: theme.colorScheme.onBackground),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: isSearching,
            onTap: onSearchTap,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: "Search by name or username",
              hintStyle: TextStyle(color: theme.hintColor),
              prefixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  final curvedAnim = CurvedAnimation(
                    parent: animation,
                    curve: Curves.fastOutSlowIn,
                  );
                  return ScaleTransition(
                    scale: curvedAnim,
                    child: FadeTransition(opacity: curvedAnim, child: child),
                  );
                },
                child: isSearching
                    ? IconButton(
                        key: const ValueKey('back'),
                        icon: Icon(
                          Icons.arrow_back,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: onBack,
                      )
                    : Icon(
                        Icons.search,
                        key: const ValueKey('search'),
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 0,
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
          ),
        ),
      ],
    );
  }
}
