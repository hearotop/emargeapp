import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 隐私政策弹窗
///
/// 首次启动时展示，用户同意后方可初始化高德 SDK。
/// 包含高德 SDK 合规所需的信息：提供方、SDK 名称、收集的个人信息、使用目的、隐私政策链接。
class PrivacyDialog {
  static const String _agreedKey = 'privacy_agreed';

  /// 检查用户是否已同意隐私政策
  static Future<bool> hasAgreed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_agreedKey) ?? false;
  }

  /// 标记用户已同意
  static Future<void> setAgreed(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_agreedKey, value);
  }

  /// 显示隐私政策弹窗，返回用户是否同意
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _PrivacyPolicyDialog(),
    );
    final agreed = result ?? false;
    if (agreed) {
      await setAgreed(true);
    }
    return agreed;
  }
}

class _PrivacyPolicyDialog extends StatelessWidget {
  const _PrivacyPolicyDialog();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.privacy_tip, color: Colors.blue[700], size: 28),
            const SizedBox(width: 8),
            const Text('隐私政策', style: TextStyle(fontSize: 20)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '欢迎使用物联急救设备共享平台。在使用本应用前，请阅读并同意以下隐私政策：',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                _section('一、应用概况', '本应用通过物联网技术连接身边的急救设备，帮助用户在紧急情况下快速定位和使用附近的急救设备。'),
                const SizedBox(height: 12),
                _section('二、第三方 SDK 说明', '本应用集成了以下第三方 SDK：'),
                const SizedBox(height: 8),
                _sdkItem(
                  '高德地图 SDK',
                  '高德软件有限公司',
                  '用于实现附近急救设备定位与地图展示、用户位置显示及导航功能。',
                  'https://lbs.amap.com/pages/privacy/',
                ),
                const SizedBox(height: 12),
                _section('三、高德 SDK 收集的个人信息', ''),
                const SizedBox(height: 4),
                _bullet('位置信息：经纬度、精确位置、粗略位置'),
                _bullet('设备标识信息：IMEI、AndroidID、OAID 等'),
                _bullet('当前应用信息：应用名、应用版本号'),
                _bullet('设备参数及系统信息：设备型号、操作系统等'),
                const SizedBox(height: 12),
                _section('四、信息使用目的', '上述信息仅用于急救设备定位、地图展示和导航功能，不会用于其他用途，也不会分享给第三方。'),
                const SizedBox(height: 12),
                _section('五、高德隐私政策', '详细了解高德 SDK 数据收集与处理方式，请访问：'),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    // TODO: 使用 url_launcher 打开链接
                  },
                  child: Text(
                    'https://lbs.amap.com/pages/privacy/',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[700],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '点击「同意」表示您已阅读并同意本隐私政策，应用将开始为您提供急救设备定位服务。',
                          style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('不同意', style: TextStyle(fontSize: 16)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.blue[700]),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('同意', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        if (content.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ],
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 13)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _sdkItem(String name, String provider, String purpose, String link) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text('提供方：$provider', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 2),
          Text('使用目的：$purpose', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
