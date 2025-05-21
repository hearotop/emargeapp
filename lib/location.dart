import 'package:flutter/material.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const TextField(
          decoration: InputDecoration(
            hintText: '搜索',
            border: InputBorder.none,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/image/map.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
