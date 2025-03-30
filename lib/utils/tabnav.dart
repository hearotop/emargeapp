import 'package:flutter/material.dart';

class TabNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3, // Tab数量
        child: Scaffold(
          appBar: AppBar(
            title: Text('头条式滑动导航'),
            bottom: TabBar(
              tabs: [
                Tab(text: '推荐'),
                Tab(text: '热点'),
                Tab(text: '视频'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Center(child: Text('推荐页面内容')),
              Center(child: Text('热点页面内容')),
              Center(child: Text('视频页面内容')),
            ],
          ),
        ),
      ),
    );
  }
}
