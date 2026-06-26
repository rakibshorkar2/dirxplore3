import 'dart:io';
import 'package:socks5_proxy/socks_client.dart';

class GlobalProxyOverrides extends HttpOverrides {
  final String host;
  final int port;
  final String? username;
  final String? password;

  GlobalProxyOverrides({
    required this.host,
    required this.port,
    this.username,
    this.password,
  });

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    
    final proxySettings = [
      ProxySettings(
        InternetAddress.tryParse(host) ?? InternetAddress.anyIPv4,
        port,
        username: username,
        password: password,
      ),
    ];

    SocksTCPClient.assignToHttpClient(client, proxySettings);
    
    // Auto-allow all certificates for BDIX compatibility
    client.badCertificateCallback = (cert, host, port) => true;
    
    return client;
  }
}
