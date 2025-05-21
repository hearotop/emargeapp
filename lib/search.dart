import 'package:flutter/material.dart';
import './utils/device_utils.dart';

class CustomSearchDelegate extends SearchDelegate<String> {
  // 定义主题蓝色
  static const Color themeBlue = Color(0xFF2196F3);

  // 搜索历史记录
  final List<String> searchHistory = [
    'AED',
    '急救箱',
    '氧气瓶及面罩',
    '轮椅',
    '担架',
    '紧急呼叫系统',
    '灭火器',
  ];

  // 热门搜索
  final List<String> popularSearches = [
    'AED',
    '急救箱',
    '轮椅',
  ];

  // 设备分类
  final Map<String, List<String>> deviceCategories = {
    '急救设备': ['AED', '急救箱', '氧气瓶及面罩'],
    '转运设备': ['轮椅', '担架'],
    '安全设备': ['灭火器', '紧急呼叫系统'],
  };

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // 显示搜索结果
    final results = searchHistory
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              '未找到相关设备',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              '请尝试其他关键词',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
              icon: Icon(Icons.refresh),
              label: Text('重新搜索'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              close(context, result);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: themeBlue.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        DeviceUtils.getDeviceImage(result),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _getDeviceCategory(result),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // 显示搜索建议
    final suggestions = query.isEmpty
        ? searchHistory
        : searchHistory
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (query.isEmpty) ...[
            _buildSearchHeader(),
            _buildPopularSearches(),
            _buildDeviceCategories(),
            _buildSearchHistory(),
          ],
          if (query.isNotEmpty) _buildSearchResults(suggestions),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '热门搜索',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildPopularSearches() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: popularSearches.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(popularSearches[index]),
              onSelected: (bool selected) {
                query = popularSearches[index];
                showResults(context);
              },
              backgroundColor: themeBlue.withOpacity(0.1),
              selectedColor: themeBlue.withOpacity(0.2),
              labelStyle: TextStyle(
                color: themeBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeviceCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '设备分类',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: deviceCategories.length,
          itemBuilder: (context, index) {
            final category = deviceCategories.keys.elementAt(index);
            final devices = deviceCategories[category]!;
            return ExpansionTile(
              title: Text(
                category,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              leading: Icon(
                _getCategoryIcon(category),
                color: themeBlue,
              ),
              children: devices.map((device) {
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: themeBlue.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        DeviceUtils.getDeviceImage(device),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(device),
                  onTap: () {
                    query = device;
                    showResults(context);
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '搜索历史',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: 实现清除历史记录功能
                },
                icon: Icon(Icons.delete_outline, size: 16),
                label: Text('清除'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: searchHistory.length,
          itemBuilder: (context, index) {
            final history = searchHistory[index];
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: themeBlue.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                 // child: Image.asset(
                   // DeviceUtils.getDeviceImage(history),
                 //   fit: BoxFit.cover,
                //  ),
                ),
              ),
              title: Text(history),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
              onTap: () {
                query = history;
                showResults(context);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults(List<String> suggestions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: themeBlue.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                DeviceUtils.getDeviceImage(suggestion),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(suggestion),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
          onTap: () {
            query = suggestion;
            showResults(context);
          },
        );
      },
    );
  }

  String _getDeviceCategory(String device) {
    for (var entry in deviceCategories.entries) {
      if (entry.value.contains(device)) {
        return entry.key;
      }
    }
    return '其他设备';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '急救设备':
        return Icons.medical_services;
      case '转运设备':
        return Icons.directions_walk;
      case '安全设备':
        return Icons.security;
      default:
        return Icons.category;
    }
  }
}
