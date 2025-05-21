

class Video {
  final String imageUrl;
  final String videoPath;
  final String title;
  final int id;
  String uploadTime;

  final String description;
  final String bimg;
  String duration;
  String timeStamp;
  String author;

  Video({
    required this.id,
    required this.imageUrl,
    required this.title,
     this.uploadTime='',
    this.author='',
    required this.videoPath,
    required this.description,
    required this.bimg,
    this.duration = '',
    this.timeStamp = '',
  });
}
