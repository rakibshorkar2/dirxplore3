import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import '../../features/proxy/logic/proxy_manager.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  
  // Use NativeAdapter to support SOCKS5 and system-level proxy settings on iOS
  dio.httpClientAdapter = NativeAdapter(
    configuration: URLSessionConfiguration.defaultSessionConfiguration,
  );

  final proxyList = ref.watch(proxyManagerProvider);
  final activeProxy = proxyList.isNotEmpty 
      ? proxyList.firstWhere((p) => p.enabled, orElse: () => proxyList.first) 
      : null;

  if (activeProxy != null && activeProxy.enabled) {
    // Note: SOCKS5 is handled by the OS when using NativeAdapter and the correct config.
    // However, for explicit SOCKS5 within the app for BDIX:
    // We can inject the proxy settings into the native configuration.
  }

  return dio;
});
