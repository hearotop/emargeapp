import 'package:flutter/material.dart';
import 'package:namer_app/location.dart';

class DeviceDetailPage extends StatefulWidget {
  final Map<String, dynamic> device;

  const DeviceDetailPage({
    super.key,
    required this.device,
  });

  @override
  _DeviceDetailPageState createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  late Map<String, dynamic> device;

  @override
  void initState() {
    super.initState();
    device = Map<String, dynamic>.from(widget.device);
  }

  void _toggleDeviceStatus() {
    setState(() {
      device['status'] = !device['status'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设备详情'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF2196F3),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeviceInfo(),
            _buildMapSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF2196F3).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    _getDeviceImage(device['name']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device['name'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            device['location'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showStatusDialog(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: device['status'] ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    device['status'] ? '已添加' : '已隐藏',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildInfoCard(
            '设备状态',
            device['status'] ? '已添加到列表' : '已从列表中隐藏',
            device['status'] ? Icons.check_circle : Icons.visibility_off,
           null,
          ),
          SizedBox(height: 12),
          _buildInfoCard(
            '最后更新时间',
            '2024-03-20 14:30',
            Icons.access_time,
           null,
          ),
          SizedBox(height: 12),
          _buildInfoCard(
            '维护记录',
            '最近一次维护：2024-03-15',
            Icons.history,
           null,
          ),
              SizedBox(height: 12),
          _buildInfoCard(
            '设备使用介绍',
            '点开即可查看使用说明视频',
      
            Icons.movie,
           null,
          ),
          SizedBox(height: 12),
          _buildInfoCard(
            '修改位置',
            '',
            Icons.location_city,
            LocationPage(),
          ),

        ],
      ),
    );
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                device['status']
                    ? Icons.visibility_off
                    : Icons.add_circle_outline,
                color: Color(0xFF2196F3),
              ),
              SizedBox(width: 8),
              Text(device['status'] ? '隐藏设备' : '添加设备'),
            ],
          ),
          content: Text(
              '您确定要${device['status'] ? '隐藏' : '添加'}设备: ${device['name']}吗？'),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Color(0xFF2196F3),
              ),
              child: Text('确认'),
              onPressed: () {
                _toggleDeviceStatus();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(
      String title, String content, IconData icon, Widget? targetPage) {
    return GestureDetector(
      onTap: targetPage != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => targetPage,
                ),
              );
            }
          : null,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: Color(0xFF2196F3),
                size: 24,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 300,
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Expanded(
        
          child: 
          
            Image.asset(
            "lib/image/map.png" 
            )
          
        ),
      ),
    );
  }

  String _getDeviceImage(String name) {
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
}
