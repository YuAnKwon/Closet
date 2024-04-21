import 'package:flutter/material.dart';
import '../resource/back_handler.dart';
import 'add_lookbook/add_lookbook_screen.dart';

class LookBookPage extends StatefulWidget {
  @override
  _LookBookPageState createState() => _LookBookPageState();
}

class _LookBookPageState extends State<LookBookPage> {
  int _pageNumber = 0;

  void _onItemTapped(int index) {
    setState(() {
      _pageNumber = index;
    });

    if (_pageNumber == 1) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: WillPopScope(
      onWillPop: BackButtonHandler.onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('나만의 LookBook'),
          centerTitle: true,
        ),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 상의, 바지, 신발을 나타내는 박스
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  clothingBox(label: '상의를 선택하세요'),
                  clothingBox(label: '바지를 선택하세요'),
                  clothingBox(label: '신발을 선택하세요'),
                ],
              ),
              // 가방을 나타내는 박스
              clothingBox(
                label: '가방을 선택하세요',
              ),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddLookBook()),
            );
          },
          tooltip: '룩 추가',
          child: Icon(Icons.add),
        ),

        // ---------NavigationBAR-------------
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon:  Icon(Icons.accessibility_sharp),
              label: 'Look Book',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '옷장',
            ),
            BottomNavigationBarItem(
              icon:  Icon(Icons.add_chart_sharp),
              label: '코디 추천',
            ),
          ],

          currentIndex: _pageNumber,
          //selectedItemColor: Color(0xB39A85),
          elevation: 10,
          onTap: _onItemTapped,
        ),
      ),
    ));
  }

  Widget clothingBox({
    required String label,
    double? height,
  }) {
    return Container(
      width: 150,
      height: 150, // 기본 높이는 150
      color: Colors.grey[300], // 밝은 회색으로 변경
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
