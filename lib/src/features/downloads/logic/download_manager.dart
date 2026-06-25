import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadTask {
  final int id;
  final String url;
  final double progress;
  final String status;
  final String? path;

  DownloadTask({
    required this.id,
    required this.url,
    this.progress = 0.0,
    this.status = 'queued',
    this.path,
  });

  DownloadTask copyWith({
    double? progress,
    String? status,
    String? path,
  }) {
    return DownloadTask(
      id: id,
      url: url,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      path: path ?? this.path,
    );
  }
}

class DownloadManager extends StateNotifier<List<DownloadTask>> {
  static const _channel = MethodChannel('com.dirxplore.app/downloads');

  DownloadManager() : super([]) {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  Future<void> startDownload(String url) async {
    try {
      final int taskId = await _channel.invokeMethod('startDownload', {'url': url});
      state = [...state, DownloadTask(id: taskId, url: url, status: 'downloading')];
    } on PlatformException catch (e) {
      print('Failed to start download: ${e.message}');
    }
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onDownloadProgress':
        final int taskId = call.arguments['taskId'];
        final double progress = call.arguments['progress'];
        _updateTask(taskId, progress: progress);
        break;
      case 'onDownloadComplete':
        final int taskId = call.arguments['taskId'];
        final String path = call.arguments['path'];
        _updateTask(taskId, status: 'completed', path: path);
        break;
      case 'onDownloadError':
        final int taskId = call.arguments['taskId'];
        _updateTask(taskId, status: 'failed');
        break;
    }
  }

  void _updateTask(int id, {double? progress, String? status, String? path}) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(progress: progress, status: status, path: path)
        else
          task
    ];
  }
}

final downloadManagerProvider = StateNotifierProvider<DownloadManager, List<DownloadTask>>((ref) {
  return DownloadManager();
});
