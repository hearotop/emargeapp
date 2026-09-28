import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'discover_devices.dart';

/// 添加设备入口页
/// 支持两种添加方式：
/// 1. 物联网设备（ESP32/ESP8266，保持 Wi-Fi 联网）：
///    局域网 mDNS 自动发现（暂不支持蓝牙 Mesh）/ 扫码 / NFC / 第三方平台
/// 2. 无网络设备：手动添加，作为标记点显示在地图上
class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  /// 进入 mDNS 设备发现页
  void _openDiscoveryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeviceDiscoveryPage()),
    );
  }

  void _openComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title：功能开发中，敬请期待')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加设备'),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 顶部：自动发现新设备（物联网设备，mDNS 局域网搜索）
          _DiscoverCard(onTap: _openDiscoveryPage),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '其他添加方式',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _AddMethodCard(
            icon: Icons.qr_code_scanner,
            iconColor: Colors.blue,
            iconBg: Colors.blue.withOpacity(0.1),
            title: '扫码添加',
            subtitle: '扫描设备二维码，绑定设备',
            onTap: () => _openComingSoon('扫码添加'),
          ),
          _AddMethodCard(
            icon: Icons.nfc,
            iconColor: Colors.teal,
            iconBg: Colors.teal.withOpacity(0.1),
            title: 'NFC 添加',
            subtitle: '触碰设备上的 NFC 标签，快速绑定设备',
            onTap: () => _openComingSoon('NFC 添加'),
          ),
          _AddMethodCard(
            icon: Icons.edit_location_alt_outlined,
            iconColor: Colors.green,
            iconBg: Colors.green.withOpacity(0.1),
            title: '手动添加',
            subtitle: '添加无网络设备，在地图上标记位置',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManualAddDevicePage(),
                ),
              );
            },
          ),
          _AddMethodCard(
            icon: Icons.cloud_outlined,
            iconColor: Colors.purple,
            iconBg: Colors.purple.withOpacity(0.1),
            title: '第三方平台',
            subtitle: '从合作厂商平台接入物联设备',
            onTap: () => _openComingSoon('第三方平台'),
          ),
        ],
      ),
    );
  }
}

/// 自动发现新设备卡片
class _DiscoverCard extends StatelessWidget {
  final VoidCallback onTap;

  const _DiscoverCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2196F3).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.sensors,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '自动发现新设备',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '搜索设备',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    onPressed: onTap,
                    icon: const Icon(Icons.search),
                    label: const Text('立即搜索'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 添加方式条目卡片
class _AddMethodCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddMethodCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

/// 手动添加设备页（无网络设备，作为地图标记）
class ManualAddDevicePage extends StatefulWidget {
  const ManualAddDevicePage({super.key});

  @override
  State<ManualAddDevicePage> createState() => _ManualAddDevicePageState();
}

class _ManualAddDevicePageState extends State<ManualAddDevicePage> {
  static const Color themeBlue = Color(0xFF2196F3);

  final TextEditingController _locationController = TextEditingController();

  // 定义设备名称列表
  final List<String> deviceNames = [
    'AED',
    '急救箱',
    '轮椅',
    '担架',
    '紧急呼叫系统',
    '灭火器'
  ];
  String? selectedDeviceName;

  String _showImg(String name) {
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

  void _addDevice() {
    final String name = selectedDeviceName ?? '';
    final String location = _locationController.text.trim();

    if (name.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择设备类型并填写位置')),
      );
      return;
    }

    // TODO: 将无网络设备保存到后端，在地图上生成标记点

    _locationController.clear();
    setState(() => selectedDeviceName = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('设备 $name 添加成功，已标记到地图')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('手动添加'),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '适用于无网络连接的设备，添加后将以标记点显示在地图上',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.brown[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: themeBlue.withOpacity(0.08),
                backgroundImage: selectedDeviceName != null
                    ? AssetImage(_showImg(selectedDeviceName!))
                    : null,
                child: selectedDeviceName == null
                    ? const Icon(Icons.medical_services_outlined,
                        size: 36, color: themeBlue)
                    : null,
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: selectedDeviceName,
              onChanged: (String? newValue) {
                setState(() {
                  selectedDeviceName = newValue;
                });
              },
              items: deviceNames
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: '设备名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: '设备位置',
                hintText: '如：1号教学楼三层走廊',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: themeBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _addDevice,
                child: const Text('添加设备'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
