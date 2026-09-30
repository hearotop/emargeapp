import 'dart:convert';
import 'dart:io';

import '../config/amap_keys.dart';

/// 高德 Web 服务 API 客户端（逆向地理编码）。
///
/// 设计动机：amap_map2 native SDK 在新版本高德控制台开启 SCODE 校验后，
/// 会因 INVALID_USER_SCODE (infocode 10008) 而无法工作。Web 服务接口走
/// HTTPS + Key 鉴权，不依赖 native SDK，不受 SCODE 影响。
///
/// 鉴权要求：
/// - Key 从 config/amap_keys.dart 读取，不硬编码
/// - 需要在高德控制台为该 Key 添加「Web 服务」平台权限，否则会返回
///   `INVALID_USER_SCODE` / `USERKEY_PLAT_NOMATCH` 错误
/// - 操作路径：高德开放平台 → 控制台 → 应用管理 → 我的应用 →
///   找到对应 Key → 编辑 → 勾选「Web 服务」→ 保存
///
/// 接口文档：https://lbs.amap.com/api/webservice/guide/api/georegeo#regeo
class AMapGeoClient {
  AMapGeoClient._();

  /// 高德 Web 服务 Key（与 Android Key 不同，单独申请的 Web 服务类型 Key）
  /// 用于逆向地理编码等 Web API 调用，不依赖 native SDK，不受 SCODE 影响
  static const String _webKey = AmapKeys.webKey;

  /// 简单内存缓存：坐标 → 地址，避免 30 秒刷新时重复请求
  /// 缓存有效期 5 分钟，过期后重新查询
  static final Map<String, _CacheEntry> _cache = {};
  static const Duration _cacheTtl = Duration(minutes: 5);

  /// 逆向地理编码：根据经纬度查询附近的地点名称。
  ///
  /// 返回适合直接展示在卡片上的简短名称（优先用 POI/建筑/街道名），
  /// 查询失败时返回 null，由调用方走兜底逻辑。
  static Future<String?> reverseGeocode({
    required double lat,
    required double lng,
    int radius = 200,
  }) async {
    final String cacheKey = '${lng.toStringAsFixed(6)},${lat.toStringAsFixed(6)}';
    final _CacheEntry? cached = _cache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.time) < _cacheTtl) {
      return cached.address;
    }

    final Uri uri = Uri(
      scheme: 'https',
      host: 'restapi.amap.com',
      path: '/v3/geocode/regeo',
      queryParameters: <String, String>{
        'key': _webKey,
        'location': '$lng,$lat', // 高德 Web API 顺序：经度,纬度
        'radius': radius.toString(),
        'extensions': 'base', // 只返回基础信息，节省流量
        'output': 'json',
      },
    );

    try {
      final HttpClient client = HttpClient();
      final HttpClientRequest request = await client.getUrl(uri);
      final HttpClientResponse response = await request.close();
      final String body = await response.transform(utf8.decoder).join();
      client.close();

      final Map<String, dynamic> json =
          jsonDecode(body) as Map<String, dynamic>;
      final String? status = json['status']?.toString();
      if (status != '1') {
        // 接口报错，打印错误码方便排查（常见：USERKEY_PLAT_NOMATCH=Key未勾选Web服务）
        final String? infocode = json['infocode']?.toString();
        print('[AMapGeoClient] reverseGeocode failed: status=$status, infocode=$infocode, info=${json['info']}');
        return null;
      }

      final Map<String, dynamic>? regeocode =
          json['regeocode'] as Map<String, dynamic>?;
      if (regeocode == null) return null;

      // formatted_address 形如：「北京市东城区东华门街道天安门广场」
      final String formatted =
          (regeocode['formatted_address'] as String?)?.trim() ?? '';
      if (formatted.isEmpty) return null;

      // 取街道/镇 + POI 片段作为简短地址
      // 注意：高德 API 某些字段可能返回空数组 [] 而非字符串，需要安全转换
      final Map<String, dynamic>? addrComponent =
          regeocode['addressComponent'] as Map<String, dynamic>?;
      final String? township = _safeString(addrComponent?['township']);
      final String? street = _safeString(addrComponent?['street']);
      final String? streetNumber = addrComponent?['streetNumber'] is Map
          ? _safeString(
              (addrComponent!['streetNumber'] as Map<String, dynamic>)['street'])
          : null;

      // 用「乡镇 + 街道」或最后的 POI 段拼接简短名
      final String shortName =
          _pickShortName(formatted, township, street, streetNumber);
      final String result = shortName.isEmpty ? formatted : shortName;

      // 写入缓存
      _cache[cacheKey] = _CacheEntry(result, DateTime.now());
      return result;
    } catch (e) {
      print('[AMapGeoClient] reverseGeocode exception: $e');
      return null; // 网络异常，走兜底
    }
  }

  /// 安全转换为字符串：高德 API 某些字段可能返回空数组 [] 而非字符串
  /// 例如 city 字段在直辖市情况下返回 []，需要兼容处理
  static String? _safeString(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null; // List、Map、null 等都返回 null
  }

  /// 从格式化地址中提取简短的地点名（去掉省/市/区前缀）
  static String _pickShortName(
    String formatted,
    String? township,
    String? street,
    String? streetNumber,
  ) {
    // 优先用「街道」组合
    String combined = '';
    if (street != null && street.isNotEmpty) {
      combined = street;
      if (streetNumber != null && streetNumber.isNotEmpty) {
        combined = '$street$streetNumber';
      }
      if (township != null && township.isNotEmpty) {
        combined = '$township$combined';
      }
    }
    if (combined.isNotEmpty) return combined;

    // 退化方案：用格式化地址的最后一段（去掉省市区前缀）
    final List<String> parts = formatted
        .split(RegExp(r'[市辖区县街道镇乡]'))
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.isNotEmpty ? parts.last : formatted;
  }

  /// 批量查询多个坐标的地址，按入参顺序返回结果（null 表示该坐标查询失败）。
  /// 并发数受 [concurrency] 限制，避免瞬时请求过多被限流。
  /// 已缓存的坐标直接返回，不发起网络请求。
  static Future<List<String?>> batchReverseGeocode(
    List<LatLngPair> coords, {
    int concurrency = 4,
  }) async {
    final int n = coords.length;
    if (n == 0) return const <String?>[];
    final List<String?> results = List<String?>.filled(n, null);
    int next = 0;
    Future<void> worker() async {
      while (true) {
        final int i = next++;
        if (i >= n) break;
        results[i] = await reverseGeocode(lat: coords[i].lat, lng: coords[i].lng);
      }
    }

    await Future.wait(List.generate(
      concurrency.clamp(1, n),
      (_) => worker(),
    ));
    return results;
  }

  /// 清空缓存（如用户手动修改了地址，可调用此方法让下次刷新重新查询）
  static void clearCache() => _cache.clear();
}

/// 缓存条目
class _CacheEntry {
  const _CacheEntry(this.address, this.time);
  final String address;
  final DateTime time;
}

/// 简单经纬度容器，替代 record 以兼容 Dart 2.x
class LatLngPair {
  const LatLngPair(this.lat, this.lng);
  final double lat;
  final double lng;
}

