// lib/view/video_list.dart
import 'package:flutter/material.dart';
import 'package:namer_app/class/video.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/utils/cheplayer.dart';

class VideoList extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> future;
  VideoList({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data found'));
        } else {
          List<Map<String, dynamic>> videoItems = snapshot.data!;
          return ListView.builder(
            itemCount: videoItems.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> videoItem = videoItems[index];
              int id = videoItem['id'];
              String title = videoItem['title'];
              String videoPath = videoItem['videoUrl'];
              String imagePath = Provider.of<Video>(context).bimg;
              String uploadTime = videoItem['uploadTime'];
              String author = videoItem['author'];
              String description = videoItem['description'];
              String imageUrl = Provider.of<Video>(context).imageUrl;

              return ListTile(
                title: Text(title),
                onTap: () {
                  context.read<VideoPlayerPer>().updateVideoUrl(videoPath);
                  print("点击了$videoPath");
                },
              );
            },
          );
        }
      },
    );
  }
}
