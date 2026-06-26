import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/routing/app_router.dart';
import 'src/features/settings/logic/theme_provider.dart';

import 'src/features/downloads/logic/notification_service.dart';

import 'dart:io';
import 'src/core/network/proxy_overrides.dart';
import 'src/features/proxy/logic/proxy_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  // Create a container to read the initial proxy state
  final container = ProviderContainer();
  final proxyList = container.read(proxyManagerProvider);
  final activeProxy = proxyList.isNotEmpty 
      ? proxyList.firstWhere((p) => p.enabled, orElse: () => proxyList.first) 
      : null;

  if (activeProxy != null && activeProxy.enabled) {
    HttpOverrides.global = GlobalProxyOverrides(
      host: activeProxy.host,
      port: activeProxy.port,
      username: activeProxy.username,
      password: activeProxy.password,
    );
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DirXploreApp(),
    ),
  );
}

class DirXploreApp extends ConsumerWidget {
  const DirXploreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeBrightness = ref.watch(themeProvider);

    return CupertinoApp.router(
      title: 'DirXplore',
      theme: CupertinoThemeData(
        brightness: themeBrightness,
        primaryColor: CupertinoColors.activeBlue,
        scaffoldBackgroundColor: themeBrightness == Brightness.dark 
            ? CupertinoColors.black 
            : const CupertinoDynamicColor.withBrightness(
                color: CupertinoColors.systemGrey6,
                darkColor: CupertinoColors.black,
              ),
      ),
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
