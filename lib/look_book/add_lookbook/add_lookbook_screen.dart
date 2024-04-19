import 'dart:convert';
import 'package:closet/api_resource/ApiResource.dart';
import 'package:flutter/material.dart';
import '../../closet/add_clothes/category_buttons.dart';
import '../../resource/Categories.dart';
import '../../resource/getImages_FromServer.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

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
  Map<String, String> _selectedImages = {}; // 선택한 이미지들을 보관하는 맵
  List<Map<String, dynamic>> items = [];

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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              _selectImage(items[index]['image']);
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
          SizedBox(height: 20),
          _buildSelectedImages(),
        ],
      ),
    );
  }

  // 선택한 이미지를 보관하는 맵에 추가하는 메소드
  void _selectImage(String image) {
    setState(() {
      _selectedImages[_selectedCategory!] = image;
    });
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
      List<Map<String, dynamic>> images =
          await getImagesFromServer(_selectedSubCategory!);

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

  // 선택한 이미지들을 보여주는 위젯
  Widget _buildSelectedImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal, // 가로 스크롤 지원
          child: Row(
            children: _selectedImages.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      '${entry.key}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.memory(
                        base64.decode(entry.value),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: _saveLookbookToServer, // 저장 버튼을 누를 때 호출되는 메서드
            child: Text('룩북에 저장'),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  void _saveLookbookToServer() async {
    // 선택된 이미지 수
    int selectedCount = _selectedImages.length;

    // 선택된 이미지가 0개 또는 1개인 경우
    if (selectedCount == 0 || selectedCount == 1) {
      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('적어도 2개의 이미지를 선택해야 합니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // 중단
    }
///  _selectedImages 안에 num 부터 넣어야함. 그거 안돼서 이러는듯
    try {
      List<Map<String, dynamic>> imageDataList = [];
      // 상위 카테고리와 해당 이미지의 num만 보내기
      _selectedImages.forEach((category, image) {
        imageDataList.add({'category': category, 'num': clothNum});
      });

      String jsonData = jsonEncode({'images': imageDataList});

      var response = await http.post(
        Uri.parse('${ApiResource.serverUrl}/lookbook/add'),
        body: jsonData,
        headers: {'Content-Type': 'application/json'},
      );
      print('전송할 데이터 입니다 !!!!!!!!!!!!!!!!!!!! ${jsonData}');

      // 응답 처리
      if (response.statusCode == 200) {
        print('전송한 데이터 입니다 !!!!!!!!!!!!!!!!!!!! ${jsonData}');

        Fluttertoast.showToast(
            msg: "성공적으로 등록되었습니다.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      } else {
        // 저장 실패에 대한 처리
        throw Exception('이미지 저장에 실패하였습니다.');
      }
    } catch (error) {
      // 에러 처리
      print('Error saving images to server: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 저장에 실패하였습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}
