import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NASBrowserTab extends ConsumerWidget {
  const NASBrowserTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('NAS & Storage'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.square_stack_3d_up, size: 64, color: CupertinoColors.activeBlue),
            const SizedBox(height: 16),
            const Text('SMB / FTP Support'),
            const SizedBox(height: 8),
            const Text('This feature is coming soon!', style: TextStyle(color: CupertinoColors.systemGrey)),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              child: const Text('Add Connection'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
