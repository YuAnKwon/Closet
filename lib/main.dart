import 'package:closet/closet/add_clothes/pic_toServer_screen.dart';
import 'package:flutter/material.dart';
import 'closet/closet_mainscreen.dart';

void main() {
  runApp(MyClosetApp());
}

class MyClosetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '내 옷장',
      routes: {
        '/home': (BuildContext context) => ClosetHomePage(), // 기본 경로 (홈 화면)
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ClosetHomePage(),
    );
  }
}
