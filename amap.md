# 高德地图集成说明

## 一、为什么高德地图在模拟器无法加载，实体机可以

### 根本原因：Native 库仅支持 ARM 架构

高德地图 Android SDK（`amap_map2` / 高德官方 SDK）的 native 动态库（`.so` 文件）**只提供 ARM 架构**（`armeabi-v7a`、`arm64-v8a`），**不再提供 x86 / x86_64 架构**的 `.so` 文件。

### 错误现象

在 x86_64 模拟器上运行时，Logcat 会输出：

```
E/ample.emergeapp: No implementation found for void com.autonavi.base.ae.gmap.GLMapEngine.nativeMainThreadTrigger(...)
W/System.err: java.lang.UnsatisfiedLinkError: No implementation found for void com.autonavi.base.ae.gmap.GLMapEngine.nativeMainThreadTrigger(...)
```

同时地图区域黑屏，但高德 logo 和距离标尺可能仍显示（这是 SDK 鉴权前的最低 UI，不依赖 native 渲染）。

### 原因分析

| 运行环境 | CPU 架构 | 高德 .so 是否存在 | 地图能否加载 |
|----------|----------|-------------------|--------------|
| 真机（绝大多数 Android 手机） | arm64-v8a / armeabi-v7a | ✅ 存在 | ✅ 正常 |
| x86_64 模拟器（Intel/AMD PC） | x86_64 | ❌ 不存在 | ❌ 黑屏 + UnsatisfiedLinkError |
| arm64 模拟器（Apple Silicon Mac） | arm64-v8a | ✅ 存在 | ✅ 正常（但性能取决于主机） |

模拟器运行时，系统会根据当前设备的 ABI 在 APK 的 `lib/<abi>/` 目录下查找对应的 `.so` 文件。由于高德只打包了 ARM 架构的 `.so`，x86_64 模拟器找不到 `libamap.so`，native 方法注册失败，地图渲染引擎无法启动。

### 解决方案

#### 方案 1：使用真机调试（推荐）

几乎所有 Android 真机都是 ARM 架构，能正确加载高德 native 库，地图渲染正常。这是国内高德开发者的标准做法，速度最快、效果最准。

#### 方案 2：使用 arm64-v8a 架构的模拟器

在 Apple Silicon（M1/M2/M3）Mac 上，可创建 ARM 架构的模拟器，原生加速运行；在 x86 PC 上也能创建 ARM 模拟器，但无硬件加速，运行非常缓慢。

```bash
# 安装 ARM 系统镜像
sdkmanager "system-images;android-30;google_apis;arm64-v8a"

# 创建 ARM 模拟器
avdmanager create avd -n arm_api30 -k "system-images;android-30;google_apis;arm64-v8a"

# 启动
emulator -avd arm_api30
```

#### 方案 3：构建时限制 ABI（已在本项目配置）

在 `android/app/build.gradle.kts` 中配置 `abiFilters`，只打包 ARM 架构，避免 APK 体积膨胀，并确保只在支持的设备上安装：

```kotlin
defaultConfig {
    ndk {
        abiFilters += listOf("arm64-v8a", "armeabi-v7a")
    }
}
```

> 注意：此配置会导致 x86_64 模拟器无法安装该 APK（INSTALL_FAILED_NO_MATCHING_ABIS），属正常现象。

### 小结

- 高德 SDK 不支持 x86/x86_64 是**官方硬性限制**，无法通过代码绕过
- 开发调试请优先使用**真机**
- 若必须用模拟器，请使用 **arm64-v8a 架构**的模拟器

---

## 二、高德 Key 配置说明

详见 [README.md](../README.md#-amap-api-key-configuration) 中的「AMap API Key Configuration」章节。

### 双 Key 策略

| 用途 | Key 类型 | 配置位置 |
|------|----------|----------|
| Android native SDK（地图/定位） | Android 平台 Key | `lib/config/amap_keys.dart` + `android/local.properties` |
| Web 服务 API（逆向地理编码） | Web 服务 Key | `lib/config/amap_keys.dart` |

### SCODE 鉴权问题

高德 2024 年引入安全码（SCODE）强制校验，`amap_map2` 的 native 代码不支持 SCODE 注入，会导致 `INVALID_USER_SCODE` (infocode 10008) 错误。

**影响**：
- 地图底图可能黑屏
- `AMapLocationClient` 定位失败

**不影响的**：
- `AMapWidget` 的 `onLocationChanged` 第一次回调仍能返回真实 GPS 位置
- Web 服务 API（逆向地理编码）走 HTTPS + Web Key，不受 SCODE 影响

**本项目的应对**：
- 逆向地理编码 → 走 Web API，绕过 native SDK
- 定位 → 借用 `AMapWidget` 的 `onLocationChanged` 回调

## 三、Android Studio 中解决模拟器黑屏

### 方案 1：使用真机调试（推荐）

1. 手机开启「开发者选项」→「USB 调试」
2. USB 连接电脑，手机弹窗点「允许 USB 调试」
3. Android Studio 顶部设备下拉框选择真机
4. 点击 Run ▶ 运行

> 真机都是 ARM 架构，高德地图正常渲染，这是最流畅的调试方式。

### 方案 2：创建 arm64-v8a 架构模拟器

> ⚠️ 在 x86 PC（Intel/AMD）上运行 arm64 模拟器**非常慢**（无硬件加速），仅用于验证功能。Apple Silicon Mac 可原生加速。

1. Android Studio → 顶部菜单 **Tools → Device Manager**
2. 点击 **+ Create Virtual Device**
3. 选择设备模板（如 Pixel 6）→ **Next**
4. **关键**：切换到 **Other Images** 标签页
5. 筛选 ABI = **arm64-v8a** 的系统镜像，点击 **Download** 下载
6. 下载完成后选中 → **Next** → **Finish**
7. 启动该 arm64 模拟器，地图可正常显示

### 方案 3：无线调试真机（免 USB 线）

手机与电脑在同一 WiFi 下：

```bash
# 1. USB 连接一次，启用无线调试端口
adb tcpip 5555

# 2. 拔掉 USB，通过 WiFi 连接（替换为手机实际 IP）
adb connect 192.168.1.100:5555

# 3. 确认设备已连接
adb devices
```

之后 Android Studio 设备列表中会出现该无线设备，直接运行即可。
