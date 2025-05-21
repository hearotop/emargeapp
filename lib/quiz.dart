import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'answer.dart';

class TestPage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _loadData() async {
    String jsonString = await rootBundle.loadString('lib/json/know.json');

    List<dynamic> data = json.decode(jsonString);
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          } else {
            List<Map<String, dynamic>> chapters = snapshot.data!;
            return ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> chapter = chapters[index];
                int id = chapter['id'];
                String text = chapter['text'];
                String path = chapter['path'];
                Color backgroundColor = _getBackgroundColor(id);

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        id.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  title: Text(text),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnswerPage(path: path),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Color _getBackgroundColor(int id) {
    switch (id % 5) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
