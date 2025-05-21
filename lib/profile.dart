import 'package:flutter/material.dart';
import 'package:namer_app/setting/setting.dart';
import 'package:namer_app/history_page.dart';

class ProfilePage extends StatelessWidget {
  List<Map<String, dynamic>> menuItems = [
    {
      'title': '我的收藏',
      'icon': Icons.favorite_border,
      'color': Colors.red,
    },
    {
      'title': '历史记录',
      'icon': Icons.history,
      'color': Colors.blue,
    },
    {
      'title': '我的设备',
      'icon': Icons.devices,
      'color': Colors.green,
    },
    {
      'title': '消息通知',
      'icon': Icons.notifications_outlined,
      'color': Colors.orange,
    },
    {
      'title': '设置',
      'icon': Icons.settings_outlined,
      'color': Colors.grey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue, Colors.blue[700]!],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              NetworkImage('https://th.bing.com/th/id/OIP.7GLMYPqMlt2LgkbPsOnDIAAAAA?rs=1&pid=ImgDetMain'),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '用户名',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ID: 888888',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '我的服务',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _handleMenuItemTap(context, index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  menuItems[index]['icon'],
                                  size: 32,
                                  color: menuItems[index]['color'],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  menuItems[index]['title'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuItemTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('我的收藏')),
        );
        break;
      case 1:
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HistoryPage()),
        );
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('我的设备')),
          
        );
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('消息通知')),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('点击了未知项')),
        );
        break;
    }
  }
}
