import 'dart:io';
import 'engine/socks5_protocol.dart';

class GlobalSocks5Overrides extends HttpOverrides {
  final String host;
  final int port;
  final String? username;
  final String? password;

  GlobalSocks5Overrides({
    required this.host,
    required this.port,
    this.username,
    this.password,
  });

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // In a pure SOCKS5 engine, we intercept the low-level connection
    // This is the production-grade approach to force SOCKS5
    return super.createHttpClient(context)
      ..findProxy = null // Disable standard proxy
      ..connectionFactory = (Uri uri, String? proxyHost, int? proxyPort) async {
        // Force all traffic through our RFC 1928 SOCKS5 tunnel
        final socket = await Socks5Protocol.connect(
          proxyHost: host,
          proxyPort: port,
          targetHost: uri.host,
          targetPort: uri.port,
          username: username,
          password: password,
        );
        return socket;
      };
  }
}
