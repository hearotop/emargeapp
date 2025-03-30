import 'package:flutter/material.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  _AddDevicePageState createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // 定义设备名称列表
  List<String> deviceNames = [
    'AED',
    '急救箱',
    '轮椅',
    '担架',
    '紧急呼叫系统',
    '灭火器'
  ];
  String? selectedDeviceName;
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
        default :
        return '';  
 }
    
  }
  void _addDevice() {
    final String name = selectedDeviceName ?? '';
    final String description = _descriptionController.text;
    final String location = _locationController.text;

    // 这里可以添加保存设备信息的逻辑
    // 例如，将设备信息保存到数据库或列表中

    // 清空输入框
    _descriptionController.clear();
    _locationController.clear();

    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('设备 $name 添加成功')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加设备'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
             CircleAvatar(
               
                    radius: 40,
                    backgroundImage:selectedDeviceName != null
                  ? AssetImage(_show_img(selectedDeviceName!))
                  : const AssetImage(''), 
                  ),
                SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: selectedDeviceName,
              onChanged: (String? newValue) {
                setState(() {
                  selectedDeviceName = newValue;
               
                });
              },
                 
           items: deviceNames.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: '设备名称',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: '设备位置',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addDevice,
              child: Text('添加设备'),
            ),
          ],
        ),
      ),
    );
  }
}
