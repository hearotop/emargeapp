import 'package:flutter/material.dart';
import 'package:namer_app/adddevice.dart';
import 'package:namer_app/home.dart';
import 'package:namer_app/profile.dart';
import 'package:namer_app/view/chatbot.dart';

import 'search.dart'; // 导入自定义的搜索委托类

void main() {
  runApp(const NavigationBarApp());
}

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const NavigationExample(),
      debugShowCheckedModeBanner: false,
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
  final List<String> appBarTitles = ['首页', '小管家', '我的'];

  final List<IconData> appBarIcons = [Icons.search, Icons.add];

  @override
  Widget build(BuildContext context) {
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
            selectedIcon: Icon(Icons.chat, color: Colors.blue),
            icon: Icon(Icons.chat_outlined),
            label: '小管家',
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
        ChatbotPage(),
        ProfilePage(),
      ][currentPageIndex],
    );
  }
}
