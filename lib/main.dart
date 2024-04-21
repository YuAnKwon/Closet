import 'package:flutter/material.dart';
import 'closet/closet_mainscreen.dart';
import 'look_book/lookbook_mainscreen.dart';
import 'look_book/test.dart';

void main() {
  runApp(MyClosetApp());
}

class MyClosetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '내 옷장',
      routes: {
        '/home': (BuildContext context) => ClosetHomePage(), // 기본 경로 (홈 화면)
        '/lookbook': (BuildContext context) => LookBookPag(), // 룩북 홈 화면
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ClosetHomePage(),
    );
  }
}
