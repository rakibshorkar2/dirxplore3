import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';
import '../../settings/logic/settings_provider.dart';

class DownloadTask {
  final int id;
  final String url;
  final double progress;
  final String status;
  final String? path;
  final int bytesWritten;
  final int totalBytes;
  final double speed; // Bytes per second
  final DateTime? startTime;

  DownloadTask({
    required this.id,
    required this.url,
    this.progress = 0.0,
    this.status = 'queued',
    this.path,
    this.bytesWritten = 0,
    this.totalBytes = 0,
    this.speed = 0.0,
    this.startTime,
  });

  DownloadTask copyWith({
    double? progress,
    String? status,
    String? path,
    int? bytesWritten,
    int? totalBytes,
    double? speed,
    DateTime? startTime,
  }) {
    return DownloadTask(
      id: id,
      url: url,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      path: path ?? this.path,
      bytesWritten: bytesWritten ?? this.bytesWritten,
      totalBytes: totalBytes ?? this.totalBytes,
      speed: speed ?? this.speed,
      startTime: startTime ?? this.startTime,
    );
  }
}

class DownloadManager extends StateNotifier<List<DownloadTask>> {
  static const _channel = MethodChannel('com.dirxplore.app/downloads');
  final Map<int, DateTime> _lastUpdateTimes = {};
  final Map<int, int> _lastBytes = {};
  final Ref ref;

  DownloadManager(this.ref) : super([]) {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  Future<void> startDownload(String url) async {
    // Check parallel limit from settings
    final maxParallel = ref.read(settingsProvider).concurrentDownloads;
    final active = state.where((t) => t.status == 'downloading').length;
    if (active >= maxParallel) {
      state = [...state, DownloadTask(id: -1, url: url, status: 'queued')];
      return;
    }

    try {
      final int taskId = await _channel.invokeMethod('startDownload', {'url': url});
      state = [...state, DownloadTask(
        id: taskId, 
        url: url, 
        status: 'downloading',
        startTime: DateTime.now(),
      )];
    } on PlatformException catch (_) {
      // Error handling
    }
  }

  Future<void> pauseDownload(int taskId) async {
    await _channel.invokeMethod('pauseDownload', {'taskId': taskId});
    _updateTask(taskId, status: 'paused');
  }

  Future<void> resumeTask(int taskId) async {
    final int? newId = await _channel.invokeMethod('resumeDownload', {'taskId': taskId});
    if (newId != null) {
      _updateTask(taskId, status: 'downloading');
    }
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onDownloadProgress':
        final int taskId = call.arguments['taskId'];
        final double progress = (call.arguments['progress'] as num).toDouble();
        final int bytesWritten = call.arguments['bytesWritten'];
        final int totalBytes = call.arguments['totalBytes'];
        
        // Calculate speed
        final now = DateTime.now();
        double speed = 0.0;
        if (_lastUpdateTimes.containsKey(taskId)) {
          final diff = now.difference(_lastUpdateTimes[taskId]!).inMilliseconds;
          if (diff > 500) { // Update speed every 500ms
            final bytesDiff = bytesWritten - (_lastBytes[taskId] ?? 0);
            speed = (bytesDiff / diff) * 1000; // bytes per second
            _lastUpdateTimes[taskId] = now;
            _lastBytes[taskId] = bytesWritten;
          } else {
            // Keep old speed for smooth UI
            final task = state.firstWhere((t) => t.id == taskId);
            speed = task.speed;
          }
        } else {
          _lastUpdateTimes[taskId] = now;
          _lastBytes[taskId] = bytesWritten;
        }

        _updateTask(taskId, 
          progress: progress, 
          bytesWritten: bytesWritten, 
          totalBytes: totalBytes,
          speed: speed,
        );
        break;
      case 'onDownloadComplete':
        final int taskId = call.arguments['taskId'];
        final String path = call.arguments['path'];
        final task = state.firstWhere((t) => t.id == taskId);
        NotificationService.showDownloadComplete(task.url.split('/').last);
        _updateTask(taskId, status: 'completed', path: path);
        break;
      case 'onDownloadError':
        final int taskId = call.arguments['taskId'];
        _updateTask(taskId, status: 'failed');
        break;
    }
  }

  void _updateTask(int id, {double? progress, String? status, String? path, int? bytesWritten, int? totalBytes, double? speed}) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(
            progress: progress,
            status: status,
            path: path,
            bytesWritten: bytesWritten,
            totalBytes: totalBytes,
            speed: speed,
          )
        else
          task
    ];
  }
}

final downloadManagerProvider = StateNotifierProvider<DownloadManager, List<DownloadTask>>((ref) {
  return DownloadManager(ref);
});
