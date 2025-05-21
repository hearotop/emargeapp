import 'package:flutter/material.dart';
import './utils/device_utils.dart';
import './widgets/device_card.dart';
import './widgets/stats_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // 定义主题蓝色
  static const Color themeBlue = Color(0xFF2196F3);

  late TabController _tabController;
  final List<String> _tabs = ['所有', '中国万达', '中国学院','中国北京'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> contacts = [
    {'name': 'AED', 'location': '中国北京', 'status': true},
    {'name': '急救箱', 'location': '中国万达', 'status': true},
    {'name': '轮椅', 'location': '中国万达', 'status': true},
    {'name': '担架', 'location': '中国万达', 'status': false},
    {'name': '紧急呼叫系统', 'location': '中国北京', 'status': true},
    {'name': '灭火器', 'location': '中国北京', 'status': false},
    {'name': 'AED', 'location': '中国学院', 'status': true},
    {'name': '急救箱', 'location': '中国学院', 'status': true},
    {'name': '灭火器', 'location': '中国学院', 'status': true},
  ];

  List<Map<String, dynamic>> _getFilteredContacts() {
    if (_tabController.index == 0) return contacts;
    final selectedTab = _tabs[_tabController.index];
    return contacts.where((contact) {
      if (selectedTab == '中国万达') {
        return contact['location'].startsWith('中国万达');
      } else if (selectedTab == '中国北京') {
        return contact['location'].startsWith('中国北京');
      }
      else if (selectedTab == '中国学院') {

        return contact['location'].startsWith('中国学院'); 
      }
      return false;
    }).toList();
  }

  void is_add_state(Map<String, dynamic> contact) {
    setState(() {
      contact['status'] = !contact['status'];
    });
  }

  void _handleAddButtonPressed(Map<String, dynamic> contact) {
    if (contact['status'] == false) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.add_circle_outline, color: themeBlue),
                SizedBox(width: 8),
                Text('共享设备'),
              ],
            ),
            content: Text('您想要共享设备: ${contact['name']}'),
            actions: <Widget>[
              TextButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: themeBlue,
                ),
                child: Text('确认'),
                onPressed: () {
                  is_add_state(contact);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.visibility_off, color: themeBlue),
                SizedBox(width: 8),
                Text('隐藏设备'),
              ],
            ),
            content: Text('您想要隐藏设备: ${contact['name']}'),
            actions: <Widget>[
              TextButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: themeBlue,
                ),
                child: Text('确认'),
                onPressed: () {
                  is_add_state(contact);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _handleLongPress(int index) {
    final filteredContacts = _getFilteredContacts();
    final contact = filteredContacts[index];
    final originalIndex = contacts.indexWhere((c) =>
        c['name'] == contact['name'] && c['location'] == contact['location']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: themeBlue),
              SizedBox(width: 8),
              Text('删除设备'),
            ],
          ),
          content: Text('您想要删除设备: ${contact['name']}'),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: themeBlue,
              ),
              child: Text('确认'),
              onPressed: () {
                setState(() {
                  contacts.removeAt(originalIndex);
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
                  labelColor: themeBlue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: themeBlue,
                  indicatorWeight: 3,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  onTap: (index) {
                    setState(() {}); // 触发重建以更新筛选后的列表
                  },
                ),
              ),
              StatsMenu(
                contacts: contacts,
                themeBlue: themeBlue,
              ),
              SizedBox(width: 8),
            ],
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: _getFilteredContacts().length,
              itemBuilder: (BuildContext context, int index) {
                final contact = _getFilteredContacts()[index];
                return DeviceCard(
                  device: contact,
                  onAddPressed: _handleAddButtonPressed,
                  onLongPress: () => _handleLongPress(index),
                  themeBlue: themeBlue,
                  getDeviceImage: DeviceUtils.getDeviceImage,
                  getStatusIcon: DeviceUtils.getStatusIcon,
                  getStatusColor: DeviceUtils.getStatusColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
