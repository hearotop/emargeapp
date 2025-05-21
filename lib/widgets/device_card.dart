import 'package:flutter/material.dart';
import '../device_detail.dart';

class DeviceCard extends StatelessWidget {
  final Map<String, dynamic> device;
  final Function(Map<String, dynamic>) onAddPressed;
  final VoidCallback onLongPress;
  final Color themeBlue;
  final Function(String) getDeviceImage;
  final Icon Function(bool) getStatusIcon;
  final Color Function(bool) getStatusColor;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onAddPressed,
    required this.onLongPress,
    required this.themeBlue,
    required this.getDeviceImage,
    required this.getStatusIcon,
    required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeviceDetailPage(device: device),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: themeBlue.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          getDeviceImage(device['name']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: getStatusColor(device['status']),
                      ),
                      child: IconButton(
                        icon: getStatusIcon(device['status']),
                        onPressed: () => onAddPressed(device),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  device['name'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeBlue,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        device['location'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
