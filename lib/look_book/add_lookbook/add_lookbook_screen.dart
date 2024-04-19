import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../api_resource/ApiResource.dart';
import '../../closet/add_clothes/category_buttons.dart';
import '../../closet/resource/Categories.dart';

class AddLookBook extends StatefulWidget {
  @override
  _AddLookBookState createState() => _AddLookBookState();
}

class _AddLookBookState extends State<AddLookBook> {
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
    return Scaffold(
        appBar: AppBar(
          title: Text('옷 선택'),
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
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
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
                      // 옷 선택되기.
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
      final response = await http.get(
        Uri.parse('${ApiResource.serverUrl}/closet/$_selectedSubCategory'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      final jsonData = jsonDecode(response.body);
      List<dynamic> imagesData = jsonData;
      List<Map<String, dynamic>> images = [];
      for (var imageData in imagesData) {
        String imageString = imageData['image'];
        int clothNum = imageData['num'];
        images.add({'image': imageString, 'num': clothNum});
      }

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
