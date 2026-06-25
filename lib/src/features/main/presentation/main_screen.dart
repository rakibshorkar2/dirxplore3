import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          child,
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: CupertinoTabBar(
                  currentIndex: _calculateSelectedIndex(context),
                  onTap: (index) => _onItemTapped(index, context),
                  backgroundColor: CupertinoColors.systemBackground.withAlpha(128),
                  activeColor: CupertinoColors.activeBlue,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(CupertinoIcons.globe), label: 'Browser'),
                    BottomNavigationBarItem(icon: Icon(CupertinoIcons.cloud_download), label: 'Downloads'),
                    BottomNavigationBarItem(icon: Icon(CupertinoIcons.shield), label: 'Proxy'),
                    BottomNavigationBarItem(icon: Icon(CupertinoIcons.folder), label: 'Files'),
                    BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: 'Settings'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/browser')) return 0;
    if (location.startsWith('/downloads')) return 1;
    if (location.startsWith('/proxy')) return 2;
    if (location.startsWith('/files')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/browser');
        break;
      case 1:
        GoRouter.of(context).go('/downloads');
        break;
      case 2:
        GoRouter.of(context).go('/proxy');
        break;
      case 3:
        GoRouter.of(context).go('/files');
        break;
      case 4:
        GoRouter.of(context).go('/settings');
        break;
    }
  }
}
