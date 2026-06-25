import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/security_service.dart';
import '../logic/theme_provider.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final security = ref.watch(securityServiceProvider);
    final themeBrightness = ref.watch(themeProvider);
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
                const CupertinoListTile(
                  title: Text('Concurrent Downloads'),
                  trailing: Text('3'),
                ),
                const CupertinoListTile(
                  title: Text('Retry Count'),
                  trailing: Text('5'),
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
                  trailing: Text('1.0.0'),
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
