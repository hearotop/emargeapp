import 'package:flutter/material.dart';

class DeviceUtils {
  static Icon getStatusIcon(bool isAdded) {
    if (isAdded) {
      return Icon(Icons.horizontal_rule, color: Colors.white);
    }
    return Icon(Icons.add, color: Colors.white);
  }

  static Color getStatusColor(bool isAdded) {
    if (isAdded) {
      return Colors.red;
    }
    return Colors.green;
  }

  static String getDeviceImage(String name) {
    switch (name) {
      case 'AED':
        return 'lib/image/device/AED.jpg';
      case '担架':
        return 'lib/image/device/danjia.jpg';
      case '急救箱':
        return 'lib/image/device/firstaid.png';
      case '灭火器':
        return 'lib/image/device/miehuoqi.png';
      case '轮椅':
        return 'lib/image/device/lunyi.jpg';
      case '紧急呼叫系统':
        return 'lib/image/device/sos.jpg';
      default:
        return '';
    }
  }
}
