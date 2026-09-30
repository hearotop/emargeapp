# 🚑 物联急救设备共享平台

简体中文 | [English](README.md)

我是一名在校大学生，热爱开发，同时作一下公益项目，希望获得更多的支持！

<p>让每一台物联急救设备都能被需要的人快速找到，为生命争取黄金时间！</p>

## 📱 项目简介

本应用致力于通过物联网（IoT）技术，连接身边的各类急救设备与可穿戴健康设备。用户打开应用即可在首页以**卡片形式**查看附近的急救设备及其实时状态，在紧急情况下快速取用设备，用于自救或救助他人。

接入的设备类型包括：

- 🏥 自动体外除颤器（AED）
- 🎒 物联急救箱（支持多厂商设备接入）
- ⌚ 可穿戴设备（智能手表、智能手环等）
- 🩺 其他物联急救设备（担架、轮椅、紧急呼叫系统等）

## ✨ 主要功能

- 🗂️ **附近设备卡片**：首页以卡片流展示附近的急救设备，含设备头像、实时距离（Haversine 计算）、自动解析地址（逆向地理编码）
- 🟢🟡🔴 **状态指示**：绿色=可使用，黄色=维护中，红色=被占用
- 🔄 **自动刷新**：每 30 秒自动刷新附近设备，支持下拉手动刷新
- 🗺️ **实时地图定位**：基于高德地图查看设备分布，一键导航快速到达设备位置
- 📍 **逆向地理编码**：设备地址通过高德 Web API 自动解析，用户也可手动编辑
- 🔗 **物联设备接入**：通过 mDNS 发现同局域网的 ESP32/ESP8266 设备
- 📡 **多种添加方式**：自动发现、扫码、NFC、手动添加、第三方平台
- 🤝 **设备共享**：用户可共享自己的急救设备，让周边的人在紧急时刻多一份保障
- 📖 **急救知识指南**：内置急救科普内容，帮助用户临危不乱、正确施救
- 📞 **紧急联系人快速拨号**
- 🔒 **隐私合规**：首次启动弹窗，用户同意后才初始化高德 SDK

## 🔌 物联设备接入

- **mDNS 发现**：IOT设备在同一 WiFi 下通过 `_emarge-device._tcp.local` 自动发现
- **物联急救箱**：接入后可上报箱内物资清单、开箱记录、补给与维保状态
- **可穿戴设备**：接入智能手表、智能手环，获取心率等健康数据，异常时辅助发起求助
- **第三方厂商**：提供统一的设备接入规范，不同品牌的急救箱均可接入

> 📐 数据库设计可参考仓库中的《共享应急设备App数据库设计.docx》。

## 💡 技术特点

- 🎯 高德地图集成，Web API 逆向地理编码绕过 SCODE 鉴权限制
- ⚡ mDNS 设备发现，Android 端通过原生 MethodChannel 申请 MulticastLock
- 📱 Flutter 跨平台开发，Android / iOS 一套代码
- 🏗️ Haversine 公式实时计算设备与用户间的球面距离
- 👥 简洁友好的卡片式界面，支持自动刷新

### 🛠️ 技术栈

