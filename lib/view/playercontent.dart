import 'package:flutter/material.dart';
import 'package:namer_app/utils/cheplayer.dart';
import 'package:namer_app/view/intro.dart';
import 'package:namer_app/class/video.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/database_helper.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
// 导入数据库帮助类

class ContentPage extends StatefulWidget {
  final Video video;
  ContentPage({required this.video});
  @override
  _ContentPageState createState() => _ContentPageState();
}

Future<List<Map<String, dynamic>>> _loadData(Video video) async {
  String path = 'lib/json/${video.videoPath}.json';
  String jsonString = await rootBundle.loadString(path);
  // 假设你有一个视频列表
  List<dynamic> data = json.decode(jsonString);
  return List<Map<String, dynamic>>.from(data);
}

class _ContentPageState extends State<ContentPage> {
  late String _videoUrl =widget.video.videoPath;
  late Future<List<Map<String, dynamic>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData(widget.video);

    _dataFuture.then((data) {
      if (data.isNotEmpty) {
        _videoUrl = data[0]['videoUrl'];
      }
    }).catchError((error) {
      print('Error loading data: $error');
    });
  }

  void _updateVideoUrl(String newUrl) {
    setState(() {
      _videoUrl = newUrl;
    });
    // 记录视频地址和已播放时长
    _recordPlayHistory(newUrl, '0');
  }

  // 记录播放历史的方法
  Future<void> _recordPlayHistory(String videoUrl, String duration) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertPlayHistory({
      'videoId':widget.video.id, // 简单使用哈希值作为视频 ID
      'title': widget.video.title,
      'timestamp':'',
      'duration': duration,
      'coverUrl': widget.video.imageUrl,
      'videoUrl': videoUrl
    });
  }

  @override
  void dispose() {
    _recordPlayHistory(_videoUrl, '0');
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('视频播放')),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoPlayerScreen(initialVideoUrl: _videoUrl),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(tabs: [Tab(text: "简介"), Tab(text: "章节")]),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Center(child: IntroductionPage(video: widget.video)),
                        Center(
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: _dataFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(child: Text('No data found'));
                              } else {
                                List<Map<String, dynamic>> videoItems =
                                    snapshot.data!;

                                return ListView.builder(
                                  itemCount: videoItems.length,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> videoItem =
                                        videoItems[index];
                                    int id = videoItem['id'];
                                    String title = videoItem['title'];
                                    String videoPath = videoItem['videoUrl'];
                                    String imagePath = widget.video.bimg;
                                    String uploadTime = videoItem['uploadTime'];
                                    String author = widget.video.author;
                                    String description =
                                        widget.video.description;
                                    String imageUrl = widget.video.imageUrl;
                                    return Column(
                                      children: [
                                        ListTile(
                                          title: Text("第${index + 1}集 $title"),
                                          onTap: () {
                                            context
                                                .read<VideoPlayerPer>()
                                                .updateVideoUrl(videoPath);
                                            _updateVideoUrl(videoPath);
                                            print("点击了$videoPath");
                                          },
                                        ),
                                        Divider(
                                          height: 1.0,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
