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
 /* List<Image> images = [
    Image.network('https://i0.hdslb.com/bfs/archive/1fd5d82320b11d15173f53578ab754c882a1860c.jpg@672w_378h_1c_!web-search-common-cover.avif', fit: BoxFit.fill),
    Image.network('https://archive.biliimg.com/bfs/archive/5bec09828624dc12c396515fdc5bc5929e842ce4.jpg@672w_378h_1c_!web-search-common-cover.avif', fit: BoxFit.fill),
    Image.network('https://i0.hdslb.com/bfs/archive/ad8d6985e113eb8947ce9bec73c8f41075161a7a.jpg@672w_378h_1c_!web-search-common-cover.avif', fit: BoxFit.fill),
  ];*/
  List<Image> images = [
    Image.asset('lib/image/1.avif', fit: BoxFit.fill),
    Image.asset('lib/image/2.avif', fit: BoxFit.fill),
    Image.asset('lib/image/3.avif', fit: BoxFit.fill),
    Image.asset("lib/image/4.avif", fit: BoxFit.fill)

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
