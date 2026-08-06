import 'package:flutter/material.dart';
import '../chat/chat_view.dart';
import 'widgets/sidebar_drawer.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: const [
            SizedBox(
              width: 280,
              child: SidebarDrawer(),
            ),
            VerticalDivider(width: 1, thickness: 0.5),
            Expanded(
              child: ChatView(),
            ),
          ],
        ),
      );
    }

    return const Scaffold(
      drawer: SidebarDrawer(),
      body: ChatView(),
    );
  }
}
