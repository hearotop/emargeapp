import 'package:flutter/material.dart';
import 'package:namer_app/mydata.dart';
import 'package:namer_app/setting/account/securtiy.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.person),
            title: Text('个人资料'),
            onTap: () {
              // 导航到个人资料页面
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyInfoPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('账号安全'),
            onTap: () {
              // 导航到账号安全页面
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SecurityPage()),
              );
            },
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('退出'),
            onTap: () {
              // 导航到账号安全页面
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SecurityPage()),
              );
            },
          ),
          // 可以继续添加其他设置项
        ],
      ),
    );
  }
}
