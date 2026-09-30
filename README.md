# 🚑 IoT First-Aid Device Sharing Platform

English | [简体中文](README.zh.md)

I'm a college student who loves building things, and I'm also running this as a public-interest project. Any support is greatly appreciated!

<p>Helping people in need quickly find every IoT-connected first-aid device nearby — winning the golden minutes to save lives!</p>

## 📱 About This Project

This app uses Internet of Things (IoT) technology to connect all kinds of first-aid devices and wearable health devices around us. As soon as users open the app, nearby first-aid devices and their real-time status are displayed as **cards on the home screen**, so devices can be reached quickly in an emergency — for self-rescue or to help others.

Supported device types include:

- 🏥 Automated External Defibrillators (AED)
- 🎒 IoT first-aid kits (open to devices from multiple manufacturers)
- ⌚ Wearable devices (smart watches, smart bands, etc.)
- 🩺 Other IoT first-aid equipment (stretchers, wheelchairs, emergency call systems, etc.)

## ✨ Key Features

- 🗂️ **Nearby device cards**: the home screen shows nearby first-aid devices as a card feed with device avatar, real-time distance (Haversine), and auto-resolved address (reverse geocoding)
- 🟢🟡🔴 **Status indicators**: green = available, yellow = maintenance, red = occupied
- 🔄 **Auto-refresh**: nearby devices refresh every 30 seconds, with pull-to-refresh support
- 🗺️ **Real-time map & positioning**: view device distribution on AMap and navigate to a device with one tap
- 📍 **Reverse geocoding**: device addresses auto-resolved via AMap Web API, users can also manually edit
- 🔗 **IoT device integration**: connect IoT first-aid kits and wearables via mDNS (ESP32/ESP8266)
- 📡 **Multiple add methods**: auto-discovery, QR scan, NFC, manual add, third-party platform
- 🤝 **Device sharing**: users can share their own first-aid devices
- 📖 **First-aid knowledge guides**: built-in first-aid educational content
- 📞 **Quick dial for emergency contacts**
- 🔒 **Privacy compliance**: AMap SDK privacy policy dialog on first launch

## 🔌 IoT Device Integration

- **mDNS discovery**: ESP32/ESP8266 devices on the same WiFi are auto-discovered via `_emarge-device._tcp.local`
- **IoT first-aid kits**: report inventory, opening records, and maintenance status
- **Wearable devices**: connect smart watches and bands for health data
- **Third-party manufacturers**: unified integration spec for all brands

> 📐 For the database design, see *共享应急设备App数据库设计.docx* in this repository.

## 💡 Technical Highlights

- 🎯 AMap integration with Web API fallback for reverse geocoding (bypassing SCODE authentication)
- ⚡ mDNS device discovery with Android MulticastLock via native MethodChannel
- 📱 Flutter cross-platform development — one codebase for Android / iOS
- 🏗️ Haversine distance calculation for real-time proximity
- 👥 Clean card-based interface with auto-refresh

### 🛠️ Tech Stack

