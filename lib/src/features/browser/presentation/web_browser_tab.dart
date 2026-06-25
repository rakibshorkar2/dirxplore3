import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../downloads/logic/download_manager.dart';

class WebBrowserTab extends ConsumerStatefulWidget {
  const WebBrowserTab({super.key});

  @override
  ConsumerState<WebBrowserTab> createState() => _WebBrowserTabState();
}

class _WebBrowserTabState extends ConsumerState<WebBrowserTab> {
  late final WebViewController _controller;
  String _currentUrl = 'https://www.google.com';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _currentUrl = url),
          onNavigationRequest: (request) {
            if (_isDownloadable(request.url)) {
              _showDownloadDialog(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));
  }

  bool _isDownloadable(String url) {
    final ext = url.split('?').first.split('.').last.toLowerCase();
    return ['mp4', 'mkv', 'zip', 'pdf', 'mp3', 'rar', '7z'].contains(ext);
  }

  void _showDownloadDialog(String url) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Download Detected'),
        content: Text('Do you want to download this file?\n\n$url'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Download'),
            onPressed: () {
              ref.read(downloadManagerProvider.notifier).startDownload(url);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_currentUrl),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () async {
            if (await _controller.canGoBack()) await _controller.goBack();
          },
        ),
      ),
      child: WebViewWidget(controller: _controller),
    );
  }
}
