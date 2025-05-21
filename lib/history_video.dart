import 'package:namer_app/class/video.dart';
import 'database_helper.dart';

class HistoryVideo {
  final String videoId;
  final String title;
  final String timestamp;
  final String duration;
  final String coverUrl;
  final String videoUrl;

  HistoryVideo({
    required this.videoId,
    required this.title,
    required this.timestamp,
    required this.duration,
    required this.coverUrl,
    required this.videoUrl,
  });

  // 从 Map 转换为 HistoryVideo 实例
  static HistoryVideo fromMap(Map<String, dynamic> map) {
    return HistoryVideo(
      videoId: map['videoId'] ?? '',
      title: map['title'] ?? '',
      timestamp: map['timestamp'] ?? '',
      duration: map['duration'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
    );
  }

  // 插入播放历史记录
  static Future<void> insertPlayHistory(Video video, String duration) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertPlayHistory({
      'videoId': video.videoPath.hashCode.toString(),
      'title': video.title,
      'timestamp': DateTime.now().toIso8601String(),
      'duration': duration,
      'coverUrl': video.bimg,
      'videoUrl': video.videoPath,
    });
  }

  // 获取播放历史记录
  static Future<List<HistoryVideo>> getPlayHistory() async {
    final dbHelper = DatabaseHelper();
    final historyMaps = await dbHelper.getPlayHistory();
    return historyMaps.map((map) => HistoryVideo.fromMap(map)).toList();
  }
}
