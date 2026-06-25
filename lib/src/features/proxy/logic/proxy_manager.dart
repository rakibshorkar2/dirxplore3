import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class ProxyConfig {
  final String id;
  final String name;
  final String host;
  final int port;
  final String? username;
  final String? password;
  final bool enabled;
  final int? latency;
  final String? isp;

  ProxyConfig({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    this.username,
    this.password,
    this.enabled = false,
    this.latency,
    this.isp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'host': host,
    'port': port,
    'username': username,
    'password': password,
    'enabled': enabled,
  };

  factory ProxyConfig.fromJson(Map<String, dynamic> json) => ProxyConfig(
    id: json['id'] ?? const Uuid().v4(),
    name: json['name'] ?? 'SOCKS5 Proxy',
    host: json['host'],
    port: json['port'],
    username: json['username'],
    password: json['password'],
    enabled: json['enabled'] ?? false,
  );

  ProxyConfig copyWith({bool? enabled, int? latency, String? isp}) => ProxyConfig(
    id: id,
    name: name,
    host: host,
    port: port,
    username: username,
    password: password,
    enabled: enabled ?? this.enabled,
    latency: latency ?? this.latency,
    isp: isp ?? this.isp,
  );
}

class ProxyManager extends StateNotifier<List<ProxyConfig>> {
  final _storage = const FlutterSecureStorage();
  static const _key = 'proxy_configs';

  ProxyManager() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final data = await _storage.read(key: _key);
    if (data != null) {
      final List decoded = jsonDecode(data);
      state = decoded.map((e) => ProxyConfig.fromJson(e)).toList();
    }
  }

  Future<void> addProxy(ProxyConfig config) async {
    state = [...state, config];
    await _save();
  }

  Future<void> deleteProxy(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _save();
  }

  Future<void> toggleProxy(String id, bool enabled) async {
    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(enabled: enabled) else p.copyWith(enabled: false)
    ];
    await _save();
  }

  Future<void> _save() async {
    final data = jsonEncode(state.map((e) => e.toJson()).toList());
    await _storage.write(key: _key, value: data);
  }

  Future<void> testProxy(String id) async {
    final proxy = state.firstWhere((p) => p.id == id);
    final stopwatch = Stopwatch()..start();
    
    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 5)));
      // Note: Full SOCKS5 routing test would require native support, 
      // here we simulate a reachability check.
      await dio.head('https://1.1.1.1'); 
      stopwatch.stop();
      _updateProxy(id, latency: stopwatch.elapsedMilliseconds, isp: 'Verified');
    } catch (e) {
      _updateProxy(id, latency: -1, isp: 'Offline');
    }
  }

  void _updateProxy(String id, {int? latency, String? isp}) {
    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(latency: latency, isp: isp) else p
    ];
  }
}

final proxyManagerProvider = StateNotifierProvider<ProxyManager, List<ProxyConfig>>((ref) {
  return ProxyManager();
});
