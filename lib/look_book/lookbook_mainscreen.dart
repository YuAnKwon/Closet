import 'dart:convert';

import 'package:closet/api_resource/ApiResource.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../resource/back_handler.dart';
import 'add_lookbook/add_lookbook_screen.dart';

class LookBookPage extends StatefulWidget {
  @override
  _LookBookPageState createState() => _LookBookPageState();
}

class _LookBookPageState extends State<LookBookPage> {
  int _pageNumber = 0;

  Map<String, String> lookbookData = {
    'top': '',
    'bottom': '',
    'shoes': '',
    'bag': '',
    'name': '',
  };

  void _fetchLookbookData() async {
    final response =
        await http.get(Uri.parse('${ApiResource.serverUrl}/lookbook/show'));

    if (response.statusCode == 200) {
      // 서버에서 받은 데이터 lookbookdata
      final responseData = json.decode(response.body);
      setState(() {
        lookbookData = {
          '상의': responseData['topImageUrl'],
          '하의': responseData['bottomImageUrl'],
          '신발': responseData['shoesImageUrl'],
          '가방': responseData['bagImageUrl'],
          'lookname': responseData['lookname'],
        };
      });
    } else {
      // 에러 처리
      throw Exception('Failed to load outfit data');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLookbookData();
  }

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // 세로 방향 가운데 정렬
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 상의, 바지, 신발을 나타내는 박스
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        clothingBox(label: '상의', imageUrl: lookbookData['상의']),
                        clothingBox(label: '바지', imageUrl: lookbookData['하의']),
                        clothingBox(label: '신발', imageUrl: lookbookData['신발']),
                      ],
                    ),
                    clothingBox(label: '가방', imageUrl: lookbookData['가방']),
                  ],
                ),
                Text('${lookbookData['lookname']}'),
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
                icon: Icon(Icons.accessibility_sharp),
                label: 'Look Book',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '옷장',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_chart_sharp),
                label: '코디 추천',
              ),
            ],

            currentIndex: _pageNumber,
            //selectedItemColor: Color(0xB39A85),
            elevation: 10,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }


  Widget clothingBox({
    required String label,
    String? imageUrl,
  }) {
    return Container(
      width: 150,
      height: 150,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          imageUrl != null
              ? Image.network(
                  imageUrl,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                )
              : SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(),
                ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
