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

- 🗂️ **Nearby device cards**: the home screen shows nearby first-aid devices as a card feed, with device type, location, and online/availability status at a glance
- 🗺️ **Real-time map & positioning**: view device distribution on AMap and navigate to a device with one tap
- 🔗 **IoT device integration**: connect IoT first-aid kits and wearables to obtain real-time device status and health data
- 🏭 **Open manufacturer access**: an open integration design for first-aid kits — manufacturers of all brands are welcome to connect their devices
- 🤝 **Device sharing**: users can share their own first-aid devices, giving people nearby one more lifeline in an emergency
- 📖 **First-aid knowledge & video guides**: built-in first-aid educational content and video tutorials to help people respond calmly and correctly
- 📞 **Quick dial for emergency contacts**
- 🔄 **Real-time device status updates**

## 🔌 IoT Device Integration Roadmap

- **IoT first-aid kits**: once connected, kits can report inventory lists, opening records, and replenishment/maintenance status
- **Wearable devices**: connect smart watches and bands to obtain health data such as heart rate, and help trigger a call for help when abnormalities are detected
- **Third-party manufacturers**: a unified device integration specification allows first-aid kits of different brands to connect, building a shared device network together

> 📐 For the database design, see *共享应急设备App数据库设计.docx* in this repository.

## 💡 Technical Highlights

- 🎯 High-precision positioning and navigation based on AMap
- ⚡ Real-time synchronization of IoT device data
- 📱 Cross-platform development with Flutter — one codebase for Android / iOS
- 👥 A clean, user-friendly card-based interface

### 🛠️ Tech Stack

- [Flutter](https://flutter.dev/)
- [AMap `amap_map` plugin](https://lbs.amap.com/)
- SQLite (local data storage)
- Provider (state management)

## 📝 How to Use

1. 📱 Open the app
2. 🔒 Grant location permission
3. 🗂️ Browse nearby first-aid devices and their status on the home screen cards
4. 🗺️ Or view device distribution on the map
5. 👆 Tap a device card to see detailed information
6. 🚶 Use navigation to reach the device quickly for self-rescue or to help others

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

### Sponsor this project 🫠

If you find this project helpful, please consider sponsoring me on GitHub Sponsors:

<p>
  <a href="https://github.com/sponsors/hearotop">
    <img src="https://img.shields.io/badge/Sponsor%20me%20on-GitHub%20Sponsors-ea4aaa?style=for-the-badge&logo=githubsponsors&logoColor=white" alt="Sponsor me on GitHub Sponsors">
  </a>
</p>

You can also support me via WeChat or Alipay:

<div style="display: flex; gap: 10px; margin-top: 20px;">
    <img src="https://gitee.com/hearotop/note/raw/master/assert/wx.jpg" alt="WeChat" style="width: 200px; height: 200px; border-radius: 10px;">
    <img src="https://gitee.com/hearotop/note/raw/master/assert/zfb.jpg" alt="Alipay" style="width: 200px; height: 200px; border-radius: 10px;">
</div>
