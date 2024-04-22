import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_resource/ApiResource.dart';
import 'add_lookbook_screen.dart';

class LookBookPage extends StatefulWidget {
  @override
  _LookBookPageState createState() => _LookBookPageState();
}

class _LookBookPageState extends State<LookBookPage> {
  int _pageNumber = 0;
  List<Map<String, dynamic>> lookBooks = []; // 룩북 데이터를 담을 리스트

  @override
  void initState() {
    super.initState();
    _fetchLookbookData();
  }

  // 룩북 num 리스트 받기
  void _fetchLookbookData() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiResource.serverUrl}/lookbook/show'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body)['lookbooks'];
        setState(() {
          lookBooks = responseData.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('룩북 불러오기 실패 - HTTP 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('룩북 에러: $e');
      throw Exception('룩북 불러오기 실패: $e');
    }
  }

// 이미지 받기
  Map<dynamic, Uint8List> _imageCache = {};

  Future<Uint8List?> _fetchClothingImage(dynamic clothingId) async {
    if (clothingId == null) return null; // clothingId가 null이면 이미지를 불러올 필요가 없음

    if (_imageCache.containsKey(clothingId)) {
      // 이미지가 캐시되어 있다면 캐시된 이미지 반환
      return _imageCache[clothingId];
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiResource.serverUrl}/lookbook/show/get_image/$clothingId'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );

      if (response.statusCode == 200) {
        final imageData = response.bodyBytes;
        _imageCache[clothingId] = imageData; // 이미지를 캐시에 저장
        return imageData;
      } else {
        throw Exception('이미지 불러오기 실패 - HTTP 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('이미지 불러오기 에러: $e');
      throw Exception('이미지 불러오기 실패: $e');
    }
  }

  Widget _buildLookBookItem(Map<String, dynamic> lookBook) {
    return Card(
      elevation: 4, // 카드의 그림자 설정
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // 카드의 여백 설정
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text(
              '${lookBook['lookname']}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        if (lookBook['상의'] != null)
                          _buildClothingItem('상의', lookBook['상의']),
                        if (lookBook['하의'] != null)
                          _buildClothingItem('하의', lookBook['하의']),
                        if (lookBook['신발'] != null)
                          _buildClothingItem('신발', lookBook['신발']),
                      ],
                    ),
                    if (lookBook['가방'] != null)
                      _buildClothingItem('가방', lookBook['가방']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      color: Colors.grey[100], // 카드의 배경색 설정
    );
  }

  // 이미지 출력
  Widget _buildClothingItem(String label, dynamic clothingId) {
    return FutureBuilder<Uint8List?>(
      future: _fetchClothingImage(clothingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('이미지 불러오기 실패');
        } else {

          return Center(
            child: Column(
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: snapshot.data != null
                      ? Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  )
                      : Container(),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('나만의 LookBook'),
          centerTitle: true,
        ),
        body: ListView.builder(
          itemCount: lookBooks.length,
          itemBuilder: (context, index) {
            return _buildLookBookItem(lookBooks[index]);
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddLookBook()),
            );
          },
          tooltip: '룩 추가',
          child: Icon(Icons.add, color : Colors.white),
          shape: CircleBorder(),
          backgroundColor:Color(0xFFC7B3A3),
        ),
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
          selectedItemColor: Color(0xFFC7B3A3),
          elevation: 10,
          onTap: (index) {
            setState(() {
              _pageNumber = index;
            });
            if (_pageNumber == 1) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
      ),
    );
  }

}
