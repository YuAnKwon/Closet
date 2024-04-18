import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../api_resource/ApiResource.dart';
import 'Categories.dart';
import 'add_clothes/pic_toServer_screen.dart';
import 'closet_info_screen.dart';
import 'main_catgory_buttons.dart';

class ClosetHomePage extends StatefulWidget {
  @override
  _ClosetHomePageState createState() => _ClosetHomePageState();
}

class _ClosetHomePageState extends State<ClosetHomePage> {
  final List<String> categories = Categories.categories;
  final Map<String, List<String>> subCategories = Categories.subCategories;

  String? _selectedCategory = '상의'; // Initialize selected category here
  String? _selectedSubCategory;

  List<Map<String, dynamic>> items = [];

  int _pageNumber = 1;

  void _onItemTapped(int index) {
    setState(() {
      _pageNumber = index;
    });
  }

  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    // Select the default category when the screen loads
    _saveSelectedCategory(_selectedCategory!);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('내 옷장'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategorySubCategoryWidgets(
              categories: categories,
              subCategories: subCategories,
              onCategorySelected: _saveSelectedCategory,
              onSubCategorySelected: (subCategory) {
                setState(() {
                  _selectedSubCategory = subCategory;
                });
                _getImagesFromServer();
              },
              selectedCategory: _selectedCategory,
              selectedSubCategory: _selectedSubCategory,
            ),
            SizedBox(height: 20),
            Expanded(
              child:GridView.builder(
                padding: EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  if (items.isEmpty) {
                    return Center(child: Text('이미지가 없습니다.'));
                  } else {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClothDetailPage(
                              image: items[index]['image']!,
                              clothNum: items[index]['num'],
                            ),
                          ),
                        );
                      },
                      child: GridTile(
                        child: Image.memory(
                          base64.decode(items[index]['image']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                },
              ),




            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraCapture()),
            );
          },
          tooltip: '옷 추가',
          child: Icon(Icons.add),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Look Book',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '옷장',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: '코디 추천',
            ),
          ],
          currentIndex: _pageNumber,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  // 선택한 카테고리를 저장하는 메소드
  void _saveSelectedCategory(String category) {
    setState(() {
      _selectedCategory = category;
      // 선택한 상위 카테고리에 해당하는 하위 카테고리 초기화
      _selectedSubCategory = null;

      // 자동으로 첫 번째 하위 카테고리 선택
      if (subCategories.containsKey(category) &&
          subCategories[category]!.isNotEmpty) {
        _selectedSubCategory = subCategories[category]![0];
        // 선택한 첫 번째 하위 카테고리를 부모 위젯으로 전달
        setState(() {
          _selectedSubCategory = subCategories[category]![0];
        });
        _getImagesFromServer();
      }
    });
  }

  void _getImagesFromServer() async {
    setState(() {
      items.clear();
    });
    try {
      final response = await http.get(
          Uri.parse('${ApiResource.serverUrl}/closet/$_selectedSubCategory'),
          headers: {'ngrok-skip-browser-warning': 'true'}
      );
      final jsonData = jsonDecode(response.body);
      List<dynamic> imagesData = jsonData;
      List<Map<String, dynamic>> images = []; // images 리스트의 타입 변경
      for (var imageData in imagesData) {
        String imageString = imageData['image'];
        int clothNum = imageData['num'];
        images.add({'image': imageString, 'num': clothNum}); // 'num'을 items에 추가
      }

      setState(() {
        items = images;
      });
    } catch (error) {
      print('Error fetching images from server: $error');
    }
  }




  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      final msg = "앱을 종료하려면 한 번 더 누르세요";

      Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[700],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return Future.value(false);
    }

    return Future.value(true);
  }
}
