import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amap_map2/amap_map2.dart';
import 'package:x_amap_base/x_amap_base.dart';
import 'package:permission_handler/permission_handler.dart';

/// 高德地图 + 定位页
///
/// - 展示用户当前位置（小蓝点），首次定位自动居中
/// - 以不同颜色标记展示附近的急救设备
///   绿色=可使用 / 黄色=维护中 / 红色=被占用
/// - 右下角「回到我的位置」按钮
class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  static const Color themeBlue = Color(0xFF2196F3);

  // 默认中心（北京天安门），定位成功后会移动到用户位置
  static const LatLng _defaultCenter = LatLng(39.909187, 116.397451);

  AMapController? _mapController;
  LatLng? _myLocation;
  bool _locationReady = false;

  // 附近设备（示例坐标，后续接真实设备数据）
  final List<Map<String, dynamic>> _nearbyDevices = const [
    {'name': 'AED', 'lat': 39.910, 'lng': 116.398, 'status': 'available'},
    {'name': '急救箱', 'lat': 39.908, 'lng': 116.396, 'status': 'available'},
    {'name': '灭火器', 'lat': 39.912, 'lng': 116.400, 'status': 'maintenance'},
    {'name': '紧急呼叫系统', 'lat': 39.907, 'lng': 116.399, 'status': 'occupied'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLocationReady());
  }

  @override
  void dispose() {
    // 用户退出页面时销毁地图控制器，停止定位回调，避免内存泄漏与持续耗电
    _mapController?.dispose();
    _mapController = null;
    _myLocation = null;
    super.dispose();
  }

  /// 完整的定位前置检查：
  /// 1. 检查系统「位置服务」总开关是否开启（MIUI 关掉后 provider=NULL）
  /// 2. 检查/申请运行时定位权限
  /// 3. 处理永久拒绝场景，引导用户去系统设置
  Future<void> _ensureLocationReady() async {
    // 1. 系统位置服务总开关
    final serviceStatus = await Permission.location.serviceStatus;
    if (!serviceStatus.isEnabled) {
      if (!mounted) return;
      _showLocationDialog(
        '位置服务未开启',
        '请在系统设置中打开「位置」开关后重试',
        onConfirm: () => openAppSettings(),
      );
      return;
    }

    // 2. 检查权限状态
    var status = await Permission.location.status;
    if (status.isGranted || status.isLimited) {
      return; // 已有权限，等地图定位回调
    }

    // 3. 之前永久拒绝过，直接引导去系统设置
    if (status.isPermanentlyDenied) {
      if (!mounted) return;
      _showLocationDialog(
        '定位权限被拒绝',
        '之前拒绝了定位权限，需要到系统设置中手动开启',
        onConfirm: () => openAppSettings(),
      );
      return;
    }

    // 4. 首次申请权限
    status = await Permission.location.request();
    if (!status.isGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未授予定位权限，无法显示当前位置')),
      );
    }
  }

  void _showLocationDialog(String title, String content, {required VoidCallback onConfirm}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(onPressed: () { Navigator.pop(ctx); onConfirm(); }, child: const Text('去设置')),
        ],
      ),
    );
  }

  /// 根据设备状态返回 Marker 颜色
  BitmapDescriptor _markerIcon(String status) {
    switch (status) {
      case 'maintenance':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case 'occupied':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  /// 构建设备 Marker 集合
  Set<Marker> _buildMarkers() {
    return _nearbyDevices.map((d) {
      return Marker(
        position: LatLng(d['lat'], d['lng']),
        icon: _markerIcon(d['status']),
        infoWindow: InfoWindow(
          title: d['name'],
          snippet: _statusText(d['status']),
        ),
      );
    }).toSet();
  }

  String _statusText(String status) {
    switch (status) {
      case 'maintenance':
        return '维护中';
      case 'occupied':
        return '被占用';
      default:
        return '可使用';
    }
  }

  /// 回到我的位置
  Future<void> _moveToMyLocation() async {
    if (_myLocation != null && _mapController != null) {
      await _mapController!.moveCamera(
        CameraUpdate.newLatLngZoom(_myLocation!, 16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final map = AMapWidget(
      initialCameraPosition: const CameraPosition(
        target: _defaultCenter,
        zoom: 15,
      ),
      myLocationStyleOptions: MyLocationStyleOptions(true),
      onMapCreated: (controller) {
        setState(() => _mapController = controller);
      },
      onLocationChanged: (AMapLocation location) {
        _myLocation = location.latLng;
        // 首次定位成功时自动居中一次
        if (!_locationReady) {
          _locationReady = true;
          _moveToMyLocation();
        }
      },
      markers: _buildMarkers(),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Stack(
        children: [
          SizedBox.expand(child: map),
          // 图例
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _legendItem(BitmapDescriptor.hueGreen, '可使用'),
                  const SizedBox(height: 4),
                  _legendItem(BitmapDescriptor.hueYellow, '维护中'),
                  const SizedBox(height: 4),
                  _legendItem(BitmapDescriptor.hueRed, '被占用'),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveToMyLocation,
        backgroundColor: themeBlue,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _legendItem(double hue, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: HSLColor.fromAHSL(1, hue, 0.7, 0.5).toColor(),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
