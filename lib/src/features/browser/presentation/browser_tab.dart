import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/crawler/directory_crawler.dart';
import '../../downloads/logic/download_manager.dart';

class BrowserTab extends ConsumerStatefulWidget {
  const BrowserTab({super.key});

  @override
  ConsumerState<BrowserTab> createState() => _BrowserTabState();
}

class _BrowserTabState extends ConsumerState<BrowserTab> {
  final TextEditingController _urlController = TextEditingController(text: 'http://172.16.50.4');
  List<DirectoryEntry> _entries = [];
  bool _isLoading = false;
  final DirectoryCrawler _crawler = DirectoryCrawler();

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final entries = await _crawler.fetchDirectory(_urlController.text);
      if (!mounted) return;
      setState(() => _entries = entries);
    } catch (e) {
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context)),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: CupertinoTextField(
          controller: _urlController,
          placeholder: 'Enter URL',
          onSubmitted: (_) => _fetch(),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.search),
          onPressed: () {
            showCupertinoModalPopup(
              context: context,
              builder: (context) => CupertinoActionSheet(
                title: const Text('Deep Scan'),
                message: const Text('Search for all files in subdirectories (up to 3 levels)'),
                actions: [
                  CupertinoActionSheetAction(
                    child: const Text('Start Deep Scan'),
                    onPressed: () async {
                      Navigator.pop(context);
                      setState(() => _isLoading = true);
                      try {
                        final entries = await _crawler.deepScan(_urlController.text);
                        setState(() => _entries = entries);
                      } catch (e) {
                        // error handling
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    },
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            );
          },
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.refresh),
          onPressed: _fetch,
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return CupertinoListTile(
                    leading: Icon(entry.isDirectory ? CupertinoIcons.folder : CupertinoIcons.doc),
                    title: Text(entry.name),
                    subtitle: entry.size != null ? Text(entry.size!) : null,
                    trailing: entry.isDirectory
                        ? const Icon(CupertinoIcons.chevron_forward)
                        : CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(CupertinoIcons.cloud_download),
                            onPressed: () {
                              ref.read(downloadManagerProvider.notifier).startDownload(entry.url);
                              showCupertinoDialog(
                                context: context,
                                builder: (context) => CupertinoAlertDialog(
                                  title: const Text('Download Started'),
                                  content: Text(entry.name),
                                  actions: [
                                    CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context)),
                                  ],
                                ),
                              );
                            },
                          ),
                    onTap: entry.isDirectory
                        ? () {
                            _urlController.text = entry.url;
                            _fetch();
                          }
                        : null,
                  );
                },
              ),
      ),
    );
  }
}
