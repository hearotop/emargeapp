import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/device_discovery.dart';
import 'utils/device_utils.dart';

/// 物联设备发现页：mDNS 搜索同一 Wi-Fi 局域网内的 ESP32/ESP8266 设备
class DeviceDiscoveryPage extends StatefulWidget {
  const DeviceDiscoveryPage({super.key});

  @override
  State<DeviceDiscoveryPage> createState() => _DeviceDiscoveryPageState();
}

class _DeviceDiscoveryPageState extends State<DeviceDiscoveryPage> {
  static const Color themeBlue = Color(0xFF2196F3);
  static const MethodChannel _wifiChannel = MethodChannel('emarge/wifi');

  /// 一次搜索的持续时间
  static const Duration _scanDuration = Duration(seconds: 8);

  final List<DiscoveredDevice> _devices = [];
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _releaseMulticastLock();
    super.dispose();
  }

  /// Android 上接收 mDNS 组播包必须持有 MulticastLock
  Future<void> _acquireMulticastLock() async {
    try {
      await _wifiChannel.invokeMethod('acquireMulticastLock');
    } on PlatformException catch (_) {
      // 非 Android 平台或系统拒绝时忽略
    } on MissingPluginException catch (_) {}
  }

  Future<void> _releaseMulticastLock() async {
    try {
      await _wifiChannel.invokeMethod('releaseMulticastLock');
    } catch (_) {}
  }

  Future<void> _startScan() async {
    if (_scanning) return;
    setState(() {
      _scanning = true;
      _devices.clear();
    });

    await _acquireMulticastLock();
    await MdnsDeviceDiscovery.discover(
      timeout: _scanDuration,
      onDeviceFound: (device) {
        if (mounted) setState(() => _devices.add(device));
      },
    );
    await _releaseMulticastLock();

    if (mounted) setState(() => _scanning = false);
  }

  /// 绑定设备（TODO：接入后端绑定接口，登记设备 ID / 组织 / 位置）
  void _bindDevice(DiscoveredDevice device) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.link, color: themeBlue),
              const SizedBox(width: 8),
              const Text('绑定设备'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('设备：${device.name}'),
              const SizedBox(height: 4),
              Text('类型：${device.type}'),
              const SizedBox(height: 4),
              Text('厂商：${device.vendor}'),
              if (device.version.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('固件版本：${device.version}'),
              ],
              const SizedBox(height: 4),
              Text('地址：${device.ip.isEmpty ? '未获取' : device.ip}:${device.port}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: themeBlue),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('设备 ${device.name} 绑定成功（待接入后端）')),
                );
              },
              child: const Text('确认绑定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自动发现新设备'),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '重新搜索',
            onPressed: _scanning ? null : _startScan,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildScanBanner(),
          Expanded(
            child: _scanning || _devices.isNotEmpty
                ? _buildDeviceList()
                : _buildEmptyView(),
          ),
        ],
      ),
    );
  }

  /// 顶部搜索状态条
  Widget _buildScanBanner() {
    return Container(
      width: double.infinity,
      color: themeBlue.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (_scanning)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            const Icon(Icons.wifi, size: 18, color: themeBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _scanning
                  ? '正在搜索设备…'
                  : '搜索完成，共发现 ${_devices.length} 台设备',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _devices.length + (_scanning ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        // 搜索中列表底部的等待提示行
        if (index == _devices.length) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            child: Text(
              '继续搜索中…',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          );
        }
        return _DeviceTile(
          device: _devices[index],
          onBind: () => _bindDevice(_devices[index]),
        );
      },
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_find, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              '未发现设备',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '请确认：\n'
              '1. 设备已上电并接入 Wi-Fi\n'
              '2. 手机与设备连接在同一 Wi-Fi 局域网\n'
              '3. 设备已注册 _emarge-device._tcp 服务',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.8),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: themeBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _startScan,
              icon: const Icon(Icons.refresh),
              label: const Text('重新搜索'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 发现到的设备条目
class _DeviceTile extends StatelessWidget {
  final DiscoveredDevice device;
  final VoidCallback onBind;

  const _DeviceTile({required this.device, required this.onBind});

  @override
  Widget build(BuildContext context) {
    final image = DeviceUtils.getDeviceImage(device.type);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF2196F3).withOpacity(0.08),
              backgroundImage: image.isNotEmpty ? AssetImage(image) : null,
              child: image.isEmpty
                  ? const Icon(Icons.sensors, color: Color(0xFF2196F3))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${device.type} · ${device.vendor}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    device.ip.isEmpty
                        ? 'IP 解析中…'
                        : '${device.ip}:${device.port}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: onBind,
              child: const Text('绑定'),
            ),
          ],
        ),
      ),
    );
  }
}
