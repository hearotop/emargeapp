import 'package:flutter/material.dart';
import 'package:regexed_validator/regexed_validator.dart';

class ChangeEmailPage extends StatefulWidget {
  @override
  _ChangeEmailPageState createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final TextEditingController _oldEmailController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('更改邮箱'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: _oldEmailController,
              decoration: InputDecoration(
                labelText: '旧邮箱',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _newEmailController,
              decoration: InputDecoration(
                labelText: '新邮箱',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _verificationCodeController,
                    decoration: InputDecoration(
                      labelText: '验证码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // 发送验证码的逻辑
                    _sendVerificationCode();
                  },
                  child: Text('发送验证码'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // 确认修改邮箱的逻辑
                _confirmEmailChange();
              },
              child: Text('确认修改'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendVerificationCode() {
    // 发送验证码的逻辑
    String oldEmail = _oldEmailController.text;
    String newEmail = _newEmailController.text;

    // 这里可以添加发送验证码的逻辑，例如调用API
    print('发送验证码到新邮箱: $newEmail');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('验证码已发送到新邮箱')),
    );
  }

  void _confirmEmailChange() {
    // 确认修改邮箱的逻辑
    String oldEmail = _oldEmailController.text;
    String newEmail = _newEmailController.text;
    String verificationCode = _verificationCodeController.text;

    // 验证逻辑
    if (oldEmail.isEmpty || newEmail.isEmpty || verificationCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请填写所有字段')),
      );
      return;
    }

    if (!validator.email(oldEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('旧邮箱格式不正确')),
      );
      return;
    }

    if (!validator.email(newEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('新邮箱格式不正确')),
      );
      return;
    }

    // 这里可以添加确认修改邮箱的逻辑，例如调用API
    print('旧邮箱: $oldEmail');
    print('新邮箱: $newEmail');
    print('验证码: $verificationCode');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('邮箱修改成功')),
    );
  }

  @override
  void dispose() {
    _oldEmailController.dispose();
    _newEmailController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }
}
