import 'dart:io';
import 'dart:async';
import 'traffic_monitor.dart';

class MonitoredSocket extends Socket {
  final Socket _inner;
  final TrafficMonitor _monitor;

  MonitoredSocket(this._inner, this._monitor);

  @override
  void add(List<int> data) {
    _monitor.logUpload(data.length);
    _inner.add(data);
  }

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _inner.listen(
      (data) {
        _monitor.logDownload(data.length);
        onData?.call(data);
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => _inner.noSuchMethod(invocation);
}
