class Video {
  final String imageUrl;
  final String videoPath;
  final String title;
  final int id;
  final String uploadTime;
  final String author;
  final String description;
  final String bimg;

  Video({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.uploadTime,
    required this.author,
    required this.videoPath,
    required this.description,
    required this.bimg,
  });
}