- [Flutter](https://flutter.dev/) (Dart 3)
- [AMap `amap_map2` plugin](https://lbs.amap.com/) + Web API
- [geolocator](https://pub.dev/packages/geolocator) (native positioning fallback)
- [multicast_dns](https://pub.dev/packages/multicast_dns) (mDNS discovery)
- [permission_handler](https://pub.dev/packages/permission_handler)
- [shared_preferences](https://pub.dev/packages/shared_preferences)

## 📝 How to Use

1. 📱 Open the app
2. 📋 Review and accept the privacy policy (first launch)
3. 🔒 Grant location permission
4. 🗂️ Browse nearby first-aid devices with real-time distance and address
5. 🗺️ Or view device distribution on the map
6. 👆 Tap a device card to see detailed information
7. ➕ Add your own devices via auto-discovery, QR, NFC, or manual entry
8. 🚶 Use navigation to reach the device quickly

## 🔑 AMap API Key Configuration

This project uses [AMap (高德地图)](https://lbs.amap.com/) for maps, positioning, and reverse geocoding. You need to apply for API keys on the [AMap Open Platform](https://console.amap.com/) before running the app.

> ⚠️ API keys are **not** stored in the repository for security. You must configure them locally after cloning.

### 1. Apply for AMap Keys

1. Go to [AMap Console → Application Management → My Applications](https://console.amap.com/dev/key/app)
2. Create an application (or use an existing one)
3. Add two keys under the application:

| Key Type | Platform | Usage |
|----------|----------|-------|
| Android Key | **Android** | Native map & positioning SDK (`amap_map2`) |
| Web Service Key | **Web Service** | Reverse geocoding API |

> When creating the Android key, you must provide the **package name** (`com.example.emergeapp`) and **SHA1** of your signing certificate.
>
> Get the debug SHA1:
> ```bash
> keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
> ```

### 2. Configure Dart Keys

Copy the template file and fill in your keys:

```bash
cp lib/config/amap_keys.example.dart lib/config/amap_keys.dart
```

Edit `lib/config/amap_keys.dart`:

```dart
class AmapKeys {
  AmapKeys._();
  static const String androidKey = 'YOUR_AMAP_ANDROID_KEY';
  static const String webKey = 'YOUR_AMAP_WEB_KEY';
}
```

> `lib/config/amap_keys.dart` is listed in `.gitignore` and will **not** be uploaded to GitHub.

### 3. Configure Android Native Key

The AMap native SDK reads the key from `AndroidManifest.xml` via a Gradle manifest placeholder.

Copy the template and fill in your SDK paths and Android key:

```bash
cp android/local.properties.example android/local.properties
```

Edit `android/local.properties`:

```properties
flutter.sdk=/path/to/flutter
sdk.dir=/path/to/Android/Sdk
amap.api.key=YOUR_AMAP_ANDROID_KEY
```

> `android/local.properties` is already listed in `.gitignore`.

### 4. Run the App

```bash
flutter pub get
flutter run
```

## 🩹 Troubleshooting

### AMap shows a black screen on the emulator but works on a real device

**Root cause**: The AMap Android SDK only ships native libraries (`.so`) for **ARM** architectures (`armeabi-v7a`, `arm64-v8a`). It does **not** provide x86 / x86_64 binaries. Most Android emulators running on Intel/AMD PCs use the x86_64 ABI, so the SDK's native methods cannot be loaded:

```
java.lang.UnsatisfiedLinkError: No implementation found for void com.autonavi.base.ae.gmap.GLMapEngine.nativeMainThreadTrigger(...)
```

| Environment | ABI | AMap .so available? | Map loads? |
|-------------|-----|---------------------|------------|
| Real Android device | arm64-v8a / armeabi-v7a | ✅ Yes | ✅ Yes |
| x86_64 emulator (Intel/AMD PC) | x86_64 | ❌ No | ❌ Black screen |
| arm64 emulator (Apple Silicon Mac) | arm64-v8a | ✅ Yes | ✅ Yes |

**Solutions**:

1. **Use a real device for debugging** (recommended) — all modern Android phones are ARM-based.
2. **Use an arm64-v8a emulator** — works natively on Apple Silicon Macs (slow on x86 PCs without hardware acceleration).
   - In Android Studio: **Tools → Device Manager → + Create Virtual Device → Next → Other Images tab → download an `arm64-v8a` image → Finish**.
3. **ABI filtering is already configured** in `android/app/build.gradle.kts`:
   ```kotlin
   ndk { abiFilters += listOf("arm64-v8a", "armeabi-v7a") }
   ```
   This may cause `INSTALL_FAILED_NO_MATCHING_ABIS` on x86_64 emulators, which is expected.

> 💡 See [describe/amap.md](describe/amap.md) for the full explanation.

## 📂 Project Documentation

Detailed docs are in the `describe/` directory:

- [UI Design](describe/ui-design.md) — page layouts and design constraints
- [Tech Notes](describe/tech-notes.md) — tech stack, AMap integration, troubleshooting
- [AMap Integration](describe/amap.md) — AMap SDK architecture & emulator black screen issue
- [Dev Log](describe/dev-log-2026-09-28.md) — development progress

## 🤝 Contributing

This project is maintained by an individual developer. Everyone is welcome to contribute, and first-aid device manufacturers are especially welcome to integrate with the platform — let's work together to help save lives!

## 🙏 Acknowledgements

As an individual developer, I'm especially grateful for the free support from:

- **[AMap Open Platform](https://lbs.amap.com/)** — free map API support
- **[Trae](https://www.trae.ai/)** — free AI coding credits that power the development of this project

## 📞 Contact

For questions, suggestions, or manufacturer cooperation, please reach out at:

- 📧 Email: [hearotop@outlook.com]

<p>Thank you for your support! 🙏</p>

---

<div align="center">
  <p>❤️ Cherish life, care for one another ❤️</p>
</div>

You can also support me via WeChat or Alipay:

<div style="display: flex; gap: 10px; margin-top: 20px;">
    <img src="https://gitee.com/hearotop/note/raw/master/assert/wx.jpg" alt="WeChat" style="width: 200px; height: 200px; border-radius: 10px;">
    <img src="https://gitee.com/hearotop/note/raw/master/assert/zfb.jpg" alt="Alipay" style="width: 200px; height: 200px; border-radius: 10px;">
</div>
