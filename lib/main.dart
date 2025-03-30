import 'package:flutter/material.dart';
import 'package:namer_app/adddevice.dart';
import 'package:namer_app/home.dart';
import 'package:namer_app/profile.dart';
import 'quiz.dart';
import 'player.dart';



import 'package:namer_app/utils/cheplayer.dart';

import 'search.dart'; // 导入自定义的搜索委托类
/// Flutter code sample for [NavigationBar].

import 'package:provider/provider.dart';

void main() => runApp(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => VideoPlayerPer())],
        child: NavigationBarApp(),
      ),
    );

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  // 定义每个页面的标题
  final List<String> appBarTitles = ['视频', '博学谷习题', '个人信息'];

  final List<IconData> appBarIcons = [Icons.search, Icons.add];

  @override
  Widget build(BuildContext context) {
    
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitles[currentPageIndex]),
        centerTitle: true,
        actions: <Widget>[
          if (currentPageIndex == 0)
            IconButton(
              icon: Icon(appBarIcons[0]),
              onPressed: () {
                // 显示搜索界面
                showSearch(context: context, delegate: CustomSearchDelegate());
              },
            ),
          if (currentPageIndex == 0)
            IconButton(
              icon: Icon(appBarIcons[1]), // 新增的 IconButton
              onPressed: () {
                // 导航到添加设备页面
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddDevicePage()),
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.movie),
            icon: Icon(Icons.movie_outlined),
            label: '视频',
          ),
          NavigationDestination(icon: Icon(Icons.map), label: '博学谷习题'),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outlined),
            // 假设Badge组件未使用，否则需要导入Badge组件
            label: '个人信息',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
       PlayerPage(),
        TestPage(),
       ProfilePage()
      ][currentPageIndex],
    );
  }
}