- [Flutter](https://flutter.dev/)（Dart 3）
- [高德地图 amap_map2 插件](https://lbs.amap.com/) + Web API
- [geolocator](https://pub.dev/packages/geolocator)（系统原生定位兜底）
- [multicast_dns](https://pub.dev/packages/multicast_dns)（mDNS 设备发现）
- [permission_handler](https://pub.dev/packages/permission_handler)（运行时权限）
- [shared_preferences](https://pub.dev/packages/shared_preferences)（隐私政策持久化）

## 📝 使用说明

1. 📱 打开应用
2. 📋 首次启动阅读并同意隐私政策
3. 🔒 允许位置权限
4. 🗂️ 在首页卡片中浏览附近的急救设备，查看实时距离和地址
5. 🗺️ 或在地图上查看设备分布
6. 👆 点击设备卡片查看详细信息
7. ➕ 通过自动发现、扫码、NFC 或手动方式添加自己的设备
8. 🚶 使用导航功能快速到达设备位置，开展自救或救助他人

## 🔑 高德地图 API Key 配置

本项目使用 [高德地图](https://lbs.amap.com/) 提供地图、定位与逆向地理编码服务。运行前需在 [高德开放平台](https://console.amap.com/) 申请 API Key。

> ⚠️ 出于安全考虑，API Key **不会** 存入仓库。克隆后需在本地自行配置。

### 1. 申请高德 Key

1. 进入 [高德控制台 → 应用管理 → 我的应用](https://console.amap.com/dev/key/app)
2. 创建应用（或使用已有应用）
3. 在应用下添加两个 Key：

| Key 类型     | 服务平台           | 用途                                |
| ------------ | ------------------ | ----------------------------------- |
| Android Key  | **Android**  | 原生地图与定位 SDK（`amap_map2`） |
| Web 服务 Key | **Web 服务** | 逆向地理编码 API                    |

> 创建 Android Key 时，需填写**包名**（`com.example.emergeapp`）和签名证书的 **SHA1**。
>
> 获取调试版 SHA1：
>
> ```bash
> keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
> ```

### 2. 配置 Dart 端 Key

复制模板文件并填入你的 Key：

```bash
cp lib/config/amap_keys.example.dart lib/config/amap_keys.dart
```

编辑 `lib/config/amap_keys.dart`：

```dart
class AmapKeys {
  AmapKeys._();
  static const String androidKey = '你的高德Android_Key';
  static const String webKey = '你的高德Web服务_Key';
}
```

> `lib/config/amap_keys.dart` 已加入 `.gitignore`，**不会** 上传到 GitHub。

### 3. 配置 Android 原生 Key

高德原生 SDK 通过 Gradle manifestPlaceholders 从 `AndroidManifest.xml` 读取 Key。

复制模板并填入 SDK 路径和 Android Key：

```bash
cp android/local.properties.example android/local.properties
```

编辑 `android/local.properties`：

```properties
flutter.sdk=/path/to/flutter
sdk.dir=/path/to/Android/Sdk
amap.api.key=你的高德Android_Key
```

> `android/local.properties` 已在 `.gitignore` 中。

### 4. 运行应用

```bash
flutter pub get
flutter run
```

## 🩹 常见问题

### 高德地图在模拟器黑屏，实体机正常

**根本原因**：高德地图 Android SDK 只提供 **ARM** 架构（`armeabi-v7a`、`arm64-v8a`）的 native 动态库（`.so` 文件），**不提供 x86 / x86_64 架构**。在 Intel/AMD PC 上运行的大多数 Android 模拟器使用 x86_64 架构，因此 SDK 的 native 方法无法加载：

```
java.lang.UnsatisfiedLinkError: No implementation found for void com.autonavi.base.ae.gmap.GLMapEngine.nativeMainThreadTrigger(...)
```

| 运行环境 | ABI 架构 | 高德 .so 是否存在 | 地图能否加载 |
|----------|----------|-------------------|--------------|
| Android 真机 | arm64-v8a / armeabi-v7a | ✅ 存在 | ✅ 正常 |
| x86_64 模拟器（Intel/AMD PC） | x86_64 | ❌ 不存在 | ❌ 黑屏 |
| arm64 模拟器（Apple Silicon Mac） | arm64-v8a | ✅ 存在 | ✅ 正常 |

**解决方案**：

1. **使用真机调试**（推荐）—— 几乎所有 Android 真机都是 ARM 架构。
2. **使用 arm64-v8a 架构的模拟器**—— 在 Apple Silicon Mac 上可原生加速，x86 PC 上无硬件加速会很慢。
   - Android Studio 操作：**Tools → Device Manager → + Create Virtual Device → Next → Other Images 标签 → 下载 arm64-v8a 镜像 → Finish**。
3. **本项目已配置 ABI 过滤**，位于 `android/app/build.gradle.kts`：
   ```kotlin
   ndk { abiFilters += listOf("arm64-v8a", "armeabi-v7a") }
   ```
   这可能导致 x86_64 模拟器安装时出现 `INSTALL_FAILED_NO_MATCHING_ABIS`，属正常现象。

> 💡 完整说明见 [describe/amap.md](describe/amap.md)。

## 📂 项目文档

详细文档位于 `describe/` 目录下：

- [界面设计文档](describe/ui-design.md) — 页面布局与设计约束
- [技术文档](describe/tech-notes.md) — 技术栈、高德集成、常见问题
- [高德集成说明](describe/amap.md) — 高德 SDK 架构与模拟器黑屏问题
- [开发日志](describe/dev-log-2026-09-28.md) — 开发进度记录

## 🤝 贡献指南

本项目由个人开发者维护，欢迎社会各界人士参与开发，也欢迎急救设备厂商对接接入，共同为拯救生命贡献一份力量！

## 🙏 致谢

作为个人开发者，特别感谢以下服务提供的免费支持：

- **[高德开放平台](https://lbs.amap.com/)**：提供免费的地图 API 支持
- **[Trae](https://www.trae.ai/)**：提供免费的 AI 编程额度，助力本项目开发

## 📞 联系方式

如有问题、建议或厂商合作意向，请通过以下方式联系我们：

- 📧 邮箱：[hearotop@outlook.com]

<p>感谢你的支持! 🙏</p>

---

<div align="center">
  <p>❤️ 珍爱生命，关怀你我 ❤️</p>
</div>

### 也可以通过微信或支付宝赞助：

<div style="display: flex; gap: 10px; margin-top: 20px;">
    <img src="https://gitee.com/hearotop/note/raw/master/assert/wx.jpg" alt="微信" style="width: 200px; height: 200px; border-radius: 10px;">
    <img src="https://gitee.com/hearotop/note/raw/master/assert/zfb.jpg" alt="支付宝" style="width: 200px; height: 200px; border-radius: 10px;">
</div>
