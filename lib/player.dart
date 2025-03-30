import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:namer_app/class/video.dart';
import 'compment/videoshow.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:namer_app/view/playercontent.dart';

class PlayerPage extends StatefulWidget {
  @override
  _PlayerPageState createState() => _PlayerPageState();
}

Future<List<Map<String, dynamic>>> _loadData() async {
  String jsonString = await rootBundle.loadString('lib/json/videoinfo.json');

  List<dynamic> data = json.decode(jsonString);
  return List<Map<String, dynamic>>.from(data);
}

class _PlayerPageState extends State<PlayerPage> {
  String basepath = "lib/image/";
  List<Image> images = [
    Image.asset('lib/image/iot0102.jpg', fit: BoxFit.fill),
    Image.asset('lib/image/java-250220.jpg', fit: BoxFit.fill),
    Image.asset('lib/image/jichuban-20252.jpg', fit: BoxFit.fill),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          } else {
            List<Map<String, dynamic>> videos = snapshot.data!;
            return ListView(
              children: [
                SizedBox(
                  height: 200, // 设置 Swiper 的高度
                  child: Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return images[index];
                    },
                    itemCount: images.length,
                    pagination: SwiperPagination(),
                    control: SwiperControl(),
                    autoplay: true,
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: videos.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map<String, dynamic> video = videos[index];
                    int id = video['id'];
                    String title = video['title'];
                    String videoPath = video['videoPath'];
                    String imagePath = video['imgPath'] ?? '';
                    String uploadTime = video['uploadTime'];
                    String author = video['author'];
                    String description = video['description'];
                    String bimg = video['bimg'];
                    Video videoObj = Video(
                      id: id,
                      title: title,
                      videoPath: videoPath,
                      imageUrl: imagePath,
                      uploadTime: uploadTime,
                      author: author,
                      description: description,
                      bimg: bimg,
                    );

                    return InkWell(
                      child: VideoCard(
                        video: videoObj,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContentPage(
                              video: videoObj,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
