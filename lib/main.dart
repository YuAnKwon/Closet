import 'package:closet/weather/weather_screen.dart';
import 'package:flutter/material.dart';
import 'closet/closet_mainscreen.dart';
import 'look_book/lookbook_mainscreen.dart';
import 'package:permission_handler/permission_handler.dart';


void main() {
  runApp(MyClosetApp());
}

class MyClosetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    initializeApp();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '내 옷장',
      routes: {
        '/home': (BuildContext context) => ClosetHomePage(), // 기본 경로 (홈 화면)
        '/lookbook': (BuildContext context) => LookBookPage(), // 룩북 홈 화면
        '/weather': (BuildContext context) => WeatherPage(), // 날씨 화면
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ClosetHomePage(),
    );
  }
  Future<void> initializeApp() async {
    // 위치 권한 확인
    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      await Permission.location.request();
    }
  }
}
