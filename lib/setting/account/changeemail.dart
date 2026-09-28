import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('更改邮箱'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _oldEmailController,
                      decoration: InputDecoration(
                        labelText: '旧邮箱',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon:
                            Icon(Icons.email_outlined, color: Colors.blue),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _newEmailController,
                      decoration: InputDecoration(
                        labelText: '新邮箱',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.blue),
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon:
                                  Icon(Icons.security, color: Colors.blue),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        ElevatedButton(
                          onPressed: _sendVerificationCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            '发送验证码',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _confirmEmailChange,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                '确认修改',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendVerificationCode() {
    String oldEmail = _oldEmailController.text;
    String newEmail = _newEmailController.text;

    if (newEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请输入新邮箱地址'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!validator.email(newEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('新邮箱格式不正确'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 这里可以添加发送验证码的逻辑，例如调用API
    print('发送验证码到新邮箱: $newEmail');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('验证码已发送到新邮箱'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _confirmEmailChange() {
    String oldEmail = _oldEmailController.text;
    String newEmail = _newEmailController.text;
    String verificationCode = _verificationCodeController.text;

    if (oldEmail.isEmpty || newEmail.isEmpty || verificationCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请填写所有必填项'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!validator.email(oldEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('旧邮箱格式不正确'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!validator.email(newEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('新邮箱格式不正确'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 这里可以添加确认修改邮箱的逻辑，例如调用API
    print('旧邮箱: $oldEmail');
    print('新邮箱: $newEmail');
    print('验证码: $verificationCode');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('邮箱修改成功'),
        backgroundColor: Colors.green,
      ),
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
