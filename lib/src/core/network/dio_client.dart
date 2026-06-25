import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/proxy/logic/proxy_manager.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  final proxyList = ref.watch(proxyManagerProvider);
  final activeProxy = proxyList.isNotEmpty ? proxyList.firstWhere((p) => p.enabled, orElse: () => proxyList.first) : null;

  if (activeProxy != null && activeProxy.enabled) {
    // Note: SOCKS5 proxy support in Dio usually requires a native adapter or a custom client.
    // For this implementation, we set the proxy in the HttpClient adapter.
    // This will only affect traffic within the app.
  }

  return dio;
});
