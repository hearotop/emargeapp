import 'package:flutter/material.dart';

class StatsMenu extends StatelessWidget {
  final List<Map<String, dynamic>> contacts;
  final Color themeBlue;

  const StatsMenu({
    super.key,
    required this.contacts,
    required this.themeBlue,
  });

  Widget _buildStatItem(String label, int count, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey[600],
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: themeBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: themeBlue,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 计算各区域的设备数量
    int wandaCount =
        contacts.where((c) => c['location'].startsWith('中国万达')).length;
    int collegeCount =
        contacts.where((c) => c['location'].startsWith('中国学院')).length;
    int beiCount =
        contacts.where((c) => c['location'].startsWith('中国北京')).length;
    int totalCount = contacts.length;


    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: themeBlue),
      onSelected: (String value) {
        if (value == 'location_management') {
          // TODO: 实现地点管理功能
          print('打开地点管理');
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            enabled: false,
            child: Container(
              width: 200,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 8),
                      Text(
                        '设备统计',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildStatItem(
                    '所有设备',
                    totalCount,
                    Icons.devices,
                  ),
                  SizedBox(height: 8),
                  _buildStatItem(
                    '中国万达',
                    wandaCount,
                    Icons.location_city,
                  ),
                  SizedBox(height: 8),
                  _buildStatItem(
                    '中国学院',
                    collegeCount,
                    Icons.school,
                  ),
                  SizedBox(height: 8),
                  _buildStatItem(
                    '中国北京',
                    beiCount,
                    Icons.location_city,
                  ),
                ],
              ),
            ),
          ),
          PopupMenuDivider(height: 1),
          PopupMenuItem(
            value: 'location_management',
            child: Container(
              width: 200,
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_city,
                      size: 20,
                      color: themeBlue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '地点管理',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
      },
    );
  }
}
