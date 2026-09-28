import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namer_app/mydata.dart';
import 'package:namer_app/setting/account/securtiy.dart';

class SettingsPage extends StatelessWidget {
  // 定义主题蓝色
  static const Color themeBlue = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1.0,
        backgroundColor: themeBlue,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: ListView(
        children: <Widget>[
          _buildSectionHeader('账号设置'),
          _buildSettingTile(
            context,
            icon: Icons.person_outline,
            title: '个人资料',
            subtitle: '修改头像、昵称等基本信息',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyInfoPage()),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.security_outlined,
            title: '账号安全',
            subtitle: '密码、手机号、邮箱等安全设置',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecurityPage()),
            ),
          ),
          _buildSectionHeader('通用设置'),
          _buildSectionHeader('关于'),
          _buildSettingTile(
            context,
            icon: Icons.info_outline,
            title: '关于我们',
            subtitle: '版本 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '应急设备定位',
                applicationVersion: '1.0.0',
                applicationIcon: Image.asset(
                  'assets/logo.png',
                  width: 50,
                ),
                children: [
                  Text('一个帮助您快速定位应急设备的应用'),
                  SizedBox(height: 16),
                  Text('© 2024 应急设备定位'),
                ],
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.help_outline,
            title: '帮助与反馈',
            subtitle: '常见问题、意见反馈',
            onTap: () {},
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FilledButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          color: themeBlue,
                        ),
                        SizedBox(width: 8),
                        Text('退出登录'),
                      ],
                    ),
                    content: Text('确定要退出登录吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('取消'),
                      ),
                      FilledButton(
                        onPressed: () {
                          // 执行退出登录操作
                          Navigator.pop(context);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: themeBlue,
                        ),
                        child: Text('确定'),
                      ),
                    ],
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: themeBlue,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(Icons.logout),
              label: Text(
                '退出登录',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
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

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
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
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: themeBlue,
          ),
      onTap: onTap,
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '选择语言',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeBlue,
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.language, color: themeBlue),
            title: Text('简体中文'),
            subtitle: Text('系统默认'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.language, color: themeBlue),
            title: Text('English'),
            subtitle: Text('English'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
