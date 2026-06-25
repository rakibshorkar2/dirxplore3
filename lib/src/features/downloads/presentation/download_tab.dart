import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/download_manager.dart';

class DownloadTab extends ConsumerWidget {
  const DownloadTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadManagerProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Downloads'),
      ),
      child: SafeArea(
        child: downloads.isEmpty
            ? const Center(child: Text('No active downloads'))
            : ListView.builder(
                itemCount: downloads.length,
                itemBuilder: (context, index) {
                  final task = downloads[index];
                  return CupertinoListTile(
                    title: Text(task.url.split('/').last),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${task.status}'),
                        const SizedBox(height: 4),
                        CupertinoProgressBar(value: task.progress),
                      ],
                    ),
                    trailing: Text('${(task.progress * 100).toStringAsFixed(1)}%'),
                  );
                },
              ),
      ),
    );
  }
}

class CupertinoProgressBar extends StatelessWidget {
  final double value;
  const CupertinoProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
