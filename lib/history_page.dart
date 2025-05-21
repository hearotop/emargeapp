import 'dart:ffi';

import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:namer_app/view/playercontent.dart';
import 'package:namer_app/class/video.dart';
import 'history_video.dart'; // 假设路径，需根据实际情况修改
import 'package:flutter/material.dart' show ThemeData, useMaterial3;

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _historyList = [];
  bool _isSelecting = false;
  Set<int> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await DatabaseHelper().getPlayHistory();
    setState(() {
      _historyList = history;
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedItems.length == _historyList.length) {
        _selectedItems.clear();
      } else {
        _selectedItems = Set<int>.from(_historyList.asMap().keys);
      }
    });
  }

  Future<void> _deleteSelected() async {
    final dbHelper = DatabaseHelper();
    for (int index in _selectedItems) {
      final item = _historyList[index];
// 假设 DatabaseHelper 存在一个正确的删除方法名为 deleteHistory，这里进行替换
// 假设 DatabaseHelper 存在一个正确的删除方法名为 deletePlayHistory，这里进行替换
      await dbHelper.deletePlayHistory(item['videoId']);
    }
    // 重新加载历史记录
    await _loadHistory();
    setState(() {
      _historyList.removeWhere((item) {
        int index = _historyList.indexOf(item);
        return _selectedItems.contains(index);
      });
      _selectedItems.clear();
      _isSelecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(useMaterial3: true),
      child: Scaffold(
        appBar: AppBar(
          elevation: 4,
          surfaceTintColor: Theme.of(context).colorScheme.surface,
          title: Text(_isSelecting ? '选择记录' : '历史记录'),
          actions: _isSelecting
              ? [
                  IconButton(
                    icon: Icon(
                      _selectedItems.length == _historyList.length
                          ? Icons.deselect
                          : Icons.select_all,
                      color: Color(0xFFFF6699),
                    ),
                    onPressed: _toggleSelectAll,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Color(0xFFFF6699)),
                    onPressed: _deleteSelected,
                  ),
                ]
              : [],
        ),
        body: _historyList.isEmpty
            ? Center(
                child: Text("空空如也 ξ( ✿＞◡❛)"),
              )
            : ListView.builder(
                itemCount: _historyList.length,
                itemBuilder: (context, index) {
                  final item = _historyList[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: GestureDetector(
                      onLongPress: () {
                        setState(() {
                          _isSelecting = true;
                          _selectedItems.add(index);
                        });
                      },
                      onTap: () {
                        if (_isSelecting) {
                          setState(() {
                            if (_selectedItems.contains(index)) {
                              _selectedItems.remove(index);
                              if (_selectedItems.isEmpty) {
                                _isSelecting = false;
                              }
                            } else {
                              _selectedItems.add(index);
                            }
                          });
                        } else {
                          final video = Video(
                            id: int.tryParse(item['videoId']) ?? 0,
                            title: item['title'] ?? '',
                            description: item['description'] ?? '',
                            bimg: item['bimg'] ?? '',
                            duration: '0',
                            imageUrl: item['coverUrl'] ?? '',
                            videoPath: item['videoUrl'] ?? '',
                            timeStamp: item['timestamp'] ?? '',
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContentPage(video: video),
                            ),
                          );
                        }
                      },
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isSelecting)
                              Checkbox(
                                value: _selectedItems.contains(index),
                                activeColor: Color(0xFFFF6699),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value != null && value) {
                                      _selectedItems.add(index);
                                    } else {
                                      _selectedItems.remove(index);
                                      if (_selectedItems.isEmpty) {
                                        _isSelecting = false;
                                      }
                                    }
                                  });
                                },
                              ),
                            Image.asset(
                              item['coverUrl'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                        title: Text(item['title'] ?? ''),
                        subtitle: Text('已播放时长: ${item['duration'] ?? '未知'}'),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
