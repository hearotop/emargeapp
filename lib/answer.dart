import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import 'result.dart';

class AnswerPage extends StatefulWidget {
  final String path;

  AnswerPage({required this.path});

  @override
  _AnswerPageState createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  late Future<List<Map<String, dynamic>>> _questionsFuture;
  List<int?> _selectedAnswers = [];
  List<bool> _showCorrectAnswers = [];
  int _currentQuestionIndex = 0; // 当前显示的题目索引
  int _correctCount = 0;
  int _errorCount = 0;
  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadData(widget.path); // 加载题目数据
  }

  // 从 JSON 文件中加载题目数据
  Future<List<Map<String, dynamic>>> _loadData(String path) async {
    try {
      String tpath = "lib/json/$path.json";
      String jsonString = await rootBundle.loadString(tpath);

      List<dynamic> data = json.decode(jsonString);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Error loading or parsing JSON: $e");
      return [];
    }
  }

  // 切换到下一题
  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _selectedAnswers.length - 1) {
        _currentQuestionIndex++;
      }
    });
  }

  // 显示提交对话框
  void _showSubmitDialog(int correct, int error, int length) {
    if (correct + error == length) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('提交答案'),
            actions: <Widget>[
              TextButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭对话框
                },
              ),
              TextButton(
                child: Text('提交'),
                onPressed: () {
                  // 在这里处理提交逻辑
                  Navigator.of(context).pop(); // 关闭对话框
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ResultPage(correct: correct, error: error)));
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('提示'),
              content: Text('还有题目没有完成，是否继续？'),
              actions: <Widget>[
                TextButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop(); // 关闭对话框
                  },
                ),
                TextButton(
                  child: Text('继续'),
                  onPressed: () {
                    // 在这里处理提交逻辑
                    Navigator.of(context).pop(); // 关闭对话框
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ResultPage(correct: correct, error: error)));
                    // 关闭对话框
                  },
                ),
              ]);
        },
      );
    }
  }

  // 判断“下一题”按钮的颜色
  Color _nextButtonColor(int index, int length) {
    if (index == length - 1) {
      return Colors.blue; // 提交按钮颜色为蓝色
    }
    return Colors.white;
  }

  // 切换到上一题
  void _previousQuestion() {
    setState(() {
      if (_currentQuestionIndex > 0) {
        _currentQuestionIndex--;
      }
    });
  }

  // 判断是否显示“上一题”按钮
  bool _shouldShowPrevious(int index) {
    return index > 0;
  }

  // 判断“下一题”按钮的文本
  String _nextButtonText(int index, int length) {
    if (index == length - 1) {
      return "提交"; // 下一题按钮展示为提交
    } else {
      return "下一题";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('答题页面'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 加载中
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // 加载错误
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found')); // 没有数据
          } else {
            List<Map<String, dynamic>> questions = snapshot.data!;
            // 初始化选中的答案和显示正确答案的状态
            if (_selectedAnswers.length < questions.length) {
              _selectedAnswers = List.filled(questions.length, null);
              _showCorrectAnswers = List.filled(questions.length, false);
            }

            Map<String, dynamic> question = questions[_currentQuestionIndex];
            int id = question['index'];
            String title = question['title'];
            List<String> options = List<String>.from(question['options']);
            int trueop = question['true'];
            int correct = 0;
            int error = 0;
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q$id: $title',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  ...options.asMap().entries.map((entry) {
                    int idx = entry.key;
                    String option = entry.value;
                    bool isCorrect = idx == trueop;
                    bool isSelected =
                        _selectedAnswers[_currentQuestionIndex] == idx;
                    bool isDisabled =
                        _selectedAnswers[_currentQuestionIndex] != null;
                    bool showCorrect =
                        _showCorrectAnswers[_currentQuestionIndex];

                    return RadioListTile<int>(
                      title: Text(option),
                      value: idx,
                      groupValue: _selectedAnswers[_currentQuestionIndex],
                      onChanged: isDisabled
                          ? null
                          : (int? value) {
                              setState(() {
                                _selectedAnswers[_currentQuestionIndex] = value;
                                if (value == trueop) {
                                  print('正确');
                                  _correctCount++;
                                } else {
                                  print('错误');
                                  _showCorrectAnswers[_currentQuestionIndex] =
                                      true;
                                  _errorCount++;
                                }
                              });
                            },
                      activeColor: isCorrect
                          ? Colors.green
                          : (isSelected ? Colors.red : null),
                      tileColor: isSelected
                          ? (isCorrect
                              ? const Color.fromARGB(255, 4, 244, 12)
                                  .withOpacity(0.1)
                              : const Color.fromARGB(255, 240, 20, 4)
                                  .withOpacity(0.1))
                          : null,
                    );
                  }),
                  if (_showCorrectAnswers[_currentQuestionIndex])
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '正确答案: ${options[trueop]}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: _shouldShowPrevious(_currentQuestionIndex),
                        child: ElevatedButton(
                          onPressed: _previousQuestion,
                          child: Text('上一题'),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: _currentQuestionIndex <
                                  questions.length - 1
                              ? _nextQuestion
                              : () => _showSubmitDialog(
                                  _correctCount, _errorCount, questions.length),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                _nextButtonColor(_currentQuestionIndex,
                                    questions.length)), //
                          ),
                          child: Text(_nextButtonText(
                              _currentQuestionIndex, questions.length))),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
