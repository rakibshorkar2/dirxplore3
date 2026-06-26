import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../settings/logic/security_service.dart';

import 'glassy_nav_bar.dart';

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(securityServiceProvider.notifier).authenticate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final security = ref.watch(securityServiceProvider);
    
    if (security.isBiometricEnabled && !security.isAuthenticated) {
      return CupertinoPageScaffold(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.lock_shield, size: 64, color: CupertinoColors.activeBlue),
              const SizedBox(height: 16),
              const Text('DirXplore is Locked'),
              const SizedBox(height: 24),
              CupertinoButton.filled(
                child: const Text('Unlock'),
                onPressed: () => ref.read(securityServiceProvider.notifier).authenticate(),
              ),
            ],
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GlassyNavBar(
              currentIndex: _calculateSelectedIndex(context),
              onTap: (index) => _onItemTapped(index, context),
              items: const [
                BottomNavigationBarItem(icon: Icon(CupertinoIcons.globe)),
                BottomNavigationBarItem(icon: Icon(CupertinoIcons.compass)),
                BottomNavigationBarItem(icon: Icon(CupertinoIcons.cloud_download)),
                BottomNavigationBarItem(icon: Icon(CupertinoIcons.shield)),
                BottomNavigationBarItem(icon: Icon(CupertinoIcons.folder)),
                BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/browser')) return 0;
    if (location.startsWith('/web')) return 1;
    if (location.startsWith('/downloads')) return 2;
    if (location.startsWith('/proxy')) return 3;
    if (location.startsWith('/files')) return 4;
    if (location.startsWith('/settings')) return 5;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/browser');
        break;
      case 1:
        GoRouter.of(context).go('/web');
        break;
      case 2:
        GoRouter.of(context).go('/downloads');
        break;
      case 3:
        GoRouter.of(context).go('/proxy');
        break;
      case 4:
        GoRouter.of(context).go('/files');
        break;
      case 5:
        GoRouter.of(context).go('/settings');
        break;
    }
  }
}
