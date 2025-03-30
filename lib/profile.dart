import 'package:flutter/material.dart';
import 'package:namer_app/setting/setting.dart';

class ProfilePage extends StatelessWidget {
  List menuTitles = [
    '历史记录',
    '设置',
  ];
  List menuIcons = [
    Icons.message,

    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.blue, // 设置背景颜色为蓝色
                  shape: BoxShape.rectangle, // 设置形状为长方形
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          NetworkImage('https://via.placeholder.com/100'),
                    ),
                    Text(
                      '用户名',
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                )),
            Expanded(
              child: ListView.builder(
                itemCount: menuTitles.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: Icon(menuIcons[index]),
                    title: Text(menuTitles[index]),
                    onTap: () => {
                      // 在这里添加点击事件的逻辑
                      _handleMenuItemTap(context, index),
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuItemTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('点击了：历史记录')),
        );
        break;
      case 1:
      Navigator.push(
            context, MaterialPageRoute(builder: (context) => SettingsPage()));
        break;   
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('点击了未知项')),
        );
        break;
    }
  }
}
