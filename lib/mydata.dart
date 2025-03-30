import 'package:flutter/material.dart';

class MyInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('个人资料'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  NetworkImage('https://via.placeholder.com/150'), // 替换为实际头像URL
            ),
            title: Text('张三'),
            subtitle: Text('名字'),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('性别'),
            subtitle: Text('男'),
          ),
          ListTile(
            leading: Icon(Icons.location_city),
            title: Text('地区'),
            subtitle: Text('北京市'),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('手机号'),
            subtitle: Text('13800138000'),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('邮箱'),
            subtitle: Text('zhangsan@example.com'),
          ),
        ],
      ),
    );
  }
}
