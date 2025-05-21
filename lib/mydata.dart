import 'package:flutter/material.dart';

class MyInfoPage extends StatelessWidget {
  // 定义主题蓝色
  static const Color themeBlue = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('个人资料'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1.0,
        backgroundColor: themeBlue,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        children: <Widget>[
          _buildProfileHeader(context),
          _buildSectionHeader('基本信息'),
          _buildInfoTile(
            context,
            icon: Icons.person_outline,
            title: '昵称',
            subtitle: '张三',
            onTap: () => _showEditDialog(context, '昵称', '张三'),
          ),
          _buildInfoTile(
            context,
            icon: Icons.transgender_outlined,
            title: '性别',
            subtitle: '男',
            onTap: () => _showGenderSelector(context),
          ),
          _buildInfoTile(
            context,
            icon: Icons.location_city_outlined,
            title: '地区',
            subtitle: '北京市',
            onTap: () => _showEditDialog(context, '地区', '北京市'),
          ),
          _buildSectionHeader('联系方式'),
          _buildInfoTile(
            context,
            icon: Icons.phone_outlined,
            title: '手机号',
            subtitle: '138****8000',
            onTap: () => _showEditDialog(context, '手机号', '13800138000'),
          ),
          _buildInfoTile(
            context,
            icon: Icons.email_outlined,
            title: '邮箱',
            subtitle: 'zhangsan@example.com',
            onTap: () => _showEditDialog(context, '邮箱', 'zhangsan@example.com'),
          ),
          _buildSectionHeader('其他信息'),
          _buildInfoTile(
            context,
            icon: Icons.calendar_today_outlined,
            title: '生日',
            subtitle: '1990-01-01',
            onTap: () => _showDatePicker(context),
          ),
          _buildInfoTile(
            context,
            icon: Icons.work_outline,
            title: '职业',
            subtitle: '工程师',
            onTap: () => _showEditDialog(context, '职业', '工程师'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    NetworkImage('https://th.bing.com/th/id/OIP.7GLMYPqMlt2LgkbPsOnDIAAAAA?rs=1&pid=ImgDetMain'),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: themeBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            '张三',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeBlue,
            ),
          ),
          Text(
            'ID: 888888',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: themeBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: themeBlue,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: themeBlue,
      ),
      onTap: onTap,
    );
  }

  void _showEditDialog(
      BuildContext context, String title, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: themeBlue),
            SizedBox(width: 8),
            Text('修改$title'),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '请输入$title',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: themeBlue),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: themeBlue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              // 处理保存逻辑
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: themeBlue,
            ),
            child: Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showGenderSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择性别',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeBlue,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.male, color: themeBlue),
              title: Text('男'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.female, color: themeBlue),
              title: Text('女'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: themeBlue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // 处理日期选择结果
    }
  }
}
