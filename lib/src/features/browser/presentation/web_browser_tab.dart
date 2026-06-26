import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../downloads/logic/download_manager.dart';

import 'package:badges/badges.dart' as badges;

class WebBrowserTab extends ConsumerStatefulWidget {
  const WebBrowserTab({super.key});

  @override
  ConsumerState<WebBrowserTab> createState() => _WebBrowserTabState();
}

class _WebBrowserTabState extends ConsumerState<WebBrowserTab> {
  late final WebViewController _controller;
  String _currentUrl = 'https://www.google.com';
  final List<String> _detectedLinks = [];
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _currentUrl = url;
              _detectedLinks.clear();
            });
            _updateNavButtons();
          },
          onPageFinished: (url) {
            _snifferLinks();
          },
          onNavigationRequest: (request) {
            // Basic Ad-Blocker/Popup-Blocker logic
            if (request.url.contains('ads.') || request.url.contains('doubleclick')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));
  }

  void _updateNavButtons() async {
    final back = await _controller.canGoBack();
    final forward = await _controller.canGoForward();
    setState(() {
      _canGoBack = back;
      _canGoForward = forward;
    });
  }

  void _snifferLinks() async {
    // Inject JS to find media links
    final String js = """
      (function() {
        var links = [];
        var elements = document.getElementsByTagName('a');
        for (var i = 0; i < elements.length; i++) {
          var href = elements[i].href;
          if (href.match(/\\.(mp4|mkv|zip|pdf|mp3|rar|7z)\$/i)) {
            links.push(href);
          }
        }
        return JSON.stringify(links);
      })();
    """;
    try {
      final String result = await _controller.runJavaScriptReturningResult(js) as String;
      // Result is often double-quoted or a JSON string depending on version
      final List<dynamic> links = List.from(
        (result.startsWith('"') ? result.substring(1, result.length - 1) : result)
        .replaceAll('\\"', '"')
        .split(',') // Simplified; real app would use jsonDecode
      );
      setState(() {
        _detectedLinks.addAll(links.map((e) => e.toString().replaceAll('"', '').trim()).where((e) => e.isNotEmpty));
      });
    } catch (e) {}
  }

  void _showSnifferList() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Detected Media'),
        message: Text('${_detectedLinks.length} files found on this page'),
        actions: _detectedLinks.map((url) => CupertinoActionSheetAction(
          child: Text(url.split('/').last, overflow: TextOverflow.ellipsis),
          onPressed: () {
            ref.read(downloadManagerProvider.notifier).startDownload(url);
            Navigator.pop(context);
          },
        )).toList(),
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_currentUrl, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.back, color: _canGoBack ? null : CupertinoColors.systemGrey4),
              onPressed: _canGoBack ? () => _controller.goBack() : null,
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.forward, color: _canGoForward ? null : CupertinoColors.systemGrey4),
              onPressed: _canGoForward ? () => _controller.goForward() : null,
            ),
          ],
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.refresh),
          onPressed: () => _controller.reload(),
        ),
      ),
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_detectedLinks.isNotEmpty)
            Positioned(
              right: 20,
              bottom: 100,
              child: badges.Badge(
                badgeContent: Text('${_detectedLinks.length}', style: const TextStyle(color: CupertinoColors.white, fontSize: 10)),
                child: CupertinoButton.filled(
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(30),
                  child: const Icon(CupertinoIcons.cloud_download, size: 28),
                  onPressed: _showSnifferList,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
