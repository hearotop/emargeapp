import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';

import 'package:provider/provider.dart';

// 视频播放器的状态管理类
class VideoPlayerPer with ChangeNotifier, DiagnosticableTreeMixin {
  int _count = 0;
  String _videoUrl = ' ';
  String get videoUrl => _videoUrl;
  int get count => _count;
  Future<void> updateVideoUrl(String newVideoUrl) async {
    _videoUrl = newVideoUrl;
    notifyListeners(); // 通知所有监听者数据已更改
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('count', count));
    properties.add(StringProperty('videoUrl', videoUrl));
  }
}

// 视频播放器的UI组件
class VideoPlayerScreen extends StatefulWidget {
  final String initialVideoUrl;

  VideoPlayerScreen({required this.initialVideoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late VideoPlayerPer _videoPlayerPer;

  @override
  void initState() {
    super.initState();
    _videoPlayerPer = Provider.of<VideoPlayerPer>(context, listen: false);
    _initializeVideoPlayer(widget.initialVideoUrl);
    _videoPlayerPer.addListener(_updateVideo);
  }

  void _initializeVideoPlayer(String videoUrl) {
    _videoPlayerController = VideoPlayerController.network(videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
      autoPlay: true,
      looping: true,
    );
    setState(() {});
  }

  void _updateVideo() {
    if (_videoPlayerPer.videoUrl != widget.initialVideoUrl) {
      _chewieController.dispose();
      _videoPlayerController.dispose();
      _initializeVideoPlayer(_videoPlayerPer.videoUrl);
    }
  }

  @override
  void dispose() {
    _videoPlayerPer.removeListener(_updateVideo);
    _chewieController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Chewie(controller: _chewieController));
  }
}
