import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/routing/app_router.dart';
import 'src/features/settings/logic/theme_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: DirXploreApp(),
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
