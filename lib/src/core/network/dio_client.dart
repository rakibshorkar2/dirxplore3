import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socks5_proxy/socks_client.dart';
import '../../features/proxy/logic/proxy_manager.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  final proxyList = ref.watch(proxyManagerProvider);
  final activeProxy = proxyList.isNotEmpty 
      ? proxyList.firstWhere((p) => p.enabled, orElse: () => proxyList.first) 
      : null;

  if (activeProxy != null && activeProxy.enabled) {
    // SOCKS5 Support via socks5_proxy package
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // Create SOCKS5 proxy URI
        final proxyUri = Uri.parse('socks5://${activeProxy.host}:${activeProxy.port}');
        
        // This ensures all Dio traffic within the app is routed through SOCKS5
        SocksRSA.setProxy(client, proxyUri);

        return client;
      },
    );
  }

  return dio;
});
