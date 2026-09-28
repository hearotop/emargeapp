import 'package:flutter/material.dart';
import '../device_detail.dart';

class DeviceCard extends StatelessWidget {
  final Map<String, dynamic> device;
  final Function(Map<String, dynamic>)? onAddPressed;
  final VoidCallback? onLongPress;
  final Color themeBlue;
  final Function(String) getDeviceImage;
  final Icon Function(bool) getStatusIcon;
  final Color Function(bool) getStatusColor;

  const DeviceCard({
    super.key,
    required this.device,
    this.onAddPressed,
    this.onLongPress,
    required this.themeBlue,
    required this.getDeviceImage,
    required this.getStatusIcon,
    required this.getStatusColor,
  });

  /// 是否为只读卡片（如附近设备）：不提供隐藏/删除入口
  bool get _readOnly => onAddPressed == null;

  /// 附近设备三态颜色：绿色=可用，黄色=维护中，红色=占用/不可用
  Color _nearbyStatusColor(dynamic status) {
    switch (status) {
      case 'maintenance':
        return Colors.amber;
      case 'occupied':
        return Colors.red;
      case 'available':
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeviceDetailPage(device: device),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _readOnly
                ? _buildNearbyLayout()
                : _buildManagedLayout(),
          ),
        ),
      ),
    );
  }

  /// 附近设备（只读）卡片：设备头像 + 设备名 + 状态圆圈 + 距离 + 地理名称
  Widget _buildNearbyLayout() {
    final distance = device['distance'] as String?;
    final address = device['address'] as String?;
    final bool addressLoading = address == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 顶部：设备头像 + 设备名 + 状态圆圈
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: themeBlue.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  getDeviceImage(device['name']),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.medical_services,
                    color: Colors.grey,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                device['name'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: themeBlue,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _nearbyStatusColor(device['status']),
              ),
            ),
          ],
        ),
        const Spacer(),
        // 距离
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                distance ?? '距离未知',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // 地址
        Row(
          children: [
            Icon(
              Icons.place_outlined,
              size: 14,
              color: Colors.grey[500],
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                address ?? '位置解析中…',
                style: TextStyle(
                  fontSize: 12,
                  color: addressLoading ? Colors.grey[400] : Colors.grey[600],
                  fontStyle: addressLoading ? FontStyle.italic : FontStyle.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 我的设备（可管理）卡片：保留完整布局与隐藏/删除按钮
  Widget _buildManagedLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: themeBlue.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  getDeviceImage(device['name']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: getStatusColor(device['status']),
              ),
              child: IconButton(
                icon: getStatusIcon(device['status']),
                onPressed: () => onAddPressed!(device),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          device['name'],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeBlue,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                device['location'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
