/// 高德地图 API Key 配置模板。
///
/// 本文件为模板，不含真实 Key。
/// 使用方法：复制本文件为 amap_keys.dart，并填入你在高德开放平台申请的 Key。
///
/// 注意：amap_keys.dart 已加入 .gitignore，不会上传到 GitHub。
class AmapKeys {
  AmapKeys._();

  /// Android 平台 Key（用于 AMapInitializer.init）
  /// 在高德控制台创建「Android」平台 Key 获取
  static const String androidKey = 'YOUR_AMAP_ANDROID_KEY';

  /// Web 服务 Key（用于逆向地理编码等 Web API）
  /// 在高德控制台创建「Web 服务」平台 Key 获取
  static const String webKey = 'YOUR_AMAP_WEB_KEY';
}
