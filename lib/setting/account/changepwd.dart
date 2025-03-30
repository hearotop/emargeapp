import 'package:flutter/material.dart';
import 'package:regexed_validator/regexed_validator.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('更改密码'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: '原密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: '新密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: '验证密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '邮箱',
                border: OutlineInputBorder(),
              ),
              enabled: false, // 邮箱不可编辑
            ),
            SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _verificationCodeController,
                    decoration: InputDecoration(
                      labelText: '邮箱验证码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // 发送邮箱验证码的逻辑
                    _sendVerificationCode();
                  },
                  child: Text('发送验证码'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // 确认更改密码的逻辑
                _confirmPasswordChange();
              },
              child: Text('确认更改'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendVerificationCode() {
    // 发送邮箱验证码的逻辑
    String email = _emailController.text;
    // 这里可以添加发送验证码的逻辑，例如调用API
    print('发送验证码到: $email');
  }

  void _confirmPasswordChange() {
    // 确认更改密码的逻辑
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String verificationCode = _verificationCodeController.text;

    // 验证逻辑
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('新密码和验证密码不一致')),
      );
      return;
    }

    if (!validator.password(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('新密码必须包含数字、字母（大小写）和特殊符号')),
      );
      return;
    }

    // 这里可以添加更改密码的逻辑，例如调用API
    print('原密码: $currentPassword');
    print('新密码: $newPassword');
    print('验证码: $verificationCode');
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }
}
