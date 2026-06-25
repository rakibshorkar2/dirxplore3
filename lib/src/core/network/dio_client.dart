import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/proxy/logic/proxy_manager.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  final proxyList = ref.watch(proxyManagerProvider);
  final activeProxy = proxyList.isNotEmpty 
      ? proxyList.firstWhere((p) => p.enabled, orElse: () => proxyList.first) 
      : null;

  if (activeProxy != null && activeProxy.enabled) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // Force the app to use the SOCKS5 proxy internally for all requests
        client.findProxy = (uri) {
          return "SOCKS5 ${activeProxy.host}:${activeProxy.port}; DIRECT";
        };
        // For BDIX servers that might have invalid certificates
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );
  }

  return dio;
});
