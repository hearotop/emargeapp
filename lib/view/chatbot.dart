// 导入必要的库
import 'package:flutter/material.dart';

// 定义聊天消息类
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
// 定义聊天机器人界面

// 定义聊天界面状态类
class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();

  // 处理用户输入
  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('消息内容不能为空')),
      );
      return;
    }
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      // 模拟机器人回复
      _messages.add(ChatMessage(text: _getResponse(text), isUser: false));
    });
  }

  // 模拟机器人回复逻辑
  String _getResponse(String userInput) {
    // 应急知识回复示例
    if (userInput.contains('火灾') || userInput.contains('火警')) {
      return '发生火灾时，请保持冷静，立即拨打119报警，用湿毛巾捂住口鼻，弯腰低姿前行，找到安全出口逃生。';
    } else if (userInput.contains('灭火器')) {
      return '使用灭火器时，请记住P.A.S.S.原则：拔出保险销（Pull），对准火源根部（Aim），按压把手（Squeeze），左右扫射（Sweep）。';
    } else if (userInput.contains('地震')) {
      return '地震发生时，请立即寻找坚固的桌子或墙角躲避，保护头部，远离窗户和重物，震动停止后迅速撤离到空旷地带。';
    } else if (userInput.contains('急救')) {
      return '在急救情况下，请记住DRABC原则：检查危险（Danger），评估反应（Response），打开气道（Airway），检查呼吸（Breathing），进行心肺复苏（Circulation）。';
    } else {
      return '您好！我是应急知识助手。我可以为您提供火灾、地震、急救等方面的应急知识。请问您想了解哪方面的内容呢？';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _buildMessage(_messages[index]),
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  // 构建聊天消息显示
  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text('B',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer)),
              ),
              color: message.isUser ? Colors.lightBlueAccent : Colors.grey[200],
            ),
          Flexible(
            child: Card(
              color: message.isUser
                  ? Color(Colors.blue.value)
                  : Color(Colors.white.value),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(message.isUser ? 12 : 4),
                  topRight: Radius.circular(message.isUser ? 4 : 12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color:
                              message.isUser ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      message.text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              message.isUser ? Colors.white : Colors.grey[700],
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (message.isUser)
            Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text('U',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary)),
              ),
            ),
        ],
      ),
    );
  }

  // 构建输入框和发送按钮
  Widget _buildTextComposer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey[300]!)),
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.mic),
              onPressed: () {},
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _controller,
                  onSubmitted: _handleSubmitted,
                  decoration: InputDecoration(
                    hintText: '输入你的问题...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () {},
            ),
            Container(
              margin: EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(Icons.send, size: 28),
                onPressed: () => _handleSubmitted(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
