import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GeneralSettings {
  final int concurrentDownloads;
  final int retryCount;

  GeneralSettings({
    this.concurrentDownloads = 3,
    this.retryCount = 5,
  });

  GeneralSettings copyWith({
    int? concurrentDownloads,
    int? retryCount,
  }) {
    return GeneralSettings(
      concurrentDownloads: concurrentDownloads ?? this.concurrentDownloads,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

class SettingsNotifier extends StateNotifier<GeneralSettings> {
  final _storage = const FlutterSecureStorage();
  static const _concurrentKey = 'concurrent_downloads';
  static const _retryKey = 'retry_count';

  SettingsNotifier() : super(GeneralSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final concurrent = await _storage.read(key: _concurrentKey);
    final retry = await _storage.read(key: _retryKey);
    
    state = GeneralSettings(
      concurrentDownloads: int.tryParse(concurrent ?? '3') ?? 3,
      retryCount: int.tryParse(retry ?? '5') ?? 5,
    );
  }

  Future<void> setConcurrentDownloads(int count) async {
    state = state.copyWith(concurrentDownloads: count);
    await _storage.write(key: _concurrentKey, value: count.toString());
  }

  Future<void> setRetryCount(int count) async {
    state = state.copyWith(retryCount: count);
    await _storage.write(key: _retryKey, value: count.toString());
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, GeneralSettings>((ref) {
  return SettingsNotifier();
});
