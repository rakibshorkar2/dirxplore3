import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'dart:developer' as dev;

class Socks5Protocol {
  static const int version = 0x05;
  
  static void _log(String message) {
    dev.log('[SOCKS5] $message', name: 'com.dirxplore.socks5');
  }

  static Future<Socket> connect({
    required String proxyHost,
    required int proxyPort,
    required String targetHost,
    required int targetPort,
    String? username,
    String? password,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    _log('Connecting to $targetHost:$targetPort via $proxyHost:$proxyPort');
    final socket = await Socket.connect(proxyHost, proxyPort, timeout: timeout);
    
    try {
      // 1. Negotiation
      _log('Negotiating auth methods...');
      final methods = [authNone];
      if (username != null && password != null) {
        methods.add(authUserPass);
      }
      
      socket.add([version, methods.length, ...methods]);
      
      final negoResponse = await _readExactly(socket, 2);
      if (negoResponse[0] != version) throw Exception('Invalid SOCKS version');
      
      final selectedMethod = negoResponse[1];
      _log('Selected auth method: $selectedMethod');
      
      // 2. Authentication
      if (selectedMethod == authUserPass) {
        _log('Authenticating...');
        if (username == null || password == null) throw Exception('Auth required');
        
        final userBytes = username.codeUnits;
        final passBytes = password.codeUnits;
        
        socket.add([
          0x01, // Auth version
          userBytes.length, ...userBytes,
          passBytes.length, ...passBytes
        ]);
        
        final authResponse = await _readExactly(socket, 2);
        if (authResponse[1] != 0x00) throw Exception('SOCKS Auth failed');
        _log('Authentication successful');
      } else if (selectedMethod == authNoAcceptable) {
        throw Exception('No acceptable auth methods');
      }

      // 3. Target Request (Connect)
      _log('Requesting connection to target...');
      final hostBytes = targetHost.codeUnits;
      final request = [
        version,
        cmdConnect,
        0x00, // Reserved
        atypDomain,
        hostBytes.length, ...hostBytes,
        (targetPort >> 8) & 0xFF,
        targetPort & 0xFF
      ];
      
      socket.add(request);
      
      // 4. Response
      final replyHeader = await _readExactly(socket, 4);
      if (replyHeader[1] != 0x00) {
        _log('Connection failed with code: ${replyHeader[1]}');
        throw Exception('SOCKS Connection failed: ${replyHeader[1]}');
      }
      
      final atyp = replyHeader[3];
      if (atyp == atypIPv4) {
        await _readExactly(socket, 6); // IP + Port
      } else if (atyp == atypDomain) {
        final len = (await _readExactly(socket, 1))[0];
        await _readExactly(socket, len + 2);
      } else if (atyp == atypIPv6) {
        await _readExactly(socket, 18);
      }
      
      _log('Successfully tunneled to $targetHost:$targetPort');
      return socket;
    } catch (e) {
      _log('Error during SOCKS5 handshake: $e');
      socket.destroy();
      rethrow;
    }
  }

  static Future<Uint8List> _readExactly(Socket socket, int length) async {
    final completer = Completer<Uint8List>();
    final buffer = BytesBuilder();
    
    StreamSubscription? sub;
    sub = socket.listen((data) {
      buffer.add(data);
      if (buffer.length >= length) {
        sub?.cancel();
        completer.complete(buffer.takeBytes().sublist(0, length));
      }
    }, onError: completer.completeError, onDone: () {
      if (!completer.isCompleted) completer.completeError(Exception('Socket closed prematurely'));
    });
    
    return completer.future.timeout(const Duration(seconds: 10));
  }
}
