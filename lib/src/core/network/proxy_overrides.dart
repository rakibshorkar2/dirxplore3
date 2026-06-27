import 'dart:io';
import 'engine/socks5_protocol.dart';
import 'engine/traffic_monitor.dart';

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
    return super.createHttpClient(context)
      ..findProxy = null
      ..connectionFactory = (Uri uri, String? proxyHost, int? proxyPort) async {
        final socket = await Socks5Protocol.connect(
          proxyHost: host,
          proxyPort: port,
          targetHost: uri.host,
          targetPort: uri.port,
          username: username,
          password: password,
        );
        
        // Wrap socket for traffic monitoring
        return _TrafficMonitoredSocket(socket);
      };
  }
}

class _TrafficMonitoredSocket extends Socket {
  final Socket _inner;
  _TrafficMonitoredSocket(this._inner);

  @override
  void add(List<int> data) {
    TrafficMonitor.instance.logUpload(data.length);
    _inner.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) => _inner.addError(error, stackTrace);

  @override
  Future addStream(Stream<List<int>> stream) {
    return _inner.addStream(stream.map((data) {
      TrafficMonitor.instance.logUpload(data.length);
      return data;
    }));
  }

  @override
  Future close() => _inner.close();

  @override
  Future get done => _inner.done;

  @override
  void destroy() => _inner.destroy();

  @override
  bool setOption(SocketOption option, bool enabled) => _inner.setOption(option, enabled);

  @override
  void setRawOption(RawSocketOption option) => _inner.setRawOption(option);

  @override
  Uint8List getRawOption(RawSocketOption option) => _inner.getRawOption(option);

  @override
  InternetAddress get address => _inner.address;

  @override
  int get port => _inner.port;

  @override
  InternetAddress get remoteAddress => _inner.remoteAddress;

  @override
  int get remotePort => _inner.remotePort;

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _inner.listen(
      (data) {
        TrafficMonitor.instance.logDownload(data.length);
        onData?.call(data);
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Encoding get encoding => _inner.encoding;

  @override
  set encoding(Encoding value) => _inner.encoding = value;

  @override
  void write(Object? obj) => _inner.write(obj);

  @override
  void writeAll(Iterable objects, [String separator = ""]) => _inner.writeAll(objects, separator);

  @override
  void writeCharCode(int charCode) => _inner.writeCharCode(charCode);

  @override
  void writeln([Object? obj = ""]) => _inner.writeln(obj);

  @override
  Future flush() => _inner.flush();
}
