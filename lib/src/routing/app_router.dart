import 'package:go_router/go_router.dart';
import '../features/main/presentation/main_screen.dart';
import '../features/browser/presentation/browser_tab.dart';
import '../features/downloads/presentation/download_tab.dart';
import '../features/proxy/presentation/proxy_tab.dart';
import '../features/files/presentation/files_tab.dart';
import '../features/settings/presentation/settings_tab.dart';

final goRouter = GoRouter(
  initialLocation: '/browser',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(
          path: '/browser',
          builder: (context, state) => const BrowserTab(),
        ),
        GoRoute(
          path: '/downloads',
          builder: (context, state) => const DownloadTab(),
        ),
        GoRoute(
          path: '/proxy',
          builder: (context, state) => const ProxyTab(),
        ),
        GoRoute(
          path: '/files',
          builder: (context, state) => const FilesTab(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsTab(),
        ),
      ],
    ),
  ],
);
