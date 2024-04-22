import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_resource/ApiResource.dart';
import 'add_lookbook/add_lookbook_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
          child: Icon(Icons.add),
          shape: CircleBorder(),
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

  Widget _buildLookBookItem(Map<String, dynamic> lookBook) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '룩 이름: ${lookBook['lookname']}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        _buildClothingItem('상의', lookBook['상의']),
        _buildClothingItem('하의', lookBook['하의']),
        _buildClothingItem('신발', lookBook['신발']),
        _buildClothingItem('가방', lookBook['가방']),
        SizedBox(height: 20),
        Divider(),
      ],
    );
  }

  Widget _buildClothingItem(String label, dynamic clothingId) {
    return FutureBuilder(
      future: _fetchClothingImage(clothingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('이미지 불러오기 실패');
        } else {
          return Column(
            children: [
              Text(label),
              SizedBox(height: 5),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: snapshot.data != null
                    ? Image.network(
                  snapshot.data.toString(),
                  fit: BoxFit.cover,
                )
                    : Icon(Icons.image),
              ),
            ],
          );
        }
      },
    );
  }

  Future<String?> _fetchClothingImage(dynamic clothingId) async {
    if (clothingId == null) return null; // clothingId가 null이면 이미지를 불러올 필요가 없음
    try {
      final response = await http.get(
        Uri.parse('${ApiResource.serverUrl}/clothing/show/get_image/$clothingId'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['imageUrl'];
      } else {
        throw Exception('이미지 불러오기 실패 - HTTP 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('이미지 불러오기 에러: $e');
      throw Exception('이미지 불러오기 실패: $e');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: LookBookPage(),
  ));
}
