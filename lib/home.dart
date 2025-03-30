import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import './utils/tabnav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> contacts = [
    {'name': 'AED', 'location': '中国丹东万达三楼', 'status': true},
    {'name': '急救箱', 'location': '中国丹东万达四楼', 'status': true},
    {'name': '轮椅', 'location': '中国丹东万达六楼', 'status': true},
    {'name': '担架', 'location': '中国丹东万达七楼', 'status': false},
    {'name': '紧急呼叫系统', 'location': '中国丹东万达八楼', 'status': true},
    {'name': '灭火器', 'location': '中国丹东万达九楼', 'status': false},
  ];

  void is_add_state(Map<String, dynamic> contact) {
    setState(() {
      contact['status'] = !contact['status'];
    });
  }

  Icon _icon_state(bool is_add) {
    if (is_add) {
      return Icon(Icons.horizontal_rule, color: Colors.white);
    }
    return Icon(
      Icons.add,
      color: Colors.white,
    );
  }

  Color _color_state(bool is_add) {
    if (is_add) {
      return Colors.red;
    }
    return Colors.green;
  }

  String _show_img(String name) {
    switch (name) {
      case 'AED':
        return 'lib/image/device/AED.jpg';
      case '担架':
        return 'lib/image/device/danjia.jpg';
      case '急救箱':
        return 'lib/image/device/firstaid.png';
      case '灭火器':
        return 'lib/image/device/miehuoqi.png';
      case '轮椅':
        return 'lib/image/device/lunyi.jpg';
      case '紧急呼叫系统':
        return 'lib/image/device/sos.jpg';
      default:
        return '';
    }
  }

  void _handleAddButtonPressed(Map<String, dynamic> contact) {
    // 在这里添加点击事件的处理逻辑
    // 例如：显示一个对话框、导航到另一个页面等
    if (contact['status'] == false) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('共享设备'),
            content: Text('您想要共享设备: ${contact['name']}'),
            actions: <Widget>[
              TextButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('确认'),
                onPressed: () {
                  // 添加设备的逻辑
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
            title: Text('隐藏设备'),
            content: Text('您想要隐藏设备: ${contact['name']}'),
            actions: <Widget>[
              TextButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('确认'),
                onPressed: () {
                  // 添加设备的逻辑
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
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('删除设备'),
              content: Text('您想要删除设备: ${contacts[index]['name']}'),
              actions: <Widget>[
                TextButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(child: Text('确认'), onPressed: () {
                    setState(() {
      contacts.removeAt(index);
       Navigator.of(context).pop();
    });
                })
              ]);
        });

  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 每行显示两个卡片
          crossAxisSpacing: 10.0, // 水平间距
          mainAxisSpacing: 10.0, // 垂直间距
        ),
        itemCount: contacts.length,
        itemBuilder: (BuildContext context, int index) {
          final contact = contacts[index];
          return GestureDetector(
              onLongPress: () {
                _handleLongPress(index);
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween, // 两端对齐
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage(
                              _show_img(contact['name']),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _color_state(
                                  contact['status']), // 可选：为图标添加背景色
                            ),
                            child: IconButton(
                              icon: _icon_state(contact['status']),
                              onPressed: () {
                                // 添加点击事件处理逻辑
                                _handleAddButtonPressed(contact);
                              },
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(contact['name'],
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text('位置: ${contact['location']}'), // 显示位置信息
                    ],
                  ),
                ),
              ));
        },
      ),
    );
  }
}
