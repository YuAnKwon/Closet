import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../api_resource/ApiResource.dart';
import '../../closet/resource/Categories.dart';
import 'add_lookbook_screen.dart';

class SelectImage extends StatefulWidget {
  final String category;

  const SelectImage({Key? key, required this.category}) : super(key: key);

  @override
  State<SelectImage> createState() => _SelectImageState();
}


class _SelectImageState extends State<SelectImage> {
  bool _isLoading = false; // 로딩 상태 변수
  List<Map<String, dynamic>> items = [];
  late String _selectedSubCategory;

  late String _selectedCategory;
  late List<String> _subCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
    _subCategories = Categories.subCategories[_selectedCategory] ?? [];

    // 하위 카테고리 중 맨 앞에 있는 것을 선택
    if (_subCategories.isNotEmpty) {
      _selectedSubCategory = _subCategories.first;
      _getImagesFromServer(_selectedSubCategory);
    }
  }

  void _getImagesFromServer(String subCategory) async {
    setState(() {
      items.clear();
      _isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('${ApiResource.serverUrl}/closet/${subCategory}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} 선택'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            _buildButtonList(
                _subCategories, _selectedSubCategory, _onSubCategorySelected),
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
                                // 이미지와 번호를 AddLookBook으로 전달
                                _onImageSelected(
                                    items[index]['image'], items[index]['num']);
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
      ),
    );
  }

  // 이미지 선택 시 실행되는 함수
  void _onImageSelected(String image, int num) {
    // 선택된 이미지 정보를 AddLookBook으로 전달
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLookBook(
          image: image,
          num: num,
        ),
      ),
    );
  }

  Widget _buildButtonList(
      List<String> itemList, String? selectedItem, Function(String) onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: itemList
          .map((item) => ElevatedButton(
                onPressed: () {
                  _getImagesFromServer(item);
                  setState(() {
                    _selectedSubCategory = item; // 선택된 카테고리 업데이트
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedItem == item ? Color(0xDAD9FF) : null,
                ),
                child: Text(item),
              ))
          .toList(),
    );
  }

  void _onSubCategorySelected(String subCategory) {
    _getImagesFromServer(subCategory);
    setState(() {
      _selectedSubCategory = subCategory;
    });
  }
}

