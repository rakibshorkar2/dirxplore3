import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/security_service.dart';
import '../logic/theme_provider.dart';
import '../logic/settings_provider.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final security = ref.watch(securityServiceProvider);
    final themeBrightness = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);
    final isDark = themeBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('APPEARANCE'),
              children: [
                CupertinoListTile(
                  title: const Text('Dark Mode'),
                  trailing: CupertinoSwitch(
                    value: isDark,
                    onChanged: (val) {
                      ref.read(themeProvider.notifier).toggleTheme(val);
                    },
                  ),
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('SECURITY'),
              children: [
                CupertinoListTile(
                  title: const Text('FaceID / TouchID'),
                  subtitle: const Text('Secure app with biometrics'),
                  trailing: CupertinoSwitch(
                    value: security.isBiometricEnabled,
                    onChanged: (val) {
                      ref.read(securityServiceProvider.notifier).toggleBiometrics(val);
                    },
                  ),
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('GENERAL'),
              children: [
                CupertinoListTile(
                  title: const Text('Concurrent Downloads'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${settings.concurrentDownloads}'),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.minus_circle, size: 22),
                        onPressed: settings.concurrentDownloads > 1 
                          ? () => ref.read(settingsProvider.notifier).setConcurrentDownloads(settings.concurrentDownloads - 1)
                          : null,
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.plus_circle, size: 22),
                        onPressed: settings.concurrentDownloads < 10
                          ? () => ref.read(settingsProvider.notifier).setConcurrentDownloads(settings.concurrentDownloads + 1)
                          : null,
                      ),
                    ],
                  ),
                ),
                CupertinoListTile(
                  title: const Text('Retry Count'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${settings.retryCount}'),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.minus_circle, size: 22),
                        onPressed: settings.retryCount > 0 
                          ? () => ref.read(settingsProvider.notifier).setRetryCount(settings.retryCount - 1)
                          : null,
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.plus_circle, size: 22),
                        onPressed: settings.retryCount < 20
                          ? () => ref.read(settingsProvider.notifier).setRetryCount(settings.retryCount + 1)
                          : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('ABOUT'),
              children: const [
                CupertinoListTile(
                  title: Text('Developer'),
                  trailing: Text('RAKIB'),
                ),
                CupertinoListTile(
                  title: Text('Version'),
                  trailing: Text('1.2.8'),
                ),
                CupertinoListTile(
                  title: Text('DirXplore iOS'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
