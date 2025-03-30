import 'package:flutter/material.dart';
import 'package:namer_app/class/video.dart';

class VideoCard extends StatelessWidget {
  final Video video;

  VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(video.imageUrl, fit: BoxFit.cover),
          Text(video.title, style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(video.author),
              Padding(
                  padding: EdgeInsets.only(left: 2),
                  child: Text(video.uploadTime)),
            ],
          ),
        ],
      ),
    );
  }
}
