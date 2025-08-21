import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'user_search_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: OpenContainer(
        transitionDuration: const Duration(milliseconds: 500),
        closedElevation: 6,
        closedShape: const CircleBorder(),
        closedColor: Theme.of(context).colorScheme.primary,
        closedBuilder: (_, openContainer) {
          return FloatingActionButton(
            onPressed: openContainer,
            backgroundColor: Theme.of(context).colorScheme.primary,
            tooltip: 'Add chat',
            child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
          );
        },
        openBuilder: (_, __) => const UserSearchPage(),
      ),
    );
  }
}
