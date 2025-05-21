import 'package:flutter/material.dart';
import 'package:namer_app/adddevice.dart';
import 'package:namer_app/home.dart';
import 'package:namer_app/profile.dart';
import 'package:namer_app/quiz.dart';
import 'player.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:namer_app/utils/cheplayer.dart';
import 'package:namer_app/view/chatbot.dart';
import 'package:namer_app/database_helper.dart';

import 'search.dart'; // 导入自定义的搜索委托类
/// Flutter code sample for [NavigationBar].

import 'package:provider/provider.dart';

const apiKey = '717812016637'; // 错误修复：确保导入了正确的包，这里需要导入webview_flutter中的JavascriptMode
void main() {

  runApp(
    /// Add this line
 

    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => VideoPlayerPer())],
      child: NavigationBarApp(),
    ),
 
  );
}

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const NavigationExample(),
      debugShowCheckedModeBanner: false, // 
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
  final List<String> appBarTitles = ['首页', '视频', '小管家', '测验', '我的'];

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
              icon: Icon(appBarIcons[1]),
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
        backgroundColor: Colors.white,
        elevation: 8,
        height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: Colors.blue),
            icon: Icon(Icons.home_outlined),
            label: '首页',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.video_library, color: Colors.blue),
            icon: Icon(Icons.video_library_outlined),
            label: '视频',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.chat, color: Colors.blue),
            icon: Icon(Icons.chat_outlined),
            label: '小管家',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.map, color: Colors.blue),
            icon: Icon(Icons.map_outlined),
            label: '测验',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person, color: Colors.blue),
            icon: Icon(Icons.person_outline),
            label: '我的',
          ),
        ],
      ),
      body: <Widget>[
        HomePage(),
        PlayerPage(),
       ChatbotPage(),
        TestPage(),
        ProfilePage()
      ][currentPageIndex],
    );
  }
}
