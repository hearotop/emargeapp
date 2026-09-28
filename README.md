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

## 📂 Project Documentation

Detailed docs are in the `describe/` directory:

- [UI Design](describe/ui-design.md) — page layouts and design constraints
- [Tech Notes](describe/tech-notes.md) — tech stack, AMap integration, troubleshooting
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
