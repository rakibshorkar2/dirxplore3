import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecurityState {
  final bool isBiometricEnabled;
  final bool isAuthenticated;

  SecurityState({this.isBiometricEnabled = false, this.isAuthenticated = false});

  SecurityState copyWith({bool? isBiometricEnabled, bool? isAuthenticated}) {
    return SecurityState(
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class SecurityService extends StateNotifier<SecurityState> {
  final LocalAuthentication _auth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();
  static const _bioKey = 'biometric_enabled';

  SecurityService() : super(SecurityState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _storage.read(key: _bioKey) == 'true';
    state = state.copyWith(isBiometricEnabled: enabled);
  }

  Future<void> toggleBiometrics(bool enabled) async {
    await _storage.write(key: _bioKey, value: enabled.toString());
    state = state.copyWith(isBiometricEnabled: enabled);
  }

  Future<bool> authenticate() async {
    if (!state.isBiometricEnabled) return true;
    
    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to access DirXplore',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      state = state.copyWith(isAuthenticated: didAuthenticate);
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }
}

final securityServiceProvider = StateNotifierProvider<SecurityService, SecurityState>((ref) {
  return SecurityService();
});
