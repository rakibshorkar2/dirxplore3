import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ProxyConfig {
  final String host;
  final int port;
  final String? username;
  final String? password;
  final bool enabled;

  ProxyConfig({
    required this.host,
    required this.port,
    this.username,
    this.password,
    this.enabled = false,
  });

  Map<String, dynamic> toJson() => {
    'host': host,
    'port': port,
    'username': username,
    'password': password,
    'enabled': enabled,
  };

  factory ProxyConfig.fromJson(Map<String, dynamic> json) => ProxyConfig(
    host: json['host'],
    port: json['port'],
    username: json['username'],
    password: json['password'],
    enabled: json['enabled'] ?? false,
  );

  ProxyConfig copyWith({bool? enabled}) => ProxyConfig(
    host: host,
    port: port,
    username: username,
    password: password,
    enabled: enabled ?? this.enabled,
  );
}

class ProxyManager extends StateNotifier<ProxyConfig?> {
  final _storage = const FlutterSecureStorage();
  static const _key = 'proxy_config';

  ProxyManager() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final data = await _storage.read(key: _key);
    if (data != null) {
      state = ProxyConfig.fromJson(jsonDecode(data));
    }
  }

  Future<void> setProxy(ProxyConfig config) async {
    state = config;
    await _storage.write(key: _key, value: jsonEncode(config.toJson()));
  }

  Future<void> toggleProxy(bool enabled) async {
    if (state != null) {
      state = state!.copyWith(enabled: enabled);
      await _storage.write(key: _key, value: jsonEncode(state!.toJson()));
    }
  }
}

final proxyManagerProvider = StateNotifierProvider<ProxyManager, ProxyConfig?>((ref) {
  return ProxyManager();
});
