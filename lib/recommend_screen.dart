import 'package:flutter/material.dart';

class RecommendPage extends StatefulWidget {
  @override
  _RecommendPageState createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  int _pageNumber = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('코디 추천'),
        centerTitle: true,
        elevation: 1.0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/weather');
            },
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: Image.asset(
                  'assets/img/weather.png',
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/uploadBody');
            },
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: Image.asset(
                  'assets/img/body_type.png',
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/bottom_icon/lookbook.png"),
              size: 24,
            ),
            label: 'Look Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '옷장',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/bottom_icon/recommend.png"),
              size: 24,
            ),
            label: '코디 추천',
          ),
        ],
        currentIndex: _pageNumber,
        selectedItemColor: Color(0xFFC7B3A3),
        elevation: 10,
        onTap: (index) {
          setState(() {
            _pageNumber = index;
          });
          if (_pageNumber == 0) {
            Navigator.pushReplacementNamed(context, '/lookbook');
          }
          if (_pageNumber == 1) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
      ),
    );
  }
}
