import 'dart:convert';
import 'package:closet/api_resource/ApiResource.dart';
import 'package:flutter/material.dart';
import '../../closet/resource/main_catgory_buttons.dart';
import '../../res/Categories.dart';
import '../../res/getImages_FromServer.dart';
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
  Map<String, dynamic> _selectedImages = {}; // 선택한 이미지들을 보관하는 맵
  List<Map<String, dynamic>> items = [];

  DateTime? currentBackPressTime;

  //---옷장 조회
  @override
  void initState() {
    super.initState();
    // Select the default category when the screen loads
    _saveSelectedCategory(_selectedCategory!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('옷 선택'),
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
                              _selectImage(items[index]);
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

  // 선택한 카테고리 저장
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

  // 선택한 이미지를 보관하는 맵에 추가
  void _selectImage(Map<String, dynamic> imageData) {
    setState(() {
      _selectedImages[_selectedCategory!] = {
        'category': _selectedCategory!,
        'image': imageData['image'],
        'num': imageData['num']
      };
    });
  }

  // 선택한 이미지 ui
  Widget _buildSelectedImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal, // 가로 스크롤 지원
          child: Row(
            children: _selectedImages.entries.map((entry) {
              String image = entry.value['image'];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      '${entry.value['category']}',
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
                        base64.decode(image),
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
            onPressed: writeLookName,
            child: Text('선택 완료'),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

// 룩 이름 저장
  void writeLookName() {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('이름'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(hintText: '룩 이름을 적어주세요'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 사용자가 입력한 룩 이름 가져오기
                String lookName = nameController.text;
                _saveLookbookToServer(lookName);
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

//-------서버로 전송하기---------
  void _saveLookbookToServer(String lookName) async {
    // 선택된 이미지 수
    int selectedCount = _selectedImages.length;

    // 선택된 이미지가 0개 또는 1개인 경우
    if (selectedCount == 0 || selectedCount == 1) {
      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('옷을 2개 이상 선택해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // 중단
    }

    try {
      List<Map<String, dynamic>> imageDataList = [];

      // 아이템 목록 생성
      _selectedImages.forEach((category, image) {
        int clothNum = _selectedImages[category]!['num'];
        imageDataList.add({ category: clothNum});
      });

      // 룩의 이름 추가
      imageDataList.add({"lookname": lookName});

      String jsonData = jsonEncode({"items": imageDataList});

      var response = await http.post(
        Uri.parse('${ApiResource.serverUrl}/lookbook/add'),
        body: jsonData,
        headers: {'Content-Type': 'application/json'},
      );

      // 응답 처리
      if (response.statusCode == 200) {
        print('전송한 데이터입니다: $jsonData');

        Fluttertoast.showToast(
            msg: "성공적으로 등록되었습니다.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);

        Navigator.pushNamedAndRemoveUntil(context, '/lookbook', (route) => false);
      } else {
        print('전송한 데이터입니다: $jsonData');

        // 저장 실패에 대한 처리
        throw Exception('룩 저장에 실패하였습니다. Status Code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (error) {
      // 에러 처리
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('룩 저장에 실패하였습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


}
