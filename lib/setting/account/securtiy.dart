import 'package:flutter/material.dart';
import 'package:namer_app/setting/account/changepwd.dart';
import 'package:namer_app/setting/account/changeemail.dart';

class SecurityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('安全设置'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('更改密码'),
            onTap: () {
              // 导航到更改密码页面
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('更改邮箱'),
            onTap: () {
              // 导航到更改邮箱页面
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangeEmailPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
