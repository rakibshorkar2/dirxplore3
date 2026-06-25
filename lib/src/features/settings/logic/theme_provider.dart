import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeNotifier extends StateNotifier<Brightness?> {
  final _storage = const FlutterSecureStorage();
  static const _key = 'theme_brightness';

  ThemeNotifier() : super(null) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final value = await _storage.read(key: _key);
    if (value == 'dark') {
      state = Brightness.dark;
    } else if (value == 'light') {
      state = Brightness.light;
    } else {
      state = null; // System default
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    state = brightness;
    await _storage.write(key: _key, value: isDark ? 'dark' : 'light');
  }

  Future<void> resetToSystem() async {
    state = null;
    await _storage.delete(key: _key);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, Brightness?>((ref) {
  return ThemeNotifier();
});
