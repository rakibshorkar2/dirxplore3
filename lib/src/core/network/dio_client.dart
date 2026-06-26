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
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        
        // Define proxy settings for socks5_proxy v2.1.1
        final proxySettings = [
          ProxySettings(
            InternetAddress.tryParse(activeProxy.host) ?? InternetAddress.anyIPv4,
            activeProxy.port,
            username: activeProxy.username,
            password: activeProxy.password,
          ),
        ];

        // Apply the SOCKS5 tunnel to the HttpClient
        SocksTCPClient.assignToHttpClient(client, proxySettings);
        
        // For BDIX servers that might have invalid certificates
        client.badCertificateCallback = (cert, host, port) => true;

        return client;
      },
    );
  }

  return dio;
});
