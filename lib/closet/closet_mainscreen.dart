import 'dart:convert';

import 'package:flutter/material.dart';

import '../res/back_handler.dart';
import '../res/Categories.dart';
import '../res/getImages_FromServer.dart';
import 'add_clothes/pic_toServer_screen.dart';
import 'edit_delete_cloth/info_edit_screen.dart';
import 'res/main_catgory_buttons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class ClosetHomePage extends StatefulWidget {
  @override
  _ClosetHomePageState createState() => _ClosetHomePageState();
}

class _ClosetHomePageState extends State<ClosetHomePage> {
  final List<String> categories = Categories.categories;
  final Map<String, List<String>> subCategories = Categories.subCategories;
  bool _isLoading = false; // 로딩 상태 변수 추가
  String? _selectedCategory = '상의';
  String? _selectedSubCategory;

  List<Map<String, dynamic>> items = [];

  int _pageNumber = 1;

  void _onItemTapped(int index) {
    setState(() {
      _pageNumber = index;
    });

    if (_pageNumber == 0) {
      Navigator.pushReplacementNamed(context, '/lookbook'); // 룩북 페이지로 이동
    }
    if (_pageNumber == 2) {
      Navigator.pushReplacementNamed(context, '/recommend');
    }
  }

  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    _saveSelectedCategory(_selectedCategory!);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: BackButtonHandler.onWillPop,
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
              child: // 로딩 표시
              _isLoading
                  ? Center(
                child: LoadingAnimationWidget.waveDots(
                  color: Color(0xFFC7B3A3),
                  size: 60.0,
                ),
              )
                  : items.isEmpty
                      ? Center(
                          child: Text(
                            '해당 카테고리에 등록된 옷이 없습니다.',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(8.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: items.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClothDetailPage(
                                      image: items[index]['image']!,
                                      clothNum: items[index]['num'],
                                      category: _selectedCategory,
                                      subcategory: _selectedSubCategory,
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
          child: Icon(Icons.add, color: Colors.white), // 아이콘 색상 흰색으로 설정
          backgroundColor:Color(0xFFC7B3A3),
          shape: CircleBorder(),

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
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> images = await getImagesFromServer(_selectedSubCategory!);

      setState(() {
        items = images;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching images from server: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }
}
