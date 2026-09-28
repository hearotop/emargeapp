import 'dart:async';

import 'package:multicast_dns/multicast_dns.dart';

/// 局域网内发现的物联设备（ESP32 / ESP8266）
class DiscoveredDevice {
  /// 设备唯一 ID（来自 TXT 记录 id，缺失时用 mDNS 实例名）
  final String id;

  /// 设备类型：AED / 急救箱 / 轮椅 ...（来自 TXT 记录 type）
  final String type;

  /// 设备型号名称（mDNS 实例名，如 emarge-aed-0001）
  final String name;

  /// 厂商标识（来自 TXT 记录 vendor）
  final String vendor;

  /// 固件版本（来自 TXT 记录 version）
  final String version;

  /// 局域网 IP 地址
  final String ip;

  /// 设备提供 HTTP API 的端口
  final int port;

  const DiscoveredDevice({
    required this.id,
    required this.type,
    required this.name,
    required this.vendor,
    required this.version,
    required this.ip,
    required this.port,
  });

  /// 设备 HTTP 接口基址
  String get apiBase => 'http://$ip:$port';

  @override
  bool operator ==(Object other) =>
      other is DiscoveredDevice && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// 基于 mDNS 的物联设备发现服务
///
/// 设备端约定（ESP32/ESP8266 固件实现）：
/// - 注册 mDNS 服务：`_emarge-device._tcp.local`
/// - TXT 记录建议携带：id、type、vendor、version
/// - SRV 端口指向设备本地 HTTP API（如 80）
///
/// 例如 Arduino ESPmDNS：
/// ```cpp
/// MDNS.addService("emarge-device", "tcp", 80);
/// MDNS.addServiceTxt("emarge-device", "tcp",
///   "id", "AED-0001", "type", "AED", "vendor", "espressif", "version", "1.0.0");
/// ```
class MdnsDeviceDiscovery {
  MdnsDeviceDiscovery._();

  /// mDNS 服务类型
  static const String serviceType = '_emarge-device._tcp.local';

  /// 解析单条服务记录的最长等待时间
  static const Duration _resolveTimeout = Duration(milliseconds: 2000);

  /// 在局域网内搜索设备。
  ///
  /// [timeout] 为整个搜索过程的持续时间；期间每发现一台设备
  /// 就通过 [onDeviceFound] 回调一次（自动按设备 ID 去重）。
  /// 返回搜索结束时发现的全部设备。
  static Future<List<DiscoveredDevice>> discover({
    Duration timeout = const Duration(seconds: 8),
    void Function(DiscoveredDevice device)? onDeviceFound,
  }) async {
    final client = MDnsClient();
    await client.start();

    final found = <String, DiscoveredDevice>{};
    final resolving = <String>{};

    Future<void> resolve(String domainName) async {
      if (!resolving.add(domainName)) return;

      String? target;
      int port = 80;
      final txt = <String, String>{};

      // SRV：拿到主机名与端口
      try {
        final srv = await client
            .lookup<SrvResourceRecord>(
                ResourceRecordQuery.service(domainName))
            .timeout(_resolveTimeout)
            .first;
        target = srv.target;
        port = srv.port;
      } catch (_) {/* 超时或无记录，继续尝试其他记录 */}

      // TXT：设备元信息。多个条目在 multicast_dns 0.3.x 中以换行符连接。
      try {
        final record = await client
            .lookup<TxtResourceRecord>(
                ResourceRecordQuery.text(domainName))
            .timeout(_resolveTimeout)
            .first;
        for (final entry in record.text.split('\n')) {
          final line = entry.trim();
          final sep = line.indexOf('=');
          if (sep > 0) {
            txt[line.substring(0, sep).trim().toLowerCase()] =
                line.substring(sep + 1).trim();
          }
        }
      } catch (_) {/* 无 TXT 记录时使用默认值 */}

      // A：主机 IPv4 地址
      String ip = '';
      if (target != null) {
        try {
          final record = await client
              .lookup<IPAddressResourceRecord>(
                  ResourceRecordQuery.addressIPv4(target))
              .timeout(_resolveTimeout)
              .first;
          ip = record.address.address;
        } catch (_) {/* 部分设备可直接从实例名解析，忽略失败 */}
      }

      // 实例名去掉 .local 后缀，作为展示名称
      final name = domainName.replaceAll(RegExp(r'\.?_emarge-device\._tcp\.local$'), '').replaceAll(RegExp(r'\.$'), '');
      final id = txt['id']?.isNotEmpty == true ? txt['id']! : name;

      final device = DiscoveredDevice(
        id: id,
        type: txt['type'] ?? '未知设备',
        name: name.isEmpty ? id : name,
        vendor: txt['vendor'] ?? '未知厂商',
        version: txt['version'] ?? '',
        ip: ip,
        port: port,
      );

      if (!found.containsKey(device.id)) {
        found[device.id] = device;
        onDeviceFound?.call(device);
      }
    }

    // PTR：监听服务实例广播
    StreamSubscription<PtrResourceRecord>? sub;
    sub = client
        .lookup<PtrResourceRecord>(
            ResourceRecordQuery.serverPointer(serviceType))
        .listen(
      (PtrResourceRecord ptr) {
        // 不 await：让多台设备可以并行解析，统一由总超时收尾
        unawaited(resolve(ptr.domainName));
      },
      onError: (_) {},
    );

    await Future<void>.delayed(timeout);

    await sub.cancel();
    client.stop();
    return found.values.toList();
  }
}
