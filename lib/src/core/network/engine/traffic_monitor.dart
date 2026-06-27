import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrafficStats {
  final int totalUploaded;
  final int totalDownloaded;

  TrafficStats({this.totalUploaded = 0, this.totalDownloaded = 0});

  TrafficStats copyWith({int? totalUploaded, int? totalDownloaded}) {
    return TrafficStats(
      totalUploaded: totalUploaded ?? this.totalUploaded,
      totalDownloaded: totalDownloaded ?? this.totalDownloaded,
    );
  }
}

class TrafficMonitor extends StateNotifier<TrafficStats> {
  static final TrafficMonitor instance = TrafficMonitor._();
  TrafficMonitor._() : super(TrafficStats());

  void logUpload(int bytes) {
    state = state.copyWith(totalUploaded: state.totalUploaded + bytes);
  }

  void logDownload(int bytes) {
    state = state.copyWith(totalDownloaded: state.totalDownloaded + bytes);
  }

  void reset() {
    state = TrafficStats();
  }
}

final trafficMonitorProvider = StateNotifierProvider<TrafficMonitor, TrafficStats>((ref) {
  return TrafficMonitor.instance;
});
