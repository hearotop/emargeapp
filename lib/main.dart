import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amap_map2/amap_map2.dart';
import 'package:x_amap_base/x_amap_base.dart';
import 'package:namer_app/adddevice.dart';
import 'package:namer_app/home.dart';
import 'package:namer_app/profile.dart';
import 'package:namer_app/view/chatbot.dart';
import 'package:namer_app/widgets/privacy_dialog.dart';

import 'search.dart'; // 导入自定义的搜索委托类

/// 高德地图 Android 平台 Key（在高德开放平台申请，已绑定本机 SHA1+包名）
const String _amapAndroidKey = 'c67248fc1ae1976bcd2e70d1e8983761';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 状态栏透明，图标深色（白底上可见）
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  runApp(const NavigationBarApp());
}

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const _AppEntry(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 应用入口：检查隐私政策同意状态
class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool? _agreed;

  @override
  void initState() {
    super.initState();
    _checkPrivacy();
  }

  Future<void> _checkPrivacy() async {
    final agreed = await PrivacyDialog.hasAgreed();
    if (!mounted) return;
    if (agreed) {
      _initAmap();
      setState(() => _agreed = true);
    } else {
      final result = await PrivacyDialog.show(context);
      if (mounted && result) {
        _initAmap();
        setState(() => _agreed = result);
      } else if (mounted) {
        setState(() => _agreed = false);
      }
    }
  }

  /// 初始化高德 SDK：传入 Android Key + 隐私合规声明
  /// 必须在用户同意隐私政策后调用，否则 SDK 不会工作（地图白屏）
  void _initAmap() {
    // Key 通过 AMapInitializer.init 传给 AMapWidget（amap_map 包不读 manifest 的 meta-data）
    AMapInitializer.init(
      context,
      apiKey: const AMapApiKey(androidKey: _amapAndroidKey),
    );
    AMapInitializer.updatePrivacyAgree(
      const AMapPrivacyStatement(
        hasContains: true,
        hasShow: true,
        hasAgree: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_agreed == null) {
      // 等待隐私政策检查
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_agreed == false) {
      // 用户不同意隐私政策
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                '您未同意隐私政策，应用无法使用',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                '急救设备定位与地图功能需要高德 SDK 支持',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  final result = await PrivacyDialog.show(context);
                  if (mounted && result) setState(() => _agreed = true);
                },
                child: const Text('重新查看隐私政策'),
              ),
            ],
          ),
        ),
      );
    }
    return const NavigationExample();
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 40,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: <Widget>[
          if (currentPageIndex == 0)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: CustomSearchDelegate());
              },
            ),
          if (currentPageIndex == 0)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: '扫一扫',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('扫一扫功能开发中，敬请期待')),
                );
              },
            ),
          if (currentPageIndex == 0)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddDevicePage()),
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 8,
        height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: Colors.blue),
            icon: Icon(Icons.home_outlined),
            label: '首页',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.chat, color: Colors.blue),
            icon: Icon(Icons.chat_outlined),
            label: '小管家',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person, color: Colors.blue),
            icon: Icon(Icons.person_outline),
            label: '我的',
          ),
        ],
      ),
      body: <Widget>[
        HomePage(),
        ChatbotPage(),
        ProfilePage(),
      ][currentPageIndex],
    );
  }
}
