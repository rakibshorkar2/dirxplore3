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
      setState(() => _entries = entries);
    } catch (e) {
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
      setState(() => _isLoading = false);
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
