import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amap_map2/amap_map2.dart';
import 'package:x_amap_base/x_amap_base.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'location.dart';
import 'services/amap_geocode.dart';

class DeviceDetailPage extends StatefulWidget {
  final Map<String, dynamic> device;

  const DeviceDetailPage({
    super.key,
    required this.device,
  });

  @override
  DeviceDetailPageState createState() => DeviceDetailPageState();
}

class DeviceDetailPageState extends State<DeviceDetailPage> {
  static const Color themeBlue = Color(0xFF2196F3);

  late Map<String, dynamic> device;
  AMapController? _mapController;
  LatLng? _myLocation;
  bool _infoExpanded = false; // 折叠区默认收起，点击 header 或状态卡片展开

  // 定位状态：locating=绿色定位中 / success=蓝色成功 / failed=红色失败
  String _locStatus = 'locating';

  @override
  void initState() {
    super.initState();
    device = Map<String, dynamic>.from(widget.device);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureLocationReady();
      _refreshAddress();
    });
    // 10 秒未定位到则标记失败
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _myLocation == null) {
        setState(() => _locStatus = 'failed');
      }
    });
  }

  /// 用 Web API 逆向地理编码获取设备地址。
  /// 若用户已手动填过地址，则不覆盖（手动优先）。
  Future<void> _refreshAddress() async {
    if (device['address'] != null && (device['address'] as String).isNotEmpty) {
      return; // 已有手动地址，跳过
    }
    final lat = device['lat'];
    final lng = device['lng'];
    if (lat is! num || lng is! num) return;
    final addr = await AMapGeoClient.reverseGeocode(
      lat: lat.toDouble(),
      lng: lng.toDouble(),
    );
    if (!mounted) return;
    if (addr != null && addr.isNotEmpty && device['address'] == null) {
      setState(() => device['address'] = addr);
    }
  }

  /// 弹出对话框让用户手动输入地址，保存后覆盖逆向地理编码结果
  Future<void> _editAddressManually() async {
    final controller = TextEditingController(text: device['address'] as String? ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改地址'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: '例如：1号教学楼一层大厅',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => device['address'] = result);
    } else if (result == '') {
      // 用户清空则重新触发逆向地理编码
      setState(() => device['address'] = null);
      await _refreshAddress();
    }
  }

  /// 确保定位权限已授予，避免 MIUI 上 provider=NULL 黑屏拿不到位置
  Future<void> _ensureLocationReady() async {
    // 1. 检查系统定位服务是否开启
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('系统位置服务未开启，无法定位')),
        );
      }
      return;
    }

    // 2. 检查/申请运行时定位权限
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('定位权限被拒绝，请到系统设置中开启'),
            action: SnackBarAction(label: '去设置', onPressed: () => openAppSettings()),
          ),
        );
      }
      return;
    }

    // 3. 权限已就绪，用 geolocator 获取位置（避免高德 SCODE 鉴权失败）
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (mounted) {
        _myLocation = LatLng(pos.latitude, pos.longitude);
        setState(() => _locStatus = 'success');
      }
    } catch (_) {
      if (mounted) setState(() => _locStatus = 'failed');
    }
  }

  @override
  void dispose() {
    // 退出设备详情页时销毁地图控制器，停止定位回调，避免内存泄漏与持续耗电
    _mapController?.dispose();
    _mapController = null;
    _myLocation = null;
    super.dispose();
  }

  // ---------- 状态相关 ----------

  /// 是否为「我的设备」（可管理，status 为 bool）
  bool get _isManaged => device['status'] is bool;

  bool get _isAvailable {
    final s = device['status'];
    if (s is bool) return s;
    return s == 'available';
  }

  Color get _statusColor {
    final s = device['status'];
    if (s is bool) return s ? Colors.green : Colors.red;
    switch (s) {
      case 'maintenance':
        return Colors.amber;
      case 'occupied':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  String get _statusBadgeText {
    final s = device['status'];
    if (s is bool) return s ? '已添加' : '已隐藏';
    switch (s) {
      case 'maintenance':
        return '维护中';
      case 'occupied':
        return '被占用';
      default:
        return '可使用';
    }
  }

  String get _statusDetailText {
    if (_isManaged) return _isAvailable ? '已添加到列表' : '已从列表中隐藏';
    switch (device['status']) {
      case 'maintenance':
        return '设备维护中，暂时无法使用';
      case 'occupied':
        return '设备正被占用，暂时无法使用';
      default:
        return '设备状态正常，可前往使用';
    }
  }

  // ---------- 距离计算 ----------

  /// 设备经纬度
  LatLng? get _deviceLatLng {
    final lat = device['lat'];
    final lng = device['lng'];
    if (lat is num && lng is num) {
      return LatLng(lat.toDouble(), lng.toDouble());
    }
    return null;
  }

  /// Haversine 公式计算两点距离（米）
  double _distanceMeters(LatLng a, LatLng b) {
    const double r = 6371000;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLng = (b.longitude - a.longitude) * pi / 180;
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    return 2 * r * asin(sqrt(h));
  }

  String get _distanceText {
    if (_myLocation == null || _deviceLatLng == null) return '定位中…';
    final m = _distanceMeters(_myLocation!, _deviceLatLng!);
    if (m < 1000) return '${m.toStringAsFixed(0)} 米';
    return '${(m / 1000).toStringAsFixed(2)} 公里';
  }

  // ---------- 地图 ----------

  Future<void> _moveToDevice() async {
    final target = _deviceLatLng;
    if (target != null && _mapController != null) {
      await _mapController!.moveCamera(CameraUpdate.newLatLngZoom(target, 17));
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    final dev = _deviceLatLng;
    if (dev != null) {
      markers.add(Marker(
        position: dev,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _isAvailable ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(title: device['name']),
      ));
    }
    return markers;
  }

  // ---------- 构建 ----------

  @override
  Widget build(BuildContext context) {
    final dev = _deviceLatLng;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Stack(
        children: [
          // 地图全屏
          Positioned.fill(
            child: dev != null
                ? _buildMap(dev)
                : Container(
                    color: Colors.grey[100],
                    child: const Center(child: Text('设备位置信息缺失')),
                  ),
          ),
          // 顶部悬浮：header（含状态+距离+定位指示）
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              bottom: false,
              child: _buildHeader(),
            ),
          ),
          // 底部详情：默认隐藏，点击状态卡片后从底部滑出
          if (_infoExpanded)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildDetailBottomSheet(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // 定位状态圆圈颜色：绿=定位中 / 蓝=成功 / 红=失败
    final Color locColor;
    switch (_locStatus) {
      case 'success':
        locColor = themeBlue;
        break;
      case 'failed':
        locColor = Colors.red;
        break;
      default:
        locColor = Colors.green;
    }

    return InkWell(
      onTap: () => setState(() => _infoExpanded = !_infoExpanded),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Row(
          children: [
            // 设备图标
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  _getDeviceImage(device['name']),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.medical_services, color: Colors.grey, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 设备名 + 位置 + 状态行
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 设备名 + 状态徽标
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          device['name'],
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: _statusColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusBadgeText,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  // 位置 + 距离
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 11, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${device['address'] ?? '地址解析中…'} · 距您 $_distanceText',
                          style: const TextStyle(fontSize: 11, color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // 定位状态小圆圈 + 展开/收起箭头
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: locColor,
                    border: Border.all(color: Colors.white, width: 1.2),
                    boxShadow: [
                      BoxShadow(color: locColor.withValues(alpha: 0.5), blurRadius: 3),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  _infoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.black54,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(LatLng devicePos) {
    final map = AMapWidget(
      initialCameraPosition: CameraPosition(target: devicePos, zoom: 16),
      myLocationStyleOptions: MyLocationStyleOptions(true),
      onMapCreated: (c) => setState(() => _mapController = c),
      onLocationChanged: (loc) {
        if (mounted) {
          final latLng = loc.latLng;
          _myLocation = latLng;
          // 仅首次定位触发 setState 居中地图，避免频繁重建 AMapWidget 导致白屏
          if (_locStatus != 'success') {
            setState(() => _locStatus = 'success');
          }
        }
      },
      markers: _buildMarkers(),
    );
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          map,
          Positioned(
            right: 8,
            bottom: 8,
            child: FloatingActionButton.small(
              heroTag: 'nav_device',
              backgroundColor: Colors.white,
              onPressed: _moveToDevice,
              child: const Icon(Icons.navigation, color: themeBlue),
            ),
          ),
        ],
      ),
    );
  }

  /// 底部详情弹窗：点击状态卡片后从底部滑出
  Widget _buildDetailBottomSheet() {
    final tiles = <Map<String, dynamic>>[
      {'icon': Icons.info_outline, 'title': '设备状态说明', 'content': _statusDetailText},
      {'icon': Icons.place_outlined, 'title': '设备地址', 'content': device['address'] as String? ?? '正在解析地址…', 'onTap': _editAddressManually},
      {'icon': Icons.access_time, 'title': '最后更新时间', 'content': '2024-03-20 14:30'},
      {'icon': Icons.history, 'title': '维护记录', 'content': '最近一次维护：2024-03-15'},
      {'icon': Icons.movie, 'title': '设备使用介绍', 'content': '点开即可查看使用说明视频'},
    ];
    if (_isManaged) {
      tiles.add({
        'icon': Icons.location_city,
        'title': '修改位置',
        'content': '点击在地图上重新标记位置',
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationPage())),
      });
    }

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        padding: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -2))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示条
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            // 标题行 + 关闭按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text('设备详细信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => setState(() => _infoExpanded = false),
                  ),
                ],
              ),
            ),
            const Divider(),
            // 内容列表
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (int i = 0; i < tiles.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      _buildDetailTile(tiles[i]),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(Map<String, dynamic> tile) {
    final content = tile['content'] as String;
    final onTap = tile['onTap'] as VoidCallback?;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(tile['icon'] as IconData, color: themeBlue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tile['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                onTap != null
                    ? InkWell(
                        onTap: onTap,
                        child: Row(
                          children: [
                            Expanded(child: Text(content, style: TextStyle(fontSize: 14, color: themeBlue))),
                            const Icon(Icons.chevron_right, color: themeBlue, size: 18),
                          ],
                        ),
                      )
                    : Text(content, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
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
