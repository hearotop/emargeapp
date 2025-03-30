import 'package:flutter/material.dart';
import 'package:namer_app/compment/total.dart';

class ResultPage extends StatelessWidget {
  final int correct;
  final int error;
  ResultPage({required this.correct, required this.error});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('成绩'),
        ),
        body: SizedBox(
          height: 300,
          child: PieChartSample2(correct: correct, error: error),
        ));
  }
}
