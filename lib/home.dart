import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:amap_map2/amap_map2.dart';
import 'package:x_amap_base/x_amap_base.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import './utils/device_utils.dart';
import './widgets/device_card.dart';
import './my_devices.dart';
import './location.dart';
import './services/amap_geocode.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color themeBlue = Color(0xFF2196F3);

  /// 自动刷新间隔（30 秒）
  static const Duration _refreshInterval = Duration(seconds: 30);

  Timer? _refreshTimer;
  LatLng? _myLocation;

  /// 附近的急救设备（示例数据，后续接入定位与组织权限接口）
  /// 只读：用户不可隐藏或删除这些设备
  /// 状态：available=可使用（绿）/ maintenance=维护中（黄）/ occupied=被占用（红）
  /// lat/lng 为设备坐标，distance/address 字段由运行时动态填充：
  ///   - distance：根据用户当前位置 Haversine 计算
  ///   - address：通过高德 Web 服务逆向地理编码获取，用户也可手动覆盖
  late final List<Map<String, dynamic>> _nearbyDevices = [
    {'name': 'AED', 'status': 'available', 'lat': 41.7290, 'lng': 123.2520, 'address': null},
    {'name': '急救箱', 'status': 'available', 'lat': 41.7280, 'lng': 123.2510, 'address': null},
    {'name': '灭火器', 'status': 'maintenance', 'lat': 41.7300, 'lng': 123.2530, 'address': null},
    {'name': '紧急呼叫系统', 'status': 'occupied', 'lat': 41.7270, 'lng': 123.2540, 'address': null},
    {'name': '担架', 'status': 'occupied', 'lat': 41.7295, 'lng': 123.2500, 'address': null},
    {'name': '轮椅', 'status': 'available', 'lat': 41.7310, 'lng': 123.2515, 'address': null},
  ];

  @override
  void initState() {
    super.initState();
    // 并行触发：地址查询（不依赖定位）+ 权限申请（不依赖地址）
    // 不用 await，避免网络请求阻塞权限对话框弹出
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // fire-and-forget：地址查询失败不阻断权限申请
      _refreshAddresses().whenComplete(() {
        if (mounted) setState(_rebuildDistances);
      });
      // 立即申请定位权限，弹对话框不等待
      _ensureLocationReady();
    });
    // 每 30 秒自动刷新一次附近设备（含重新获取定位，适配用户移动）
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => _refreshDevices());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    super.dispose();
  }

  /// 确保定位权限已授予并获取一次位置；后续定时器会持续刷新
  Future<void> _ensureLocationReady() async {
    try {
      // 1. 检查系统定位服务是否开启
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('[HomePage] location service enabled: $serviceEnabled');
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('系统位置服务未开启，无法计算距离')),
          );
        }
        return;
      }

      // 2. 检查/申请运行时定位权限
      LocationPermission permission = await Geolocator.checkPermission();
      print('[HomePage] location permission: $permission');
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('[HomePage] after request, permission: $permission');
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

      // 3. 权限已就绪，立即获取位置并刷新
      await _fetchLocationAndRefresh();
    } catch (e) {
      print('[HomePage] _ensureLocationReady exception: $e');
    }
  }

  /// 用系统原生定位（geolocator）获取一次当前位置，然后刷新附近设备距离
  /// 使用 geolocator 而非 AMapLocationClient，避免高德 SCODE 鉴权失败导致拿不到位置
  Future<void> _fetchLocationAndRefresh() async {
    // 1. 先尝试获取最后一次已知位置（立即返回，不超时）
    try {
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null && _myLocation == null) {
        _myLocation = LatLng(lastPos.latitude, lastPos.longitude);
        print('[HomePage] getLastKnownPosition: ${lastPos.latitude}, ${lastPos.longitude}');
        if (mounted) setState(_rebuildDistances);
      }
    } catch (e) {
      print('[HomePage] getLastKnownPosition failed: $e');
    }

    // 2. 再异步获取当前位置（降低精度 + 增大超时，提高成功率）
    try {
      print('[HomePage] getCurrentPosition start');
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _myLocation = LatLng(pos.latitude, pos.longitude);
      print('[HomePage] getCurrentPosition success: ${pos.latitude}, ${pos.longitude}');
    } catch (e) {
      print('[HomePage] getCurrentPosition failed: $e');
    }
    // 立即刷新距离（不等地址查询，让用户先看到距离）
    if (!mounted) return;
    setState(_rebuildDistances);
    // 异步刷新地址（不阻塞 UI，完成后再次 setState 显示地址）
    _refreshAddresses().whenComplete(() {
      if (mounted) setState(_rebuildDistances);
    });
  }

  /// 用 Web 服务 API 批量查询附近设备的地址，写入 address 字段。
  /// Web Key 未配置时静默失败，保留原有手动地址作为兜底。
  Future<void> _refreshAddresses() async {
    final List<LatLngPair> coords = _nearbyDevices
        .map((d) => LatLngPair(
              (d['lat'] as num).toDouble(),
              (d['lng'] as num).toDouble(),
            ))
        .toList();
    final List<String?> addresses =
        await AMapGeoClient.batchReverseGeocode(coords);
    for (int i = 0; i < _nearbyDevices.length && i < addresses.length; i++) {
      final String? addr = addresses[i];
      if (addr != null && addr.isNotEmpty) {
        _nearbyDevices[i]['address'] = addr;
      }
    }
  }

  /// 重新计算所有设备的距离并按由近到远排序
  void _rebuildDistances() {
    for (final d in _nearbyDevices) {
      // distanceMeters 存 double 用于排序；distance 存 String 用于显示
      final meters = _calcDistanceMeters(
        _myLocation,
        (d['lat'] as num).toDouble(),
        (d['lng'] as num).toDouble(),
      );
      d['distanceMeters'] = meters;
      d['distance'] = _formatDistance(meters);
    }
    _nearbyDevices.sort((a, b) {
      final da = (a['distanceMeters'] as num?)?.toDouble() ?? double.infinity;
      final db = (b['distanceMeters'] as num?)?.toDouble() ?? double.infinity;
      return da.compareTo(db);
    });
  }

  /// Haversine 公式计算两点间球面距离（米），返回 double
  /// 若用户位置未知，返回 null
  double? _calcDistanceMeters(LatLng? me, double lat, double lng) {
    if (me == null) return null;
    const double r = 6371000.0;
    double toRad(double deg) => deg * math.pi / 180.0;
    final double dLat = toRad(lat - me.latitude);
    final double dLng = toRad(lng - me.longitude);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(toRad(me.latitude)) *
            math.cos(toRad(lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  /// 把距离（米）格式化为展示文本
  String _formatDistance(double? meters) {
    if (meters == null) return '距离未知';
    if (meters < 1000) return '${meters.round()}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  /// 拉取附近设备数据（当前是示例数据，后续接入定位与组织权限接口）
  Future<void> _refreshDevices() async {
    // TODO: 替换为真实接口调用
    // final list = await DeviceApi.fetchNearby(myLocation: _myLocation);
    // 定时器触发时重新获取定位，保持距离与用户当前位置一致
    await _fetchLocationAndRefresh();
  }

  /// 高德 AMapWidget 的定位回调（借用地图 SDK 的定位服务）
  /// MIUI 限制 geolocator 定位超时，但高德 SDK 的 onLocationChanged
  /// 第一次能拿到真实 GPS 位置（即使 SCODE 鉴权失败也能拿到）
  void _onAmapLocationChanged(AMapLocation loc) {
    final latLng = loc.latLng;
    // 过滤鉴权失败后的空位置 [0.0, 0.0]
    if (latLng.latitude != 0.0 || latLng.longitude != 0.0) {
      final newLoc = LatLng(latLng.latitude, latLng.longitude);
      // 只在位置有变化时更新，避免重复 setState
      if (_myLocation == null ||
          (_myLocation!.latitude - newLoc.latitude).abs() > 0.0001 ||
          (_myLocation!.longitude - newLoc.longitude).abs() > 0.0001) {
        _myLocation = newLoc;
        print('[HomePage] AMap onLocationChanged: ${newLoc.latitude}, ${newLoc.longitude}');
        if (mounted) setState(_rebuildDistances);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 隐藏的 AMapWidget（1x1 像素，放在屏幕外），仅用于激活高德定位服务
            // MIUI 上 geolocator 超时，但高德 SDK 定位第一次能拿到真实 GPS 位置
            Positioned(
              left: -1,
              top: -1,
              child: SizedBox(
                width: 1,
                height: 1,
                child: IgnorePointer(
                  child: AMapWidget(
                    myLocationStyleOptions: MyLocationStyleOptions(true),
                    onLocationChanged: _onAmapLocationChanged,
                  ),
                ),
              ),
            ),
            // 原有的首页内容
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部：两个入口卡片（我的设备 / 地图）
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(child: _MyDevicesEntryCard()),
                      const SizedBox(width: 12),
                      Expanded(child: _MapEntryCard()),
                    ],
                  ),
                ),
                // 附近设备标题
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Text(
                    '附近的急救设备',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // 附近设备（只读卡片，无隐藏/删除权限），支持下拉刷新
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshDevices,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      itemCount: _nearbyDevices.length,
                      itemBuilder: (BuildContext context, int index) {
                        return DeviceCard(
                          device: _nearbyDevices[index],
                          themeBlue: themeBlue,
                          getDeviceImage: DeviceUtils.getDeviceImage,
                          getStatusIcon: DeviceUtils.getStatusIcon,
                          getStatusColor: DeviceUtils.getStatusColor,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 「我的设备」入口卡片（半宽，竖向布局）
class _MyDevicesEntryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _EntryCard(
      gradient: const [Color(0xFF42A5F5), Color(0xFF1976D2)],
      icon: Icons.inventory_2_outlined,
      title: '我的设备',
      subtitle: '管理你共享的设备',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyDevicesPage()),
        );
      },
    );
  }
}

/// 「地图」入口卡片（半宽，竖向布局）
class _MapEntryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _EntryCard(
      gradient: const [Color(0xFF66BB6A), Color(0xFF2E7D32)],
      icon: Icons.map_outlined,
      title: '地图',
      subtitle: '查看附近设备位置',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LocationPage()),
        );
      },
    );
  }
}

/// 通用半宽入口卡片
class _EntryCard extends StatelessWidget {
  final List<Color> gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _EntryCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

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
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.last.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white24,
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
