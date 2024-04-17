import 'package:flutter/material.dart';
import 'closet/closet_mainscreen.dart';

void main() {
  runApp(MyClosetApp());
}

class MyClosetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '내 먐 ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ClosetHomePage(),
    );
  }
}
