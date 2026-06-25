import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: downloads.length,
                itemBuilder: (context, index) {
                  final task = downloads[index];
                  final fileName = task.url.split('/').last;
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBackground.resolveFrom(context),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey.withAlpha(50),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(CupertinoIcons.doc_fill, color: CupertinoColors.activeBlue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                fileName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusBadge(task.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CupertinoProgressBar(value: task.progress),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_formatBytes(task.bytesWritten)} / ${_formatBytes(task.totalBytes)}',
                              style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                            ),
                            Text(
                              '${(task.progress * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        if (task.status == 'downloading') ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Speed: ${_formatSpeed(task.speed)}',
                                style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                              ),
                              Text(
                                'ETA: ${_calculateETA(task)}',
                                style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (task.status == 'downloading')
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: const Icon(CupertinoIcons.pause_fill, size: 20),
                                onPressed: () => ref.read(downloadManagerProvider.notifier).pauseDownload(task.id),
                              )
                            else if (task.status == 'paused')
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: const Icon(CupertinoIcons.play_fill, size: 20),
                                onPressed: () => ref.read(downloadManagerProvider.notifier).resumeTask(task.id),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'completed': color = CupertinoColors.activeGreen; break;
      case 'failed': color = CupertinoColors.destructiveRed; break;
      case 'paused': color = CupertinoColors.systemOrange; break;
      default: color = CupertinoColors.activeBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (bytes.toString().length - 1) ~/ 3;
    var res = bytes / (1024 * 1024 * 1024); // Start with GB if logic is simple
    // More precise logic:
    double doubleBytes = bytes.toDouble();
    int suffixIndex = 0;
    while (doubleBytes >= 1024 && suffixIndex < suffixes.length - 1) {
      doubleBytes /= 1024;
      suffixIndex++;
    }
    return '${doubleBytes.toStringAsFixed(1)} ${suffixes[suffixIndex]}';
  }

  String _formatSpeed(double bps) {
    if (bps <= 0) return '0 B/s';
    return '${_formatBytes(bps.toInt())}/s';
  }

  String _calculateETA(DownloadTask task) {
    if (task.speed <= 0 || task.totalBytes <= 0) return '--';
    final remainingBytes = task.totalBytes - task.bytesWritten;
    final seconds = remainingBytes / task.speed;
    if (seconds > 3600) return '${(seconds / 3600).toStringAsFixed(1)}h';
    if (seconds > 60) return '${(seconds / 60).toStringAsFixed(1)}m';
    return '${seconds.toInt()}s';
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
